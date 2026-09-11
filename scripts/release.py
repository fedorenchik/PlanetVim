#!/usr/bin/env python3
"""Build deterministic, unpublished PlanetVim archives from a clean Git commit.

One pinned upstream website submodule is intentionally omitted and
listed in the manifest. All other submodules, including changed exclusion pins,
must be reviewed and vendored before packaging. Runtime help and license files
are ordinary tracked files and remain in both archives.
"""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import sys
import tarfile
import tempfile
import time
import zipfile

ROOT = Path(__file__).resolve().parents[1]

# Verified against each vendored plugin's .gitmodules and test harness. These
# are exact path/commit exceptions, never a general tests/ or docs/ exclusion.
OPTIONAL_SUBMODULES = {
    '.vim/pack/web/start/emmet-vim/docs': {
        'commit': 'ff5a094cc821051de0eea9b51fd8c90356d2c712',
        'reason': 'Upstream gh-pages website; runtime help is the separately vendored doc/emmet.txt.',
    },
}


class ReleaseError(RuntimeError):
    pass


def git(source, *arguments, input=None):
    result = subprocess.run(['git', '-c', 'core.fsmonitor=false', '-C', str(source), *arguments],
                            input=input, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode:
        raise ReleaseError(result.stderr.decode(errors='replace').strip() or 'Git command failed')
    return result.stdout


def clean_commit(source):
    if git(source, 'status', '--porcelain=v1', '--untracked-files=normal').strip():
        raise ReleaseError('Source checkout is dirty. Commit or remove changes before building a release.')
    return git(source, 'rev-parse', '--verify', 'HEAD').decode().strip()


def included(name):
    path = PurePosixPath(name)
    if path.is_absolute() or '..' in path.parts or '\\' in name:
        raise ReleaseError('Unsafe archive path: ' + name)
    if any(part in ('.git', '__pycache__') for part in path.parts):
        return False
    if path.suffix in ('.pyc', '.pyo') or path.parts[0] in ('build', 'dist'):
        return False
    if len(path.parts) > 1 and path.parts[0] == '.vim' and path.parts[1] in (
            'session', 'undo', 'view', 'viminfo', 'tab', 'bookmarks', 'command-history'):
        return False
    if len(path.parts) == 2 and path.parts[0] == '.vim' and path.parts[1] in (
            'planetvimrc.vim', 'fern-bookmark.json', 'clap_yanks.history'):
        return False
    return True


def snapshot(source, commit):
    tracked = []
    excluded_submodules = []
    for record in git(source, 'ls-tree', '-r', '-z', commit).split(b'\0'):
        if not record:
            continue
        metadata, path = record.split(b'\t', 1)
        name = path.decode('utf-8')
        mode, kind, object_id = metadata.split()
        if mode == b'160000':
            pin = object_id.decode('ascii')
            optional = OPTIONAL_SUBMODULES.get(name)
            # Check before generic generated-state exclusions: an unknown
            # gitlink must not silently disappear even under build/ or dist/.
            if optional is None:
                raise ReleaseError('Submodule contents are not vendored into the release: ' + name)
            if pin != optional['commit']:
                raise ReleaseError('Optional submodule pin changed; review the release exclusion: ' + name)
            excluded_submodules.append(dict(path=name, commit=pin, reason=optional['reason']))
        elif included(name):
            if mode == b'120000':
                raise ReleaseError('Distribution symlinks are unsupported by the safe installer: ' + name)
            if kind != b'blob' or mode not in (b'100644', b'100755'):
                raise ReleaseError('Unsupported Git source entry: ' + name)
            tracked.append((name, object_id, 0o755 if mode == b'100755' else 0o644))
    # Read committed blobs directly. Unlike git archive, this does not honor
    # upstream export-ignore/export-subst rules that can omit or rewrite notices.
    # Checkout line endings, ignored files and filesystem modes have no effect.
    raw = git(source, 'cat-file', '--batch', input=b''.join(oid + b'\n' for _, oid, _ in tracked))
    stream = io.BytesIO(raw)
    result = []
    for name, object_id, mode in tracked:
        header = stream.readline().split()
        if len(header) != 3 or header[:2] != [object_id, b'blob']:
            raise ReleaseError('Cannot read committed Git blob: ' + name)
        size = int(header[2])
        contents = stream.read(size)
        if len(contents) != size or stream.read(1) != b'\n':
            raise ReleaseError('Incomplete committed Git blob: ' + name)
        result.append((name, contents, mode))
    if stream.read(1):
        raise ReleaseError('Unexpected data after committed Git blobs.')
    return sorted(result), sorted(excluded_submodules, key=lambda item: item['path'])


def write_tar(path, prefix, entries, epoch):
    with path.open('wb') as output, gzip.GzipFile(filename='', mode='wb', fileobj=output,
                                               compresslevel=9, mtime=0) as compressed:
        with tarfile.open(fileobj=compressed, mode='w', format=tarfile.PAX_FORMAT) as archive:
            for name, contents, mode in entries:
                info = tarfile.TarInfo(prefix + '/' + name)
                info.size, info.mode, info.mtime = len(contents), mode, epoch
                info.uid = info.gid = 0
                info.uname = info.gname = ''
                archive.addfile(info, io.BytesIO(contents))


def write_zip(path, prefix, entries, epoch):
    stamp = time.gmtime(max(epoch, 315532800))[:6]
    with zipfile.ZipFile(path, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name, contents, mode in entries:
            info = zipfile.ZipInfo(prefix + '/' + name, stamp)
            info.create_system = 3
            info.external_attr = (stat.S_IFREG | mode) << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, contents, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build(source=ROOT, output=None):
    source = Path(source).resolve()
    commit = clean_commit(source)
    epoch = int(git(source, 'show', '-s', '--format=%ct', commit).decode().strip())
    entries, excluded_submodules = snapshot(source, commit)
    files = {name: contents for name, contents, _ in entries}
    try:
        version = files['VERSION'].decode('ascii').strip()
    except (KeyError, UnicodeError) as error:
        raise ReleaseError('The committed VERSION file must contain an ASCII version.') from error
    if not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?', version):
        raise ReleaseError('VERSION must be a semantic version without paths or whitespace.')
    for name in ('.vimrc', 'scripts/planetvim.vim', 'scripts/install.py', 'LICENSE'):
        if name not in files:
            raise ReleaseError('Release source is missing ' + name)
    if not any(name.startswith('.vim/') for name in files):
        raise ReleaseError('Release source is missing the distribution runtime.')
    prefix = 'PlanetVim-' + version
    output = Path(output or source / 'dist').resolve()
    output.mkdir(parents=True, exist_ok=True)
    filenames = [prefix + '.tar.gz', prefix + '.zip', prefix + '.manifest.json']
    for name in filenames:
        if (output / name).exists() or (output / name).is_symlink():
            raise ReleaseError('Refusing to overwrite existing artifact: ' + str(output / name))
    with tempfile.TemporaryDirectory(prefix='planetvim-release-') as temporary:
        staging = Path(temporary)
        write_tar(staging / filenames[0], prefix, entries, epoch)
        write_zip(staging / filenames[1], prefix, entries, epoch)
        manifest = dict(schema=1, version=version, source_commit=commit, source_date_epoch=epoch,
                        archive_root=prefix, file_count=len(entries), excluded_submodules=excluded_submodules,
                        artifacts=[dict(filename=name, sha256=digest(staging / name),
                                        bytes=(staging / name).stat().st_size) for name in filenames[:2]])
        (staging / filenames[2]).write_text(json.dumps(manifest, indent=2, sort_keys=True) + '\n', encoding='utf-8', newline='\n')
        if clean_commit(source) != commit:
            raise ReleaseError('Source commit changed while building the release; retry from a stable checkout.')
        published = []
        try:
            for name in filenames:
                target = output / name
                # Exclusive creation protects existing output even if another
                # process created it between preflight and the final copy.
                with target.open('xb') as destination:
                    published.append(target)
                    with (staging / name).open('rb') as incoming:
                        shutil.copyfileobj(incoming, destination)
        except BaseException:
            for target in published:
                target.unlink(missing_ok=True)
            raise
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT, help='Clean committed Git checkout')
    parser.add_argument('--output', type=Path, help='Artifact directory (default: SOURCE/dist)')
    args = parser.parse_args()
    try:
        manifest = build(args.source, args.output)
        print(json.dumps(manifest, indent=2))
        print('Archives built locally. No tag, upload, or publication was performed.')
        return 0
    except (ReleaseError, OSError, ValueError) as error:
        print('PlanetVim release: ' + str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())

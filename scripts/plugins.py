#!/usr/bin/env python3
"""Inventory bundled plugins and check upstream branch tips without changing code."""
import argparse
import configparser
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / 'docs/plugins.json'
IGNORED_DIRECTORIES = {'.git', '__pycache__'}
LICENSE_NAME = re.compile(r'^(licen[sc]e|copying|copyright|notice)([._-].*)?$', re.I)
VIM_LICENSE_HEADER = re.compile(
    r'^\s*"\s*(?:licen[sc]e\b|copyright\s+(?:\(c\)|©)|permission is hereby granted)',
    re.I | re.M)
FIRST_PARTY_PACKAGES = {
    '.vim/pack/planet/start/guitablabel.vim',
    '.vim/pack/planet/start/guitabtooltip.vim',
    '.vim/pack/planet/start/planet.vim',
    '.vim/pack/planet/start/title.vim',
}


def package_files(package):
    return sorted(path for path in package.rglob('*') if path.is_file()
                  and not any(part in IGNORED_DIRECTORIES for part in path.relative_to(package).parts)
                  and path.suffix not in ('.pyc', '.pyo'))


def license_evidence(package, first_party=False):
    files = []
    for path in sorted(package.iterdir()):
        if path.is_file() and LICENSE_NAME.match(path.name):
            files.append(path.relative_to(ROOT).as_posix())
    if files:
        return {'status': 'notice_files_found', 'paths': files}
    if first_party and (ROOT / 'LICENSE').is_file():
        return {'status': 'project_license', 'paths': ['LICENSE']}
    # Some upstreams keep their notice beside Vim help instead of at the root.
    # Test-fixture/dependency notices do not describe the plugin itself.
    for path in sorted((package / 'doc').glob('*')):
        if path.is_file() and LICENSE_NAME.match(path.name):
            files.append(path.relative_to(ROOT).as_posix())
    if files:
        return {'status': 'notice_files_found', 'paths': files}
    # A README/help mention is a pointer for human review, not an inferred license.
    candidates = list(package.glob('README*')) + list(package.glob('readme*')) + list(package.glob('doc/*.txt'))
    for path in sorted(candidates):
        if path.is_file() and re.search(r'\blicen[sc]e\b|\bcopyright\b', path.read_text(errors='replace'), re.I):
            files.append(path.relative_to(ROOT).as_posix())
    if files:
        return {'status': 'documentation_mentions', 'paths': files}
    # Header evidence can cover only one source file, not the whole package.
    # Restrict matching to comments so syntax keywords such as "license" do not
    # masquerade as notices. This is still an evidence pointer, not a conclusion.
    for path in package_files(package):
        if path.suffix == '.vim':
            with path.open(encoding='utf-8', errors='replace') as source:
                header = ''.join(next(source, '') for _ in range(80))
            if VIM_LICENSE_HEADER.search(header):
                files.append(path.relative_to(ROOT).as_posix())
    return {'status': 'source_header_mentions' if files else 'not_found', 'paths': files}


def tree_hash(package, files):
    digest = hashlib.sha256()
    for path in files:
        digest.update(path.relative_to(package).as_posix().encode('utf-8') + b'\0')
        digest.update(path.read_bytes())
        digest.update(b'\0')
    return digest.hexdigest()


def inventory():
    plugins = []
    for path in sorted((ROOT / '.vim/pack').glob('*/*/*')):
        if not path.is_dir() or path.parent.name not in ('start', 'opt'):
            continue
        metadata = path / '.gitrepo'
        provenance = {'kind': 'local', 'remote': None, 'branch': None, 'commit': None}
        files = package_files(path)
        if metadata.is_file():
            config = configparser.ConfigParser(interpolation=None)
            config.read(metadata, encoding='utf-8')
            section = config['subrepo']
            provenance = {'kind': 'git-subrepo', 'remote': section.get('remote'),
                          'branch': section.get('branch'), 'commit': section.get('commit')}
            if not re.fullmatch(r'[0-9a-f]{40}', provenance['commit'] or ''):
                raise ValueError('Missing/invalid upstream commit in ' + str(metadata))
        relative_path = path.relative_to(ROOT).as_posix()
        first_party = provenance['kind'] == 'local' and relative_path in FIRST_PARTY_PACKAGES
        plugin = {'name': path.name, 'group': path.parent.parent.name,
                  'load': path.parent.name, 'path': path.relative_to(ROOT).as_posix(),
                  'provenance': provenance,
                  'license_evidence': license_evidence(path, first_party=first_party)}
        if provenance['kind'] == 'git-subrepo':
            plugin['snapshot_sha256'] = tree_hash(path, files)
            plugin['local_patches'] = 'not_compared_with_upstream'
        else:
            plugin['local_patches'] = 'part_of_distribution_checkout'
        plugins.append(plugin)
    return {'schema': 1, 'description': 'Bundled package inventory; license pointers are evidence, not legal classifications.',
            'plugins': plugins}


def update_check(packages, names, all_packages=False):
    selected = []
    for name in names:
        matches = [package for package in packages if package['name'] == name or package['path'] == name]
        if len(matches) != 1:
            raise ValueError('Select one exact package name or path: ' + name)
        selected.extend(matches)
    if all_packages:
        selected = [package for package in packages if package['provenance']['kind'] == 'git-subrepo']
    if not selected:
        raise ValueError('Select at least one package, or explicitly pass --all.')
    failed = False
    for package in selected:
        provenance = package['provenance']
        record = {'name': package['name'], 'recorded_commit': provenance['commit']}
        if provenance['kind'] != 'git-subrepo':
            record['status'] = 'local_package'
        else:
            url = urlparse(provenance['remote'])
            if url.scheme != 'https' or url.hostname != 'github.com' or url.username or url.password:
                raise ValueError('Only credential-free HTTPS GitHub remotes are supported by update-check.')
            try:
                result = subprocess.run(['git', 'ls-remote', '--exit-code', provenance['remote'],
                                         'refs/heads/' + provenance['branch']],
                                        text=True, capture_output=True, timeout=30, check=False)
                lines = result.stdout.splitlines()
                if result.returncode or len(lines) != 1:
                    record.update(status='error', message=result.stderr.strip() or 'Branch was not found.')
                    failed = True
                else:
                    commit = lines[0].split()[0]
                    record.update(branch_tip=commit, status='same' if commit == provenance['commit'] else 'different')
            except (OSError, subprocess.TimeoutExpired) as error:
                record.update(status='error', message=str(error))
                failed = True
        print(json.dumps(record, sort_keys=True), flush=True)
    return 1 if failed else 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    listing = commands.add_parser('inventory', help='offline inventory and snapshot fingerprints')
    output = listing.add_mutually_exclusive_group()
    output.add_argument('--write', type=Path, nargs='?', const=DEFAULT_MANIFEST)
    output.add_argument('--check', type=Path, nargs='?', const=DEFAULT_MANIFEST)
    check = commands.add_parser('update-check', help='read selected upstream refs; never fetch/merge/update files')
    check.add_argument('packages', nargs='*')
    check.add_argument('--all', action='store_true', help='explicitly query every upstream package')
    args = parser.parse_args(argv)
    try:
        result = inventory()
        if args.command == 'update-check':
            return update_check(result['plugins'], args.packages, args.all)
        if args.check:
            saved = json.loads(args.check.read_text(encoding='utf-8'))
            if saved != result:
                previous = {p['path']: p for p in saved.get('plugins', [])}
                current = {p['path']: p for p in result['plugins']}
                changed = sorted(path for path in set(previous) | set(current) if previous.get(path) != current.get(path))
                print('Plugin inventory differs: ' + ', '.join(changed), file=sys.stderr)
                print('Review the differences, then run python scripts/plugins.py inventory --write.', file=sys.stderr)
                return 1
            print(str(len(result['plugins'])) + ' package records match the current checkout.')
        elif args.write:
            args.write.parent.mkdir(parents=True, exist_ok=True)
            args.write.write_text(json.dumps(result, indent=2, ensure_ascii=False, sort_keys=True) + '\n', encoding='utf-8')
            print('Wrote ' + str(args.write))
        else:
            print(json.dumps(result, indent=2, ensure_ascii=False, sort_keys=True))
        return 0
    except (OSError, ValueError, KeyError, configparser.Error) as error:
        print('PlanetVim plugin inventory: ' + str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())

# Contributing to Vimspector

Contributions to Vimspector are always welcome. Contributions can take many
forms, such as:

* Raising, responding to, or reacting to Issues or Pull Requests
* Testing new in-progress changes and providing feedback
* Discussing in the Gitter channel
* etc.

At all times the [code of conduct](#code-of-conduct) applies.

## Troubleshooting

It's not completely trivial to configure Vimspector and there is a fairly large
amount of documentation. I know full well that documentation isn't everything,
so the first step in troubleshooting is to try a sample project that's known to
work, to check if the problem is your project configuration rather than an
actual bug.

Therefore before raising an issue for a supported language, please check with
the sample projects in `support/test/<language>` and `tests/testdata/` to see if
the problem is with your project settings, rather than with vimspector. 

Information on these is in [the README](README.md#trying-it-out).

If in doubt, ask on Gitter.

## Diagnostics

Whenever reporting any type of fault, or difficulty in making the plugin
work, please always include _all_ of the diagnostics requested in the
[issue template][issue-template]. Please do not be offended if your request
is ignored if it does not include the requested diagnostics.

The Vimspector log file contains a full trace of the communication between
Vimspector and the debug adapter. This is the primary source of diagnostic
information when something goes wrong that's not a clear Vim traceback.

If you just want to see the Vimspector log file, use `:VimspectorToggleLog`,
which will tail it in a little window (doesn't work on Windows).

## Issues

The GitHub issue tracker is for *bug reports* and *features requests* for the
Vimspector project, and on-topic comments and follow-ups to them. It is not for
general discussion, general support or for any other purpose.

Please do not be offended if your Issue or comment is closed or hidden, for any
of the following reasons:

* The [issue template][issue-template] was not completed
* The issue or comment is off-topic
* The issue does not represent a Vimspector bug or feature request
* The issue cannot be reasonably reproduced using the minimal vimrc
* etc.

Issue titles are important. It's not usually helpful to write a title like
`Issue with Vimspector` or `Issue configuring` or even pasting an error message.
Spend a minute to come up with a consise summary of the problem. This helps with
management of issues, with triage, and above all with searching.

But above all else, please *please* complete the issue template. I know it is a
little tedious to get all the various diagnostics, but you *must* provide them,
*even if you think they are irrelevant*. This is important, because the
maintainer(s) can quickly cross-check theories by inspecting the provided
diagnostics without having to spend time asking for them, and waiting for the
response. This means *you get a better answer, faster*. So it's worth it,
honestly.

### Reproduce your issue with the minimal vimrc

Many problems can be caused by unexpected configuration or other plugins. 
Therefore when raising an issue, you must attempt to reproduce your issue
with the minimal vimrc provided, and to provide any additional changes required
to that file in order to reproduce it. The purpose of this is to ensure that
the issue is not a conflict with another plugin, or a problem unique to your
configuration.

If your issue does _not_ reproduce with the minimal vimrc, then you must say so
in the issue report.

The minimal vimrc is in `support/test/minimal_vimrc` and can be used as follows:

```
vim -Nu /path/to/vimspector/support/minimal_vimrc
```

## Pull Requests

When contributing pull requests, I ask that:

* You provide a clear and complete summary of the change, the use case and how
  the change was tested.
* You avoid using APIs that are not available in the versions listed in the
  dependencies on README.md
* You add tests for your PR.
* You follow the style of the code as-is; the python code is YCM-stye, it is
  *not* PEP8, nor should it be.

### Running the tests locally

There are 2 ways:

1. In the docker container. The CI tests for linux run in a container, so as to
   ensure a consistent test environment. The container is defined in
   `./tests/ci/`. There is also a container in `./tests/manual` which can be
   used to run the tests interractively. To do this install and start docker,
   then run `./tests/manual/run`.  This will drop you into a bash shell inside
   the linux container with your local vimspector code mounted. You can then
   follow the instructions for running tets directly.
1. Directly: Run `./install_gadget.py --all` and then `./run_tests`. Note that
   this depends on your runtime environment and might not match CI. I recommend
   running the tests in the docker container. If you have your own custom
   gadgets and/or custom configurations (in `vimspector/configurations` and/or
   `vimspector/gadget`, then consider using `./run_tests --install --basedir
   /tmp/vimspector_test` (then delete `/tmp/vimspector_test`). This will install
   the gadgets to that dir and use it for the gadget dir/config dir so that your
   custom configuration won't interfere with the tess.

When tests fail, they dump a load of logs to a directory for each failed tests.
Usually the most useful output is `messages`, which tells you what actually
failed.

For more infomration on the test framework, see
[this article](https://vimways.org/2019/a-test-to-attest-to/), authored by the
Vimspector creator.

### Code Style

The code style of the Python code is "YCM" style, because that's how I like it.
[`flake8`][] is used to check for certain errors and code style.

The code style of the Vimscript is largely the same, and it is linted by
[`vint`][].

To run them:

* (optional) Create and activate a virtual env:
  `python3 -m venv venv ; source venv/bin/activate`
* Install the development dependencies: `pip install -r dev_requirements.txt`
* Run `flake8`: `flake8 python3/ *.py`
* Run `vint`: `vint autoload/ plugin/ tests/`

They're also run by CI, so please check for lint failures. The canonical
definition of the command to run is the command run in CI, i.e. in
`azure-pipelines.yml`.

# Code of conduct

Please see [code of conduct](CODE_OF_CONDUCT.md).

[vint]: https://github.com/Vimjas/vint
[flake8]: https://flake8.pycqa.org/en/latest/
[issue-template]: https://github.com/puremourning/vimspector/blob/master/.github/ISSUE_TEMPLATE/bug_report.md

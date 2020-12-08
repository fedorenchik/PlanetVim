Calculator.vim
==============

Calculator inside of vim.

Introduction
------------

Real calculator inside vim. It supports arbitrary complex arithmetics,
expressions, variables, logic statements and loops.

Some examples:

```
> 5+4
9.0
> 7 * sqrt(4)
14.0
```

Installation
------------

### Requirements

* vim 8.1 (for buftype=prompt)
* with +float
* with +channel

### Installation

I recommend using Vim's native package management functionality: simply run
following commands:

```
mkdir -p ~/.vim/pack/bundle/start
cd ~/.vim/pack/bundle/start
git clone https://github.com/fedorenchik/calculator.vim.git
vim -c 'helptags ALL' -c 'q'
```

Otherwise use your favourite package manager for Vim.

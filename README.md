# shinobi

[![AppVeyor](https://img.shields.io/appveyor/build/marcosbozzani/shinobi)](https://ci.appveyor.com/project/marcosbozzani/shinobi)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/marcosbozzani/shinobi)](https://github.com/marcosbozzani/shinobi/releases/latest)
[![GitHub](https://img.shields.io/github/license/marcosbozzani/shinobi)](https://github.com/marcosbozzani/shinobi/blob/master/LICENSE.md)

Opinionated `Ninja` and `Make` files generator for `C` projects

# Install

- scoop: 
  1. run `scoop bucket add marcosbozzani https://github.com/marcosbozzani/scoop`
  2. run `scoop install shinobi`

- manual:
  1. download the [latest release](https://github.com/marcosbozzani/shinobi/releases/latest)
  2. move the `shinobi.ps1` to the $PATH

# Overview

This tool adopts a set of conventions:
- the `build.config` file defines the project root
- the supported compiler is `gcc`
- the supported builders are `ninja` and `make`
- `headsup` is used for declaration generation
- all source `.c` and header `.h` files must go inside the `source` folder in the project root 
- a source `.c` file must include its respective header `.h` file. For example: `calc.c` must `#include <calc.h>`
- all source `.c` and header `.h` files must include a declaration `.decl` file with the same name of the file. For example: `calc.c` must `#include <calc.c.cdecl>` and `calc.h` must `#include <calc.h.cdecl>`
- for every added file inside `source` folder the `shinobi` command must be executed to update the project dependecies and declaration files

Following those conventions and using `shinobi` gives you:
- automatic `ninja` or `make` dependencies listing, so you don't have to add new source files manually or write all the included files for a source for the build system
- automatic `C prototypes` and `C variables`  declarations at the top, so you can define the functions and the variables in any order
- automatic `typedef`s for `struct`s, `union`s and `enum`s, so you can declare variable of those types without the keyword prefix
- separated compilation of each `translation unit`, so you won't need to rebuild the whole project every time. This results in faster compilation times on the average
- separeted folder for each target, so `debug` artifacts don't mix up with `release` artifacts for example

# Usage

- create a `build.config` file
- create a `source` folder
- create your source `.c` and header `.h` files inside the `source` folder
- `shinobi [-builder (ninja|make)]`
  - options:
    - `-b|-build` : choose the builder (ninja or make) [default: ninja]
  - examples: 
    - `shinobi`
    - `shinobi -b make`
    - `shinobi -builder ninja`
- run `ninja -f target.ninja` or `make -f target.make`

# Configuration file (build.config)

- this file must be in the root directory of the project
- the `name` and the `value` of the properties are 
- values can span multiple lines
- separeted by a colon `:`. If you need to use a colon `:` in the `name` or the `value`, scape it with a double colon `::`.
- each target must contains two properties:
  - `{target}.name` : the output binary name
  - `{target}.cflags` : the C flags for the target
- example with two targets (debug and release):
  ```
  debug.name: app.exe
  debug.cflags: -O0 -g
    -fvisibility=hidden
    -fdiagnostics-color=always
    -Wall -Wextra 
    -Wno-unused-parameter 
    -Wno-missing-field-initializers

  release.name: app.exe
  release.cflags: -O3 -s 
    -fvisibility=hidden
    -fdiagnostics-color=always
    -Wall -Wextra 
    -Wno-unused-parameter 
    -Wno-missing-field-initializers
  ```

# Project structure

- example with two targets (debug and release):
  ```
  source/
    main.c
    calc.c
    calc.h
  debug/
    declaration/
      main.c.decl
      calc.h.decl
      calc.c.decl
    object/
      main.o
      calc.o
    calc.exe
  release/
    declaration/
      main.c.decl
      calc.h.decl
      calc.c.decl
    object/
      main.o
      calc.o
    calc.exe
  build.config
  ```
- for a sample project, look at the `test` folder

# Build

1. prerequisites: `ninja`, `gcc`, `headsup`:
   - if you use scoop: 
     - `scoop bucket add marcosbozzani https://github.com/marcosbozzani/scoop`
     - `scoop install ninja gcc headsup`
2. clone `git clone https://github.com/marcosbozzani/shinobi.git`
3. run `./build.ps1`

# Test

1. run `./test.ps1`

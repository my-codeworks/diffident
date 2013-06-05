# 0.2.0

## TL;DR

Enables the external interface to work with files as well as strings.

Rewrites the parser class, `Tokenizer`, to use `StringScanner` instead of looping over arrays of strings.

Adds primitives for all the possible changes (addition, deletion, update, conflict, no change) based on a common superclass, `Change`.

Exposes and documents the diff structure as an API.

# 0.1.0

## TL;DR

This release adds nothing to the interface, internal or external, over [differ 0.1.2](https://rubygems.org/gems/differ).

It changes how the global separator string/regex is defined, `$;=' '` is gone in favour of `Diffident.separator=' '`.

## Changes

It removes the use of a global (`$;`) variable for defining a custom separation string/regex in favour of a class method (`Diffident.separator`).

Internally there has been some refactoring, mainly breaking out the main parsing logic into a new `Tokenizer` class.

The readme has been substantially updated to give examples of using regex in a few new ways as well as to describe the new functionality for setting the separator. It has also changed substantially in style, going for more of a conversational, easy presentation. It also got a few badges for Travis CI, Code Climate and gem version.

Continuous integration testing has been added in Travis and some updates where made to accomodate this.

Gemspec updated to reflect the new gem name, author, version and other information. It was also cleaned up and dependancy on Jewler was removed. Version was reset to 0.1.0.

# Legacy

## TL;DR

This gem originated as a pull request for some updates to the [differ](http://github.com/pvande/differ) gem by Pieter Vande Bruggen.

For details on the development previous to Diffident 0.1.0 please have a look at [the differ repository at the time of the fork](https://github.com/pvande/differ/commit/85407d9059519de4d64469e827f6bcdafff2c449).
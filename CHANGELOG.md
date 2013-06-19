# Changelog

Searchlight does its best to use [semantic versioning](http://semver.org).

## Unreleased

Fix bug introduced in v1.2: setting defaults in `initialize` did not add them to the options hash, which meant they weren't used in searches.

## v1.2.2

Gracefully handle being given explicit `nil` in initialization instead of options hash or empty arguments

## v1.2.1

Bugfix for v1.2.0 - screen out from options any collections containing only blank values

## v1.2.0

- Provide `options` accessor that returns all options considered non-blank
- Slightly nicer errors when passing invalid options

## v1.1.0

ActiveRecord adapter ensures that searches return a relation, even if no options are given

## v1.0.0

- If no search target is given, search class attempts to guess based on its own name
- All errors that can be raise extend `Searchlight::Error`
- Better testing
- Still more documentation!

## v0.9.1

Bugfix for ActiveRecord adapter

## v0.9.0

- Clean up dynamic module inclusion
- Better `ActionView` and `ActiveRecord` adapters
- Better error messages
- More documentation

## v0.0.1

Experimental and unstable, Searchlight totters onto the scene and takes its first wide-eyed look at the world.

It is adorable.

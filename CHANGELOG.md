# Changelog

Searchlight does its best to use [semantic versioning](http://semver.org).

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

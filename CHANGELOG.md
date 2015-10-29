# Changelog

Searchlight does its best to use [semantic versioning](http://semver.org), for the maintainers' best guess of ["what is a breaking change?"](https://xkcd.com/1172/).

## Unreleased

## v4.1.0 - 2015-10-29

- Option readers now will find symbol keys as well as string keys

## v4.0.0 - 2015-10-28

Removed the DSL methods to simplify some things. This is a breaking change, but I think the upgrade will be pretty easy. See below for details.

- Removed all DSL methods.
  - `search_on` is now `def base_query`. Defining the base query in an instance method removes the need for procs and makes modification in subclasses as simple as `super`. Note that you *must* define `base_query` - Searchlight will no longer guess your search class based on the name of the search class. If you want such magic, [here it was](https://github.com/nathanl/searchlight/blob/v3.1.1/lib/searchlight/search.rb#L50).
  - `searches` is removed. If your search has a public method like `search_title`, Searchlight will know to hand the `title` option to that method, and will define a `.title` reader for the option's value. This is slightly magical, but makes your code less repetitive.
- Option-grabbing methods like `.title` and `.title?` are gone, in favor of `options[:title]` and `checked?(options[:title])`.
  - `checked?` interprets `'0'` and `'false'` as false
  - `empty?` interprets empty arrays and hashes as empty, as well as empty or whitespace-only strings. It's used to filter the options that get passed to your search methods.
- `explain` tells you exactly how searchlight interpreted the options a search was given. (Depending on your ORM, you might also want to call `.sql` or `.to_sql` on `search.results` for further debugging.)
- `Searchlight::Adapters::ActionView` adapter must now be explicitly required and included.
- Within your `search_` methods, the query you chain on is now called `query`, not `search`

## v3.1.1

### Bugfix

- Bugfix for Sequel users. Don't use `.call` unless target is a proc; avoids mistakenly using `Sequel::Dataset#call`. See [bug report](https://github.com/nathanl/searchlight/issues/25). Thanks to [Jorge Marques](https://github.com/jorge-marques) for pointing out this problem. Bug was introduced in v3.1.0.

## v3.1.0

Allow callable search targets, thanks to [Adam Nowak](https://github.com/lubieniebieski).

## v3.0.0

Two major releases in two days!? Well, I thought of another good, but breaking, change. To the major version bump, Robin!

Inputs generated using `ActionView` forms are now named after your search form. Eg, the form for 'UserSearch' will submit parameters under 'user_search', not just 'search'. This makes the code more standard and namespaces the form, in case, eg, you want to have two forms on the same page.

Note that to upgrade, Rails users will need to change references to `params[:search]` to something like `params[:user_search]` (depending on name of the search class).

## v2.0.0

Now with fewer features! :D

### No more ORM adapters

ORM "adapters", which were never actually necessary, have been removed. They required lots of hackery, added test dependencies, and sometimes introduced [weird bugs](https://github.com/nathanl/searchlight/pull/15). All that just so that if you said your class `searches :first_name, :last_name`, we could save you from typing simple search methods like:

```ruby
def search_first_name
  search.where(first_name: first_name)
end
```

You can easily save yourself this effort with something like:

```ruby
%w[name address pant_size].each do |attr|
  define_method("search_#{attr}") do
    search.where(:"#{attr}" => attr)
  end
end
```

...and you'll get much saner backtraces if anything goes wrong.

**ActiveRecord users**: note that with this change, you'll need to update your `search_on` calls to return an `ActiveRecord::Relation` so that, if no options are passed, you don't return the model class itself. Eg, instead of `search_on User`, do `search_on User.all` for Rails > 4 or `search_on User.scoped` for Rails < 4.

With this change, Searchlight no longer has any ties to any ORM, but can still work with any of them that use method chaining. Hooray!

## v1.3.1

Add license to gemspec, thanks to notice from Benjamin Fleischer - see [his blog post](http://www.benjaminfleischer.com/2013/07/12/make-the-world-a-better-place-put-a-license-in-your-gemspec/)

## v1.3.0

New Mongoid adapter, thanks to [iliabylich](https://github.com/iliabylich).

## v1.2.4

- `options` method only returns those that map to search methods (not `attr_accessor` type values)
- Previously, `searches :name` in a class with an `ActiveRecord` target would always trigger the `ActiveRecord` adapter to define `searches_name` as `search.where(name: name)`. Now it first checks whether `name` is a column on the model, and if not, defines the method to raise an error.

## v1.2.3

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

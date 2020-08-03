# Searchlight

## Status

**I consider searchlight "done"**.
It has no production dependencies, so there's no reason it shouldn't work indefinitely.
I've also moved on to other things.

If you find a bug, feel free to open an issue so others can find it and discuss, but I'm unlikely to respond personally.
If Searchlight doesn't meet your needs anymore, fork away! :)

## Description

Searchlight is a low-magic way to build database searches using an ORM.

Searchlight can work with **any** ORM or object that can build a query using **chained method calls** (eg, ActiveRecord's `.where(...).where(...).limit(...)`, or similar chains with [Sequel](https://rubygems.org/gems/sequel), [Mongoid](https://rubygems.org/gems/mongoid), etc).

[![Gem Version](https://badge.fury.io/rb/searchlight.png)](https://rubygems.org/gems/searchlight)
[![Code Climate](https://codeclimate.com/github/nathanl/searchlight.png)](https://codeclimate.com/github/nathanl/searchlight)
[![Build Status](https://api.travis-ci.org/nathanl/searchlight.png?branch=master)](https://travis-ci.org/nathanl/searchlight)

## Getting Started

A [demo app](http://bookfinder-searchlight-demo.herokuapp.com) and [the code for that app](https://github.com/nathanl/searchlight_demo) are available to help you get started.

## Overview

Searchlight's main use is to support search forms in web applications.

Searchlight doesn't write queries for you. What it does do is:

- Give you an object with which you can build a search form (eg, using `form_for` in Rails)
- Give you a sensible place to put your query logic
- Decide which parts of the search to run based on what the user submitted (eg, if they didn't fill in a "first name", don't do the `WHERE first_name =` part)

For example, if you have a Searchlight search class called `YetiSearch`, and you instantiate it like this:

```ruby
  search = YetiSearch.new(
    # or params[:yeti_search]
    "active" => true, "name" => "Jimmy", "location_in" => %w[NY LA]
  )
```

... calling `search.results` will build a search by calling the methods `search_active`, `search_name`, and `search_location_in` on your `YetiSearch`, assuming that you've defined them. (If you do it again but omit `"name"`, it won't call `search_name`.)

The `results` method will then return the return value of the last search method. If you're using ActiveRecord, this would be an `ActiveRecord::Relation`, and you can then call `each` to loop through the results, `to_sql` to get the generated query, etc.

## Usage

### Search class

A search class has two main parts: a `base_query` and some `search_` methods. For example:

```ruby
class PersonSearch < Searchlight::Search

  # This is the starting point for any chaining we do, and it's what
  # will be returned if no search options are passed.
  # In this case, it's an ActiveRecord model.
  def base_query
    Person.all # or `.scoped` for ActiveRecord 3
  end

  # A search method.
  def search_first_name
    # If `"first_name"` was the first key in the options_hash,
    # `query` here will be the base query, namely, `Person.all`.
    query.where(first_name: options[:first_name])
  end

  # Another search method.
  def search_last_name
    # If `"last_name"` was the second key in the options_hash,
    # `query` here will be whatever `search_first_name` returned.
    query.where(last_name: last_name)
  end
end
```

Calling `PersonSearch.new("first_name" => "Gregor", "last_name" => "Mendel").results` would run `Person.all.where(first_name: "Gregor").where(last_name: "Mendel")` and return the resulting `ActiveRecord::Relation`. If you omitted the `last_name` option, or provided `"last_name" => ""`, the second `where` would not be added.

Here's a fuller example search class. Note that **because Searchlight doesn't write queries for you, you're free to do anything your ORM supports**. (See `spec/support/book_search.rb` for even more fanciness.)

```ruby
# app/searches/city_search.rb
class CitySearch < Searchlight::Search

  # `City` here is an ActiveRecord model
  def base_query
    City.includes(:country)
  end

  # Reach into other tables
  def search_continent
    query.where('`countries`.`continent` = ?', continent)
  end

  # Other kinds of queries
  def search_country_name_like
    query.where("`countries`.`name` LIKE ?", "%#{country_name_like}%")
  end

  # .checked? considers "false", 0 and "0" to be false
  def search_is_megacity
    query.where("`cities`.`population` #{checked?(is_megacity) ? '>=' : '<'} ?", 10_000_000)
  end

end
```

Here are some example searches.

```ruby
CitySearch.new.results.to_sql
  # => "SELECT `cities`.* FROM `cities` "
CitySearch.new("name" => "Nairobi").results.to_sql
  # => "SELECT `cities`.* FROM `cities`  WHERE `cities`.`name` = 'Nairobi'"

CitySearch.new("country_name_like" =>  "aust", "continent" => "Europe").results.count # => 6

non_megas = CitySearch.new("is_megacity" => "false")
non_megas.results.to_sql 
  # => "SELECT `cities`.* FROM `cities`  WHERE (`cities`.`population` < 10000000"
non_megas.results.each do |city|
  # ...
end
```

### Option Readers

For each search method you define, Searchlight will define a corresponding option reader method. Eg, if you add `def search_first_name`, your search class will get a `.first_name` method that returns `options["first_name"]` or, if that key doesn't exist, `options[:first_name]`. This is useful mainly when building forms.

Since it considers the keys `"first_name"` and `:first_name` to be interchangeable, Searchlight will raise an error if you supply both.

### Examining Options

Searchlight provides some methods for examining the options provided to your search.

- `raw_options` contains exactly what it was instantiated with
- `options` contains all `raw_options` that weren't `empty?`. Eg, if `raw_options` is `categories: nil, tags: ["a", ""]`, options will be `tags: ["a"]`.
- `empty?(value)` returns true for `nil`, whitespace-only strings, or anything else that returns true from `value.empty?` (eg, empty arrays)
- `checked?(value)` returns a boolean, which mostly works like `!!value` but considers `0`, `"0"`, and `"false"` to be `false`

Finally, `explain` will tell you how Searchlight interpreted your options. Eg, `book_search.explain` might output:

```
Initialized with `raw_options`: ["title_like", "author_name_like", "category_in",
"tags", "book_thickness", "parts_about_lolcats"]

Of those, the non-blank ones are available as `options`: ["title_like",
"author_name_like", "tags", "book_thickness", "in_print"]

Of those, the following have corresponding `search_` methods: ["title_like",
"author_name_like", "in_print"]. These would be used to build the query.

Blank options are: ["category_in", "parts_about_lolcats"]

Non-blank options with no corresponding `search_` method are: ["tags",
"book_thickness"]
```

### Defining Defaults

Sometimes it's useful to have default search options - eg, "orders that haven't been fulfilled" or "houses listed in the last month".

This can be done by overriding `options`. Eg:

```ruby
class BookSearch < SearchlightSearch

  # def base_query...

  def options
    super.tap { |opts|
      opts["in_print"] ||= "either"
    }
  end

  def search_in_print
    return query if options["in_print"].to_s == "either"
    query.where(in_print: checked?(options["in_print"]))
  end

end
```

### Subclassing

You can subclass an existing search class and support all the same options with a different base query. This may be useful for single table inheritance, for example. 

```ruby
class VillageSearch < CitySearch
  def base_query
    Village.all
  end
end
```

Or you can use `super` to get the superclass's `base_query` value and modify it:

```ruby
class SmallTownSearch < CitySearch
  def base_query
    super.where("`cities`.`population` < ?", 1_000)
  end
end
```

### Custom Options

You can provide a Searchlight search any options you like; only those with a matching `search_` method will determine what methods are run. Eg, if you want to do `AccountSearch.new("super_user" => true)` to find restricted results, just ensure that you check `options["super_user"]` when building your query.

## Usage in Rails

### ActionView adapter

Searchlight plays nicely with Rails forms - just include the `ActionView` adapter as follows:

```ruby
require "searchlight/adapters/action_view"

class MySearch < Searchlight::Search
  include Searchlight::Adapters::ActionView

  # ...etc
end
```

This will enable using a `Searchlight::Search` with `form_for`:

```ruby
# app/views/cities/index.html.haml
...
= form_for(@search, url: search_cities_path) do |f|
  %fieldset
    = f.label      :name, "Name"
    = f.text_field :name

  %fieldset
    = f.label      :country_name_like, "Country Name Like"
    = f.text_field :country_name_like

  %fieldset
    = f.label  :is_megacity, "Megacity?"
    = f.select :is_megacity, [['Yes', true], ['No', false], ['Either', '']]

  %fieldset
    = f.label  :continent, "Continent"
    = f.select :continent, ['Africa', 'Asia', 'Europe'], include_blank: true

  = f.submit "Search"
  
- @results.each do |city|
  = render partial: 'city', locals: {city: city}
```

### Controllers

As long as your form submits options your search understands, you can easily hook it up in your controller:

```ruby
# app/controllers/orders_controller.rb
class OrdersController < ApplicationController

  def index
    @search  = OrderSearch.new(search_params) # For use in a form
    @results = @search.results                # For display along with form
  end
  
  protected
  
  def search_params
    # Ensure the user can only browse or search their own orders
    (params[:order_search] || {}).merge(user_id: current_user.id)
  end
end
```

## Compatibility

For any given version, check `.travis.yml` to see what Ruby versions we're testing for compatibility.

## Installation

Add this line to your application's Gemfile:

    gem 'searchlight'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install searchlight

## Contributing

`rake` runs the tests; `rake mutant` runs mutation tests using [mutant](https://github.com/mbj/mutant).

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Shout Outs

- The excellent [Mr. Adam Hunter](https://github.com/adamhunter), co-creator of Searchlight.
- [TMA](http://tma1.com) for supporting the initial development of Searchlight.

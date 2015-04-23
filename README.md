# Searchlight

Searchlight is a low-magic way to build database searches using an ORM.

Searchlight can work with **any** ORM or object that can build a query using **chained method calls** (eg, ActiveRecord's `.where(...).where(...).limit(...)`, or similar chains with [Sequel](https://rubygems.org/gems/sequel), [Mongoid](https://rubygems.org/gems/mongoid), etc).

[![Gem Version](https://badge.fury.io/rb/searchlight.png)](https://rubygems.org/gems/searchlight)
[![Code Climate](https://codeclimate.com/github/nathanl/searchlight.png)](https://codeclimate.com/github/nathanl/searchlight)
[![Build Status](https://api.travis-ci.org/nathanl/searchlight.png?branch=master)](https://travis-ci.org/nathanl/searchlight)
[![Dependency Status](https://gemnasium.com/nathanl/searchlight.png)](https://gemnasium.com/nathanl/searchlight)

## Getting Started

An [introductory video](https://vimeo.com/69179161), [the demo app it uses](http://bookfinder-searchlight-demo.herokuapp.com) and [the code for that app](https://github.com/nathanl/bookfinder) are available to help you get started.

## Overview

The basic idea of Searchlight is to build a search by chaining method calls that you define. It calls **public** methods on the object you specify, based on the options you pass.

For example, if you have a Searchlight search class called `YetiSearch`, and you instantiate it like this:

```ruby
  search = YetiSearch.new(
    active: true, name: 'Jimmy', location_in: %w[NY LA] # or params[:yeti_search]
  )
```

... calling `results` on the instance will build a search by chaining calls to `search_active`, `search_name`, and `search_location_in`.

The `results` method will then return the return value of the last search method. If you're using ActiveRecord, this would be an `ActiveRecord::Relation`, and you can then call `each` to loop through the results, `to_sql` to get the generated query, etc.

## Usage

### Search class

A search class has three main parts: a target, options, and methods. For example:

```ruby
class PersonSearch < Searchlight::Search

  # The search target; in this case, an ActiveRecord model.
  # This is the starting point for any chaining we do, and it's what
  # will be returned if no search options are passed.
  search_on Person.all # or `.scoped` for ActiveRecord 3

  # The options the search understands. Supply any combination of them to an instance.
  searches :first_name, :last_name

  # A search method.
  def search_first_name
    # If this is the first search method called, `search` here will be
    # the search target, namely, `Person`.
    # `first_name` is an automatically-defined accessor for the option value.
    search.where(first_name: first_name)
  end

  # Another search method.
  def search_last_name
    # If this is the second search method called, `search` here will be
    # whatever `search_first_name` returned.
    search.where(last_name: last_name)
  end
end
```

Here's a fuller example search class.

```ruby
# app/searches/city_search.rb
class CitySearch < Searchlight::Search

  # `City` here is an ActiveRecord model (see notes below on the adapter)
  search_on City.includes(:country)

  searches :name, :continent, :country_name_like, :is_megacity

  # Reach into other tables
  def search_continent
    search.where('`countries`.`continent` = ?', continent)
  end

  # Other kinds of queries
  def search_country_name_like
    search.where("`countries`.`name` LIKE ?", "%#{country_name_like}%")
  end

  # For every option, we also add an accessor that coerces to a boolean,
  # considering 'false', 0, and '0' to be false
  def search_is_megacity
    search.where("`cities`.`population` #{is_megacity? ? '>=' : '<'} ?", 10_000_000)
  end

end
```

Here are some example searches.

```ruby
CitySearch.new.results.to_sql
  # => "SELECT `cities`.* FROM `cities` "
CitySearch.new(name: 'Nairobi').results.to_sql
  # => "SELECT `cities`.* FROM `cities`  WHERE `cities`.`name` = 'Nairobi'"

CitySearch.new(country_name_like: 'aust', continent: 'Europe').results.count # => 6

non_megas = CitySearch.new(is_megacity: 'false')
non_megas.results.to_sql 
  # => "SELECT `cities`.* FROM `cities`  WHERE (`cities`.`population` < 100000"
non_megas.results.each do |city|
  # ...
end
```

### Accessors

For each search option you allow, Searchlight defines two accessors: one for a value, and one for a boolean.

For example, if your class `searches :awesomeness` and gets instantiated like:

```ruby
search = MySearchClass.new(awesomeness: 'Xtreme')
```

... your search methods can use:

- `awesomeness` to retrieve the given value, `'Xtreme'`
- `awesomeness?` to get a boolean version: `true`

The boolean conversion is form-friendly, so that `0`, `'0'`, and `'false'` are considered `false`.

All accessors are defined in modules, so you can override them and use `super` to call the original methods.

```ruby
class PersonSearch < Searchlight::Search

  searches :names, :awesomeness

  def names
    # Make sure this is an array and never search for Jimmy.
    # Jimmy is a private man. An old-fashioned man. Leave him be.
    Array(super).reject { |name| name == 'Jimmy' }
  end

  def searches_names
    search.where("name IN (?)", names)
  end

  def awesomeness?
    # Disagree about what is awesome
    !super
  end

end
```

Additionally, each search instance has an `options` accessor, which will have all the usable options with which it was instantiated. This excludes empty collections, blank strings, `nil`, etc. These usable options will be used in determining which search methods to run.

### Defining Defaults

Set defaults using plain Ruby. These can be used to prefill a form or to assume what the user didn't specify.

```ruby

class CitySearch < Searchlight::Search

  #...

  def initialize(options = {})
    super    
    self.continent ||= 'Asia'
  end

  #...
end

CitySearch.new.results.to_sql
  => "SELECT `cities`.* FROM `cities`  WHERE (`countries`.`continent` = 'Asia')"
CitySearch.new(continent: 'Europe').results.to_sql
  => "SELECT `cities`.* FROM `cities`  WHERE (`countries`.`continent` = 'Europe')"
```

You can define defaults for boolean attributes if you treat them as "yes/no/either" choices.

```ruby
class AnimalSearch < Searchlight::Search

  search_on Animal.all
  
  searches :is_fictional
  
  def initialize(*args)
    super
    self.is_fictional = :either if is_fictional.blank?
  end
  
  def search_is_fictional
    case is_fictional.to_s
    when 'true'   then search.where(fictional: true)
    when 'false'  then search.where(fictional: false)
    when 'either' then search # unmodified
    end
  end
end


AnimalSearch.new(fictional: true).results.to_sql
  => "SELECT `animals`.* FROM `animals` WHERE (`fictional` = true)"
AnimalSearch.new(fictional: false).results.to_sql
  => "SELECT `animals`.* FROM `animals` WHERE (`fictional` = false)"
AnimalSearch.new.results.to_sql
  => "SELECT `animals`.* FROM `animals`"
```

### Subclassing

You can subclass an existing search class and support all the same options with a different search target. This may be useful for single table inheritance, for example. 

```ruby
class VillageSearch < CitySearch
  search_on Village.all
end
```

You can also use `search_target` to get the superclass's `search_on` value, so you can do this:

```ruby
class SmallTownSearch < CitySearch
  search_on search_target.where("`cities`.`population` < ?", 1_000)
end

SmallTownSearch.new(country_name_like: 'Norfolk').results.to_sql
  => "SELECT `cities`.* FROM `cities`  WHERE (`cities`.`population` < 1000) AND (`countries`.`name` LIKE '%Norfolk%')"
```

### Delayed scope evaluation

If your search target has a time-sensitive condition, you can wrap it in a callable object to prevent it from being evaluated when the class is defined. For example:

```ruby
class RecentOrdersSearch < Searchlight::Search
  search_on proc { Orders.since(Time.now - 3.hours) }
end
```

This does make subclassing a bit more complex:

```ruby
class ExpensiveRecentOrdersSearch < RecentOrderSearch
  search_on proc { superclass.search_target.call.expensive }
end
```

### Dependent Options

To allow search options that don't trigger searches directly, just use `attr_accessor`.

## Usage in Rails

### Forms

Searchlight plays nicely with Rails forms. All search options and any `attr_accessor`s you define can be hooked up to form fields.

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
  = render 'city'
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
## ActionView Adapter

Searchlight's ActionView adapter adds ActionView-friendly methods to your classes if it sees that `ActionView` is a defined constant. See the code for details, but the upshot is that you can use a search with `form_for`.

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

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Shout Outs

- The excellent [Mr. Adam Hunter](https://github.com/adamhunter), co-creator of Searchlight.
- [TMA](http://tma1.com) for supporting the initial development of Searchlight.

# Searchlight

Searchlight helps you build searches from options via Ruby methods that you write.

Searchlight comes with ActiveRecord integration, but can work with any ORM or object that allows chaining search methods.

[![Build Status](https://api.travis-ci.org/nathanl/searchlight.png?branch=master)](https://travis-ci.org/nathanl/searchlight)
[![Code Climate](https://codeclimate.com/github/nathanl/searchlight.png)](https://codeclimate.com/github/nathanl/searchlight)

## Overview

The basic idea of Searchlight is to build a search by chaining method calls that you define. It calls methods on the object you specify, based on the options you pass.

For example, if you have a Searchlight search class called `YetiSearch`, and you instantiate it like this:

```ruby
  yeti_search = YetiSearch(active: true, name: 'Jimmy', location_in: %w[NY LA]) # or params[:search]
```

... calling `results` will call the instance methods `search_active`, `search_name`, and `search_location_in`. (If you omit the `active` option, `search_active` won't be called.)

The `results` method will then return the return value of the last search method. If you're using ActiveRecord, this would be an `ActiveRecord::Relation`. You can then call `each` to loop through the results, `to_sql` to get the generated query, etc.

## Usage

### Search class

Here's an example search class that uses ActiveRecord.

```ruby
# app/searches/city_search.rb
class CitySearch < Searchlight::Search

  search_on City.includes(:country)

  searches :name, :continent, :country_name_like, :is_megacity

  # This simple method is auto-defined by the ActiveRecord adapter, but you can override it
  # def search_name
  #   search.where(name: name)
  # end

  # Reach into other tables
  def search_continent
    search.where('`countries`.`continent` = ?', continent)
  end

  # Other kinds of queries
  def search_country_name_like
    search.where("`countries`.`name` LIKE ?", "%#{country_name_like}%")
  end

  # For every option, we add an accessor that coerces to a boolean,
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
non_megas.results.to_sql => "SELECT `cities`.* FROM `cities`  WHERE (`cities`.`population` < 100000"
non_megas.results.each do |city|
  # ...
end

```

### Defining Defaults

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

### Overriding Accessors

All accessors are defined in modules, so you can access the original values via `super` and tweak them if you like.

```ruby
class CitySearch < Searchlight::Search

  def continent
    super.to_s.reverse
  end

end

CitySearch.new(continent: 'Europe').results.to_sql
  => "SELECT `cities`.* FROM `cities`  WHERE (`countries`.`continent` = 'eporuE')"
```

### Subclassing

You can subclass an existing search class and support all the same options with a different search target. This may be useful for single table inheritance, for example. You can also use `search_target` to get the superclass's `search_on` value, so you can do this:

```ruby
class SmallTownSearch < CitySearch

  search_on search_target.where("`cities`.`population` < ?", 1_000)

end

SmallTownSearch.new(country_name_like: 'Norfolk').results.to_sql
  => "SELECT `cities`.* FROM `cities`  WHERE (`cities`.`population` < 1000) AND (`countries`.`name` LIKE '%Norfolk%')"
```

## Usage in Rails

You can do something like this in your controller:

```ruby
# app/controllers/cities_controller.rb
class CitiesController

def search
  @search = CitySearch.new(params[:search])
end
...
```

Searchlight also plays nicely with Rails views.

```ruby
# app/views/accounts/index.html.haml
...
= form_for(search, url: search_cities_path) do |f|
  %fieldset
    = f.label :name, "Name"
    = f.input :name

  %fieldset
    = f.label :country_name_like, "Country Name Like"
    = f.input :country_name_like

  %fieldset
    = f.label  :is_megacity, "Megacity?"
    = f.select :is_megacity, [['Yes', true], ['No', false], ['Either', '']]

  %fieldset
    = f.label  :continent, "Continent"
    = f.select :continent, continents_collection
```

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

- The excellent [Mr. Adam Hunter](https://github.com/adamhunter), co-creator of Searchlight
- [TMA](http://tma1.com) for supporting the development of Searchlight.

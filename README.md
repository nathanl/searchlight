# Pilfer

Pilfer helps you build searches from options via Ruby methods that you write. It's like Ransack, but less so.

Pilfer comes with ActiveRecord integration, but can call search methods on any ORM or other object that you wish.

[![Build Status](https://secure.travis-ci.org/nathanl/pilfer.png?branch=master)](http://travis-ci.org/nathanl/pilfer)
[![Code Climate](https://codeclimate.com/github/nathanl/pilfer.png)](https://codeclimate.com/github/nathanl/pilfer)

## Overview

The basic idea of Pilfer is to build a search by chaining method calls that you define. It calls methods on the object you specify, based on the options you pass.

For example, if you have a Pilfer search class called `FooSearch`, and you instantiate it like this:

```ruby
  foo_search = FooSearch(active: true, name: 'Jimmy', location_in: %w[NY LA]) # or params[:search]
```

... calling `results` will call the instance methods `search_active`, `search_name`, and `search_location_in`. (If you omit the `active` option, `search_active` won't be called.)

The `results` method will then return the return value of the last search method. If you're using ActiveRecord, this would be an `ActiveRecord::Relation`. You can then call `each` to loop through the results, `to_sql` to get the generated query, etc.

## Usage

### Search class

Here's an example search class that uses ActiveRecord.

```ruby
# app/searches/account_search.rb
class AccountSearch < Pilfer::Search

  # Defines the `search_target`
  search_on Account

  # The search options this class knows how to handle
  searches :contract_id, :invoicing_status, :active

  # If a `contract_id` option is given, this method will be called
  def search_contract_id
    search.where(contract_id: contract_id)
  end

  # If an `invoicing` option is given, this method will be called
  def search_invoicing
    case invoicing_status
    when 'partial'
      search.partially_invoiced
    when 'complete'
      search.completely_invoiced
    when 'never'
      search.uninvoiced
    else
      search
    end
  end

  # If an `active` option is given, this method will be called
  def search_active
    search.where(status: active? ? 'active' : 'inactive')
  end

end
```

### Controller

```ruby
# app/controllers/accounts_controller.rb
class AccountsController

def search
  @search = AccountSearch.new(params[:search])
end
...
```

### View
```ruby
# app/views/accounts/index.html.haml
...
= form_for(search, url: '#') do |f|
  %fieldset
    = f.label  :contract_id, "Contract"
    = f.select :contract_id, available_contracts_collection

  %fieldset
    = f.label  :invoicing_status, "Invoicing Status"
    = f.select :invoicing_status, invoice_statuses_collection

  %fieldset
    = f.label  :active, "Active?"
    = f.select :active, [['Active', true], ['Inactive', false], ['Either', nil]]
```

## Installation

Add this line to your application's Gemfile:

    gem 'pilfer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pilfer

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

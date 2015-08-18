# Rbngram

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rbngram'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rbngram

## Usage

to generate binary language model

    $ binlm.rb <dst> <src>

to query language model


    require 'rbngram'
    model = Ngram::Ngram.new "path_to_file"
    model.prob ["word1","word2"]
    model.bow ["word1", "word2"]


## Contributing

1. Fork it ( https://github.com/chenkovsky/rbngram/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

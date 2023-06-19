# FractionalIndexing

This is based on [Implementing Fractional Indexing](https://observablehq.com/@dgreensp/implementing-fractional-indexing) by [David Greenspan ](https://github.com/dgreensp).

Fractional indexing is a technique to create an ordering that can be used for [Realtime Editing of Ordered Sequences](https://www.figma.com/blog/realtime-editing-of-ordered-sequences/).

This implementation includes variable-length integers, and the prepend/append optimization described in David's article.

## Installation

Add it to your application's Gemfile:

```ruby
gem 'fractional_indexing', git: 'https://github.com/dooly-ai/fractional_indexing'
```

Then run `bundle install`.

## Usage

### `generate_key_between`

Generate a single key in between two points.

```ruby
first = FractionalIndexing.generate_key_between(nil, nil) # "a0"

# Insert after 1st
second = FractionalIndexing.generate_key_between(first, nil) # "a1"

# Insert after 2nd
third = FractionalIndexing.generate_key_between(second, nil) # "a2"

# Insert before 1st
zeroth = FractionalIndexing.generate_key_between(nil, first) # "Zz"

# Insert in between 2nd and 3rd (midpoint)
secondAndHalf = FractionalIndexing.generate_key_between(second, third) # "a1V"
```

### `generate_n_keys_between`

Use this when generating multiple keys at some known position, as it spaces out indexes more evenly and leads to shorter keys.

```ruby
first = FractionalIndexing.generate_n_keys_between(nil, nil, 2)

# Insert two keys after 2nd
FractionalIndexing.generate_n_keys_between(first[1], nil, 2)

# Insert two keys before 1st
FractionalIndexing.generate_n_keys_between(nil, first[0], 2)

# Insert two keys in between 1st and 2nd (midpoints)
FractionalIndexing.generate_n_keys_between(second, third, 2)
```

## Other Languages

This is a Ruby port of the original JavaScript implementation by [@rocicorp](https://github.com/rocicorp). That means that this implementation is byte-for-byte compatible with:

| Language   | Repo                                                 |
| ---------- | ---------------------------------------------------- |
| JavaScript | https://github.com/rocicorp/fractional-indexing      |
| Go         | https://github.com/rocicorp/fracdex                  |
| Python     | https://github.com/httpie/fractional-indexing-python |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

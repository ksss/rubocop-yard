# RuboCop::YARD

You can check YARD format in Ruby code comment by RuboCop.

<img src="https://github.com/ksss/rubocop-yard/blob/main/demo.png?raw=true" width=700 />

## Features

### `YARD/TagTypeSyntax`

Check tag type syntax error.

```
# @param [Symbol|String]
          ^^^^^^^^^^^^^ (SyntaxError) invalid character at |
```

### `YARD/CollectionStyle`

`EnforcedStyle long (default)`

```
# bad
# @param [{KeyType => ValueType}]

# bad
# @param [(String)]

# bad
# @param [<String>]

# good
# @param [Hash{KeyType => ValueType}]

# good
# @param [Array(String)]

# good
# @param [Array<String>]
```

`EnforcedStyle short`

```
# bad
# @param [Hash{KeyType => ValueType}]

# bad
# @param [Array(String)]

# bad
# @param [Array<String>]

# good
# @param [{KeyType => ValueType}]

# good
# @param [(String)]

# good
# @param [<String>]
```

### `YARD/CollectionType`

```
# @param [Hash<Symbol, String>]
          ^^^^^^^^^^^^^^^^^^^^ `<Type>` is the collection type syntax. Did you mean `{KeyType => ValueType}` or `Hash{KeyType => ValueType}`
```

### `YARD/MismatchName`

Check `@param` and `@option` name with method definition.

```rb
# @param [String]
^^^^^^^^^^^^^^^^^ No tag name is supplied in `@param`

# @param string
^^^^^^^^^^^^^^^ No types are associated with the tag in `@param`

# @param [String] string
                  ^^^^^^ `string` is not found in method arguments
# @option opt bar [String]
          ^^^ `opt` is not found in method arguments
def foo(strings, opts = {})
```

### `YARD/MeaninglessTag`

Check `@param` and `@option` with class/module or casgn

```rb
# @param [String] foo
^^^^^^^^^^^^^^^^^^^^^ `@param` is meaningless tag on module
module Foo
  # @option foo bar [String]
  ^^^^^^^^^^^^^^^^^^^^^^^^^^ `@option` is meaningless tag on casgn
  CONST = 1
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rubocop-yard --require=false

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rubocop-yard

## Usage

Put this into your `.rubocop.yml`.

```yaml
require: rubocop-yard
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ksss/rubocop-yard. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ksss/rubocop-yard/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RuboCop::YARD project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ksss/rubocop-yard/blob/main/CODE_OF_CONDUCT.md).

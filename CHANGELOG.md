## [Unreleased]

## [1.1.0] - 2026-01-29

* Fix NoMethodError when method signature includes **nil by @ksss in https://github.com/ksss/rubocop-yard/pull/39
* Migrate smoke tests to RSpec by @ksss in https://github.com/ksss/rubocop-yard/pull/38

## [1.0.0] - 2025-06-21

* Use plugins instead of require by @sue445 in https://github.com/ksss/rubocop-yard/pull/34

## [0.10.0] - 2024-11-20

* Guess argument types by @ksss in https://github.com/ksss/rubocop-yard/pull/32

## [0.9.3] - 2024-01-31

- Suppress YARD warning logs

## [0.9.0] - 2023-11-28

- Add `YARD/TagTypePosition`

## [0.8.0] - 2023-11-6

- Support EnforcedStylePrototypeName

## [0.7.0] - 2023-10-14

- New feature
    - `YARD/MismatchName`: Check undocumented argument.

## [0.6.0] - 2023-10-10

- Split cop from `YARD/TagType` to
    - `YARD/TagTypeSyntax`
    - `YARD/CollectionType`

## [0.4.0] - 2023-09-19

- Add new cop `YARD/MeaninglessTag`

## [0.3.1] - 2023-09-16

Fix config/default.yml

## [0.3.0] - 2023-09-16

- Add `YARD/MismatchName`
    - Check `@param` and `@option` name with method definition

## [0.2.0] - 2023-09-14

- `YARD/TagType`
    - Check collection tag type syntax

## [0.1.0] - 2023-09-13

- Add new `YARD/TagType` cop

- Initial release

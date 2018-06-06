# Changelog
## Unreleased
### 0.2.0
- Add transitions
- Add fie nil types
- Solve security issues

## Released
### 0.1.13
- Improved the reliability of the connection to pools (no more dropouts at page load)
### 0.1.12
- Fixed breaking bug in pools
### 0.1.11
- Fixed bug in tracking hashes
- Three way data binding in form inputs was conflicting with enter fie events. Therefore three way data binding no longer reacts to the enter key.
- Three way data binding persists the data in input forms after 500ms. However a user may fire an event before that when the state has not yet been persisted. Three way data binding now therefore persists the state in the case an event was called before it had a chance to persist.
### 0.1.10
- Improved code quality using CodeFactor
- Added tracking to `delete` and `delete_at` hash and array method
# Changelog

## Unreleased

### 0.5.0

- Add a testing framework

### 0.4.0

- Marginaly improve rendering speed by only re-rendering partials that contain a variable that changed.

## Released

### 0.3.4

- Added support for namespaced controllers such as `Module::FooController`

### 0.3.3

- Fixed bugs in `Fie.executeCommanderMethod`
- `Util.execJS` now accepts function names such as `module.funcName`
- Event `fieReady` will now be triggered once the state is initially loaded.

### 0.3.2

- Added a `connect?` method to the commander to verify if the client is still connected to the commander. Particularly useful in long running processes.

### 0.3.1

- Converted all Opal to ES6
- Reduced JS size to ~50kb down from originally ~600kb

### 0.3.0

- Fixed slow typing causing missed characters
- Fixed inputs blurring on rerender
- Reduced JS size
- Improved performance

### 0.2.3

- Added support for circular dependencies (e.g. Active Records has_many <-> belongs_to)
- Added `executeCommanderMethod` JavaScript function to activate commander methods from JavaScript

### 0.2.2

- Untrack bug caused by inconsistent use of symbols and strings solved

### 0.2.1

- fie now works with ruby versions > 2.4 (fixed encryption bug)

### 0.2.0

- Add fie nil types
- Solve security issues
- Improve pools speed (through lazy broadcast)

### 0.2.0pa

- Improved pools speed (through lazy broadcast)

### 0.1.14

- Solved javascript regexp bug that blocked three-way data binding

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

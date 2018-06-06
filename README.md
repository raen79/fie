# <a href="https://fie.eranpeer.co/" target="_blank"><img src="https://image.ibb.co/c0JaA8/github_fie.jpg" height="200" /></a>

[![Gem Version](https://badge.fury.io/rb/fie.svg)](https://badge.fury.io/rb/fie)
[![Build Status](https://travis-ci.org/raen79/fie.svg?branch=master)](https://travis-ci.org/raen79/fie)
[![CodeFactor](https://www.codefactor.io/repository/github/raen79/fie/badge)](https://www.codefactor.io/repository/github/raen79/fie)
[![Join the chat at https://gitter.im/rails-fie/Lobby](https://badges.gitter.im/rails-fie/Lobby.svg)](https://gitter.im/rails-fie/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Beerpay](https://beerpay.io/raen79/fie/badge.svg?style=beer-square)](https://beerpay.io/raen79/fie)

### Fie is a Rails-centric frontend framework running over a permanent WebSocket connection.

fie is a framework for Ruby on Rails that shares the state of your views with the backend.

For each controller within which you wish to use fie, you must create a commander. fie uses commanders in the same way a Ruby on Rails application uses controllers.

When an instance variable is changed in the commander, the view is updated. Likewise, if the same variable is modified within the view (through a form for example), the change is reflected in the commander and within other instances of the variable in the view. This means that fie supports three-way data binding.

fie therefore replaces traditional Javascript frontend frameworks while requiring you to write less code overall. If you implement fie within your application, you will no longer rely on Javascript for complex tasks, but rather use it only for what it was intended to be used for: to be sprinkled in your views and make them feel more dynamic (through animations for example).

## Installation

1. Add the gem to your gemfile like so:
```ruby
gem 'fie', '~> 0.1.11'
```
2. Run the bundler
```bash
$ bundle install
```
3. Replace yield in your main layout with `render template: 'layouts/fie' %>`. Below is an example.
    * Old:
    ```erb
    <!DOCTYPE html>
    <html>
    <head>
      <title>Fie</title>
      <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
      <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
    </head>

    <body>
      <%= yield %>
    </body>
    </html>
    ```
    * New:
    ```erb
    <!DOCTYPE html>
    <html>
      <head>
        <title>Fie</title>
        <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
        <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
      </head>

      <body>
        <%= render template: 'layouts/fie' %>
      </body>
    </html>
    ```
4. Add `//= require fie` to your `app/assets/application.js` file.
```javascript
//= require rails-ujs
//= require turbolinks
//= require fie
//= require_tree .
```

5. Ensure action cable uses Redis in development by changing async to redis in `config/cable.yml`.
```yaml
redis: &redis
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: fie_example_app_production

development: *redis
test: *redis
production: *redis
```

6. Create an `app/commanders` folder.

7. Restart your application.

8. Create your first commander in the `app/commanders` with the same prefix as one of your controllers. e.g. `app/commanders/hello_world_commander.rb`

```ruby
class HelloWorldCommander < Fie::Commander
end
```

## Hello World

Create a hello world app using our [tutorial](https://fie.eranpeer.co/start#hello-world).

## Usage

Usage is documented and described in our [guide](https://fie.eranpeer.co/guide).

## Development

Your first step is to run `npm install` within the root folder in order to install the relevant node packages. Also run `npm install uglify-js -g`.

The project does not use javascript, but opal. To build the opal project (in `lib/opal`), run `rake build_opal`. If you are actively developing the frontend using opal, run `bundle exec guard` which will start a watcher for the opal source and will recompile in the `vendor/javascript` folder on every change.

To transfer gems and node packages to opal, add `Opal.use_gem(gem_name)` or `Opal.append_path('./node_modules/module_name/dist')` in the Rakefile within the `build_opal` task.

The ruby files can be found within `lib/fie` and their development is the same as in any other gem.

Please add tests if you add new features or resolve bugs.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/raen79/fie. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fie project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/fie/blob/master/CODE_OF_CONDUCT.md). 

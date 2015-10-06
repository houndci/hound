# Haml-rails

Haml-rails provides Haml generators for Rails 4. It also enables Haml as the templating engine for you, so you don't have to screw around in your own application.rb when your Gemfile already clearly indicated what templating engine you have installed. Hurrah.

To use it, add this line to your Gemfile:

    gem "haml-rails", "~> 0.9"

This ensures that:

  * Any time you generate a resource, view, or mailer, you'll get Haml templates (instead of ERB)
  * When your Rails application loads, Haml will be loaded and initialized automatically
  * Haml templates will be respected by the view template cache digestor

Pretty fancy, eh? The modern world is just so amazing.

### Converting Rails application layout file to haml format

Once Haml-rails is installed on the Rails application,
you can convert the erb layout file, `app/views/layouts/application.html.erb`
to `app/views/layouts/application.html.haml` using this command:

    $ rails generate haml:application_layout convert

After the application layout file is converted successfully,
make sure to delete `app/views/layouts/application.html.erb`, so Rails can
start using `app/views/layouts/application.html.haml` instead.

### Converting all .erb views to haml format

If you want to convert all of your .erb views into .haml, you can do so using the following command:

    $ rake haml:erb2haml

If you already have .haml files for one or more of the .erb files, the rake task will give you the option of either
replacing these .haml files or leaving them in place.

Once the task is complete, you will have the option of deleting the original .erb files. Unless you are under
version control, it is recommended that you decline this option.

### Older versions of Rails

The current version of Haml-rails requires 4.0.1 or later.

Haml-rails version 0.4 is the last version to support Rails 3. To use it, add this line to your Gemfile:

    gem "haml-rails", "~> 0.4.0"

### Contributors

Haml generators originally from [rails3-generators](http://github.com/indirect/rails3-generators), and written by José Valim, André Arko, Paul Barry, Anuj Dutta, Louis T, and Chris Rhoden. Tests originally written by Louis T.

### Code Status

[![Build Status](https://travis-ci.org/indirect/haml-rails.png)](https://travis-ci.org/indirect/haml-rails)

### License

Ruby license or MIT license, take your pick.

# Rails Template

This repository contains a rails application [template](https://guides.rubyonrails.org/rails_application_templates.html). This will create and setup a general rails application with React. [Rvm](https://rvm.io/) must be installed to manage the application's gems. The template assumes the `.railsrc` file is present and the flags are used during creation of a new rails application.

## Pre Steps

- Install and configure [rvm](https://rvm.io/) with your desired version of ruby.
- Change terminal directory to the location you will be storing your application.
- Create a gemset on your desired ruby version and set it as current. Spell it the same as you will be spelling the name of your rails application.
  - `$ rvm use <RUBY-VERSION>@<APPNAME> --create`
- Install the rails gem. This is needed when you run `$ rails new ...`
  - `$ gem install rails`

## Usage Steps

1.  Ensure the Pre Steps have been completed and your environment is setup.
2.  Run `rails new` with the template. Use the command that fits your needs

- Using a `.railsrc` file:
  - `$ rails new <APPNAME> -m <THIS TEMPLATE SRC>`
- Not using a `.railsrc` file:
  - `$ rails new <APPNAME> --database=postgresql --skip-test --skip-turbolinks --webpack=react --skip-coffee -m <THIS TEMPLATE SRC>`

3.  Follow the cli input instructions

## Template Gem Additions and Features

- Gems:

  - devise
  - cancancan
  - rolify
  - deployem
  - rabl
  - gon
  - resque
  - font-awesome-rails
  - spire
  - aws-sdk-s3
  - pry
  - rspec-rails
  - factory_bot_rails
  - faker
  - letter_opener
  - dotenv-rails

- Sets up:

  - Postgres Database
  - Removal of unnecessary files

- Optionally sets up:

  - Devise
  - Cancancan
  - Rolify
  - Rspec
  - Mailers (SMTP)
  - Force SSL on production
  - Integration with Spire
  - .env file
  - Initial git comit and push to repository
  - Heroku app (staging and production)
  - ... and more (to be added in future releases)

_Note: If you have any problems running this application using the above steps please submit an issue. If you found your own solution feel free to submit a pull request. Thanks for your help!_

Contributors:

- [Christopher Francis](https://github.com/7chris71000)

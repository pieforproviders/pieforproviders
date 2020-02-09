# README
![CI](https://github.com/pieforproviders/pieforproviders/workflows/CI/badge.svg?branch=develop)

A digital assistant for your child care business.

## Prerequisites

* postgres
* bundler

## Optional

* rvm or another ruby version manager to isolate your dependency installation
* heroku cli

## Architecture

* Backend: Rails
  * **SUPER IMPORTANT** This is configured to use UUIDs for primary keys in the generators: rails/config/initializers/generators.rb
  * Rubocop
  * Data Migrations: https://github.com/ilyakatz/data-migrate
  * RSpec
    * SimpleCov
    * Shoulda Matchers
    * DatabaseCleaner
    * FactoryBot
    * Faker
  * v1 API Routes returning JSON
  * Postgres DB
* Frontend: TBD (probably React)

## Assumptions, Assertions, and Comments

* I decided to go with a monorepo because of previous experience managing multi-repo projects.  If you need to make changes to multiple layers of the application, creating and managing multiple branches on multiple repos is more disruptive than handling merge conflicts, in my experience.  With a monorepo, everything you need to code review a PR is in the same place, and it makes it easier to track changes that impacted multiple layers of the application.

## Get Started

- clone the repo
- `cd pieforproviders/rails`
- copy `.env.sample` to `.env` and add values
- `bundle install`
- `bundle exec rails db:setup`
- `bundle exec rails s` or `heroku local` if you prefer to use the heroku cli

Visit `localhost:3000` to see Rails running. 🥳

## Running tests

`bundle exec rspec` or `bundle exec guard` to watch

## Resources/Further Reading

# README

* [Quickstart for Rails](https://docs.docker.com/compose/rails/)
* [PosgreSQL UUID as primary key in Rails 5.1](https://clearcove.ca/2017/08/postgres-uuid-as-primary-key-in-rails-5-1)
* [Build a RESTful JSON API With Rails 5 - Part One](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-one)
* [Build a RESTful JSON API With Rails 5 - Part Two](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-two)

## Authentication

Authentication heavily based on [API authentication using Devise and Doorkeeper](https://naturaily.com/blog/api-authentication-devise-doorkeeper-setup), with some help from [Doorkeeper Guides - Ruby on Rails](https://doorkeeper.gitbook.io/guides/ruby-on-rails/getting-started), and a dash of [Rails API authentication with Devise and Doorkeeper](https://scotch.io/@jiggs/rails-api-doorkeeper-devise). Also needed to configure [Using PostgreSQL UUIDs as primary keys with Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-PostgreSQL-UUIDs-as-primary-keys-with-Doorkeeper).

We might need [How To Set Up Devise AJAX Authentication With Rails 4.0](https://blog.andrewray.me/how-to-set-up-devise-ajax-authentication-with-rails-4-0/) once we've got a front-end hitting the API.

## TODO

* Friendly IDs so the UUIDs don't get in the way: https://github.com/norman/friendly_id

## Notes

* re: names - full_name with a greeting_name is more culturally inclusive - UX will probably have to make it make sense but not everyone has one first name and one last name
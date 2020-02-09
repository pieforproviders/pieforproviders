# README

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
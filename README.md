# README
![CI](https://github.com/pieforproviders/pieforproviders/workflows/CI/badge.svg?branch=develop)

A digital assistant for your child care business.

## Code of Conduct

Please note we have a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with this project.

## Why Contribute?

We have a vision for equity and justice in the early childhood field. We know that technology is part of the solution - and that today’s products do not meet the needs of most communities. We’re building the market for early childhood technology that educators, families and children deserve. 

We need your help. 

Pie for Providers helps small child care providers and families claim the government funding for which they are already eligible. Today, 85% of eligible children do not claim this funding. This means families struggle to afford care. This means mothers cannot advance their careers and support their families. This means child care providers - small, women-owned businesses - do not get paid for their work. 

Let’s change that. [Contribute to Pie for Providers today](CONTRIBUTING.md) by picking up any of our [open issues](https://github.com/pieforproviders/pieforproviders/issues?q=is%3Aopen+is%3Aissue+label%3A%22ready+for+work%22).

Learn more at [www.pieforproviders.com](http://www.pieforproviders.com)

<details>
  <summary>Architecture</summary>

* ERD/Database Planning Diagram: [https://dbdiagram.io/d/5e1a354f94d9ab14375a1f91](https://dbdiagram.io/d/5e1a354f94d9ab14375a1f91)

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
* Frontend: React
  * ESLint/Prettier
  * Jest/Enzyme
  * Husky for pre-commit hooks
</details>

<details>
  <summary>Assumptions, Assertions, and Comments</summary>
  
  * I decided to go with a monorepo because of previous experience managing multi-repo projects.  If you need to make changes to multiple layers of the application, creating and managing multiple branches on multiple repos is more disruptive than handling merge conflicts, in my experience.  With a monorepo, everything you need to code review a PR is in the same place, and it makes it easier to track changes that impacted multiple layers of the application.
</details>

## Prerequisites

* `postgres`
* `bundler`
* `XCode Select` tools if you're on Mac

## Optional

* `rvm` or another ruby version manager to isolate your dependency installation
* `heroku cli`

## Get Started

- clone the repo
- `cd pieforproviders/rails`
- copy `.env.sample` to `.env` and add values (contact a repo contributor)
- `gem install bundler`
- `bundle install`
- `bundle exec rails db:setup`
- `npm install yarn -g`
- `cd client`
- `yarn install`
- `cd ../`
- `bundle exec rails s` or `heroku local -f Procfile.dev` if you prefer to use the heroku cli

Visit `localhost:3000` to see the React frontend. 🥳

## Running tests

`bundle exec rspec` or `bundle exec guard` to watch

## Resources/Further Reading

* [Quickstart for Rails](https://docs.docker.com/compose/rails/)
* [PosgreSQL UUID as primary key in Rails 5.1](https://clearcove.ca/2017/08/postgres-uuid-as-primary-key-in-rails-5-1)
* [Build a RESTful JSON API With Rails 5 - Part One](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-one)
* [Build a RESTful JSON API With Rails 5 - Part Two](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-two)

## TODO

* Friendly IDs so the UUIDs don't get in the way: https://github.com/norman/friendly_id

## Notes

* re: names - full_name with a greeting_name is more culturally inclusive - UX will probably have to make it make sense but not everyone has one first name and one last name

## Troubleshooting

If you get the following error:

```
gyp: No Xcode or CLT version detected!
```

try removing and reinstalling XCode command line tools OR running `xcode-select --reset` (see [this github issue](https://github.com/schnerd/d3-scale-cluster/issues/7) for more info)
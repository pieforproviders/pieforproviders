# README
![CI](https://github.com/pieforproviders/pieforproviders/workflows/CI/badge.svg?branch=develop)

We help child care providers and families claim the government funding for which they are already eligible. 

## Code of Conduct

Please note we have a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with this project.

## Why Contribute?

We have a vision for equity and justice in the early childhood field. We know that technology is part of the solution - and that today’s products do not meet the needs of most communities. We’re building the market for early childhood technology that educators, families and children deserve. 

We need your help. 

Pie for Providers helps small child care providers and families claim the government funding for which they are already eligible. Today, 85% of eligible children do not claim this funding. This means families struggle to afford care. This means mothers cannot advance their careers and support their families. This means child care providers - small, women-owned businesses - do not get paid for their work. 

Let’s change that. [Contribute to Pie for Providers today](CONTRIBUTING.md) by picking up any of our [open issues](https://github.com/pieforproviders/pieforproviders/issues?q=is%3Aopen+is%3Aissue+label%3A%22ready+for+work%22+sort%3Aupdated-desc+no%3Aassignee).

Learn more at [www.pieforproviders.com](http://www.pieforproviders.com)

<details>
  <summary>Architecture</summary>

* ERD/Database Planning Diagram: [https://dbdiagram.io/d/5e83dbfd4495b02c3b8910b4](https://dbdiagram.io/d/5e83dbfd4495b02c3b8910b4)

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

## Getting Started

- clone the repo
- `cd pieforproviders`
- Run `cp .env.sample .env` and `cp client/.env.development.sample cp client/.env.development` and add values (contact a repo contributor)
- Run  (contact a repo contributor)
- install bundler for gems: `gem install bundler`
- install gems: `bundle install`
- set up the database: `bundle exec rails db:setup`
- install yarn globally if you don't have it yet: `npm install yarn -g`
- `cd client`
- install front-end packages: `yarn install`
- `cd ../`

## Running the app locally
You have several convenient options for running the app locally.

1. Rake task
  - Install [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)
  - `rails start`

2. Foreman
  - Install [foreman](https://github.com/ddollar/foreman) -- `gem install foreman`
  - Run `foreman start`

3. Without Foreman or Heroku
  - Start rails in one terminal: `rails s -p 3001`
  - Open a second terminal and start react: `cd client && yarn start`

Visit `localhost:3000` to see the React frontend. 🥳

Visit `localhost:3001/api-docs` to see Swagger UI for API endpoints 📑

## Running tests

- `bundle exec rspec` or `bundle exec guard` to watch
- When tests pass and you're ready for a PR, please run `rails rswag` to update the API documentation

## Adding/Updating Models

Please make sure you write specs that include JSON validation of the request output for schema (see [spec/support/api/schemas/user.json](spec/support/api/schemas/user.json))

## Adding/Updating API Controllers

Update the controller actions in [spec/swagger_helper.rb](spec/swagger_helper.rb) to include your controller actions

## Resources/Further Reading

* [Quickstart for Rails](https://docs.docker.com/compose/rails/)
* [PosgreSQL UUID as primary key in Rails 5.1](https://clearcove.ca/2017/08/postgres-uuid-as-primary-key-in-rails-5-1)
* [Build a RESTful JSON API With Rails 5 - Part One](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-one)
* [Build a RESTful JSON API With Rails 5 - Part Two](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-two)

## TODO

* Friendly IDs so the UUIDs don't get in the way: https://github.com/norman/friendly_id

## Notes

* re: names - `full_name` with a `greeting_name` is more culturally inclusive - UX will probably have to make it make sense but not everyone has one first name and one last name

## Troubleshooting

If you get the following error:

```
gyp: No Xcode or CLT version detected!
```

try removing and reinstalling XCode command line tools OR running `xcode-select --reset` (see [this github issue](https://github.com/schnerd/d3-scale-cluster/issues/7) for more info)

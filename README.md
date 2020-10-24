# README

[![CI](https://github.com/pieforproviders/pieforproviders/workflows/CI/badge.svg?branch=develop)](https://github.com/pieforproviders/pieforproviders/actions?query=branch%3Adevelop)

We help child care providers and families claim the government funding for which they are already eligible.

## Code of Conduct

Please note we have a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with this project.

## Why Contribute?

We have a vision for equity and justice in the early childhood field. We know that technology is part of the solution - and that today’s products do not meet the needs of most communities. We’re building the market for early childhood technology that educators, families and children deserve.

We need your help!

Pie for Providers helps small child care providers and families claim the government funding for which they are already eligible. Today, 85% of eligible children do not claim this funding. This means families struggle to afford care. This means mothers cannot advance their careers and support their families. This means child care providers - small, women-owned businesses - do not get paid for their work.

Let’s change that. [Contribute to Pie for Providers today](CONTRIBUTING.md) by picking up any of our [open issues](https://bit.ly/PieIssues).

Learn more at [www.pieforproviders.com](http://www.pieforproviders.com)

## Important URLs

- Staging: [https://pie-staging.herokuapp.com/](https://pie-staging.herokuapp.com/)  

<br />

<details>
  <summary>Architecture</summary>

---

- [ERD/Database Planning Diagram](docs/dbdiagram.pdf)

- Backend: Rails
  - **SUPER IMPORTANT** This is configured to use UUIDs for primary keys in the generators: rails/config/initializers/generators.rb
  - Rubocop
  - Data Migrations: https://github.com/ilyakatz/data-migrate
  - RSpec
    - SimpleCov
    - Shoulda Matchers
    - DatabaseCleaner
    - FactoryBot
    - Faker
    - RSwag
  - v1 API Routes returning JSON
  - Postgres DB
  - API Documentation with swagger
- Frontend: React
  - ESLint/Prettier
  - Jest/React Testing Library
  - Husky for pre-commit hooks
  
</details>  

---

<details>
  <summary>Prerequisites</summary>

---

### Required

- `postgres` v12.3
- `bundler`
- `git`
- `graphviz` - [https://graphviz.org/download/](https://graphviz.org/download/)
- `XCode Select` tools if you're on Mac

##@ Optional

- `heroku cli`
- `foreman`

</details>  

---

<details>
  <summary>Setup and configuration</summary>

---

- clone the repo: `git clone git@github.com:pieforproviders/pieforproviders.git`
- navigate to the app directory: `cd pieforproviders`
- install bundler for gems: `gem install bundler`
- install gems: `bundle install`
- set up an environment file: copy `.env.sample` to `.env`
- configure Devise: run `rails secret` to generate a secret string, add it to `.env` as the `DEVISE_JWT_SECRET_KEY` value
- create and seed the database: `bundle exec rails db:setup`
- install yarn globally if you don't have it yet: `npm install yarn -g`
- navigate to the frontend directory: `cd client`
- install front-end and end-to-end packages: `yarn install`

</details>  

---

<details>
  <summary>Running the app locally</summary>

---
You have several convenient options for running the app locally.

### 1. Rake task (requires `heroku cli`)

- `rails start`
- This spins up both the front end and the back end in the same terminal window

### 2. Foreman (requires `foreman`)

- Run `foreman start`
- This spins up both the front end and the back end in the same terminal windo

### 3. Without Foreman or Heroku

- Start rails in one terminal: `rails s -p 3001`
- Open a second terminal and start react: `cd client && yarn start`

Visit `localhost:3000` to see the React frontend. 🥳

Visit `localhost:3001/api-docs` to see Swagger UI for API endpoints 📑  
  
> ***NOTE:*** Swagger UI is currently not configured to use authentication, so any authenticated endpoints will not be accessible at this route, you'll get unauthorized errors.
</details>  

---

<details>
  <summary>Using the application</summary>

---

You can create a new user account by visiting `/signup` (or clicking "Sign Up" on the login page at the root).

When you create a new account, you should see a demo email pop up in a new tab; **the link in this URL can't be clicked in local development**.  Instead, copy the path (starting with `localhost`) and paste it into a browser window.  This will confirm your user and automatically log you in.
</details>  

---

<details>
  <summary>Running tests</summary>

---

### API

- `bundle exec rspec` or `bundle exec guard` to watch
- When tests pass and you're ready for a PR, please run `rails rswag` to update the API documentation

### Frontend

- `yarn test` (auto-watch) or `yarn test-once` to run the suite one time only

### End to End

- `yarn run cy:ci` from the root directory

### Interactive End to End

- `yarn start-server` in one terminal (make sure rails is not currently running)
- `yarn run cy:open` in another terminal
</details>  

---

<details>
  <summary>Development guidelines</summary>

---

There's a helper rake task that runs all test suites and linting steps, and generates the swagger documentation; use `rails prep` to run this command.

### Adding/Updating Models

Please make sure you write specs that include JSON validation of the request output for schema (see [spec/support/api/schemas/user.json](spec/support/api/schemas/user.json))

### Adding/Updating API Controllers

Update the controller actions in [spec/swagger_helper.rb](spec/swagger_helper.rb) to include your controller actions

### Data Model

The data model is documented in `pie_erd.pdf` - `docs/dbdiagram.dbml` and `docs/dbdiagram.pdf` are deprecated
</details>  

---

<details>
  <summary>Troubleshooting and common problems</summary>

---

### Rails Devise Secret

I keep getting redirected to the login screen when after I've created and confirmed my account

### Postgres

Sometimes Postgres doesn't play nice depending on how you've installed it.  If you're having trouble with Postgres, I strongly recommend `Postgres.app` - you can install multiple versions and it plays nicer with rails.

### XCode

If you get the following error:

```
gyp: No Xcode or CLT version detected!
```

try removing and reinstalling XCode command line tools OR running `xcode-select --reset` (see [this github issue](https://github.com/schnerd/d3-scale-cluster/issues/7) for more info)
</details>  

---

<details>
  <summary>Resources and further reading</summary>

---

- [Quickstart for Rails](https://docs.docker.com/compose/rails/)
- [PosgreSQL UUID as primary key in Rails 5.1](https://clearcove.ca/2017/08/postgres-uuid-as-primary-key-in-rails-5-1)
- [Build a RESTful JSON API With Rails 5 - Part One](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-one)
- [Build a RESTful JSON API With Rails 5 - Part Two](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-two)
</details>  
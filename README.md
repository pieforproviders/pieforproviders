# README
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-2-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

[![CI](https://github.com/pieforproviders/pieforproviders/workflows/CI/badge.svg?branch=develop)](https://github.com/pieforproviders/pieforproviders/actions?query=branch%3Adevelop)

We help child care providers and families claim the government funding for which they are already eligible.

## Code of Conduct

Please note we have a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with this project.

## Why You Should Contribute

We have a vision for equity and justice in the early childhood field. We know that technology is part of the solution - and that today’s products do not meet the needs of most communities. We’re building the market for early childhood technology that educators, families and children deserve.

We need your help!

Pie for Providers helps small child care providers and families claim the government funding for which they are already eligible. Today, 85% of eligible children do not claim this funding. This means families struggle to afford care. This means mothers cannot advance their careers and support their families. This means child care providers - small, women-owned businesses - do not get paid for their work.

Let’s change that. [Contribute to Pie for Providers today](CONTRIBUTING.md) by picking up any of our [help-wanted issues](http://bit.ly/PieHelpWanted).

Learn more at [www.pieforproviders.com](http://www.pieforproviders.com)

## Important URLs

- Staging: [https://pie-staging.herokuapp.com/](https://pie-staging.herokuapp.com/)  

<br />

---

<details>
  <summary>Architecture</summary>

---

- [ERD/Database Planning Diagram](docs/dbdiagram.pdf)

- Backend: Rails
  - **SUPER IMPORTANT** This is configured to use UUIDs for primary keys in the generators: rails/config/initializers/generators.rb
  - Rubocop
  - Data Migrations: [https://github.com/ilyakatz/data-migrate](https://github.com/ilyakatz/data-migrate)
  - RSpec
    - SimpleCov
    - Shoulda Matchers
    - DatabaseCleaner
    - FactoryBot
    - Faker
  - v1 API Routes returning JSON
  - Postgres DB
- Frontend: React
  - ESLint/Prettier
  - Jest/React Testing Library
  - Husky for pre-commit hooks
  
</details>  

---

<details>
  <summary>Docker Setup</summary>

### Prerequisites
Docker should be installed on your local machine.

### Procedure
* Use the "git clone" command to download this repository.
* Use the "cd" command to enter the root directory of this repository.
* Enter the command "docker/build".  You will be asked to enter database parameters.  The docker/build script automatically sets up the app, runs the test suite, seeds the database, draws the block diagram, runs quality checks of this code base, and logs the screen output.
* After the build process is complete, enter the command "docker/server" to start the Rails server.
* Start a second terminal tab for entering additional commands.

### URLs
* App: http://localhost:3000
* MailCatcher: http://localhost:1080

### Database Parameters
* Host: localhost
* Port number: 15432
* Database: pie_development
* Username and password: specified in .docker-env/development/database

### Other Important Scripts
* Enter the command "docker/git_check" before "git add" and "git commit".  This runs the tests, Rubocop, and Brakeman.  The docker/git_check script is a sanity check to allow you to make sure to commit quality working code only.
* Enter the command "docker/qserver" for the quick version of "docker/server".  Note that the "docker/qserver" script does not log the screen output, does not remove tmp/pids/server.pid, skips "docker-compose down", skips "bundle install", and skips the database migration.
* Enter "docker/nuke" to destroy the Docker image, container, and networks.
* Enter "docker/nukec" to destroy the Docker container but leave the base images in place.

</details>

---

<details>
  <summary>Non-Docker Setup</summary>

---
**for local development, we strongly recommend you use version managers to handle your dependencies, such as `rvm` for ruby and `nvm` for javascript** 

### Prerequisites

- `postgres` v12.3
- `bundler`
- `git`
- `yarn`
- `graphviz` - [https://graphviz.org/download/](https://graphviz.org/download/)
- `XCode Select` tools if you're on Mac

### Optional

- `heroku cli` - [https://devcenter.heroku.com/articles/heroku-cli#download-and-install](https://devcenter.heroku.com/articles/heroku-cli#download-and-install)
- `foreman`
- `rvm`
- `nvm`

### Procedure

- clone the repo: `git clone git@github.com:pieforproviders/pieforproviders.git`
- navigate to the app directory: `cd pieforproviders`
- install bundler for gems: `gem install bundler`
- install gems: `bundle install`
- set up an environment file: copy `.env.sample` to `.env`
- configure Devise: run `rails secret` to generate a secret string, add it to `.env` as the `DEVISE_JWT_SECRET_KEY` value
- create and seed the database: `bundle exec rails db:setup`
- install front-end and end-to-end packages: `yarn install-all`

### Running Locally

You have several convenient options for running the app locally.

1. Rake task (requires `heroku cli`)
    - `rails start`
    - This spins up both the front end and the back end in the same terminal window
2. Foreman (requires `foreman`)
    - Run `foreman start`
    - This spins up both the front end and the back end in the same terminal window
3. Without Foreman or Heroku
    - Start rails in one terminal: `rails s -p 3001`
    - Open a second terminal and start react: `cd client && yarn start`

Visit `localhost:3000` to see the React frontend. 🥳
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

See [CONTRIBUTING.md](CONTRIBUTING.md)
</details>  

---

<details>
  <summary>Troubleshooting and FAQs</summary>

---

### Login Issues

**Q: I keep getting redirected to the login screen when after I've created and confirmed my account**  
**A:** Make sure you've created a secret for `DEVISE_JWT_SECRET_KEY` in `.env` using `rails secret`

### Postgres

**Q: I get postgres errors when I try to set up the database**  
**A:** Make sure Postgres is running on port 5432. Sometimes Postgres doesn't play nice depending on how you've installed it.  If you're having trouble with Postgres, I strongly recommend `Postgres.app` - you can install multiple versions and it plays nicer with rails.  

### XCode

**Q: I see the following error in my terminal: `gyp: No Xcode or CLT version detected!`**  
**A:** try removing and reinstalling XCode command line tools OR running `xcode-select --reset` (see [this github issue](https://github.com/schnerd/d3-scale-cluster/issues/7) for more info)
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

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/arku"><img src="https://avatars.githubusercontent.com/u/7039523?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Arun Kumar Mohan</b></sub></a><br /><a href="#infra-arku" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=arku" title="Tests">⚠️</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=arku" title="Documentation">📖</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=arku" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/nemiasalc56"><img src="https://avatars.githubusercontent.com/u/57147732?v=4?s=100" width="100px;" alt=""/><br /><sub><b>nemiasalc56</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=nemiasalc56" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/jontrainor"><img src="https://avatars.githubusercontent.com/u/1022615?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jon Trainor</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=jontrainor" title="Code">💻</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=jontrainor" title="Documentation">📖</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=jontrainor" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/rahman-aj"><img src="https://avatars.githubusercontent.com/u/59799545?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Rahman</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=rahman-aj" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
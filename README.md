[![CI](https://github.com/pieforproviders/pieforproviders/workflows/CI/badge.svg?branch=develop)](https://github.com/pieforproviders/pieforproviders/actions?query=branch%3Adevelop) [![Maintainability](https://api.codeclimate.com/v1/badges/593c088e5aa9ac0913a1/maintainability)](https://codeclimate.com/github/pieforproviders/pieforproviders/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/593c088e5aa9ac0913a1/test_coverage)](https://codeclimate.com/github/pieforproviders/pieforproviders/test_coverage)

[![CI](https://static.hotjar.com/b/hotjar-badge-light.png "Hotjar - Unlimited insights from your web and mobile sites")](//www.hotjar.com/?utm_source=badge) 

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-24-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->


We help child care providers and families claim the government funding for which they are already eligible.

## Code of Conduct

Please note we have a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with this project.

## Why You Should Contribute

We have a vision for equity and justice in the early childhood field. We know that technology is part of the solution - and that today’s products do not meet the needs of most communities in this field. We’re building the market for early childhood technology that educators, families and children deserve.

We need your help!

Pie for Providers helps small child care providers and families claim the government funding for which they are already eligible. Today, 85% of eligible children do not claim this funding. This means families struggle to afford care. This means mothers cannot advance their careers and support their families. This means child care providers - small, women-owned businesses - do not get paid for their work.

Let’s change that. [Contribute to Pie for Providers today](CONTRIBUTING.md) by picking up any of our [help-wanted issues](http://bit.ly/PieHelpWanted).

Learn more at [www.pieforproviders.com](http://www.pieforproviders.com)

## Important URLs

- Staging: [https://staging.pieforproviders.com/](https://staging.pieforproviders.com/)  

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
  
</details>

---

<details>
  <summary>Local Setup (Option One: Direct Install)</summary>

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

### Running the App

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
  <summary>Local Setup (Option Two: Docker)</summary>
  
We also have a dockerized setup if you prefer to develop that way.

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
* Enter the command "docker/git_check" before "git add" and "git commit".  This runs the tests, Rubocop, and Brakeman.  The docker/git_check script is a sense check to allow you to make sure to commit quality working code only.
* Enter the command "docker/qserver" for the quick version of "docker/server".  Note that the "docker/qserver" script does not log the screen output, does not remove tmp/pids/server.pid, skips "docker-compose down", skips "bundle install", and skips the database migration.
* Enter "docker/nuke" to destroy the Docker image, container, and networks.
* Enter "docker/nukec" to destroy the Docker container but leave the base images in place.

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
    <td align="center"><a href="https://github.com/jessehall3"><img src="https://avatars.githubusercontent.com/u/5696388?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jesse</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=jessehall3" title="Code">💻</a></td>
    <td align="center"><a href="https://www.linkedin.com/in/nora-harris/"><img src="https://avatars.githubusercontent.com/u/31748798?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nora Harris</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=noragharris" title="Code">💻</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=noragharris" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/sassygrody"><img src="https://avatars.githubusercontent.com/u/6587024?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Sasha</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=sassygrody" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/cyranix"><img src="https://avatars.githubusercontent.com/u/161077?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Andrew Harrison</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=cyranix" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/weedySeaDragon"><img src="https://avatars.githubusercontent.com/u/673794?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ashley Engelund</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=weedySeaDragon" title="Code">💻</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=weedySeaDragon" title="Documentation">📖</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=weedySeaDragon" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/carolinekinnen"><img src="https://avatars.githubusercontent.com/u/41166358?v=4?s=100" width="100px;" alt=""/><br /><sub><b>carolinekinnen</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=carolinekinnen" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/Jess-White"><img src="https://avatars.githubusercontent.com/u/58121322?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jess-White</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=Jess-White" title="Documentation">📖</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=Jess-White" title="Code">💻</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=Jess-White" title="Tests">⚠️</a></td>
    <td align="center"><a href="http://huntermarcks.net"><img src="https://avatars.githubusercontent.com/u/6887982?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Hunter Marcks</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=hmarcks" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/rebeldroid12"><img src="https://avatars.githubusercontent.com/u/5873894?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Loren</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=rebeldroid12" title="Code">💻</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=rebeldroid12" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/nneka-nu"><img src="https://avatars.githubusercontent.com/u/13953987?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nneka Udoh</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=nneka-nu" title="Code">💻</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=nneka-nu" title="Tests">⚠️</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/wittejm"><img src="https://avatars.githubusercontent.com/u/2104990?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jordan Witte</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=wittejm" title="Code">💻</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=wittejm" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/cjhaddad"><img src="https://avatars.githubusercontent.com/u/4565578?v=4?s=100" width="100px;" alt=""/><br /><sub><b>cjhaddad</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=cjhaddad" title="Documentation">📖</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=cjhaddad" title="Code">💻</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=cjhaddad" title="Tests">⚠️</a></td>
    <td align="center"><a href="http://www.pieforproviders.com"><img src="https://avatars.githubusercontent.com/u/26717304?v=4?s=100" width="100px;" alt=""/><br /><sub><b>csprayregen</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=csprayregen" title="Documentation">📖</a> <a href="#business-csprayregen" title="Business development">💼</a> <a href="#ideas-csprayregen" title="Ideas, Planning, & Feedback">🤔</a> <a href="#projectManagement-csprayregen" title="Project Management">📆</a> <a href="https://github.com/pieforproviders/pieforproviders/pulls?q=is%3Apr+reviewed-by%3Acsprayregen" title="Reviewed Pull Requests">👀</a> <a href="#translation-csprayregen" title="Translation">🌍</a></td>
    <td align="center"><a href="http://www.katelovescode.com"><img src="https://avatars.githubusercontent.com/u/8364647?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Kate Donaldson</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=katelovescode" title="Documentation">📖</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=katelovescode" title="Tests">⚠️</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=katelovescode" title="Code">💻</a> <a href="#projectManagement-katelovescode" title="Project Management">📆</a> <a href="#ideas-katelovescode" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/pieforproviders/pieforproviders/pulls?q=is%3Apr+reviewed-by%3Akatelovescode" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/rebeccakarasiktw"><img src="https://avatars.githubusercontent.com/u/26929739?v=4?s=100" width="100px;" alt=""/><br /><sub><b>rebeccakarasiktw</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=rebeccakarasiktw" title="Documentation">📖</a> <a href="#ideas-rebeccakarasiktw" title="Ideas, Planning, & Feedback">🤔</a> <a href="#userTesting-rebeccakarasiktw" title="User Testing">📓</a> <a href="#design-rebeccakarasiktw" title="Design">🎨</a> <a href="#translation-rebeccakarasiktw" title="Translation">🌍</a> <a href="https://github.com/pieforproviders/pieforproviders/pulls?q=is%3Apr+reviewed-by%3Arebeccakarasiktw" title="Reviewed Pull Requests">👀</a> <a href="#projectManagement-rebeccakarasiktw" title="Project Management">📆</a> <a href="#content-rebeccakarasiktw" title="Content">🖋</a></td>
    <td align="center"><a href="https://github.com/JonErvin"><img src="https://avatars.githubusercontent.com/u/58059331?v=4?s=100" width="100px;" alt=""/><br /><sub><b>JonErvin</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=JonErvin" title="Documentation">📖</a> <a href="#data-JonErvin" title="Data">🔣</a> <a href="https://github.com/pieforproviders/pieforproviders/pulls?q=is%3Apr+reviewed-by%3AJonErvin" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=JonErvin" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/joseluisrangel-dataheim"><img src="https://avatars.githubusercontent.com/u/60363977?v=4?s=100" width="100px;" alt=""/><br /><sub><b>joseluisrangel-dataheim</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=joseluisrangel-dataheim" title="Documentation">📖</a> <a href="#data-joseluisrangel-dataheim" title="Data">🔣</a> <a href="https://github.com/pieforproviders/pieforproviders/pulls?q=is%3Apr+reviewed-by%3Ajoseluisrangel-dataheim" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=joseluisrangel-dataheim" title="Tests">⚠️</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/JTBassett"><img src="https://avatars.githubusercontent.com/u/44791973?v=4?s=100" width="100px;" alt=""/><br /><sub><b>J.T. Bassett</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=JTBassett" title="Documentation">📖</a> <a href="#data-JTBassett" title="Data">🔣</a> <a href="https://github.com/pieforproviders/pieforproviders/pulls?q=is%3Apr+reviewed-by%3AJTBassett" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=JTBassett" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/jacqzwy"><img src="https://avatars.githubusercontent.com/u/25641018?v=4?s=100" width="100px;" alt=""/><br /><sub><b>jacqzwy</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=jacqzwy" title="Documentation">📖</a> <a href="#data-jacqzwy" title="Data">🔣</a> <a href="https://github.com/pieforproviders/pieforproviders/pulls?q=is%3Apr+reviewed-by%3Ajacqzwy" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=jacqzwy" title="Tests">⚠️</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=jacqzwy" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/abbie"><img src="https://avatars.githubusercontent.com/u/7609014?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Abbie</b></sub></a><br /><a href="https://github.com/pieforproviders/pieforproviders/commits?author=Abbie" title="Documentation">📖</a> <a href="#data-Abbie" title="Data">🔣</a> <a href="https://github.com/pieforproviders/pieforproviders/pulls?q=is%3Apr+reviewed-by%3AAbbie" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=Abbie" title="Tests">⚠️</a> <a href="https://github.com/pieforproviders/pieforproviders/commits?author=Abbie" title="Code">💻</a> <a href="#design-Abbie" title="Design">🎨</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
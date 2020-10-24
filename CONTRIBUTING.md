# Contributing to Pie for Providers

Please note we have a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with this project.

Pie for Providers' [open issues](https://github.com/pieforproviders/pieforproviders/projects/3) are on our project board in the To Do column. We'll tag issues that would make a good first pull request for new contributors.

An easy way to get started helping the project is to *file an issue*. You can do that on the Pie for Providers' issues page by clicking on the green button at the right. Issues can include bugs to fix, features to add, or documentation that looks outdated.

Contributions to Pie for Providers should be made in the form of GitHub pull requests. When contributing to this repository with a pull request, please fill out the pull request template as completely as is reasonable. Each pull request will be reviewed by a core contributor (someone with permission to merge) and either merged into `develop` or given feedback for requested changes.

## Workflow

When you're ready to start working on an issue:  

- [ ] visit the [project board](https://github.com/pieforproviders/pieforproviders/projects/3) and pull a ticket from the top of "To Do" into "In Progress"
  - if you can't pull a ticket (due to permissions), comment on the issue that you'd like to work on and @katelovescode will help
  - take the first ticket you are comfortable with, starting from the top
  - if you can't find something in "To Do", check with the admins on Slack
- [ ] Branch from `develop` and, if needed, rebase to the current `develop` branch before submitting your pull request
- [ ] Add tests relevant to the fixed bug or new feature
- [ ] There's a convenience rake task to run all linters, tests, and auto-documenting API routes: `bundle exec rails prep` - if you run this before making a pull request, you can be confident your PR will pass CI
- [ ] when your code is ready, make a pull request to `develop` - we prefer direct PRs rather than from forks, if possible!
- [ ] when you have one approval, the admins will merge, but do not close the ticket itself, we want that open until QA
- [ ] move your ticket to "In QA" on the [project board](https://github.com/pieforproviders/pieforproviders/projects/3); one of our QAs will check it and close the ticket, OR move the ticket back to in progress if there are issues during QA

## Translations

If you're working on any part of the code that needs translation, the Spanish language translation should be in Figma before you start working.  However, if it isn't, our workflow should be:

- make a first pass with [https://www.deepl.com/translator](https://www.deepl.com/translator) or Google Translate
- when you make a PR, tag Chelsea (@csprayregen) and ask her to review **and add the "Needs Spanish" label**
- Chelsea will make suggestions or comment ✅ or "approved" and will remove the label

Also if you notice something that isn't translated (i.e. the English text is hardcoded), make sure to call it out during code review, but I'm sure some stuff has been getting by us, or will in the future, so if you notice something, feel free to grab it as tech debt and make a PR (no ticket required)

## Architecture/Methodology Notes

- We use uuids for the id primary key in API tables
- We use rswag to generate docs, which means the request specs use the rswag DSL
- We validate the JSON response of the API on every endpoint
- A diagram of the db is saved using database markup language in [`/docs/dbdiagram.dbml`](/docs/dbdiagram.dbml) and a PDF version is available at [`/docs/dbdiagram.pdf`](/docs/dbdiagram.pdf).  A live version can be found here: [dbdiagram.io](https://dbdiagram.io/d/5f7b95883a78976d7b767120).  When making changes to the schema, ensure they are also recorded here.

There's a helper rake task that runs all test suites and linting steps, and generates the swagger documentation; use `rails prep` to run this command.

## Adding/Updating Models

Please make sure you write specs that include JSON validation of the request output for schema (see [spec/support/api/schemas/user.json](spec/support/api/schemas/user.json))

## Adding/Updating API Controllers

Update the controller actions in [spec/swagger_helper.rb](spec/swagger_helper.rb) to include your controller actions

## Data Model

The data model is documented in `pie_erd.pdf` - `docs/dbdiagram.dbml` and `docs/dbdiagram.pdf` are deprecated

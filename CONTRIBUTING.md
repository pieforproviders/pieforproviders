# Contributing to Pie for Providers

Please note we have a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with this project.

Pie for Providers' [open issues](https://github.com/pieforproviders/pieforproviders/projects/3) are on our project board in the To Do column. We'll tag issues that would make a good first pull request for new contributors w/ the `good first issue` tag.  The `help-wanted` tag is also a good one to look for.

One way to get started helping the project is to *file an issue*. You can do that on the Pie for Providers' issues page by clicking on the green button at the right. Issues can include bugs to fix, features to add, or documentation that looks outdated.  Our goal is to build an open and accessible API (with authentication and authorization protocols), as well as our front-end UI (see `/client`).  If you see any way to help these goals that that we haven't flagged ourselves, please feel free to create an issue.

Contributions to Pie for Providers should be made in the form of GitHub pull requests. When contributing to this repository with a pull request, please fill out the pull request template as completely as is reasonable. Each pull request will be reviewed by a core contributor (someone with permission to merge) and either merged into `main` or given feedback for requested changes.

## Workflow

When you're ready to start working on an issue:  

- [ ] visit the [project board](https://github.com/pieforproviders/pieforproviders/projects/3) and pull a ticket from the top of "To Do" into "In Progress"
  - if you can't pull a ticket (due to permissions), comment on the issue that you'd like to work on and @katelovescode will help
  - take the first ticket you are comfortable with, starting from the top
  - if you can't find something in "To Do", check with the admins on Slack
- [ ] Branch from `main` and, if needed, rebase to the current `main` branch before submitting your pull request
- [ ] Add tests relevant to the fixed bug or new feature
- [ ] There's a convenience rake task to run all linters and tests and regenerating the Entity-Relationship Diagram if anything has changed: `bundle exec rails prep` - if you run this before making a pull request, you can be confident your PR will pass CI and that your table documentation is up to date
- [ ] when your code is ready, make a pull request to `main` - we prefer direct PRs rather than from forks, if possible!
- [ ] when you have one approval, one of the admins will merge and the ticket will be moved to "In QA" automatically
- [ ] one of our QAs will check it and move the ticket to "Approved", OR move the ticket back to "in progress" and comment/tag you if there are issues during QA

## Translations

If you're working on any part of the code that needs translation, the Spanish language translation should be in Figma before you start working.  However, if it isn't, our workflow should be:

- make a first pass with [https://www.deepl.com/translator](https://www.deepl.com/translator) or Google Translate
- when you make a PR, tag Chelsea (@csprayregen) and ask her to review **and add the "Needs Spanish" label**
- Chelsea will make suggestions or comment ✅ or "approved" and will remove the label

Also if you notice something that isn't translated (i.e. the English text is hardcoded), make sure to call it out during code review, but I'm sure some stuff has been getting by us, or will in the future, so if you notice something, feel free to grab it as tech debt and make a PR (no ticket required)

## Architecture/Methodology Notes

- We use uuids for the id primary key in API tables
- We validate the JSON response of the API on every endpoint

## Adding/Updating Models

Please make sure you write specs that include JSON validation of the request output for schema (see [spec/support/api/schemas/user.json](spec/support/api/schemas/user.json))

## Data Model

The data model is documented in `pie_erd.pdf` - `docs/dbdiagram.dbml` and `docs/dbdiagram.pdf` are deprecated

# Contributing

Please note we have a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with this project.

Pie for Providers' [open issues are here](https://github.com/pieforproviders/pieforproviders/issues?q=is%3Aopen+is%3Aissue+label%3A%22ready+for+work%22). We'll tag issues that would make a good first pull request for new contributors.

An easy way to get started helping the project is to *file an issue*. You can do that on the Pie for Providers' issues page by clicking on the green button at the right. Issues can include bugs to fix, features to add, or documentation that looks outdated.

Contributions to Pie for Providers should be made in the form of GitHub pull requests. When contributing to this repository with a pull request, please fill the pull request template out as completely as is reasonable. Each pull request will be reviewed by a core contributor (someone with permission to merge) and either merged into `develop` or given feedback for requested changes.

## Workflow

When you start working on an issue:  
[ ] assign the ticket to yourself  
[ ] visit the [project board](https://github.com/pieforproviders/pieforproviders/projects/1) and pull the ticket into "In Progress"  

## Translations

If you're working on any part of the code that needs translation (basically anything with display text), our workflow should be:

- make a first pass with [https://www.deepl.com/translator](https://www.deepl.com/translator) or Google Translate
- when you make a PR, tag Chelsea (@csprayregen) and ask her to review **and add the "translations" label**
- Chelsea will make suggestions or comment ✅ or "approved" and will remove the translations label

PRs with translation won't be merged until the suggestions have been merged and the translations label has been removed.

Also if you notice something that isn't translated (i.e. the English text is hardcoded), make sure to call it out during code review, but I'm sure some stuff has been getting by us, or will in the future, so if you notice something, feel free to grab it as tech debt and make a PR (no ticket required)

## Pull Request Checklist

[ ] Branch from the develop branch and, if needed, rebase to the current develop branch before submitting your pull request. If it doesn't merge cleanly with develop you may be asked to rebase your changes  
[ ] Commits should be as small as possible, while ensuring that each commit is correct independently (i.e., each commit should pass tests and linters)  
[ ] When updating dependencies, please explain _why_ the update is necessary  
[ ] If your PR is not getting reviewed or you need a specific person to review it, you can @-tag a reviewer asking for a review in the pull request or a comment  
[ ] Add tests relevant to the fixed bug or new feature  
[ ] Run rubocop on your branch; failed builds will not be merged  

## Architecture/Methodology Notes

* We use uuids for the id primary key in API tables
* We use rswag to generate docs, which means the request specs use the rswag DSL
* We validate the JSON response of the API on every endpoint
* A diagram of the db is saved using database markup language in [`/docs/dbdiagram.dbml`](/docs/dbdiagram.dbml) and a PDF version is available at [`/docs/dbdiagram.pdf`](/docs/dbdiagram.pdf).  A live version can be found here: [dbdiagram.io](https://dbdiagram.io/d/5f22e9597543d301bf5d5480).  When making changes to the schema, ensure they are also recorded here.

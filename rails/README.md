# README

* [Quickstart for Rails](https://docs.docker.com/compose/rails/)
* [9 Steps for Dockerizing a Rails API-Only Application](https://medium.com/@nirmalyaghosh/9-steps-for-dockerizing-a-rails-api-only-application-d65a8836f3df)
* [Cache Rails gems using docker-compose](https://dev.to/k_penguin_sato/cache-rails-gems-using-docker-compose-3o3f)
* <del>[Creating staging and other environments in Rails](http://nts.strzibny.name/creating-staging-environments-in-rails/)</del> - decided against using this method to keep staging as close to prod as possible
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
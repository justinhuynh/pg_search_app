# Simple Enhanced Searching with pg_search

Postgres has powerful, [built-in fulltext search](http://www.postgresql.org/docs/9.5/static/textsearch.html) capabilities. But rather than manually constructing extensive SQL queries, we can rely on the [`pg_search` gem](https://github.com/Casecommons/pg_search/blob/master/README.md) to handle this for us.

### Steps (to be updated)

1. Add `gem 'pg_search'` to your `Gemfile`
2. Add `include PgSearch` and method to your model
3. Add search form that sends a query to controller path (this will come in as a query string on the url - much like Google)

- Adding ActiveRecord scopes to your model is like creating a class method for your model, but one that is capable of handling the `nil` case [more here](http://aspiringwebdev.com/use-activerecord-scopes-not-class-methods-in-rails-to-avoid-errors/)
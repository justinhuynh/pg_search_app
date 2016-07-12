# Simple Enhanced Searching with pg_search

Postgres has powerful, [built-in fulltext search](http://www.postgresql.org/docs/9.5/static/textsearch.html) capabilities. But rather than manually constructing extensive SQL queries, we can rely on the [`pg_search` gem](https://github.com/Casecommons/pg_search/blob/master/README.md) to handle this for us.

### Steps

1. Add `gem 'pg_search'` to your `Gemfile`
2. `bundle`
3. Add `include PgSearch` to your model
4. Add a `pg_search_scope` to your model   
`pg_search_scope :search_article_only, against: [:title, :body]`

5. Add an ActiveRecord `scope` that accepts a `query` argument and executes the scope you defined. We need our search functionality to return matching results if there is a query - and ALL results if there is no query.
Adding ActiveRecord scopes to your model is like creating a class method for your model, but one that is capable of handling the `nil` case. Scopes also return all results when there are no matches (which is what we expect for search/filters) [more here](http://aspiringwebdev.com/use-activerecord-scopes-not-class-methods-in-rails-to-avoid-errors/)
```rb
# models/article.rb
scope :search, -> (query) { search_article_only(query) if query.present? }
```
We would call this with:
```ruby
Article.search("blah")
```
6. Add search form that sends a query to controller path (this will come in as a query string on the url - much like Google)
```rb
# views/articles/_search.html.erb
<h3>Search</h3>
<p>
  <%= form_tag articles_path, method: :get do %>
    <%= label_tag :query, "Keywords" %>
    <%= text_field_tag :query %>
    <%= submit_tag "Search" %>
  <% end %>
</p>
```
The reason we use a GET request is that we're trying to access a list of articles - and we're just sending a filter query along. So we essentially want `articles#index`, but filtered.

7. Finally, add a method to your controller (`articles#index`) that implements this method:

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  def index
    # return article based on search methods defined on model
    @articles = Article.search(params[:query])
    @article = Article.new
  end
```

### Adding Global Multisearch

```sh
rails g pg_search:migration:multisearch
rake db:migrate
```

Then add the following to your models after `include PgSearch` (note that `:title` and `:body` would represent columns on the specific model - in this case, `Article`)

`multisearchable against: [:title, :body]`

To rebuild/re-index, go into `rails c` and run the following:
(if `Comment` is the model we are trying to re-index)

`PgSearch::Multisearch.rebuild(Comment)`

PgSearch offers a Rake task, but this is not always effective.

We can then add another `pg_search_scope` that uses the option `associated_against` and passes in an object that specifies the associated model and the columns of that associated model.

```ruby
# models/article.rb
class Article < ActiveRecord::Base
  include PgSearch

  has_many :comments

  # ... more code ...

  pg_search_scope :search_article_and_comments,
    against: [:title, :body],
    associated_against: {
      comments: [:body]
    }
```

Note that our `Article` model `has_many :comments`, so we need to specify `comments:` - rather than `comment:`

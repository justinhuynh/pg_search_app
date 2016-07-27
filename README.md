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

### More On Global Multisearch

##### What if you want to search across many **non-associated** models?

Let's say that `Article` and `Comment` were not in fact associated.

First, set up `multisearchable against: [:column1, :column2]` in each model, with `column1` and `column2` corresponding to the columns in each model that you want to be indexed

We have two options:
1) Do a global search and return an **array** (not an `ActiveRecord::Relation`!) of all matching objects, regardless of type (model)

```ruby
query = "cool"

results = PgSearch.multisearch("keffiyeh")

=> [ ...
#<PgSearch::Document:0x007feb6c16b660
 id: 101,
 content: "hedgehog dog pop-up chillwave selvage cleanse keffiyeh Blue bottle selvage art party messenger bag.",
 searchable_id: 101,
 searchable_type: "Article",
 created_at: Sun, 10 Jul 2016 22:41:47 UTC +00:00,
 updated_at: Sun, 10 Jul 2016 22:41:47 UTC +00:00>,
#<PgSearch::Document:0x007feb6c16b520
 id: 901,
 content: "keffiyeh",
 searchable_id: 400,
 searchable_type: "Comment",
 created_at: Wed, 27 Jul 2016 20:39:26 UTC +00:00,
 updated_at: Wed, 27 Jul 2016 20:40:33 UTC +00:00>]

results.class
# => PgSearch::Document::ActiveRecord_Relation
```

Calling `PgSearch.multisearch` directly returns an `ActiveRecord_Relation` of `PgSearch::Document` objects.

The `searchable_type` field contains the model name, and the `searchable_id` contains the id of the record within that model. So in the above example, the two matches are: `Article` with an `id` of `101` and `Comment` with an `id` of `400`.

We can convert this into an array of assorted objects by running something like the following:

```ruby
results.map do |result|
  Object.const_get(result.searchable_type).find(result.searchable_id)
end
```

If `result.searchable_type` is "Comment", `Object.const_get(result.searchable_type)` returns the class `Comment` (which is a constant, since the names of Ruby classes are constants.

Then we are simply calling `.find` on the `Comment` class.

2) Create a model that does not inherit from `ActiveRecord::Base`, which can be responsible for implementing the same query across each model

```ruby
class GlobalSearch
  def initialize(query)
    @query = query
  end

  def result_articles
    Article.search(query)
  end

  def result_comments
    Comment.search(query)
  end
end
```

### How To Test Stuff Out

Once you've updated your models for search capability, just try things out in `rails c` to ensure that you are getting the results that you expected. It's really easy to create new objects that will match a search to sanity check your search setup (without having to deal with the Controller or View levels).

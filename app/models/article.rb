class Article < ActiveRecord::Base
  include PgSearch

  has_many :comments
  validates :title, presence: true
  validates :body, presence: true

  multisearchable against: [:title, :body]

  pg_search_scope :search_article_only, against: [:title, :body]
  pg_search_scope :search_article_and_comments,
    against: [:title, :body],
    associated_against: {
      comments: [:body]
    }

  scope :search, -> (query) { search_article_only(query) if query.present? }

  scope :global_search, -> (query) {
    search_article_and_comments(query) if query.present?
  }

  # def self.search(query)
  #   search_by_title_and_body(query) if query.present?
  # end
end

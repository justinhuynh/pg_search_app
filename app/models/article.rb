class Article < ActiveRecord::Base
  include PgSearch

  has_many :comments
  validates :title, presence: true
  validates :body, presence: true

  multisearchable against: [:title, :body]
  pg_search_scope :search_by_title_and_body, against: [:title, :body]

  scope :search, -> (query) { search_by_title_and_body(query) if query.present? }

  # def self.search(query)
  #   search_by_title_and_body(query) if query.present?
  # end
end

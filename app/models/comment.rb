class Comment < ActiveRecord::Base
  include PgSearch

  belongs_to :article

  # this allows PgSearch to index this model
  multisearchable against: [:body]
end

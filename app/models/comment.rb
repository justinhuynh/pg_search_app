class Comment < ActiveRecord::Base
  include PgSearch

  belongs_to :article
  multisearchable against: [:body]
end

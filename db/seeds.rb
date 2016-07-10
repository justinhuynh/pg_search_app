require 'faker'

COMMON_WORDS = ["cow", "pig", "dog", "frog", "hedgehog", "mono"]
HIPSTER_WORDS = Faker::Hipster.words(15)
HIPSTER_SENTENCES = Faker::Hipster.sentences(10)

def build_title
  title_words = COMMON_WORDS.sample(2) + HIPSTER_WORDS.sample(2)
  title_words.join(" ")
end

def build_body
  HIPSTER_WORDS.sample(3).join(" ") + " #{HIPSTER_SENTENCES.sample}"
end

100.times do
  article_attributes = {
    title: build_title,
    body: build_body
  }
  Article.create(article_attributes)
end

COMMENT_BODY = [
  "How interesting. I love how it ties the room together.",
  "This is an interesting article",
  "I loved your article. For more info, please check out my site",
  "That's a pretty bizarre statement",
  "What a bizarre article",
  "I don't understand your statement",
  "That's a pretty strange combination of words"
]

def build_comment_body
  COMMENT_BODY.sample + " #{HIPSTER_WORDS.sample}"
end

400.times do
  comment_attributes = {
    body: build_comment_body,
    article_id: Article.pluck(:id).sample
  }
  Comment.create(comment_attributes)
end

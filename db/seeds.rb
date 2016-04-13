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

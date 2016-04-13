FactoryGirl.define do
  factory :article do
    sequence(:title) { |n| "Title #{n}" }
    sequence(:body) { |n| "Body #{n}" }
  end
end

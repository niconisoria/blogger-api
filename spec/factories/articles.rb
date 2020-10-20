FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "My Article #{n}" }
    sequence(:content) { |n| "My Article's content #{n}" }
    sequence(:slug) { |n| "my-article-#{n}" }
  end
end

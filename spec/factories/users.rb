FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "JDoo#{n}" }
    name { "John Doo" }
    url { "http://example.com" }
    avatar_url { "http://example.com/avatar" }
    provider { "github" }
  end
end

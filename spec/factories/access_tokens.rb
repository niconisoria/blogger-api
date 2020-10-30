FactoryBot.define do
  factory :access_token do
    token { 'token' }
    association :user
  end
end

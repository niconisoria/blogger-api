FactoryBot.define do
  factory :comment do
    content { 'My comment' }
    association :user
    association :article
  end
end

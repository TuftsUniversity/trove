FactoryBot.define do
  factory :image do
    sequence(:title) { |n| ["Image: #{n}"] }
    creator { ["Image Creator"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    displays_in { ['trove'] }

    transient do
      user { create(:user) }
    end

    after(:build) do |image, evaluator|
      image.depositor = evaluator.user.user_key
    end
  end
end

FactoryBot.define do
  factory :image do
    sequence(:title) { |n| ["Image: #{n}"] }
    creator { ["Image Creator"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    displays_in { ['trove'] }

    transient do
      user { nil }
    end
  end
end

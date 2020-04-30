FactoryBot.define do
  factory :image do
    title { ["Image: #{FFaker::Movie.title}"] }
    creator { ["Image Creator"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    transient do
      user { nil }
    end
  end
end

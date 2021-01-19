FactoryBot.define do
  factory :file_set do
    transient do
      user { create(:user) }
      content { nil }
    end

    after(:build) do |fs, evaluator|
      fs.apply_depositor_metadata evaluator.user.user_key
      fs.title = ['testfile']
    end

    after(:create) do |fs, evaluator|
      Hydra::Works::UploadFileToFileSet.call(fs, evaluator.content) if evaluator.content
    end

    trait :public do
      read_groups { ["public"] }
    end

    trait :registered do
      read_groups { ["registered"] }
    end
  end
end

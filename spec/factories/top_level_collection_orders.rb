require 'factory_bot'

FactoryBot.define do
  factory :top_level_collection_order do
    user_id { 'fake_id01' }
    order { '["fake",   "order"]' }

    factory :invalid_top_level_collection_order do
      user_id { nil }
    end
  end

  factory :top_level_course_collection_order, class: TopLevelCollectionOrder do
    user_id { TopLevelCollectionOrder.course_collection_id }
    order { '["fake", "course", "order"]' }
  end
end
FactoryBot.define do
  factory :collection_type, class: Hyrax::CollectionType do
    title { 'Generic Collection' }
    machine_id { 'generic_collection' }

    description { 'Collection type with all options' }
    nestable { true }
    discoverable { true }
    sharable { true }
    brandable { true }
    share_applies_to_new_works { true }
    allow_multiple_membership { true }
    require_membership { false }
    assigns_workflow { false }
    assigns_visibility { false }

    factory :personal_collection_type do
      title { 'Personal Collection' }
      machine_id { 'personal_collection' }
    end

    factory :course_collection_type do
      title { 'Course Collection' }
      machine_id { 'course_collection' }
    end
  end
end

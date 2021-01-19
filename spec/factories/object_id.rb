# Defines a new sequence
FactoryBot.define do
  sequence :object_id do |n|
    "trove-#{n}"
  end
end

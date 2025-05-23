FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence(word_count: 3) }
    content { Faker::Lorem.paragraph(sentence_count: 5) }
    published { true }

    # Create a draft variant
    trait :draft do
      published { false }
    end
  end
end

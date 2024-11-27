FactoryBot.define do
    factory :url_shortener do
      original { Faker::Internet.url }
      short { Faker::Alphanumeric.alphanumeric(number: 6) }
    end
  end
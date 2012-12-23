require 'faker'

FactoryGirl.define do
  factory :user do |f|
    f.username { Faker::Internet.user_name }
    f.password { Faker::Lorem.characters(10) }
    f.nom { Faker::Name.first_name }
    f.cognoms { Faker::Name.last_name }
    f.email 'pepito@andorra.ad'
#f.email { Faker::Internet.safe_email }
  end
end

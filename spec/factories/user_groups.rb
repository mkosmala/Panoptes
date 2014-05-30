FactoryGirl.define do
  factory :user_group do
    display_name "A User Group"
    classification_count { 10 + rand(1000) }
    sequence(:name) {|n| "group_#{n}"}

    factory :user_group_with_users do
      after(:create) do |ug|
        n = Array(20..100).sample
        create_list(:membership, n, user_group: ug)
      end
    end

    factory :user_group_with_projects do
      after(:create) do |ug|
        n = Array(2..10).sample
        create_list(:projects, n, owner: ug)
      end
    end

    factory :user_group_with_collections do
      after(:Create) do |ug|
        n = Array(2..10).sample
        create_list(:collections, n, owner: ug)
      end
    end
  end
end
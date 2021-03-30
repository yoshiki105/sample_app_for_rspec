FactoryBot.define do
  factory :task do
    sequence(:title, 'title_1')
    content { 'Sample content.' }
    status { :todo }
    deadline { 1.week.from_now }
    association :user
  end
end

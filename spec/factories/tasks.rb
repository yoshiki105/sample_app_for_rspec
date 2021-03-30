FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Test task #{n}" }
    content { 'Sample content.' }
    status { :todo }
    deadline { 1.week.from_now }
    association :user
  end
end

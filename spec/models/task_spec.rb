require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validation' do
    it 'is valid with all attributes' do
      task = FactoryBot.build(:task)
      expect(task).to be_valid
    end
    it 'is invalid without title' do
      task = FactoryBot.build(:task, title: '')
      task.valid?
      expect(task.errors).to_not be_empty
      expect(task.errors[:title]).to eq ["can't be blank"]
    end
    it 'is invalid without status' do
      task = FactoryBot.build(:task, status: nil)
      task.valid?
      expect(task.errors).to_not be_empty
      expect(task.errors[:status]).to eq ["can't be blank"]
    end
    it 'is invalid with a duplicate title' do
      task = FactoryBot.create(:task, title: 'Sample title')
      other_task = FactoryBot.build(:task, title: 'Sample title')
      other_task.valid?
      expect(other_task.errors).to_not be_empty
      expect(other_task.errors[:title]).to eq ['has already been taken']
    end
    it 'is valid with another title' do
      task = FactoryBot.create(:task, title: 'Sample title')
      other_task = FactoryBot.build(:task, title: 'Another title')
      other_task.valid?
      expect(other_task).to be_valid
    end
  end
end

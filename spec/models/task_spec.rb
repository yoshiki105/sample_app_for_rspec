require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validation' do
    it 'is valid with all attributes' do
      task = build(:task)
      expect(task).to be_valid
    end
    it 'is invalid without title' do
      task = build(:task, title: '')
      expect(task).to be_invalid
      expect(task.errors[:title]).to eq ["can't be blank"]
    end
    it 'is invalid without status' do
      task = build(:task, status: nil)
      expect(task).to be_invalid
      expect(task.errors[:status]).to eq ["can't be blank"]
    end
    it 'is invalid with a duplicate title' do
      task = create(:task)
      other_task = build(:task, title: task.title)
      expect(other_task).to be_invalid
      expect(other_task.errors[:title]).to eq ['has already been taken']
    end
    it 'is valid with another title' do
      task = create(:task, title: 'Sample title')
      other_task = build(:task, title: 'Another title')
      expect(other_task).to be_valid
    end
  end
end

require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  let!(:user) { create(:user); }
  let!(:task) { create(:task, user: user) }

  context 'ログイン前' do
    describe 'タスクの新規作成' do
      it '失敗すること' do
        visit new_task_path
        expect(current_path).to eq login_path
        expect(page).to have_selector '#alert', text: 'Login required'
      end
    end
    describe 'タスクの編集' do
      it '失敗すること' do
        visit edit_task_path(task)
        expect(current_path).to eq login_path
        expect(page).to have_selector '#alert', text: 'Login required'
      end
    end
  end
  context 'ログイン後' do
    before(:each) do
      sign_in_as(user)
    end
    describe 'タスクの新規作成' do
      it '成功すること' do
        visit new_task_path

        # タスクを新規作成する
        new_task = {
          title: 'new_task_test',
          content: 'This is new task test.',
          status: :todo,
          deadline: 1.day.from_now
        }
        fill_in 'Title',	with: new_task[:title]
        fill_in 'Content',	with: new_task[:content]
        select new_task[:status], from: 'Status'
        fill_in 'Deadline',	with: new_task[:deadline]
        click_on 'Create'

        # タスクが作成されていることを検証する
        expect(current_path).to eq task_path(Task.last)
        expect(page).to have_selector '#notice', text: 'Task was successfully created.'
      end
    end
    describe 'タスクの編集' do
      it '成功すること' do
        visit edit_task_path(task)

        fill_in 'Title',	with: 'Edit task test'
        fill_in 'Content',	with: 'This is a edit test.'
        select :todo, from: 'Status'
        fill_in 'Deadline',	with: 2.day.from_now.to_s
        click_on 'Update'

        expect(current_path).to eq task_path(task)
        expect(page).to have_selector '#notice', text: 'Task was successfully updated.'
      end
    end
    describe 'タスクの削除' do
      it '成功すること' do
        visit tasks_path
        page.accept_confirm do
          click_on 'Destroy'
        end
        expect(current_path).to eq tasks_path
        expect(page).to have_selector '#notice', text: 'Task was successfully destroyed.'
      end
    end
    describe '他ユーザーのタスク編集ページ' do
      it '遷移できないこと ' do
        another_user = create(:user)
        sign_in_as(another_user)

        visit edit_task_path(task)

        expect(current_path).to eq root_path
        expect(page).to have_selector '#alert', text: 'Forbidden access.'
      end
    end
  end
end

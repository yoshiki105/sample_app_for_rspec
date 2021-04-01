require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task, user: user) }

  context 'ログイン前' do
    describe 'ページ遷移確認' do
      context 'タスクの新規作成へのアクセス' do
        it '失敗すること' do
          visit new_task_path
          expect(current_path).to eq login_path
          expect(page).to have_selector '#alert', text: 'Login required'
        end
      end

      context 'タスクの編集ページへのアクセス' do
        it '失敗すること' do
          visit edit_task_path(task)
          expect(current_path).to eq login_path
          expect(page).to have_selector '#alert', text: 'Login required'
        end
      end

      context 'タスクの詳細ページへのアクセス' do
        it 'タスクの詳細情報が表示されること' do
          visit task_path(task)
          expect(current_path).to eq task_path(task)
          expect(page).to have_content task.title
          expect(page).to have_content task.content
          expect(page).to have_content task.status
        end
      end

      context 'タスクの一覧ページへのアクセス' do
        it 'すべてのユーザーのタスク情報が表示されること' do
          tasks = create_list(:task, 3)
          visit tasks_path
          expect(current_path).to eq tasks_path
          expect(page).to have_content tasks[0].title
          expect(page).to have_content tasks[1].title
          expect(page).to have_content tasks[2].title
        end
      end
    end
  end

  context 'ログイン後' do
    before { sign_in_as(user) }

    describe 'ページ遷移確認' do
      context '他ユーザーのタスク編集ページへのアクセス' do
        it '遷移できないこと ' do
          another_user = create(:user)
          sign_in_as(another_user)

          visit edit_task_path(task)

          expect(current_path).to eq root_path
          expect(page).to have_selector '#alert', text: 'Forbidden access.'
        end
      end
    end

    describe 'タスクの新規作成' do
      let(:other_task) { create(:task) }
      before  do
        visit new_task_path
        fill_in 'Title',	with: 'new_task_test'
        fill_in 'Content',	with: 'This is new task test.'
        select :todo, from: 'Status'
        fill_in 'Deadline',	with: 1.day.from_now
      end

      context 'フォームの入力値が正常のとき' do
        it '成功すること' do
          click_on 'Create'
          expect(current_path).to eq task_path(Task.last)
          expect(page).to have_selector '#notice', text: 'Task was successfully created.'
        end
      end

      context 'タイトルが未入力のとき' do
        it '失敗すること' do
          fill_in 'Title',	with: ''
          click_on 'Create'
          expect(current_path).to eq tasks_path
          expect(page).to have_content "Title can't be blank"
        end
      end

      context '登録済のタイトルを入力したとき' do
        it '失敗すること' do
          fill_in 'Title',	with: other_task.title
          click_on 'Create'
          expect(current_path).to eq tasks_path
          expect(page).to have_content 'Title has already been taken'
        end
      end
    end

    describe 'タスクの編集' do
      let!(:task) { create(:task, user: user) }
      let(:other_task) { create(:task, user: user) }
      before  { visit edit_task_path(task) }

      context 'フォームの入力値が正常のとき' do
        it '成功すること' do
          fill_in 'Title',	with: 'Edit task test'
          fill_in 'Content',	with: 'This is a edit test.'
          select :todo, from: 'Status'
          fill_in 'Deadline',	with: 2.day.from_now.to_s
          click_on 'Update'
          expect(current_path).to eq task_path(task)
          expect(page).to have_selector '#notice', text: 'Task was successfully updated.'
        end
      end

      context 'タイトルが未入力のとき' do
        it '失敗すること' do
          fill_in 'Title',	with: ''
          click_on 'Update'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content "Title can't be blank"
        end
      end

      context '登録済のタイトルを入力したとき' do
        it '失敗すること' do
          fill_in 'Title',	with: other_task.title
          click_on 'Update'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content 'Title has already been taken'
        end
      end
    end

    describe 'タスクの削除' do
      let!(:task) { create(:task, user: user) }

      it '成功すること' do
        visit tasks_path
        click_on 'Destroy'
        expect(page.accept_confirm).to eq 'Are you sure?'
        expect(current_path).to eq tasks_path
        expect(page).to have_selector '#notice', text: 'Task was successfully destroyed.'
        expect(page).to_not have_content task.title
      end
    end
  end
end

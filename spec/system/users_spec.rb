require 'rails_helper'

RSpec.describe 'Users', type: :system do
  context 'ログイン前' do
    describe 'ユーザー新規登録' do
      before(:each) do
        visit new_user_path
        fill_in 'Email',	with: 'tester@example.com'
        fill_in 'Password',	with: 'password'
        fill_in 'Password confirmation',	with: 'password'
      end
      context '正しい情報を入力した時' do
        it '成功すること' do
          within '.actions' do
            click_on 'SignUp'
          end
          expect(current_path).to eq login_path
          expect(page).to have_content 'User was successfully created.'
        end
      end
      context 'メールアドレス未入力の時' do
        it '失敗すること' do
          fill_in 'Email',	with: ''
          within '.actions' do
            click_on 'SignUp'
          end
          expect(current_path).to eq users_path
          expect(page).to have_selector '#error_explanation', text: "Email can't be blank"
        end
      end
      context '登録済みメールアドレスを使用した時' do
        it '失敗すること' do
          user = create(:user)
          fill_in 'Email',	with: user.email
          within '.actions' do
            click_on 'SignUp'
          end
          expect(current_path).to eq users_path
          expect(page).to have_selector '#error_explanation', text: 'Email has already been taken'
        end
      end
    end

    describe 'マイページ' do
      it '遷移ができないこと' do
        not_logged_in_user = create(:user)
        visit user_path(not_logged_in_user)
        expect(current_path).to eq login_path
        expect(page).to have_selector '#alert', text: 'Login required'
      end
    end
  end

  context 'ログイン後' do
    let(:user) { create(:user) }
    describe 'ユーザー情報の編集' do
      before(:each) do
        sign_in_as(user)
        visit edit_user_path(user)
        fill_in 'Email',	with: 'tester@example.com'
        fill_in 'Password',	with: 'foobar'
        fill_in 'Password confirmation',	with: 'foobar'
      end
      context '正しい情報を入力した時' do
        it '成功すること' do
          within '.actions' do
            click_on 'Update'
          end
          expect(current_path).to eq user_path(user)
          expect(page).to have_content 'User was successfully updated.'
        end
      end
      context 'メールアドレス未入力の時' do
        it '失敗すること' do
          fill_in 'Email',	with: ''
          within '.actions' do
            click_on 'Update'
          end
          expect(current_path).to eq user_path(user)
          expect(page).to have_content "Email can't be blank"
        end
      end
      context '登録済みメールアドレスを使用した時' do
        it '失敗すること' do
          other_user = create(:user)
          fill_in 'Email',	with: other_user.email
          within '.actions' do
            click_on 'Update'
          end
          expect(current_path).to eq user_path(user)
          expect(page).to have_selector '#error_explanation', text: 'Email has already been taken'
        end
      end
      describe '他のユーザーの編集ページ' do
        it '遷移できないこと' do
          other_user = create(:user)
          visit edit_user_path(other_user)
          expect(current_path).to eq user_path(user)
          expect(page).to have_selector '#alert', text: 'Forbidden access.'
        end
      end
    end
    describe 'マイページ' do
      context 'タスクを新規作成した時' do
        it '新規作成したタスクが表示されること' do
          sign_in_as(user)
          # タスク新規作成ページへ行く
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

          # マイページへ行く
          visit user_path(user)

          # 新規作成したタスクが表示されているかどうか確認する
          expect(page).to have_content new_task[:title]
          expect(page).to have_content new_task[:status]
        end
      end
    end
  end
end

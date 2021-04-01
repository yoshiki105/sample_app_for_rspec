require 'rails_helper'

RSpec.describe 'UserSessions', type: :system do
  let(:user) { create(:user) }

  context 'ログイン前' do
    context 'フォームに正しい値を入力した時' do
      it 'ログインに成功する' do
        visit login_path
        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'password'
        click_button 'Login'
        expect(current_path).to eq root_path
        expect(page).to have_content 'Login successful'
      end
    end
    context 'フォームが未入力の時' do
      it 'ログインが失敗する' do
        visit login_path
        click_button 'Login'
        expect(current_path).to eq login_path
        expect(page).to have_content 'Login failed'
      end
    end
  end

  context 'ログイン後' do
    context 'ログアウトボタンをクリックした時' do
      it 'ログアウトする' do
        sign_in_as(user)
        click_on 'Logout'
        expect(current_path).to eq root_path
        expect(page).to have_content 'Logged out'
      end
    end
  end
end

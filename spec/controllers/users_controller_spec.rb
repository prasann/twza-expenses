require 'spec_helper'

describe UsersController do

  describe 'POST Create User' do
    it 'creates a new User' do
      expect {
        post :create, :user => {:user_name => 'test',:password => 'password'}
      }.to change(User, :count).by(1)
      response.should redirect_to(root_path)
    end
  end
end

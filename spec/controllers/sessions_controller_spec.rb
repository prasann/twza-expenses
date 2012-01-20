require 'spec_helper'

describe SessionsController do

  describe 'POST create sessions' do
    it 'create login session for registered user' do
      user1 = User.create!({user_name:'test',password:'password'})
      session[:user_id].should be nil
      post :create, :user_name => 'test' , :password => 'password'
      session[:user_id].should == user1.id
      response.should redirect_to(outbound_travels_path)
    end
  end

  describe 'GET delete sessions' do

    before(:each) do
      user = User.create!({user_name:'test',password:'password'})
      post :create, :user_name => 'test' , :password => 'password'
    end

    it 'removes session id when the user logs out' do
      session[:user_id].should_not be nil
      get :destroy
      session[:user_id].should be nil
      response.should redirect_to(root_path)
    end
  end

end

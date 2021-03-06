require 'spec_helper'

describe ApplicationController do
  describe "Application Cache control" do
    controller do
      def index
        redirect_to "/404.html"
      end
    end

    it "invalidates cache before every request" do
      get :index

      response.headers["Cache-Control"].should == "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"].should == "no-cache"
      response.headers["Expires"].should == "Fri, 01 Jan 1990 00:00:00 GMT"
    end

  end

  describe "Application Layout" do
    it "should apply tabs layout to all index action and default to application for the rest" do
      pending " to be done "
    end
  end
end

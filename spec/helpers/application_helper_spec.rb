require 'spec_helper'
require 'date'

describe ApplicationHelper do

  describe "prepare flash message HTML for UI" do
    it "should create escaped HTML for flash message for display in UI" do
      flash[:error] = 'Could not save expense report'
      flash[:success] = 'Email sent successfully'

      message = flash_message
      message.should include "<div class=\"error notification\">Could not save expense report</div>"
      message.should include "<div class=\"success notification\">Email sent successfully</div>"
      message.should include javascript_tag('$(\'.notification\').fadeOut(5000);')
    end
  end
end

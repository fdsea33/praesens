require File.dirname(__FILE__) + '/../../test_helper'
require 'accountancy/settings_controller'

# Re-raise errors caught by the controller.
class Accountancy::SettingsController; def rescue_action(e) raise e end; end

class Accountancy::SettingsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Accountancy::SettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

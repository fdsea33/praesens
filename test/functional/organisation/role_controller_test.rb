require File.dirname(__FILE__) + '/../../test_helper'
require 'organisation/role_controller'

# Re-raise errors caught by the controller.
class Organisation::RoleController; def rescue_action(e) raise e end; end

class Organisation::RoleControllerTest < Test::Unit::TestCase
  def setup
    @controller = Organisation::RoleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

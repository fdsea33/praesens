require File.dirname(__FILE__) + '/../../test_helper'
require 'organisation/company_controller'

# Re-raise errors caught by the controller.
class Organisation::CompanyController; def rescue_action(e) raise e end; end

class Organisation::CompanyControllerTest < Test::Unit::TestCase
  def setup
    @controller = Organisation::CompanyController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

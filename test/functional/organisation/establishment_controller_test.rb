require File.dirname(__FILE__) + '/../../test_helper'
require 'organisation/establishment_controller'

# Re-raise errors caught by the controller.
class Organisation::EstablishmentController; def rescue_action(e) raise e end; end

class Organisation::EstablishmentControllerTest < Test::Unit::TestCase
  fixtures :company_establishments

  def setup
    @controller = Organisation::EstablishmentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = company_establishments(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:company_establishments)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:company_establishment)
    assert assigns(:company_establishment).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:company_establishment)
  end

  def test_create
    num_company_establishments = CompanyEstablishment.count

    post :create, :company_establishment => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_company_establishments + 1, CompanyEstablishment.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:company_establishment)
    assert assigns(:company_establishment).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      CompanyEstablishment.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      CompanyEstablishment.find(@first_id)
    }
  end
end

require File.dirname(__FILE__) + '/../../test_helper'
require 'organisation/department_controller'

# Re-raise errors caught by the controller.
class Organisation::DepartmentController; def rescue_action(e) raise e end; end

class Organisation::DepartmentControllerTest < Test::Unit::TestCase
  fixtures :company_departments

  def setup
    @controller = Organisation::DepartmentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = company_departments(:first).id
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

    assert_not_nil assigns(:company_departments)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:company_department)
    assert assigns(:company_department).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:company_department)
  end

  def test_create
    num_company_departments = CompanyDepartment.count

    post :create, :company_department => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_company_departments + 1, CompanyDepartment.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:company_department)
    assert assigns(:company_department).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      CompanyDepartment.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      CompanyDepartment.find(@first_id)
    }
  end
end

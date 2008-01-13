require File.dirname(__FILE__) + '/../../test_helper'
require 'administration/application_controller'

# Re-raise errors caught by the controller.
class Administration::ApplicationController; def rescue_action(e) raise e end; end

class Administration::ApplicationControllerTest < Test::Unit::TestCase
  fixtures :parts

  def setup
    @controller = Administration::ApplicationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = parts(:first).id
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

    assert_not_nil assigns(:parts)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:part)
    assert assigns(:part).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:part)
  end

  def test_create
    num_parts = Part.count

    post :create, :part => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_parts + 1, Part.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:part)
    assert assigns(:part).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Part.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Part.find(@first_id)
    }
  end
end

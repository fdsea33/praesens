require File.dirname(__FILE__) + '/../../test_helper'
require 'organisation/access_profile_controller'

# Re-raise errors caught by the controller.
class Organisation::AccessProfileController; def rescue_action(e) raise e end; end

class Organisation::AccessProfileControllerTest < Test::Unit::TestCase
  fixtures :access_profiles

  def setup
    @controller = Organisation::AccessProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = access_profiles(:first).id
  end

  def test_add_privilege
    get :add_privilege
    assert_response :success
    assert_template 'add_privilege'
  end

  def test_remove_privilege
    get :remove_privilege
    assert_response :success
    assert_template 'remove_privilege'
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

    assert_not_nil assigns(:access_profiles)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:access_profile)
    assert assigns(:access_profile).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:access_profile)
  end

  def test_create
    num_access_profiles = AccessProfile.count

    post :create, :access_profile => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_access_profiles + 1, AccessProfile.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:access_profile)
    assert assigns(:access_profile).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      AccessProfile.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      AccessProfile.find(@first_id)
    }
  end
end

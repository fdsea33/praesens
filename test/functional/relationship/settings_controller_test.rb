require File.dirname(__FILE__) + '/../../test_helper'
require 'relationship/settings_controller'

# Re-raise errors caught by the controller.
class Relationship::SettingsController; def rescue_action(e) raise e end; end

class Relationship::SettingsControllerTest < Test::Unit::TestCase
  fixtures :entity_natures

  def setup
    @controller = Relationship::SettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = entity_natures(:first).id
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

    assert_not_nil assigns(:entity_natures)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:entity_nature)
    assert assigns(:entity_nature).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:entity_nature)
  end

  def test_create
    num_entity_natures = EntityNature.count

    post :create, :entity_nature => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_entity_natures + 1, EntityNature.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:entity_nature)
    assert assigns(:entity_nature).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      EntityNature.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      EntityNature.find(@first_id)
    }
  end
end

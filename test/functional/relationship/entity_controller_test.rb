require File.dirname(__FILE__) + '/../../test_helper'
require 'relationship/entity_controller'

# Re-raise errors caught by the controller.
class Relationship::EntityController; def rescue_action(e) raise e end; end

class Relationship::EntityControllerTest < Test::Unit::TestCase
  fixtures :entities

  def setup
    @controller = Relationship::EntityController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = entities(:first).id
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

    assert_not_nil assigns(:entities)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:entity)
    assert assigns(:entity).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:entity)
  end

  def test_create
    num_entities = Entity.count

    post :create, :entity => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_entities + 1, Entity.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:entity)
    assert assigns(:entity).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Entity.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Entity.find(@first_id)
    }
  end
end

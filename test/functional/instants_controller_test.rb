require 'test_helper'

class InstantsControllerTest < ActionController::TestCase
  setup do
    @instant = instants(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:instants)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create instant" do
    assert_difference('Instant.count') do
      post :create, :instant => @instant.attributes
    end

    assert_redirected_to instant_path(assigns(:instant))
  end

  test "should show instant" do
    get :show, :id => @instant.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @instant.to_param
    assert_response :success
  end

  test "should update instant" do
    put :update, :id => @instant.to_param, :instant => @instant.attributes
    assert_redirected_to instant_path(assigns(:instant))
  end

  test "should destroy instant" do
    assert_difference('Instant.count', -1) do
      delete :destroy, :id => @instant.to_param
    end

    assert_redirected_to instants_path
  end
end

require 'test_helper'

class CompatibilitiesControllerTest < ActionController::TestCase
  setup do
    @compatibility = compatibilities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:compatibilities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create compatibility" do
    assert_difference('Compatibility.count') do
      post :create, compatibility: { copyleft_compatible_with_future_versions: @compatibility.copyleft_compatible_with_future_versions, copyleft_compatible_with_other: @compatibility.copyleft_compatible_with_other, sublicense_future_versions: @compatibility.sublicense_future_versions, sublicense_other: @compatibility.sublicense_other }
    end

    assert_redirected_to compatibility_path(assigns(:compatibility))
  end

  test "should show compatibility" do
    get :show, id: @compatibility
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @compatibility
    assert_response :success
  end

  test "should update compatibility" do
    put :update, id: @compatibility, compatibility: { copyleft_compatible_with_future_versions: @compatibility.copyleft_compatible_with_future_versions, copyleft_compatible_with_other: @compatibility.copyleft_compatible_with_other, sublicense_future_versions: @compatibility.sublicense_future_versions, sublicense_other: @compatibility.sublicense_other }
    assert_redirected_to compatibility_path(assigns(:compatibility))
  end

  test "should destroy compatibility" do
    assert_difference('Compatibility.count', -1) do
      delete :destroy, id: @compatibility
    end

    assert_redirected_to compatibilities_path
  end
end

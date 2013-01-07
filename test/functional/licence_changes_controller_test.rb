require 'test_helper'

class LicenceChangesControllerTest < ActionController::TestCase
  setup do
    @licence_change = licence_changes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:licence_changes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create licence_change" do
    assert_difference('LicenceChange.count') do
      post :create, licence_change: { licence_changes_effective_immediately: @licence_change.licence_changes_effective_immediately }
    end

    assert_redirected_to licence_change_path(assigns(:licence_change))
  end

  test "should show licence_change" do
    get :show, id: @licence_change
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @licence_change
    assert_response :success
  end

  test "should update licence_change" do
    put :update, id: @licence_change, licence_change: { licence_changes_effective_immediately: @licence_change.licence_changes_effective_immediately }
    assert_redirected_to licence_change_path(assigns(:licence_change))
  end

  test "should destroy licence_change" do
    assert_difference('LicenceChange.count', -1) do
      delete :destroy, id: @licence_change
    end

    assert_redirected_to licence_changes_path
  end
end

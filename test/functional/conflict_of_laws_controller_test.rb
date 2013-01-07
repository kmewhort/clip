require 'test_helper'

class ConflictOfLawsControllerTest < ActionController::TestCase
  setup do
    @conflict_of_law = conflict_of_laws(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:conflict_of_laws)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create conflict_of_law" do
    assert_difference('ConflictOfLaw.count') do
      post :create, conflict_of_law: { forum_of: @conflict_of_law.forum_of, law_of: @conflict_of_law.law_of }
    end

    assert_redirected_to conflict_of_law_path(assigns(:conflict_of_law))
  end

  test "should show conflict_of_law" do
    get :show, id: @conflict_of_law
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @conflict_of_law
    assert_response :success
  end

  test "should update conflict_of_law" do
    put :update, id: @conflict_of_law, conflict_of_law: { forum_of: @conflict_of_law.forum_of, law_of: @conflict_of_law.law_of }
    assert_redirected_to conflict_of_law_path(assigns(:conflict_of_law))
  end

  test "should destroy conflict_of_law" do
    assert_difference('ConflictOfLaw.count', -1) do
      delete :destroy, id: @conflict_of_law
    end

    assert_redirected_to conflict_of_laws_path
  end
end

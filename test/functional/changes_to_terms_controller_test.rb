require 'test_helper'

class ChangesToTermsControllerTest < ActionController::TestCase
  setup do
    @changes_to_term = changes_to_terms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:changes_to_terms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create changes_to_term" do
    assert_difference('ChangesToTerm.count') do
      post :create, changes_to_term: { licence_changes_effective_immediately: @changes_to_term.licence_changes_effective_immediately }
    end

    assert_redirected_to changes_to_term_path(assigns(:changes_to_term))
  end

  test "should show changes_to_term" do
    get :show, id: @changes_to_term
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @changes_to_term
    assert_response :success
  end

  test "should update changes_to_term" do
    put :update, id: @changes_to_term, changes_to_term: { licence_changes_effective_immediately: @changes_to_term.licence_changes_effective_immediately }
    assert_redirected_to changes_to_term_path(assigns(:changes_to_term))
  end

  test "should destroy changes_to_term" do
    assert_difference('ChangesToTerm.count', -1) do
      delete :destroy, id: @changes_to_term
    end

    assert_redirected_to changes_to_terms_path
  end
end

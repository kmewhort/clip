require 'test_helper'

class CopyleftClausesControllerTest < ActionController::TestCase
  setup do
    @copyleft_clause = copyleft_clauses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:copyleft_clauses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create copyleft_clause" do
    assert_difference('CopyleftClause.count') do
      post :create, copyleft_clause: { copyleft_applies_to: @copyleft_clause.copyleft_applies_to, copyleft_engages_on: @copyleft_clause.copyleft_engages_on }
    end

    assert_redirected_to copyleft_clause_path(assigns(:copyleft_clause))
  end

  test "should show copyleft_clause" do
    get :show, id: @copyleft_clause
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @copyleft_clause
    assert_response :success
  end

  test "should update copyleft_clause" do
    put :update, id: @copyleft_clause, copyleft_clause: { copyleft_applies_to: @copyleft_clause.copyleft_applies_to, copyleft_engages_on: @copyleft_clause.copyleft_engages_on }
    assert_redirected_to copyleft_clause_path(assigns(:copyleft_clause))
  end

  test "should destroy copyleft_clause" do
    assert_difference('CopyleftClause.count', -1) do
      delete :destroy, id: @copyleft_clause
    end

    assert_redirected_to copyleft_clauses_path
  end
end

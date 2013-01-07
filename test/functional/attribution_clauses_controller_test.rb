require 'test_helper'

class AttributionClausesControllerTest < ActionController::TestCase
  setup do
    @attribution_clause = attribution_clauses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:attribution_clauses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create attribution_clause" do
    assert_difference('AttributionClause.count') do
      post :create, attribution_clause: { attribution_details: @attribution_clause.attribution_details, attribution_type: @attribution_clause.attribution_type }
    end

    assert_redirected_to attribution_clause_path(assigns(:attribution_clause))
  end

  test "should show attribution_clause" do
    get :show, id: @attribution_clause
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @attribution_clause
    assert_response :success
  end

  test "should update attribution_clause" do
    put :update, id: @attribution_clause, attribution_clause: { attribution_details: @attribution_clause.attribution_details, attribution_type: @attribution_clause.attribution_type }
    assert_redirected_to attribution_clause_path(assigns(:attribution_clause))
  end

  test "should destroy attribution_clause" do
    assert_difference('AttributionClause.count', -1) do
      delete :destroy, id: @attribution_clause
    end

    assert_redirected_to attribution_clauses_path
  end
end

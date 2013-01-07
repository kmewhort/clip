require 'test_helper'

class PatentClausesControllerTest < ActionController::TestCase
  setup do
    @patent_clause = patent_clauses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:patent_clauses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create patent_clause" do
    assert_difference('PatentClause.count') do
      post :create, patent_clause: { patent_licence_extends_to: @patent_clause.patent_licence_extends_to, patent_retaliation_applies_to: @patent_clause.patent_retaliation_applies_to, patent_retaliation_upon_countercliam: @patent_clause.patent_retaliation_upon_countercliam, patent_retaliation_upon_originating_claim: @patent_clause.patent_retaliation_upon_originating_claim }
    end

    assert_redirected_to patent_clause_path(assigns(:patent_clause))
  end

  test "should show patent_clause" do
    get :show, id: @patent_clause
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @patent_clause
    assert_response :success
  end

  test "should update patent_clause" do
    put :update, id: @patent_clause, patent_clause: { patent_licence_extends_to: @patent_clause.patent_licence_extends_to, patent_retaliation_applies_to: @patent_clause.patent_retaliation_applies_to, patent_retaliation_upon_countercliam: @patent_clause.patent_retaliation_upon_countercliam, patent_retaliation_upon_originating_claim: @patent_clause.patent_retaliation_upon_originating_claim }
    assert_redirected_to patent_clause_path(assigns(:patent_clause))
  end

  test "should destroy patent_clause" do
    assert_difference('PatentClause.count', -1) do
      delete :destroy, id: @patent_clause
    end

    assert_redirected_to patent_clauses_path
  end
end

require 'test_helper'

class RightsControllerTest < ActionController::TestCase
  setup do
    @right = rights(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rights)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create right" do
    assert_difference('Right.count') do
      post :create, right: { covers_circumventions: @right.covers_circumventions, covers_copyright: @right.covers_copyright, covers_moral_rights: @right.covers_moral_rights, covers_neighbouring_rights: @right.covers_neighbouring_rights, covers_patents_explicitly: @right.covers_patents_explicitly, covers_sgdrs: @right.covers_sgdrs, covers_trademarks: @right.covers_trademarks, prohibits_commercial_use: @right.prohibits_commercial_use, prohibits_tpms: @right.prohibits_tpms, prohibits_tpms_unless_parallel: @right.prohibits_tpms_unless_parallel, right_to_distribute: @right.right_to_distribute, right_to_modify: @right.right_to_modify, right_to_use_and_reproduce: @right.right_to_use_and_reproduce }
    end

    assert_redirected_to right_path(assigns(:right))
  end

  test "should show right" do
    get :show, id: @right
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @right
    assert_response :success
  end

  test "should update right" do
    put :update, id: @right, right: { covers_circumventions: @right.covers_circumventions, covers_copyright: @right.covers_copyright, covers_moral_rights: @right.covers_moral_rights, covers_neighbouring_rights: @right.covers_neighbouring_rights, covers_patents_explicitly: @right.covers_patents_explicitly, covers_sgdrs: @right.covers_sgdrs, covers_trademarks: @right.covers_trademarks, prohibits_commercial_use: @right.prohibits_commercial_use, prohibits_tpms: @right.prohibits_tpms, prohibits_tpms_unless_parallel: @right.prohibits_tpms_unless_parallel, right_to_distribute: @right.right_to_distribute, right_to_modify: @right.right_to_modify, right_to_use_and_reproduce: @right.right_to_use_and_reproduce }
    assert_redirected_to right_path(assigns(:right))
  end

  test "should destroy right" do
    assert_difference('Right.count', -1) do
      delete :destroy, id: @right
    end

    assert_redirected_to rights_path
  end
end

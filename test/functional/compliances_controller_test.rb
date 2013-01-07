require 'test_helper'

class CompliancesControllerTest < ActionController::TestCase
  setup do
    @compliance = compliances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:compliances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create compliance" do
    assert_difference('Compliance.count') do
      post :create, compliance: { is_dfcw_compliant: @compliance.is_dfcw_compliant, is_okd_compliant: @compliance.is_okd_compliant, is_osi_compliant: @compliance.is_osi_compliant }
    end

    assert_redirected_to compliance_path(assigns(:compliance))
  end

  test "should show compliance" do
    get :show, id: @compliance
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @compliance
    assert_response :success
  end

  test "should update compliance" do
    put :update, id: @compliance, compliance: { is_dfcw_compliant: @compliance.is_dfcw_compliant, is_okd_compliant: @compliance.is_okd_compliant, is_osi_compliant: @compliance.is_osi_compliant }
    assert_redirected_to compliance_path(assigns(:compliance))
  end

  test "should destroy compliance" do
    assert_difference('Compliance.count', -1) do
      delete :destroy, id: @compliance
    end

    assert_redirected_to compliances_path
  end
end

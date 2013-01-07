require 'test_helper'

class ObligationsControllerTest < ActionController::TestCase
  setup do
    @obligation = obligations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:obligations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create obligation" do
    assert_difference('Obligation.count') do
      post :create, obligation: { obligation_attribution: @obligation.obligation_attribution, obligation_copyleft: @obligation.obligation_copyleft, obligation_modifiable_form: @obligation.obligation_modifiable_form, obligation_notice: @obligation.obligation_notice }
    end

    assert_redirected_to obligation_path(assigns(:obligation))
  end

  test "should show obligation" do
    get :show, id: @obligation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @obligation
    assert_response :success
  end

  test "should update obligation" do
    put :update, id: @obligation, obligation: { obligation_attribution: @obligation.obligation_attribution, obligation_copyleft: @obligation.obligation_copyleft, obligation_modifiable_form: @obligation.obligation_modifiable_form, obligation_notice: @obligation.obligation_notice }
    assert_redirected_to obligation_path(assigns(:obligation))
  end

  test "should destroy obligation" do
    assert_difference('Obligation.count', -1) do
      delete :destroy, id: @obligation
    end

    assert_redirected_to obligations_path
  end
end

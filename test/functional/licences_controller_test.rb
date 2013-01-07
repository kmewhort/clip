require 'test_helper'

class LicencesControllerTest < ActionController::TestCase
  setup do
    @licence = licences(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:licences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create licence" do
    assert_difference('Licence.count') do
      post :create, licence: { domain_content: @licence.domain_content, domain_data: @licence.domain_data, domain_software: @licence.domain_software, id: @licence.id, maintainer: @licence.maintainer, title: @licence.title, url: @licence.url }
    end

    assert_redirected_to licence_path(assigns(:licence))
  end

  test "should show licence" do
    get :show, id: @licence
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @licence
    assert_response :success
  end

  test "should update licence" do
    put :update, id: @licence, licence: { domain_content: @licence.domain_content, domain_data: @licence.domain_data, domain_software: @licence.domain_software, id: @licence.id, maintainer: @licence.maintainer, title: @licence.title, url: @licence.url }
    assert_redirected_to licence_path(assigns(:licence))
  end

  test "should destroy licence" do
    assert_difference('Licence.count', -1) do
      delete :destroy, id: @licence
    end

    assert_redirected_to licences_path
  end
end

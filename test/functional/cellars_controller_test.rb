require 'test_helper'

class CellarsControllerTest < ActionController::TestCase
  setup do
    @cellar = cellars(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cellars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cellar" do
    assert_difference('Cellar.count') do
      post :create, :cellar => @cellar.attributes
    end

    assert_redirected_to cellar_path(assigns(:cellar))
  end

  test "should show cellar" do
    get :show, :id => @cellar.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cellar.to_param
    assert_response :success
  end

  test "should update cellar" do
    put :update, :id => @cellar.to_param, :cellar => @cellar.attributes
    assert_redirected_to cellar_path(assigns(:cellar))
  end

  test "should destroy cellar" do
    assert_difference('Cellar.count', -1) do
      delete :destroy, :id => @cellar.to_param
    end

    assert_redirected_to cellars_path
  end
end

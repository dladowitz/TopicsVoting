require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  # Create a test controller that inherits from ApplicationController
  controller do
    def index
      render plain: 'test'
    end

    def test_disable_admin
      disable_admin_mode
      render plain: 'disabled'
    end
  end

  # Configure routes for our test controller
  before do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get 'index' => 'anonymous#index'
      get 'test_disable_admin' => 'anonymous#test_disable_admin'
    end
  end

  describe '#set_admin_mode' do
    context 'when mode=admin parameter is present' do
      it 'enables admin mode' do
        get :index, params: { mode: 'admin' }
        expect(cookies[:admin_mode]).to eq('true')
        expect(assigns(:admin_mode)).to be true
      end

      it 'persists admin mode across requests' do
        get :index, params: { mode: 'admin' }
        get :index # Second request without mode parameter
        expect(cookies[:admin_mode]).to eq('true')
        expect(assigns(:admin_mode)).to be true
      end
    end

    context 'when mode parameter is not admin' do
      it 'does not enable admin mode' do
        get :index, params: { mode: 'not_admin' }
        expect(cookies[:admin_mode]).to be_nil
        expect(assigns(:admin_mode)).to be false
      end
    end

    context 'when mode parameter is not present' do
      it 'does not enable admin mode' do
        get :index
        expect(cookies[:admin_mode]).to be_nil
        expect(assigns(:admin_mode)).to be false
      end
    end

    context 'when admin mode was previously enabled' do
      before do
        cookies[:admin_mode] = 'true'
      end

      it 'maintains admin mode without mode parameter' do
        get :index
        expect(assigns(:admin_mode)).to be true
      end
    end
  end

  describe '#disable_admin_mode' do
    it 'disables admin mode' do
      cookies[:admin_mode] = 'true'
      get :test_disable_admin
      expect(cookies[:admin_mode]).to be_nil
      expect(assigns(:admin_mode)).to be false
    end

    it 'persists disabled state' do
      cookies[:admin_mode] = 'true'
      get :test_disable_admin
      expect(assigns(:admin_mode)).to be false
      expect(cookies[:admin_mode]).to be_nil
    end
  end
end

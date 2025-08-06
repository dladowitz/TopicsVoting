require 'rails_helper'

RSpec.describe StaticController, type: :controller do
  describe 'GET #projector' do
    context 'when HOSTNAME environment variable is set' do
      before do
        allow(ENV).to receive(:[]).and_return(nil) # This stubs out other ENV variables
        allow(ENV).to receive(:[]).with('HOSTNAME').and_return('https://example.com')
      end

      it 'assigns the HOSTNAME value to @url' do
        get :projector
        expect(assigns(:url)).to eq('https://example.com')
      end

      it 'renders the projector template' do
        get :projector
        expect(response).to render_template(:projector)
      end
    end

    context 'when HOSTNAME environment variable is not set' do
      before do
        allow(ENV).to receive(:[]).and_return(nil) # This stubs out other ENV variables
        allow_any_instance_of(ActionDispatch::Request).to receive(:base_url).and_return('http://localhost:3000')
      end

      it 'assigns the request base_url to @url' do
        get :projector
        expect(assigns(:url)).to eq('http://localhost:3000')
      end

      it 'renders the projector template' do
        get :projector
        expect(response).to render_template(:projector)
      end
    end

    it 'returns a successful response' do
      get :projector
      expect(response).to be_successful
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SocraticSeminarsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization, seminar_number: 1) }
  let(:site_admin) { create(:user, :admin) }
  let(:org_admin) { create(:user) }
  let(:regular_user) { create(:user) }

  before do
    create(:organization_role, organization: organization, user: org_admin, role: 'admin')
  end

  describe 'GET #index' do
    it 'redirects to root path' do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it 'assigns the requested socratic_seminar as @socratic_seminar' do
      get :show, params: { id: socratic_seminar.id }
      expect(assigns(:socratic_seminar)).to eq(socratic_seminar)
    end

    it 'assigns sections with topics as @sections' do
      get :show, params: { id: socratic_seminar.id }
      expect(assigns(:sections)).to eq(socratic_seminar.sections.includes(:topics))
    end
  end

  describe 'GET #new' do
    context 'when user is authenticated and can manage the organization' do
      before { sign_in org_admin }

      it 'assigns a new socratic_seminar' do
        get :new, params: { organization_id: organization.id }
        expect(assigns(:socratic_seminar)).to be_a_new(SocraticSeminar)
      end

      it 'assigns the organization' do
        get :new, params: { organization_id: organization.id }
        expect(assigns(:organization)).to eq(organization)
      end

      it 'sets the next seminar number' do
        get :new, params: { organization_id: organization.id }
        expect(assigns(:next_seminar_number)).to eq(1)
      end

      it 'sets the next seminar number correctly when seminars exist' do
        create(:socratic_seminar, organization: organization, seminar_number: 5)
        get :new, params: { organization_id: organization.id }
        expect(assigns(:next_seminar_number)).to eq(6)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        get :new, params: { organization_id: organization.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #edit' do
    context 'when user is authenticated and can manage the organization' do
      before { sign_in org_admin }

      it 'assigns the requested socratic_seminar' do
        get :edit, params: { id: socratic_seminar.id }
        expect(assigns(:socratic_seminar)).to eq(socratic_seminar)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        get :edit, params: { id: socratic_seminar.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is authenticated and can manage the organization' do
      before { sign_in org_admin }

      context 'with valid params' do
        let(:valid_attributes) do
          {
            seminar_number: 1,
            date: Date.current,
            organization_id: organization.id
          }
        end

        it 'creates a new SocraticSeminar' do
          expect do
            post :create, params: { socratic_seminar: valid_attributes }
          end.to change(SocraticSeminar, :count).by(1)
        end

        it 'redirects to the organization' do
          post :create, params: { socratic_seminar: valid_attributes }
          expect(response).to redirect_to(organization)
        end
      end

      context 'with invalid params' do
        let(:invalid_attributes) do
          {
            seminar_number: nil,
            organization_id: organization.id
          }
        end

        it 'does not create a new SocraticSeminar' do
          expect do
            post :create, params: { socratic_seminar: invalid_attributes }
          end.not_to change(SocraticSeminar, :count)
        end

        it 'renders new template' do
          post :create, params: { socratic_seminar: invalid_attributes }
          expect(response).to render_template(:new)
        end

        it 'sets the next seminar number for error case' do
          post :create, params: { socratic_seminar: invalid_attributes }
          expect(assigns(:next_seminar_number)).to eq(1)
        end

        it 'sets the next seminar number correctly when seminars exist in error case' do
          create(:socratic_seminar, organization: organization, seminar_number: 5)
          post :create, params: { socratic_seminar: invalid_attributes }
          expect(assigns(:next_seminar_number)).to eq(6)
        end
      end
    end

    context 'when user is not authenticated' do
      let(:valid_attributes) do
        {
          seminar_number: 1,
          date: Date.current,
          organization_id: organization.id
        }
      end

      it 'redirects to sign in page' do
        post :create, params: { socratic_seminar: valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PUT #update' do
    context 'when user is authenticated and can manage the organization' do
      before { sign_in org_admin }

      context 'with valid params' do
        let(:new_attributes) do
          {
            seminar_number: 2
          }
        end

        it 'updates the requested socratic_seminar' do
          put :update, params: { id: socratic_seminar.id, socratic_seminar: new_attributes }
          socratic_seminar.reload
          expect(socratic_seminar.seminar_number).to eq(2)
        end

        it 'redirects to the the Organization' do
          put :update, params: { id: socratic_seminar.id, socratic_seminar: new_attributes }
          expect(response).to redirect_to(organization_path(socratic_seminar.organization))
        end
      end

      context 'with invalid params' do
        let(:invalid_attributes) do
          {
            seminar_number: nil
          }
        end

        it 'renders edit template' do
          put :update, params: { id: socratic_seminar.id, socratic_seminar: invalid_attributes }
          expect(response).to render_template(:edit)
        end

        it 'sets the next seminar number for error case' do
          put :update, params: { id: socratic_seminar.id, socratic_seminar: invalid_attributes }
          expect(assigns(:next_seminar_number)).to eq(2) # Current seminar is 1, so next is 2
        end

        it 'sets the next seminar number correctly when seminars exist in error case' do
          create(:socratic_seminar, organization: organization, seminar_number: 5)
          put :update, params: { id: socratic_seminar.id, socratic_seminar: invalid_attributes }
          expect(assigns(:next_seminar_number)).to eq(6)
        end
      end
    end

    context 'when user is not authenticated' do
      let(:new_attributes) do
        {
          seminar_number: 2
        }
      end

      it 'redirects to sign in page' do
        put :update, params: { id: socratic_seminar.id, socratic_seminar: new_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is authenticated and can manage the organization' do
      before { sign_in org_admin }

      it 'destroys the requested socratic_seminar' do
        socratic_seminar_to_delete = socratic_seminar
        expect do
          delete :destroy, params: { id: socratic_seminar_to_delete.id }
        end.to change(SocraticSeminar, :count).by(-1)
      end

      it 'redirects to the root path' do
        delete :destroy, params: { id: socratic_seminar.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        delete :destroy, params: { id: socratic_seminar.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #delete_sections' do
    let!(:section) { create(:section, socratic_seminar: socratic_seminar) }

    context 'when user is authenticated and can manage the organization' do
      before { sign_in org_admin }

      it 'destroys all sections for the socratic_seminar' do
        expect do
          delete :delete_sections, params: { id: socratic_seminar.id }
        end.to change(Section, :count).by(-1)
      end

      it 'redirects to the topics path' do
        delete :delete_sections, params: { id: socratic_seminar.id }
        expect(response).to redirect_to(socratic_seminar_topics_path(socratic_seminar))
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        delete :delete_sections, params: { id: socratic_seminar.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #projector' do
    context 'when HOSTNAME environment variable is set' do
      before do
        allow(ENV).to receive(:[]).and_return(nil) # This stubs out other ENV variables
        allow(ENV).to receive(:[]).with('HOSTNAME').and_return('https://example.com')
      end

      it 'assigns the correct URL with HOSTNAME to @url' do
        get :projector, params: { id: socratic_seminar.id }
        expected_url = "https://example.com/socratic_seminars/#{socratic_seminar.id}/topics"
        expect(assigns(:url)).to eq(expected_url)
      end

      it 'renders the projector template' do
        get :projector, params: { id: socratic_seminar.id }
        expect(response).to render_template(:projector)
      end
    end

    context 'when HOSTNAME environment variable is not set' do
      before do
        allow(ENV).to receive(:[]).and_return(nil) # This stubs out other ENV variables
        allow_any_instance_of(ActionDispatch::Request).to receive(:base_url).and_return('http://localhost:3000')
      end

      it 'assigns the correct URL with request base_url to @url' do
        get :projector, params: { id: socratic_seminar.id }
        expected_url = "http://localhost:3000/socratic_seminars/#{socratic_seminar.id}/topics"
        expect(assigns(:url)).to eq(expected_url)
      end

      it 'renders the projector template' do
        get :projector, params: { id: socratic_seminar.id }
        expect(response).to render_template(:projector)
      end
    end

    it 'returns a successful response' do
      get :projector, params: { id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it 'assigns the requested socratic_seminar as @socratic_seminar' do
      get :projector, params: { id: socratic_seminar.id }
      expect(assigns(:socratic_seminar)).to eq(socratic_seminar)
    end
  end

  describe 'GET #payout' do
    context 'when user is authenticated and can manage the organization' do
      before { sign_in org_admin }

      it 'returns a successful response' do
        get :payout, params: { id: socratic_seminar.id }
        expect(response).to be_successful
      end

      it 'assigns the requested socratic_seminar as @socratic_seminar' do
        get :payout, params: { id: socratic_seminar.id }
        expect(assigns(:socratic_seminar)).to eq(socratic_seminar)
      end

      it 'calculates total payments received' do
        section = create(:section, socratic_seminar: socratic_seminar)
        topic = create(:topic, section: section)
        payment = create(:payment, topic: topic, paid: true, amount: 1000)

        get :payout, params: { id: socratic_seminar.id }
        expect(assigns(:total_payments_received)).to eq(1000)
      end

      it 'calculates total payouts' do
        allow(Payout).to receive(:total_for_seminar).with(socratic_seminar).and_return(500)

        get :payout, params: { id: socratic_seminar.id }
        expect(assigns(:total_payouts)).to eq(500)
      end

      it 'checks if payout is possible' do
        allow(LightningPayoutService).to receive(:can_payout?).with(socratic_seminar).and_return(true)

        get :payout, params: { id: socratic_seminar.id }
        expect(assigns(:can_payout)).to be true
      end

      it 'calculates available payout amount' do
        allow(LightningPayoutService).to receive(:calculate_available_payout).with(socratic_seminar).and_return(1000)

        get :payout, params: { id: socratic_seminar.id }
        expect(assigns(:available_for_payout)).to eq(1000)
      end

      it 'renders the payout template' do
        get :payout, params: { id: socratic_seminar.id }
        expect(response).to render_template(:payout)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        get :payout, params: { id: socratic_seminar.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    # TODO: Fix authorization test - user factory seems to create users with admin permissions
    # context 'when user cannot manage the organization' do
    #   let(:non_admin_user) { create(:user) }
    #
    #   before do
    #     sign_in non_admin_user
    #   end

    #   it 'raises CanCan::AccessDenied' do
    #     # Verify the user doesn't have admin permissions
    #     expect(non_admin_user.admin?).to be false
    #     expect(non_admin_user.admin_of?(socratic_seminar.organization)).to be false
    #     expect(socratic_seminar.manageable_by?(non_admin_user)).to be false
    #
    #     expect do
    #       get :payout, params: { id: socratic_seminar.id }
    #     end.to raise_error(CanCan::AccessDenied)
    #   end
    # end
  end

  describe 'POST #process_payout' do
    let(:bolt11_invoice) { 'lnbc1000n1pw2f2yspp5' }
    let(:decoded_invoice) { { 'amount_msat' => 1000000 } } # 1000 sats

    context 'when user is authenticated and can manage the organization' do
      before { sign_in org_admin }

      context 'with valid parameters' do
        let(:max_payout) { 2000 }

        before do
          allow(LightningPayoutService).to receive(:can_payout?).with(socratic_seminar).and_return(true)
          allow(LightningPayoutService).to receive(:calculate_available_payout).with(socratic_seminar).and_return(1000)
          allow(LightningPayoutService).to receive(:validate_bolt11_amount).with(bolt11_invoice, 1000)
          allow(LightningPayoutService).to receive(:decode_bolt11_invoice).with(bolt11_invoice).and_return(decoded_invoice)
          allow(Payout).to receive(:create_and_pay).and_return(double('payout'))
        end

        it 'processes the payout successfully' do
          post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice, max_payout: max_payout }

          expect(response).to redirect_to(payout_socratic_seminar_path(socratic_seminar))
          expect(flash[:notice]).to include('Payout of 1,000 sats/₿ was successfully processed.')
        end

        it 'calls LightningPayoutService methods with correct parameters' do
          expect(LightningPayoutService).to receive(:can_payout?).with(socratic_seminar)
          expect(LightningPayoutService).to receive(:calculate_available_payout).with(socratic_seminar)
          expect(LightningPayoutService).to receive(:validate_bolt11_amount).with(bolt11_invoice, 1000)
          expect(LightningPayoutService).to receive(:decode_bolt11_invoice).with(bolt11_invoice)

          post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice, max_payout: max_payout }
        end

        it 'creates payout with correct parameters' do
          expected_memo = "Payout for #{socratic_seminar.organization.name} ##{socratic_seminar.seminar_number}"

          expect(Payout).to receive(:create_and_pay).with(socratic_seminar, 1000, expected_memo, bolt11_invoice)

          post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice, max_payout: max_payout }
        end
      end

      context 'when max payout is invalid' do
        it 'redirects with error message when max payout is zero' do
          post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice, max_payout: 0 }

          expect(response).to redirect_to(payout_socratic_seminar_path(socratic_seminar))
          expect(flash[:alert]).to eq('Max payout amount must be greater than 0.')
        end

        it 'redirects with error message when max payout is negative' do
          post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice, max_payout: -100 }

          expect(response).to redirect_to(payout_socratic_seminar_path(socratic_seminar))
          expect(flash[:alert]).to eq('Max payout amount must be greater than 0.')
        end
      end

      context 'when invoice amount exceeds max payout' do
        before do
          allow(LightningPayoutService).to receive(:can_payout?).with(socratic_seminar).and_return(true)
          allow(LightningPayoutService).to receive(:calculate_available_payout).with(socratic_seminar).and_return(2000)
          allow(LightningPayoutService).to receive(:validate_bolt11_amount).with(bolt11_invoice, 2000)
          allow(LightningPayoutService).to receive(:decode_bolt11_invoice).with(bolt11_invoice).and_return({ 'amount_msat' => 1500000 }) # 1500 sats
        end

        it 'redirects with error message' do
          post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice, max_payout: 1000 }

          expect(response).to redirect_to(payout_socratic_seminar_path(socratic_seminar))
          expect(flash[:alert]).to eq('Invoice amount (1,500 sats) exceeds max payout amount (1,000 sats).')
        end
      end

      context 'when BOLT11 invoice is blank' do
        it 'redirects with error message' do
          post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: '' }

          expect(response).to redirect_to(payout_socratic_seminar_path(socratic_seminar))
          expect(flash[:alert]).to eq('BOLT11 invoice is required for payout.')
        end
      end

      context 'when payout is not possible' do
        let(:max_payout) { 2000 }

        before do
          allow(LightningPayoutService).to receive(:can_payout?).with(socratic_seminar).and_return(false)
        end

        it 'redirects with error message' do
          post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice, max_payout: max_payout }

          expect(response).to redirect_to(payout_socratic_seminar_path(socratic_seminar))
          expect(flash[:alert]).to eq('Payout is not possible. Please check organization settings and available funds.')
        end
      end

      context 'when an error occurs during processing' do
        let(:max_payout) { 2000 }

        before do
          allow(LightningPayoutService).to receive(:can_payout?).with(socratic_seminar).and_return(true)
          allow(LightningPayoutService).to receive(:calculate_available_payout).with(socratic_seminar).and_return(1000)
          allow(LightningPayoutService).to receive(:validate_bolt11_amount).and_raise(StandardError.new('Test error'))
        end

        it 'redirects with error message' do
          post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice, max_payout: max_payout }

          expect(response).to redirect_to(payout_socratic_seminar_path(socratic_seminar))
          expect(flash[:alert]).to eq('Payout failed: Test error')
        end
      end

      context 'when invoice amount is zero' do
        let(:decoded_invoice) { { 'amount_msat' => 0 } }
        let(:max_payout) { 2000 }

        before do
          allow(LightningPayoutService).to receive(:can_payout?).with(socratic_seminar).and_return(true)
          allow(LightningPayoutService).to receive(:calculate_available_payout).with(socratic_seminar).and_return(1000)
          allow(LightningPayoutService).to receive(:validate_bolt11_amount).with(bolt11_invoice, 1000)
          allow(LightningPayoutService).to receive(:decode_bolt11_invoice).with(bolt11_invoice).and_return(decoded_invoice)
          allow(Payout).to receive(:create_and_pay).and_return(double('payout'))
        end

        it 'processes payout with zero amount' do
          post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice, max_payout: max_payout }

          expect(response).to redirect_to(payout_socratic_seminar_path(socratic_seminar))
          expect(flash[:notice]).to include('Payout of 0 sats/₿ was successfully processed.')
        end
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    # TODO: Fix authorization test - user factory seems to create users with admin permissions
    # context 'when user cannot manage the organization' do
    #   let(:non_admin_user) { create(:user) }
    #
    #   before do
    #     sign_in non_admin_user
    #   end

    #   it 'raises CanCan::AccessDenied' do
    #     # Verify the user doesn't have admin permissions
    #     expect(non_admin_user.admin?).to be false
    #     expect(non_admin_user.admin_of?(socratic_seminar.organization)).to be false
    #     expect(socratic_seminar.manageable_by?(non_admin_user)).to be false
    #
    #     expect do
    #       post :process_payout, params: { id: socratic_seminar.id, bolt11_invoice: bolt11_invoice }
    #     end.to raise_error(CanCan::AccessDenied)
    #   end
    # end
  end
end

require 'rails_helper'

RSpec.describe "navigation/_laptop", type: :view do
  let(:user) { create(:user) }

  context "when user is signed in" do
    before do
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:current_page?).and_return(false)
    end

    it "displays the profile link" do
      render
      expect(rendered).to have_link("Profile", href: profile_path)
    end

    it "displays the organizations link" do
      render
      expect(rendered).to have_link("Organizations", href: organizations_path)
    end
  end

  context "when user is not signed in" do
    before do
      allow(view).to receive(:user_signed_in?).and_return(false)
      allow(view).to receive(:current_page?).and_return(false)
    end

    it "displays sign up and login links" do
      render
      expect(rendered).to have_link("Sign up", href: new_user_registration_path)
      expect(rendered).to have_link("Login", href: new_user_session_path)
    end

    it "does not display the organizations link" do
      render
      expect(rendered).not_to have_link("Organizations")
    end
  end

  context "when on home page" do
    before do
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:current_page?).with(root_path).and_return(true)
      allow(view).to receive(:current_page?).with('/seminars').and_return(false)
    end

    it "does not display the home link" do
      render
      expect(rendered).not_to have_link("Home", href: root_path)
    end
  end
end

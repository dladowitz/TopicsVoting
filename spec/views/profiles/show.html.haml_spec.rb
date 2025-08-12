require 'rails_helper'

RSpec.describe "profiles/show", type: :view do
  let(:user) { create(:user) }

  before do
    allow(view).to receive(:current_user).and_return(user)
    render
  end

  it "displays the user's email" do
    expect(rendered).to have_content(user.email)
  end

  it "displays the user's role" do
    expect(rendered).to have_content(user.role.titleize)
  end

  it "contains edit profile link" do
    expect(rendered).to have_link("Edit profile", href: edit_user_registration_path)
  end

  it "contains logout button" do
    expect(rendered).to have_button("Logout")
  end

  context "with different roles" do
    User::ROLES.each do |role|
      it "displays the #{role} role correctly" do
        user.update(role: role)
        render
        expect(rendered).to have_content(role.titleize)
      end
    end
  end
end

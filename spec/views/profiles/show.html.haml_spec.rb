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

  it "displays the user's role as User by default" do
    expect(rendered).to have_content("User")
  end

  it "displays Admin role for admin users" do
    create(:site_role, user: user, role: 'admin')
    render
    expect(rendered).to have_content("Admin")
  end

  it "contains edit profile link" do
    expect(rendered).to have_link("Edit profile", href: edit_user_registration_path)
  end

  it "contains logout button" do
    expect(rendered).to have_button("Logout")
  end
end

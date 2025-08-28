require 'rails_helper'

RSpec.describe Section, type: :model do
  describe "associations" do
    it { should belong_to(:socratic_seminar) }
    it { should have_many(:topics) }
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:section)).to be_valid
    end
  end

  describe "#allows_topic_creation_by?" do
    let(:organization) { create(:organization) }
    let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }
    let(:section) { create(:section, socratic_seminar: socratic_seminar) }
    let(:user) { create(:user) }

    context "when user is nil" do
      it "only allows creation if public submissions are enabled" do
        section.update(allow_public_submissions: true)
        expect(section.allows_topic_creation_by?(nil)).to be true

        section.update(allow_public_submissions: false)
        expect(section.allows_topic_creation_by?(nil)).to be false
      end
    end

    context "when user is a site-wide admin" do
      before do
        create(:site_role, user: user, role: "admin")
      end

      it "allows creation regardless of public submissions setting" do
        section.update(allow_public_submissions: false)
        expect(section.allows_topic_creation_by?(user)).to be true

        section.update(allow_public_submissions: true)
        expect(section.allows_topic_creation_by?(user)).to be true
      end
    end

    context "when user is an admin of the organization" do
      before do
        create(:organization_role, user: user, organization: organization, role: "admin")
      end

      it "allows creation regardless of public submissions setting" do
        section.update(allow_public_submissions: false)
        expect(section.allows_topic_creation_by?(user)).to be true

        section.update(allow_public_submissions: true)
        expect(section.allows_topic_creation_by?(user)).to be true
      end

      it "denies creation when user is admin of a different organization" do
        other_org = create(:organization)
        user.organization_roles.destroy_all
        create(:organization_role, user: user, organization: other_org, role: "admin")
        section.update(allow_public_submissions: false)
        expect(section.allows_topic_creation_by?(user)).to be false
      end
    end

    context "when user is a moderator of the organization" do
      before do
        create(:organization_role, user: user, organization: organization, role: "moderator")
      end

      it "allows creation regardless of public submissions setting" do
        section.update(allow_public_submissions: false)
        expect(section.allows_topic_creation_by?(user)).to be true

        section.update(allow_public_submissions: true)
        expect(section.allows_topic_creation_by?(user)).to be true
      end

      it "denies creation when user is moderator of a different organization" do
        other_org = create(:organization)
        user.organization_roles.destroy_all
        create(:organization_role, user: user, organization: other_org, role: "moderator")
        section.update(allow_public_submissions: false)
        expect(section.allows_topic_creation_by?(user)).to be false
      end
    end

    context "when user has no special roles" do
      it "only allows creation if public submissions are enabled" do
        section.update(allow_public_submissions: true)
        expect(section.allows_topic_creation_by?(user)).to be true

        section.update(allow_public_submissions: false)
        expect(section.allows_topic_creation_by?(user)).to be false
      end
    end
  end
end

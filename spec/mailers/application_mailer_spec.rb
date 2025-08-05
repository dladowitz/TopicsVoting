require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  # Create a test mailer that inherits from ApplicationMailer
  class TestMailer < ApplicationMailer
    def test_email
      mail(
        to: "to@example.com",
        subject: "Test Email"
      ) do |format|
        format.text { render plain: "Test email body" }
      end
    end
  end

  describe "basic functionality" do
    let(:mail) { TestMailer.test_email }

    it "sends an email" do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(mail.from).to eq([ "from@example.com" ])
      expect(mail.to).to eq([ "to@example.com" ])
    end
  end
end

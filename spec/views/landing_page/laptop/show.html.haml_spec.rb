# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "landing_page/laptop/show", type: :view do
  let(:organization) { create(:organization, name: "Bitcoin Builders", city: "San Francisco") }
  let!(:upcoming_seminar) { create(:socratic_seminar, :with_topics, date: 1.day.from_now, organization: organization) }
  let!(:future_seminar) { create(:socratic_seminar, :with_topics, date: 2.days.from_now, organization: organization) }
  let!(:past_seminar) { create(:socratic_seminar, :with_topics, date: 1.day.ago, organization: organization) }
  let(:user) { create(:user) }

  before do
    assign(:socratic_seminars, SocraticSeminar.all)
    assign(:upcoming_seminars, SocraticSeminar.upcoming.limit(10))
    assign(:past_seminars, SocraticSeminar.past.limit(10))
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:can?).and_return(false)
    render
  end

  it "displays the Lightning Voting title" do
    expect(rendered).to have_content("Lightning Voting")
  end

  it "displays voting instructions" do
    expect(rendered).to have_content("Vote for free with the Up & Down arrows")
    expect(rendered).to have_content("Send Lightning payments for additional votes")
    expect(rendered).to have_content("All payments help support the community")
  end

  it "displays upcoming events section" do
    expect(rendered).to have_content("Upcoming Events")
    expect(rendered).to have_selector(".upcoming-events .event-row", count: SocraticSeminar.upcoming.count)
  end

  it "displays past events section" do
    expect(rendered).to have_content("Past Events")
    expect(rendered).to have_selector(".past-events .event-row", count: SocraticSeminar.past.count)
  end

  it "displays event details correctly" do
    expect(rendered).to have_content("Bitcoin Builders")
    expect(rendered).to have_content("San Francisco")
    expect(rendered).to have_content("##{upcoming_seminar.seminar_number}")
  end

  context "when user can create seminars" do
    before do
      allow(view).to receive(:can?).with(:create, SocraticSeminar).and_return(true)
      render
    end

    it "displays new event link" do
      expect(rendered).to have_link("New Event", href: new_socratic_seminar_path)
    end
  end

  context "when user cannot create seminars" do
    it "does not display new event link" do
      expect(rendered).not_to have_link("New Event")
    end
  end

  it "displays footer links" do
    expect(rendered).to have_link("Sats Vs Bitcoin")
    expect(rendered).to have_link("Projector Mode")
  end

  context "when there are no events" do
    before do
      assign(:socratic_seminars, SocraticSeminar.none)
      assign(:upcoming_seminars, SocraticSeminar.none)
      assign(:past_seminars, SocraticSeminar.none)
      render
    end

    it "displays no events messages" do
      expect(rendered).to have_content("No upcoming events scheduled")
      expect(rendered).to have_content("No past events found")
    end
  end
end

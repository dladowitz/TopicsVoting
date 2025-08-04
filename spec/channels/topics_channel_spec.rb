require 'rails_helper'

RSpec.describe TopicsChannel, type: :channel do
  before do
    # Initialize connection with identifiers
    stub_connection
  end

  it "subscribes to the topics stream" do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("topics")
  end
end

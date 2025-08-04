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

  it "logs subscription with connection identifier" do
    expect { subscribe }.to output(/\[TopicsChannel\] Subscribed:/).to_stdout
  end

  it "logs unsubscription with connection identifier" do
    subscribe
    expect { unsubscribe }.to output(/\[TopicsChannel\] Unsubscribed:/).to_stdout
  end
end

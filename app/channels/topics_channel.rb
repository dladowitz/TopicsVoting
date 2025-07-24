class TopicsChannel < ApplicationCable::Channel
  def subscribed
    puts "[TopicsChannel] Subscribed: \\#{connection.connection_identifier}"
    stream_from "topics"
  end

  def unsubscribed
    puts "[TopicsChannel] Unsubscribed: \\#{connection.connection_identifier}"
    # Any cleanup needed when channel is unsubscribed
  end
end

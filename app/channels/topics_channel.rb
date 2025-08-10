# Channel for real-time topic updates
# Broadcasts changes to topics (votes, payments) to all subscribed clients
class TopicsChannel < ApplicationCable::Channel
  # Called when a client subscribes to the channel
  # Starts streaming from the "topics" stream
  # @return [void]
  def subscribed
    # puts "[TopicsChannel] Subscribed: #{connection.connection_identifier}"
    stream_from "topics"
  end

  # Called when a client unsubscribes from the channel
  # Performs any necessary cleanup
  # @return [void]
  def unsubscribed
    # puts "[TopicsChannel] Unsubscribed: #{connection.connection_identifier}"
    # Any cleanup needed when channel is unsubscribed
  end
end

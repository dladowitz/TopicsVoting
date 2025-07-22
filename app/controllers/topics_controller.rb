class TopicsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  def index
    @topics = Topic.order(votes: :desc)
    @vote_states = session[:votes] || {}
  end

  def show
    @topic = Topic.find(params[:id])
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params)
    if @topic.save
      @topic.update!(lnurl: generate_lnurl(@topic.id))
      redirect_to @topic
    else
      render :new
    end
  end

  def upvote
    @topic = Topic.find(params[:id])
    session[:votes] ||= {}
    vote_state = session[:votes][@topic.id.to_s]

    case vote_state
    when 'up'
      # Already upvoted, do nothing
    when 'down'
      # User previously downvoted, revert to original state
      @topic.increment!(:votes, 1)
      session[:votes].delete(@topic.id.to_s)
    else
      @topic.increment!(:votes, 1)
      session[:votes][@topic.id.to_s] = 'up'
    end
    redirect_to topics_path
  end

  def downvote
    @topic = Topic.find(params[:id])
    session[:votes] ||= {}
    vote_state = session[:votes][@topic.id.to_s]

    case vote_state
    when 'down'
      # Already downvoted, do nothing
    when 'up'
      # User previously upvoted, revert to original state
      @topic.decrement!(:votes, 1)
      session[:votes].delete(@topic.id.to_s)
    else
      @topic.decrement!(:votes, 1)
      session[:votes][@topic.id.to_s] = 'down'
    end
    redirect_to topics_path
  end

  private

  def topic_params
    params.require(:topic).permit(:name)
  end

  def generate_lnurl(topic_id)
    url = "https://enough-hound-destined.ngrok-free.app/lnurl-pay/#{topic_id}"
    data = url.unpack("C*")
    words = Bech32.convert_bits(data, 8, 5, true)
    Bech32.encode("lnurl", words, :bech32)
  end
end

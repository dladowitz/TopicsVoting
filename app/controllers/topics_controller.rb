class TopicsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'
  before_action :set_socratic_seminar
  before_action :set_topic, only: [:show, :upvote, :downvote]

  def index
    @topics = @socratic_seminar.topics.order(votes: :desc)
    @vote_states = session[:votes] || {}
  end

  def show
  end

  def new
    @topic = @socratic_seminar.topics.new
    @topic.socratic_seminar_id = params[:socratic_seminar_id] if params[:socratic_seminar_id]
  end

  def create
    @topic = @socratic_seminar.topics.new(topic_params)
    if @topic.save
      @topic.update!(lnurl: generate_lnurl(@topic.id))
      redirect_to [@socratic_seminar, @topic]
    else
      render :new
    end
  end

  def upvote
    session[:votes] ||= {}
    vote_state = session[:votes][@topic.id.to_s]

    case vote_state
    when 'up'
      # Already upvoted, do nothing
    when 'down'
      @topic.increment!(:votes, 1)
      session[:votes].delete(@topic.id.to_s)
    else
      @topic.increment!(:votes, 1)
      session[:votes][@topic.id.to_s] = 'up'
    end
    redirect_to [@socratic_seminar, :topics]
  end

  def downvote
    session[:votes] ||= {}
    vote_state = session[:votes][@topic.id.to_s]

    case vote_state
    when 'down'
      # Already downvoted, do nothing
    when 'up'
      @topic.decrement!(:votes, 1)
      session[:votes].delete(@topic.id.to_s)
    else
      @topic.decrement!(:votes, 1)
      session[:votes][@topic.id.to_s] = 'down'
    end
    redirect_to [@socratic_seminar, :topics]
  end

  private

  def set_socratic_seminar
    @socratic_seminar = SocraticSeminar.find(params[:socratic_seminar_id])
  end

  def set_topic
    @topic = @socratic_seminar.topics.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:name, :link, :socratic_seminar_id)
  end

  def generate_lnurl(topic_id)
    url = "https://enough-hound-destined.ngrok-free.app/lnurl-pay/#{topic_id}"
    data = url.unpack("C*")
    words = Bech32.convert_bits(data, 8, 5, true)
    Bech32.encode("lnurl", words, :bech32)
  end
end

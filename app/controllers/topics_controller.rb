class TopicsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  def index
    @topics = Topic.all
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

class TopicsController < ApplicationController
  def index
    @topics = Topic.all
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params)
    if @topic.save
      redirect_to topics_path, notice: 'Topic was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def topic_params
    params.require(:topic).permit(:name, :description)
  end
end

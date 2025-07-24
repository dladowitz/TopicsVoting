class TopicsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'
  before_action :set_socratic_seminar
  before_action :set_topic, only: [:show, :edit, :update, :destroy, :upvote, :downvote]

  def index
    @topics = @socratic_seminar.topics.order(Arel.sql('COALESCE(votes, 0) DESC'), :id)
    @sections = @socratic_seminar.sections.order(:id)
    @vote_states = session[:votes] || {}
  end

  def show
  end

  def new
    @topic = @socratic_seminar.topics.new
    @topic.socratic_seminar_id = params[:socratic_seminar_id] if params[:socratic_seminar_id]
    @sections = @socratic_seminar.sections
  end

  def create
    @topic = @socratic_seminar.topics.new(topic_params)
    if @topic.save
      redirect_to [@socratic_seminar, @topic]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @topic.update(topic_params)
      redirect_to [@socratic_seminar, @topic], notice: "Topic was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @topic.destroy!
    redirect_to [@socratic_seminar, :topics], notice: "Topic was successfully destroyed."
  end

  def import_sections_and_topics
    # Call the rake task with the seminar number
    builder_number = @socratic_seminar.seminar_number.to_s
    
    # Capture the output from the rake task
    output = `cd #{Rails.root} && bin/rails "import:import_sections_and_topics[#{builder_number}]" 2>&1`
    
    if $?.success?
      redirect_to [@socratic_seminar, :topics], notice: "Import completed successfully. #{output.lines.last}"
    else
      redirect_to [@socratic_seminar, :topics], alert: "Import failed: #{output.lines.last}"
    end
  end

  def upvote
    session[:votes] ||= {}
    vote_state = session[:votes][@topic.id.to_s]

    case vote_state
    when 'up'
      # Already upvoted, do nothing
    when 'down'
      @topic.votes = (@topic.votes || 0) + 1
      @topic.save!
      session[:votes].delete(@topic.id.to_s)
    else
      @topic.votes = (@topic.votes || 0) + 1
      @topic.save!
      session[:votes][@topic.id.to_s] = 'up'
    end

    respond_to do |format|
      format.html { redirect_to [@socratic_seminar, :topics] }
      format.json {
        render json: {
          vote_count: @topic.votes,
          vote_state: session[:votes][@topic.id.to_s]
        }
      }
    end
  end

  def downvote
    session[:votes] ||= {}
    vote_state = session[:votes][@topic.id.to_s]

    case vote_state
    when 'down'
      # Already downvoted, do nothing
    when 'up'
      @topic.votes = (@topic.votes || 0) - 1
      @topic.save!
      session[:votes].delete(@topic.id.to_s)
    else
      @topic.votes = (@topic.votes || 0) - 1
      @topic.save!
      session[:votes][@topic.id.to_s] = 'down'
    end

    respond_to do |format|
      format.html { redirect_to [@socratic_seminar, :topics] }
      format.json {
        render json: {
          vote_count: @topic.votes,
          vote_state: session[:votes][@topic.id.to_s]
        }
      }
    end
  end

  private

  def set_socratic_seminar
    @socratic_seminar = SocraticSeminar.find(params[:socratic_seminar_id])
  end

  def set_topic
    @topic = @socratic_seminar.topics.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:name, :link, :socratic_seminar_id, :section_id)
  end
end

# Controller for managing topics within Socratic Seminars
# Handles CRUD operations, voting, and importing topics
class TopicsController < ApplicationController
  include ScreenSizeConcern
  require "net/http"
  require "uri"
  require "json"

  before_action :set_socratic_seminar
  before_action :set_topic, only: [ :show, :edit, :update, :destroy, :upvote, :downvote ]

  # Lists all topics for a seminar, ordered by vote count
  # @return [void]
  def index
    @topics = @socratic_seminar.topics.order(Arel.sql("COALESCE(votes, 0) DESC"), :id)
    @sections = @socratic_seminar.sections.order(:id)
    @vote_states = session[:votes] || {}

    # Render the appropriate view based on the layout
    render "topics/#{current_layout}/index"
  end

  # Shows details for a specific topic
  # @return [void]
  def show
    # Render the appropriate view based on the layout
    render "topics/#{current_layout}/show"
  end

  # Displays form for creating a new topic
  # @return [void]
  def new
    @topic = Topic.new
    @sections = @socratic_seminar.sections
  end

  # Creates a new topic
  # @return [void]
  def create
    @topic = Topic.new(topic_params)
    if @topic.save
      redirect_to [ @socratic_seminar, :topics ]
    else
      @sections = @socratic_seminar.sections
      render :new
    end
  end

  # Displays form for editing a topic
  # @return [void]
  def edit
  end

  # Updates an existing topic
  # @return [void]
  def update
    if @topic.update(topic_params)
      redirect_to [ @socratic_seminar, @topic ], notice: "Topic was successfully updated."
    else
      render :edit
    end
  end

  # Deletes a topic
  # @return [void]
  def destroy
    @topic.destroy!
    redirect_to [ @socratic_seminar, :topics ], notice: "Topic was successfully destroyed."
  end



  # Upvotes a topic
  # @note Handles vote state transitions and updates session
  # @return [void]
  def upvote
    session[:votes] ||= {}
    vote_state = session[:votes][@topic.id.to_s]

    case vote_state
    when "up"
      # Already upvoted, do nothing
    when "down"
      @topic.votes = (@topic.votes || 0) + 1
      @topic.save!
      session[:votes].delete(@topic.id.to_s)
    else
      @topic.votes = (@topic.votes || 0) + 1
      @topic.save!
      session[:votes][@topic.id.to_s] = "up"
    end

    respond_to do |format|
      format.html { redirect_to [ @socratic_seminar, :topics ] }
      format.json {
        render json: {
          vote_count: @topic.votes,
          vote_state: session[:votes][@topic.id.to_s]
        }
      }
    end
  end

  # Downvotes a topic
  # @note Handles vote state transitions and updates session
  # @return [void]
  def downvote
    session[:votes] ||= {}
    vote_state = session[:votes][@topic.id.to_s]

    case vote_state
    when "down"
      # Already downvoted, do nothing
    when "up"
      @topic.votes = (@topic.votes || 0) - 1
      @topic.save!
      session[:votes].delete(@topic.id.to_s)
    else
      @topic.votes = (@topic.votes || 0) - 1
      @topic.save!
      session[:votes][@topic.id.to_s] = "down"
    end

    respond_to do |format|
      format.html { redirect_to [ @socratic_seminar, :topics ] }
      format.json {
        render json: {
          vote_count: @topic.votes,
          vote_state: session[:votes][@topic.id.to_s]
        }
      }
    end
  end

  private

  # Sets the current socratic seminar from params
  # @return [void]
  def set_socratic_seminar
    @socratic_seminar = SocraticSeminar.find(params[:socratic_seminar_id])
  end

  # Sets the current topic from params
  # @return [void]
  def set_topic
    @topic = @socratic_seminar.topics.find(params[:id])
  end

  # Whitelists allowed topic parameters
  # @return [ActionController::Parameters] Permitted parameters
  def topic_params
    params.require(:topic).permit(:name, :link, :section_id)
  end
end

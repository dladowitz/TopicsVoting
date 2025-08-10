# Controller for managing Socratic Seminars
# Handles CRUD operations and section management for seminars
class SocraticSeminarsController < ApplicationController
  include ScreenSizeConcern
  before_action :set_socratic_seminar, only: %i[ show edit update destroy delete_sections ]

  # Lists all seminars, ordered by date descending
  # @return [void]
  def index
    @socratic_seminars = SocraticSeminar.all.order(date: :desc)
    render "socratic_seminars/#{current_layout}/index"
  end

  # Shows details for a specific seminar
  # @return [void]
  def show
    render "socratic_seminars/#{current_layout}/show"
  end

  # Displays form for creating a new seminar
  # @return [void]
  def new
    @socratic_seminar = SocraticSeminar.new
  end

  # Displays form for editing a seminar
  # @return [void]
  def edit
  end

  # Creates a new seminar
  # @return [void]
  def create
    @socratic_seminar = SocraticSeminar.new(socratic_seminar_params)

    respond_to do |format|
      if @socratic_seminar.save
        format.html { redirect_to @socratic_seminar, notice: "Socratic seminar was successfully created." }
        format.json { render :show, status: :created, location: @socratic_seminar }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @socratic_seminar.errors, status: :unprocessable_content }
      end
    end
  end

  # Updates an existing seminar
  # @return [void]
  def update
    respond_to do |format|
      if @socratic_seminar.update(socratic_seminar_params)
        format.html { redirect_to @socratic_seminar, notice: "Socratic seminar was successfully updated." }
        format.json { render :show, status: :ok, location: @socratic_seminar }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @socratic_seminar.errors, status: :unprocessable_content }
      end
    end
  end

  # Deletes a seminar and all associated records
  # @note Also deletes all sections, topics, and payments
  # @return [void]
  def destroy
    @socratic_seminar.sections.each do |section|
      section.topics.each do |topic|
        topic.payments.destroy_all
        topic.destroy!
      end
      section.destroy!
    end

    @socratic_seminar.destroy!

    respond_to do |format|
      format.html { redirect_to socratic_seminars_path, status: :see_other, notice: "Socratic seminar was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Disables admin mode and redirects to seminars list
  # @return [void]
  def disable_admin_mode_action
    disable_admin_mode
    redirect_to socratic_seminars_path, notice: "Admin mode has been disabled."
  end

  # Deletes all sections (and associated topics/payments) for a seminar
  # @note Maintains referential integrity by deleting in correct order
  # @return [void]
  def delete_sections
    # Find all sections belonging to this socratic seminar
    sections = @socratic_seminar.sections

    # Find all topics belonging to these sections
    topic_ids = sections.joins(:topics).pluck("topics.id")
    topics = Topic.where(id: topic_ids)

    # Find all payments belonging to these topics
    payment_ids = topics.joins(:payments).pluck("payments.id")
    payments = Payment.where(id: payment_ids)

    # Delete in the correct order to avoid foreign key constraint issues
    payments.destroy_all
    topics.destroy_all
    sections.destroy_all

    redirect_to socratic_seminar_topics_path(@socratic_seminar), notice: "All sections, topics, and payments for this seminar have been deleted."
  end

  private

  # Sets the current seminar from params
  # @return [void]
  def set_socratic_seminar
    @socratic_seminar = SocraticSeminar.find(params.expect(:id))
  end

  # Whitelists allowed seminar parameters
  # @return [ActionController::Parameters] Permitted parameters
  def socratic_seminar_params
    params.expect(socratic_seminar: [ :seminar_number, :date ])
  end
end

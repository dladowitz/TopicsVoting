class SocraticSeminarsController < ApplicationController
  before_action :set_socratic_seminar, only: %i[ show edit update destroy delete_sections ]

  # GET /socratic_seminars or /socratic_seminars.json
  def index
    @socratic_seminars = SocraticSeminar.all.order(date: :desc)
  end

  # GET /socratic_seminars/1 or /socratic_seminars/1.json
  def show
  end

  # GET /socratic_seminars/new
  def new
    @socratic_seminar = SocraticSeminar.new
  end

  # GET /socratic_seminars/1/edit
  def edit
  end

  # POST /socratic_seminars or /socratic_seminars.json
  def create
    @socratic_seminar = SocraticSeminar.new(socratic_seminar_params)

    respond_to do |format|
      if @socratic_seminar.save
        format.html { redirect_to @socratic_seminar, notice: "Socratic seminar was successfully created." }
        format.json { render :show, status: :created, location: @socratic_seminar }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @socratic_seminar.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /socratic_seminars/1 or /socratic_seminars/1.json
  def update
    respond_to do |format|
      if @socratic_seminar.update(socratic_seminar_params)
        format.html { redirect_to @socratic_seminar, notice: "Socratic seminar was successfully updated." }
        format.json { render :show, status: :ok, location: @socratic_seminar }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @socratic_seminar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /socratic_seminars/1 or /socratic_seminars/1.json
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

  # POST /socratic_seminars/disable_admin_mode
  def disable_admin_mode_action
    disable_admin_mode
    redirect_to socratic_seminars_path, notice: "Admin mode has been disabled."
  end

  # DELETE /socratic_seminars/:id/delete_sections
  def delete_sections
    # Find all sections belonging to this socratic seminar
    sections = @socratic_seminar.sections
    
    # Find all topics belonging to these sections
    topic_ids = sections.joins(:topics).pluck('topics.id')
    topics = Topic.where(id: topic_ids)
    
    # Find all payments belonging to these topics
    payment_ids = topics.joins(:payments).pluck('payments.id')
    payments = Payment.where(id: payment_ids)
    
    # Delete in the correct order to avoid foreign key constraint issues
    payments.destroy_all
    topics.destroy_all
    sections.destroy_all
    
    redirect_to socratic_seminar_topics_path(@socratic_seminar), notice: "All sections, topics, and payments for this seminar have been deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_socratic_seminar
      @socratic_seminar = SocraticSeminar.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def socratic_seminar_params
      params.expect(socratic_seminar: [ :seminar_number, :date ])
    end
end

# frozen_string_literal: true

class SocraticSeminarsController < ApplicationController
  include ScreenSizeConcern
  before_action :authenticate_user!, except: [ :show, :projector, :index ]
  before_action :set_socratic_seminar, only: [ :show, :edit, :update, :destroy, :delete_sections, :projector, :payout ]
  load_and_authorize_resource except: [ :show, :projector, :new, :create ]

  def index
    redirect_to root_path
  end

  def show
    @sections = @socratic_seminar.sections.includes(:topics)
  end

  def new
    @organization = Organization.find(params[:organization_id])
    authorize! :create, SocraticSeminar
    @socratic_seminar = SocraticSeminar.new
    @next_seminar_number = SocraticSeminar.next_seminar_number_for(@organization)
    render "socratic_seminars/#{current_layout}/new"
  end

  def edit
    render "socratic_seminars/#{current_layout}/edit"
  end

  def create
    @socratic_seminar = SocraticSeminar.new(socratic_seminar_params)
    @organization = @socratic_seminar.organization
    authorize! :create, @socratic_seminar

    if @socratic_seminar.save
      redirect_to @organization, notice: "Event was successfully created."
    else
      @next_seminar_number = SocraticSeminar.next_seminar_number_for(@organization)
      render "socratic_seminars/#{current_layout}/new", status: :ok
    end
  end

  def update
    if @socratic_seminar.update(socratic_seminar_params)
      redirect_to organization_path(@socratic_seminar.organization), notice: "Event was successfully updated."
    else
      @next_seminar_number = SocraticSeminar.next_seminar_number_for(@socratic_seminar.organization)
      render "socratic_seminars/#{current_layout}/edit", status: :ok
    end
  end

  def destroy
    @socratic_seminar.destroy!
    redirect_to root_path, notice: "Event was successfully destroyed."
  end

  def delete_sections
    @socratic_seminar.sections.destroy_all
    redirect_to socratic_seminar_topics_path(@socratic_seminar), notice: "All sections were successfully deleted."
  end

  # Renders the projector view for a specific seminar
  # @note Used for displaying topics in presentation mode
  # @return [void]
  def projector
    @url = "#{ENV['HOSTNAME'] || request.base_url}/socratic_seminars/#{@socratic_seminar.id}/topics"

    render "socratic_seminars/#{current_layout}/projector"
  end

  # Renders the payout view for managing Bitcoin received for a seminar
  # @note Only accessible to users who can manage the organization
  # @return [void]
  def payout
    unless @socratic_seminar.manageable_by?(current_user)
      raise CanCan::AccessDenied
    end

    # Calculate total payments received for this seminar
    @total_payments_received = @socratic_seminar.topics.joins(:payments)
                                                 .where(payments: { paid: true })
                                                 .sum("payments.amount")

    # Placeholder for total payouts (will be implemented later)
    @total_payouts = 0

    render "socratic_seminars/#{current_layout}/payout"
  end

  private

  def set_socratic_seminar
    @socratic_seminar = SocraticSeminar.find(params[:id])
  end

  def socratic_seminar_params
    params.require(:socratic_seminar).permit(:seminar_number, :date, :organization_id, :topics_list_url)
  end
end

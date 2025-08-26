# frozen_string_literal: true

class SocraticSeminarsController < ApplicationController
  include ScreenSizeConcern
  include ApplicationHelper
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

    # Calculate total payouts already made
    @total_payouts = Payout.total_for_seminar(@socratic_seminar)

    # Check if payout is possible
    @can_payout = LightningPayoutService.can_payout?(@socratic_seminar)
    @available_for_payout = LightningPayoutService.calculate_available_payout(@socratic_seminar)

    render "socratic_seminars/#{current_layout}/payout"
  end

  # Processes a payout to the organization
  # @note Only accessible to users who can manage the organization
  # @return [void]
  def process_payout
    unless @socratic_seminar.manageable_by?(current_user)
      raise CanCan::AccessDenied
    end

    # Get the BOLT11 invoice from params
    bolt11_invoice = params[:bolt11_invoice]&.strip

    # Validate that BOLT11 invoice is provided
    if bolt11_invoice.blank?
      redirect_to payout_socratic_seminar_path(@socratic_seminar),
                  alert: "BOLT11 invoice is required for payout."
      return
    end

    # Validate that payout is possible
    unless LightningPayoutService.can_payout?(@socratic_seminar)
      redirect_to payout_socratic_seminar_path(@socratic_seminar),
                  alert: "Payout is not possible. Please check organization settings and available funds."
      return
    end

    # Get the amount to pay (all available funds)
    amount_sats = LightningPayoutService.calculate_available_payout(@socratic_seminar)
    memo = "Payout for #{@socratic_seminar.organization.name} ##{@socratic_seminar.seminar_number}"

    begin
      # Validate BOLT11 invoice amount is not larger than available amount
      LightningPayoutService.validate_bolt11_amount(bolt11_invoice, amount_sats)

      # Get the actual amount from the invoice for payment
      decoded_invoice = LightningPayoutService.decode_bolt11_invoice(bolt11_invoice)
      invoice_amount_sats = (decoded_invoice["amount_msat"] || 0) / 1000

      # Create and process the payout with the invoice amount
      payout = Payout.create_and_pay(@socratic_seminar, invoice_amount_sats, memo, bolt11_invoice)

      puts "\n\n ->>>>>>>> Payout successful: #{payout.inspect} \n\n"

      redirect_to payout_socratic_seminar_path(@socratic_seminar),
                  notice: "Payout of #{format_with_commas(invoice_amount_sats)} sats/₿ was successfully processed."
    rescue StandardError => e
      redirect_to payout_socratic_seminar_path(@socratic_seminar),
                  alert: "Payout failed: #{e.message}"
    end
  end

  private

  def set_socratic_seminar
    @socratic_seminar = SocraticSeminar.find(params[:id])
  end

  def socratic_seminar_params
    params.require(:socratic_seminar).permit(:seminar_number, :date, :organization_id, :topics_list_url)
  end
end

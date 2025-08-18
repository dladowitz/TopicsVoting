class OrganizationsController < ApplicationController
  include ScreenSizeConcern
  layout :current_layout
  before_action :authenticate_user!
  before_action :set_organization, only: [ :show, :edit, :update, :destroy ]
  load_and_authorize_resource except: [ :index, :settings ]

  def index
    @organizations = Organization.accessible_by(current_ability)
    render "organizations/#{current_layout}/index"
  end

  def show
    @active_tab = "overview"
    render "organizations/#{current_layout}/show"
  end

  def settings
    @organization = Organization.find(params[:id])
    authorize! :settings, @organization
    @active_tab = "settings"
    render "organizations/#{current_layout}/settings"
  end

  def new
    @organization = Organization.new
    render "organizations/#{current_layout}/new"
  end

  def edit
    render "organizations/#{current_layout}/edit"
  end

  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      redirect_to @organization, notice: "Organization was successfully created."
    else
      render "organizations/#{current_layout}/new", status: :unprocessable_content
    end
  end

  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: "Organization was successfully updated."
    else
      render "organizations/#{current_layout}/edit", status: :unprocessable_content
    end
  end

  def destroy
    @organization.destroy
    redirect_to organizations_url, notice: "Organization was successfully deleted."
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name, :city, :country, :website)
  end
end

class OrganizationsController < ApplicationController
  include ScreenSizeConcern
  layout :current_layout
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_organization, only: [ :show, :edit, :update, :destroy ]

  def index
    @organizations = Organization.all
    render "organizations/#{current_layout}/index"
  end

  def show
    render "organizations/#{current_layout}/show"
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
      render "organizations/#{current_layout}/new", status: :unprocessable_entity
    end
  end

  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: "Organization was successfully updated."
    else
      render "organizations/#{current_layout}/edit", status: :unprocessable_entity
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

  def ensure_admin
    unless current_user.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end

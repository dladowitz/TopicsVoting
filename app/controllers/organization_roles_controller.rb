# frozen_string_literal: true

class OrganizationRolesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization, except: :destroy

  def create
    @user = User.find_by(email: params[:email])

    if @user.nil?
      redirect_to settings_organization_path(@organization), alert: "User not found."
      return
    end

    @organization_role = @organization.organization_roles.build(user: @user, role: params[:role])
    authorize! :create, @organization_role

    if @organization_role.save
      redirect_to settings_organization_path(@organization), notice: "Role was successfully assigned."
    else
      redirect_to settings_organization_path(@organization), alert: @organization_role.errors.full_messages.to_sentence
    end
  end

  def destroy
    @user = User.find(params[:id])
    @organization_role = @organization.organization_roles.find_by(user: @user, role: params[:role])

    if @organization_role.nil?
      head :not_found
      return
    end

    authorize! :destroy, @organization_role
    @organization_role.destroy
    redirect_to settings_organization_path(@organization), notice: "Role was successfully removed."
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end
end

# frozen_string_literal: true

class SocraticSeminarsController < ApplicationController
  include ScreenSizeConcern
  before_action :set_socratic_seminar, only: [ :show, :edit, :update, :destroy, :delete_sections ]

  def index
    redirect_to root_path
  end

  def show
    @sections = @socratic_seminar.sections.includes(:topics)
  end

  def new
    @organization = Organization.find(params[:organization_id])
    @socratic_seminar = SocraticSeminar.new
  end

  def edit
    render "socratic_seminars/#{current_layout}/edit"
  end

  def create
    @socratic_seminar = SocraticSeminar.new(socratic_seminar_params)
    @organization = @socratic_seminar.organization

    if @socratic_seminar.save
      redirect_to @organization, notice: "Event was successfully created."
    else
      render :new, status: :ok
    end
  end

  def update
    if @socratic_seminar.update(socratic_seminar_params)
      redirect_to @socratic_seminar, notice: "Event was successfully updated."
    else
      render :edit, status: :ok
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

  private

  def set_socratic_seminar
    @socratic_seminar = SocraticSeminar.find(params[:id])
  end

  def socratic_seminar_params
    params.require(:socratic_seminar).permit(:seminar_number, :date, :organization_id)
  end
end

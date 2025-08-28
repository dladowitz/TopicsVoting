# frozen_string_literal: true

# Controller for managing sections within Socratic Seminars
class SectionsController < ApplicationController
  include ScreenSizeConcern
  before_action :set_socratic_seminar
  before_action :set_section, only: [ :edit, :update, :destroy ]

  def new
    @section = @socratic_seminar.sections.build
    @next_order = @socratic_seminar.sections.count
    render "sections/laptop/new"
  end

  def create
    @section = @socratic_seminar.sections.build(section_params)

    # Set default order if not provided
    if @section.order.nil?
      @section.order = @socratic_seminar.sections.count
    end

    if @section.save
      redirect_to edit_socratic_seminar_path(@socratic_seminar), notice: "Section was successfully created."
    else
      render "sections/laptop/new", status: :unprocessable_content and return
    end
  end

  def edit
    render "sections/laptop/edit"
  end

  def update
    if @section.update(section_params)
      redirect_to edit_socratic_seminar_path(@socratic_seminar), notice: "Section was successfully updated."
    else
      render "sections/laptop/edit", status: :unprocessable_content and return
    end
  end

  def destroy
    @section.destroy
    redirect_to edit_socratic_seminar_path(@socratic_seminar), notice: "Section was successfully deleted."
  end

  private

  def set_socratic_seminar
    @socratic_seminar = SocraticSeminar.find(params[:socratic_seminar_id])
  end

  def set_section
    @section = Section.find(params[:id])
  end

  def section_params
    params.require(:section).permit(:name, :order, :allow_public_submissions)
  end
end

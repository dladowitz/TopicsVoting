class SocraticSeminarsController < ApplicationController
  before_action :set_socratic_seminar, only: %i[ show edit update destroy ]

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
    @socratic_seminar.destroy!

    respond_to do |format|
      format.html { redirect_to socratic_seminars_path, status: :see_other, notice: "Socratic seminar was successfully destroyed." }
      format.json { head :no_content }
    end
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

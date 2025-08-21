# Controller for importing topics into a Socratic Seminar
class ImportTopicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_socratic_seminar
  before_action :authorize_import!

  # Shows the import topics page
  # @return [void]
  def show
  end

  # Performs the import operation
  # @return [void]
  def create
    @success, @import_output = ImportService.import_sections_and_topics(@socratic_seminar)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("import_results",
            partial: "import_results",
            locals: { success: @success, import_output: @import_output })
        ]
      end
      format.html do
        if @success
          flash[:notice] = "Import completed successfully"
        else
          flash[:alert] = "Import failed"
        end
        redirect_to socratic_seminar_import_topics_path(@socratic_seminar)
      end
    end
  end

  private

  def set_socratic_seminar
    @socratic_seminar = SocraticSeminar.find(params[:socratic_seminar_id])
  end

  def authorize_import!
    unless current_user.can_manage?(@socratic_seminar)
      redirect_to socratic_seminar_topics_path(@socratic_seminar),
                  alert: "You are not authorized to import topics for this seminar"
    end
  end
end

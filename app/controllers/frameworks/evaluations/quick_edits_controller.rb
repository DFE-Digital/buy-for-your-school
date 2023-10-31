class Frameworks::Evaluations::QuickEditsController < Frameworks::ApplicationController
  include HasDateParams

  before_action :evaluation, only: %i[edit update]

  def edit
    @quick_edit = @evaluation.quick_editor
  end

  def update
    @quick_edit = @evaluation.quick_editor(**quick_edit_params)

    if @quick_edit.valid?
      @quick_edit.save!

      redirect_to(after_update_redirect_path, notice: "Evaluation updated")
    else
      render :edit
    end
  end

private

  def after_update_redirect_path
    if params[:redirect_back].present?
      Base64.decode64(params[:redirect_back])
    else
      frameworks_root_path(anchor: "evaluations")
    end
  end

  def evaluation
    @evaluation = Frameworks::Evaluation.find(params[:evaluation_id])
  end

  def quick_edit_params
    form_params
      .except("next_key_date(3i)", "next_key_date(2i)", "next_key_date(1i)")
      .merge(next_key_date: date_param(:quick_edit, :next_key_date).compact_blank)
      .to_h
      .symbolize_keys
  end

  def form_params
    params.require(:quick_edit).permit(:note, :next_key_date, :next_key_date_description)
  end
end

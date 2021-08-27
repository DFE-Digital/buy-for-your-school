# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update]

  def index
    render :show
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params) && @user == @current_user
      redirect_to @current_user, notice: I18n.t("user.updated_flash")
    else
      render :edit
    end
  end

private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:id, :full_name, :email, :phone_number)
  end
end

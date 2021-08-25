# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    render :show
  end

  def show; end

  def edit; end

  def update
    if @current_user.update(user_params)
      redirect_to @current_user, notice: "User updated."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:id, :full_name, :email, :phone_number, :contact_preferences)
  end
end

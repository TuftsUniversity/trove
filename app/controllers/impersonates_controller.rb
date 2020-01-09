class ImpersonatesController < ApplicationController
  before_action :admin?
  respond_to :html, :json
  
  def index
    @users = User.all
    respond_with(@users)
  end

  def impersonate
    user = User.find(params[:id])
    impersonate_user(user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end

  def admin?
    current_user.admin?
  end
end

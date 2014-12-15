class AdminUpgradesController < ApplicationController
  before_filter :authenticate_user!
  skip_authorization_check

  def new
  end

  def create
    raise CanCan::AccessDenied.new("Incorrect Access code") unless params[:access_code] == @tenant.admin_upgrade_code

    current_user.add_role :super_admin
    flash[:notice] = "Successfully upgraded to super_admin"
    redirect_to root_path
  end
end
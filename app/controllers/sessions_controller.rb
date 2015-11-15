class SessionsController < ApplicationController
  skip_before_action :authenticate

  def new
    if logged_in?
      redirect_to after_signin_path
    else
      redirect_to '/auth/cobot'
    end
  end

  def create
    user = User.where(cobot_id: auth.uid).first || User.create(cobot_id: auth.uid)
    session[:current_user_id] = user.id
    create_spaces user

    redirect_to after_signin_path
  end

  private

  def after_signin_path
    session.delete(:return_to) || spaces_path
  end

  def create_spaces(user)
    auth.extra.raw_info.admin_of.each do |admin|
      space = Space.where(subdomain: admin.space_subdomain).first ||
        Space.create!(subdomain: admin.space_subdomain)
      user.admins.create access_token: auth.credentials.token, space: space
      space.update name: admin.space_name
    end
  end

  def auth
    request.env['omniauth.auth']
  end
end

class PagesController < ApplicationController

  def admin 
    redirect_to root_url unless (user_signed_in? and current_user.admin?)
  end

  def home
  end
end

class UsersController < ApplicationController
before_filter :authenticate_user!

  def show
    @user = User.find(params[:id])
    unless @user
      render json: { errors: "Couldn't find game" }, status: 422
      return
    end
    respond_to do |format|
        format.html # show.html.erb
        format.xml { render :xml => @user }
    end
  end
end

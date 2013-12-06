class UsersController < ApplicationController
before_filter :authenticate_user!

  def show
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      # TODO: do this inside the respond_to block with the appropriate format
      return render text: "Invalid user ID"
    end
    respond_to do |format|
        format.html # show.html.erb
        format.xml { render xml: @user }
        format.json { render json: @user}
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
   
    respond_to do |format|
      if @user.update(params[:user].permit(:gender, :school, :about))
        format.json { respond_with_bip(@user) }
      else
        format.json { respond_with_bip(@user) }
      end
    end
  end
end

class GamesController < ApplicationController
  before_action :load_game, only: :create
  load_and_authorize_resource
  skip_load_and_authorize_resource only: [:competition, :create_game, :open_games, :compile, :execute]
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  require('open3')

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show

  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render action: 'show', status: :created, location: @game }
      else
        format.html { render action: 'new' }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end

  # Public actions - accessible by non-admins
  def open_games
    @games = Game.where(winner_id: -1).where(player2_id: -1)
    # render json will include only table attributes without asking for
    # additional details
    render json: @games.as_json(only: [:id, :problem_id, :time_limit, :rating], methods: [:rating])
  end

  def join
    @game = Game.find(params[:id])
    unless @game
      render json: { errors: "Couldn't find game" }, status: 422
      return
    end

    if @game.player1_id == @game.player2_id
      render json: { errors: "Can't join your own game" }, status: 422
      return
    end
    if @game.player2_id != -1
      render json: { errors: "Game is full" }, status: 422
      return
    end

    @game.player2_id = current_user.id
    time = Time.now
    @game.joinTime = time.to_f
    if @game.save
      render json: { head: "ok" }
    else
      render json: { errors: "Failed to join game" }, status: 422
    end
  end

  # POST /games/create
  def create_game

    if current_user == nil
      flash[:error] = "You must be signed in inorder to create a game!"
      return redirect_to liveGraph_path
    else
      @game = Game.new
    end
    @game.player1_id = current_user.id
    @game.time_limit = params[:time_limit]
    @game.problem_id = 1
    unless @game.save
      render text: "Couldn't create game"
      return
    end
    redirect_to competition_path(@game)
  end

  def competition
    @game = Game.find(params[:id])
    unless current_user.id == @game.player1_id or current_user.id == @game.player2_id
      render text: "You are not a player in this game!"
    end
  end

  # POST /games/compile/
  def compile
    problem = Problem.find(params[:main])
    directory=params[:session]
    java=params[:code]
    dir = File.dirname("#{Rails.root}/tmp/java/#{directory}/ignored")
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(File.join(dir, 'main.java'), 'w') do |f|
      f.puts problem.mainClass
      f.puts
      f.puts java
    end
    

    Dir.chdir "#{Rails.root}/tmp/java/#{directory}/"
    startTime = Time.now
    compile = %x(javac main.java 2>&1)
    deltaTime = Time.now - startTime
    if compile==""
      success = true
    else
      success = false
    end
    return render json: {"success"=>success,"output"=>compile,"deltaTime"=>deltaTime}
  end

  # POST /games/execute
  def execute
    directory=params[:session]
    Dir.chdir "#{Rails.root}/tmp/java/#{directory}/"
    startTime = Time.now
    cmd ='timelimit -t 10 java main'
    json = Open3.popen3(cmd) do |i,o,e,t|
      output=o.read
      error=e.read
      deltaTime = Time.now - startTime
      {:output=>output,:error=>error,:deltaTime=>deltaTime}
    end
    if json[:error].include?("timelimit:")
      json[:error] = "Execution took to long, do you have an infinite loop?\n"
    end
    return render json: json
  end

  private
    def load_game
      @game = Game.new(game_params)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:time_limit, :player1_id, :player2_id, :problem_id, :winner_id)
    end
end

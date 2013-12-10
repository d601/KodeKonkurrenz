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
    #doesn't display practice games open games
    @games = Game.where(winner_id: -1).where(player2_id: -1).where(isPractice: false)
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
    @game.player2_id = current_user.id

    if @game.player1_id == @game.player2_id
      render json: { errors: "Can't join your own game" }, status: 422
      return
    end
    if @game.player2_id != -1
      render json: { errors: "Game is full" }, status: 422
      return
    end

    time = Time.now
    @game.joinTime = time.to_f
    @game.started_at = time
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
    #randomly choose from all possible problem id's
    #Later restrict people from seeing the same problems. 
    @problem = Problem.pluck(:id)
    @problem = @problem.sample(1)
    @game.problem_id = @problem[0]
    @game.rated = params[:rated]
    unless @game.save
      flash[:error] = "couldn't create game =-("
      return redirect_to liveGraph_path
    end
    #show newly created game in live graph. Eventually remove redirection here.
    flash[:success] = "Your game has been created!"
    redirect_to liveGraph_path
  end

  def create_game_practice

    if current_user == nil
      flash[:error] = "You must be signed in inorder to practice!"
      return redirect_to problems_practice_path
    else
      @game = Game.new
    end
    @game.player1_id = current_user.id
    @game.player2_id = -1
    @game.time_limit = params[:time].to_f
    @problem = Problem.where(time: params[:time].to_f).where(difficulty: Integer(params[:difficulty])).where(category: Integer(params[:category])).select(:id).collect(&:id)
    #randomly choose from all possible problem id's
    if @problem.empty?
      flash[:error] = "There is no game with those specifications. Sorry. Try Again!"
      return redirect_to problems_practice_path
    end
    #Later restrict people from seeing the same problems.
    @problem = @problem.sample(1)
    @game.problem_id = @problem[0]
    @game.isPractice = true
    time = Time.now
    @game.joinTime = time.to_f
    unless @game.save
      flash[:error] = "Couldn't create the game =-("
      return redirect_to problems_practice_path
    end
    redirect_to competition_path(@game)
  end

  def competition
    @game = Game.find(params[:id])
    unless current_user.id == @game.player1_id or current_user.id == @game.player2_id
      flash[:error] = "You are not a player in this game!"
      return redirect_to root_path
    end
    if @game.winner_id != -1
      return render text: "This game has ended!"
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
    @game = Game.find(params[:game])
    submitting = params[:submitting]
    results = private_execution(params[:session])

    if submitting == "true" and @game.winner_id == -1
      if @game.player1_id == current_user.id
        @game.isSubmitted = true
      elsif @game.player2_id == current_user.id
        @game.isSubmitted2 = true
      end
    
      p "******************* DEBUG ********************"
      p results.inspect
      if @game.has_ended?
        p "drawing game"
        draw_game
      elsif results[:exitCode] == 1
        p "winning game"
        win_game
      else
        p "losing game"
        lose_game
      end
    end

    @game.save

    return render json: {
      output: results[:output],
      error: results[:error],
      deltaTime: results[:deltaTime],
      winnerExists: @game.winner_id == -1 ? false : true,
      winner: @game.winner_id }
  end

  # GET /games/status/:id
  # The client will periodically poll the server to see if the other player has
  # won (or the timer is up).
  def status
    unless @game.started_at
      return render json: {status: 'inactive'}
    end

    unless @game.has_ended?
      return render json: {status: 'active'}
    end

    # Do server-side draw calculations if the timer's up and there's no winner
    draw_game if @game.winner_id == -1

    return render json: {status: 'finished', winner: @game.winner_id}
  end

  # There's probably a way to rewrite this so that win_game() is called with
  # a user, and then the current lose/win_game() functions are replaced
  # with wrapper functions that call win_game() instead. This works for now,
  # though.

  # Also, these win/lose/draw methods should be in the Game model.
  
  def lose_game
    if @game.isSubmitted
      @game.winner_id = @game.player2_id
      winner = User.find(@game.player2_id)
    elsif @game.isSubmitted2
      @game.winner_id = @game.player1_id
      winner = User.find(@game.player1_id)
    end

    @game.save
    
    update_rating(winner, current_user)
  end

  def win_game
    @game.winner_id = current_user.id

      if @game.isSubmitted
        loser = User.find(@game.player2_id)
      elsif @game.isSubmitted2
        loser = User.find(@game.player1_id)
      end

      @game.save

      update_rating(current_user, loser)
  end

  def draw_game
    # TODO: magic values in the DB are bad, IMO. -1 for unfinished and 0 for
    # draw could be replaced with boolean columns in the future. -js
    @game.winner_id = 0
    update_rating(User.find(@game.player1_id),
                  User.find(@game.player2_id),
                  'draw')
    @game.save
  end

  private
    # winner and loser are User objects, not IDs
    def update_rating(winner, loser, result = 'win')
      if result == 'draw'
        winner_result, loser_result = 0.5, 0.5
      else
        winner_result, loser_result = 1, 0
      end
      winner.rating += calculate_elo(winner_result, winner.rating, loser.rating)
      loser.rating += calculate_elo(loser_result, winner.rating, loser.rating)
      winner.save
      loser.save
    end

    # Formula from here: http://www.chess-mind.com/en/elo-system
    # s = score: 1 = won, 0 = lost, 0.5 = draw
    # f = f factor, us. 400, larger makes it easier to gain/lose points
    def calculate_elo(s, score1, score2)
      d = (score1 - score2).abs
      f = 400
      
      k = if score1 > 2400 and score2 > 2400
            16
          elsif score1 < 2100 or score2 < 2100
            32
          else
            24
          end

      dElo = (k * (s - (1 / (10 ** ((-d / f) + 1)))))
    end

    def private_execution(directory)
      Dir.chdir "#{Rails.root}/tmp/java/#{directory}/"
      startTime = Time.now
      cmd ='timelimit -t 10 java main'
      results = Open3.popen3(cmd) do |i,o,e,t|
        output=o.read
        error=e.read
        o.close
        e.close
        exitCode=t.value
        deltaTime = Time.now - startTime
        {:output=>output,:error=>error,:deltaTime=>deltaTime,:exitCode=>exitCode.exitstatus}
      end
      if results[:error].include?("timelimit:")
        results[:error] = "Execution took to long, do you have an infinite loop?\n"
      end
      return results
    end

    def load_game
      @game = Game.new(game_params)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:time_limit, :player1_id, :player2_id, :problem_id, :winner_id, :isPractice)
    end
end

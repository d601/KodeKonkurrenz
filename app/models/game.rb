class Game < ActiveRecord::Base
  belongs_to :player1, class_name: "User"
  belongs_to :player2, class_name: "User"

  def rating
    return -1 unless player1
    player1.rating
  end
end

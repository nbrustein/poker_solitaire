# average score: 8 points

require File.expand_path("../../player", __FILE__)

class PokerSolitaire::Players::Random < PokerSolitaire::Player
  
  def take_turn(state, card)
    position = state.open_positions.sample
    [position.row_index, position.column_index]
  end
  
end
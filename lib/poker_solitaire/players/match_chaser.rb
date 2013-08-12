# average score: 24 points

require File.expand_path("../../player", __FILE__)

class PokerSolitaire::Players::MatchChaser < PokerSolitaire::Player
  
  def take_turn(state, card)
    best_position = nil
    current_match_size = 0
    state.open_positions.each do |position|
      match_sizes = [:row, :column].map do |row_or_column| 
        position.cards_in(row_or_column).map(&:rank).count(card.rank)
      end
      if match_sizes.max > current_match_size
        best_position = position
        current_match_size = match_sizes.max
      end
    end
    position = best_position || state.open_positions.sample
    [position.row_index, position.column_index]
  end
  
end
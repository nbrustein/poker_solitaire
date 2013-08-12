require File.expand_path("../../player", __FILE__)

# features:
#   - starting (2 features)
#     - 0 cards
#     - 1 cards
#   - nothing
#    - 2-4 cards with nothing
#   - straights (9 features)
#    - 2 cards that are 0, 1, 2, 3 spaces apart
#    - 3 cards with 0, 1, 2 spaces in between
#    - 4 cards with 0, 1 spaces in between
#   - flushes (3 features)
#    - 2-4 cards of all the same suit
#   - matches (10 features)
#    - 2-4 cards with one match
#    - 3-4 cards with 3-of-a-kind
#    - 4 cards with 2-pair
#    - 4 cards with 4-of-a-kind
# 
#   - combinations (33)
#     - exclusive starting (2)
#     - exclusive matches (10)
#     - exclusive flushes (3)
#     - exclusive straights (9)
#     - straights + possible flush (9)
#   
# - for each of these, we could consider the cards left in the deck.
# - we could consider interactions between rows and columns.
#   - it's bad if we're chasing the same flush in two rows
#   - it's good if one card can help both a row and a column at the same time

# To do:
# 1. build a reinforcement learner that takes a simplified view of the 
#    current state of each row and column, and ignores the cards 
#    remaining and the interactions
# 2. consider each of the 39 possible partial hands, but ignore
#    cards remaining and interactions
# 3. consider cards remaining
# 4. consider interactions

class PokerSolitaire::Players::TwoWayRLearner < PokerSolitaire::Player
  
  attr_reader :partial_hand_type_values
  
  def best_move(state, card)
    best_moves = []
    best_move_score = -1
    state.open_positions.map do |position|
      current_hands = position.row_and_column.map(&:hand)
      result_hands = current_hands.map { |hand| hand << card; hand }
      expected_scores = result_hands.map do |hand| 
        partial_hand_type = self.class.partial_hand_type(hand)
        if partial_hand_type == COMPLETE
          hand.score
        else
          partial_hand_type_values.fetch(partial_hand_type)[:average] || 100
        end
      end
      expected_score = expected_scores[0] + expected_scores[1]
      if expected_score > best_move_score
        best_moves = [position]
        best_move_score = expected_score
      end
    end
    position = best_moves.sample
  end
  
  class Player < PokerSolitaire::Players::TwoWayRLearner
    
    def initialize
      @partial_hand_type_values = {}
    end
    
    def take_turn(state, card)
      position = best_move(state, card)
      [position.row_index, position.column_index]
    end
    
  end
  
  class Trainer < PokerSolitaire::Players::TwoWayRLearner
    
    def initialize(partial_hand_type_values)
      @partial_hand_type_values = partial_hand_type_values
    end
    
    def take_turn(state, card)
      if rand < 0.1
        position = state.open_positions.sample
      else
        position = best_move(state, card)
      end
      [position.row_index, position.column_index]
    end
    
  end
      
end
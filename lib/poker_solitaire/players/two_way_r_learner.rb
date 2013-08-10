require File.expand_path("../../player", __FILE__)

# features:
#   - starting (2 features)
#     - 0 cards
#     - 1 cards
#   - straights (9 features)
#    - 2 cards that are 0, 1, 2, 3 spaces apart
#    - 3 cards with 0, 1, 2 spaces in between
#    - 4 cards with 0, 1 spaces in between
#   - flushes (3 features)
#    - 2-4 cards of all the same suit
#   - matches (10 features)
#    - 2-4 cards with one match
#    - 2-4 cards with no match
#    - 3-4 cards with 3-of-a-kind
#    - 4 cards with 2-pair
#    - 4 cards with 4-of-a-kind
# 
#   - combinations (39)
#     - exclusive starting (2)
#     - exclusive matches (10)
#     - exclusive flushes (9)
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

module PokerSolitaire::Players::TwoWayRLearner

  module Train
    
    def self.train
      
    end
      
  end
  
  # def take_turn(state, card)
  #   position = state.open_positions.sample
  #   [position.row_index, position.column_index]
  # end
      
end
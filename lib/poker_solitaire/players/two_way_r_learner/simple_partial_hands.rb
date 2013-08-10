require File.expand_path("../../two_way_r_learner", __FILE__)

module PokerSolitaire::Players::TwoWayRLearner::SimplePartialHands
  extend PokerSolitaire::Players::TwoWayRLearner::Train

  class Player < PokerSolitaire::Player
    
  end
  
  class Trainer < PokerSolitaire::Player
    
  end
  
  # def take_turn(state, card)
  #   position = state.open_positions.sample
  #   [position.row_index, position.column_index]
  # end
      
end
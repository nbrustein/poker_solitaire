# average score: 32 points

require File.expand_path("../../two_way_r_learner", __FILE__)

class PokerSolitaire::Players::TwoWayRLearner::SimplePartialHands < PokerSolitaire::Player
  
  HAND_TYPE_STARTING = "starting"
  HAND_TYPE_POSSIBLE_STRAIGHT = "possible_straight"
  HAND_TYPE_POSSIBLE_FLUSH = "possible_flush"
  HAND_TYPE_ONE_PAIR = "one_pair"
  HAND_TYPE_TWO_PAIR = "two_pair"
  HAND_TYPE_THREE_OF_A_KIND = "three_of_a_kind"
  HAND_TYPE_FOUR_OF_A_KIND = "four_of_a_kind"
  COMPLETE = "complete"
  NOTHING = "nothing"
  
  PARTIAL_HAND_TYPES = [
    HAND_TYPE_STARTING,
    HAND_TYPE_POSSIBLE_STRAIGHT,
    HAND_TYPE_POSSIBLE_FLUSH,
    HAND_TYPE_ONE_PAIR,
    HAND_TYPE_TWO_PAIR,
    HAND_TYPE_THREE_OF_A_KIND,
    HAND_TYPE_FOUR_OF_A_KIND,
    COMPLETE,
    NOTHING
  ]
  
  def self.train(n)
    partial_hand_type_values = {}
    (PARTIAL_HAND_TYPES - [COMPLETE]).each do |partial_hand_type|
      partial_hand_type_values[partial_hand_type] = {
        :n => 0,
        :total_score => 0,
        :average => nil
      }
    end
    
    last_puts = Time.now
    require 'pp'
    average_score, time_elapsed = PokerSolitaire.play_n_games(self::Trainer, n, [partial_hand_type_values]) do |game, average_score, percent_complete|
      
      game.rows_and_columns.each do |row_or_column|
        row_or_column.history.each do |row_or_column_state|
          cards = row_or_column_state.map(&:card)
          partial_hand = PokerSolitaire::Hand.new(cards)
          partial_hand_type = self.partial_hand_type(partial_hand)
          next if partial_hand_type == COMPLETE
          entry = partial_hand_type_values.fetch(partial_hand_type)
          entry[:n] += 1
          entry[:total_score] += row_or_column.hand.score
          entry[:average] = entry[:total_score].to_f / entry[:n]
        end
      end
      
      if Time.now - last_puts > 2.seconds
        puts "#{"%02d" % percent_complete}% complete. Average score = #{"%.2f" % average_score}"
        pp partial_hand_type_values
        last_puts = Time.now
      end
      
    end
    
    pp partial_hand_type_values
  end
  
  def self.partial_hand_type(partial_hand)
    if partial_hand.size < 2
      HAND_TYPE_STARTING
    elsif partial_hand.complete?
      COMPLETE
    elsif partial_hand.possible_straight?
      HAND_TYPE_POSSIBLE_STRAIGHT
    elsif partial_hand.possible_flush?
      HAND_TYPE_POSSIBLE_FLUSH
    elsif partial_hand.four_of_a_kind?
      HAND_TYPE_FOUR_OF_A_KIND
    elsif partial_hand.three_of_a_kind?
      HAND_TYPE_THREE_OF_A_KIND
    elsif partial_hand.two_pair?
      HAND_TYPE_TWO_PAIR
    elsif partial_hand.one_pair?
      HAND_TYPE_ONE_PAIR
    else
      NOTHING
    end
  end
  
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
  
  class Player < PokerSolitaire::Players::TwoWayRLearner::SimplePartialHands
    
    def initialize
      @partial_hand_type_values = {
        "starting"=>
          {:n=>19060, :total_score=>47498, :average=>2.49202518363064},
        "possible_straight"=>
          {:n=>7715, :total_score=>28653, :average=>3.7139338950097214},
        "possible_flush"=>
          {:n=>3873, :total_score=>8340, :average=>2.1533694810224633},
        "one_pair"=>
          {:n=>8079, :total_score=>22416, :average=>2.774600816932789},
        "two_pair"=>
          {:n=>185, :total_score=>730, :average=>3.945945945945946},
        "three_of_a_kind"=>
          {:n=>395, :total_score=>2662, :average=>6.739240506329114},
        "four_of_a_kind"=>
          {:n=>2, :total_score=>32, :average=>16.0},
        "nothing"=>
          {:n=>8341, :total_score=>8414, :average=>1.008751948207649}}
    end
    
    def take_turn(state, card)
      position = best_move(state, card)
      [position.row_index, position.column_index]
    end
    
  end
  
  class Trainer < PokerSolitaire::Players::TwoWayRLearner::SimplePartialHands
    
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
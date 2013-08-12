require File.expand_path("../../two_way_r_learner", __FILE__)

class PokerSolitaire::Players::TwoWayRLearner::AllPartialHands < PokerSolitaire::Player
  
  HAND_TYPE_STARTING = "starting"
  
  # straights
    # number of cards, number of spaces between
  HAND_TYPE_POSSIBLE_STRAIGHTS = {}
  [
    [2,0], [2,1], [2,2], [2,3],
    [3,0], [3,1], [3,2],
    [4,0], [4,1]
  ].each { |pair| HAND_TYPE_POSSIBLE_STRAIGHTS[pair] = "possible_straight_#{pair[0]}_cards_#{pair[1]}_spaces"}
  
  #straight flushes
  HAND_TYPE_POSSIBLE_STRAIGHT_FLUSHES = {}
  HAND_TYPE_POSSIBLE_STRAIGHTS.map do |pair, name| 
    name = name.gsub("possible_straight", "possible_straight_flush")
    HAND_TYPE_POSSIBLE_STRAIGHT_FLUSHES[pair] = name
  end
  
  # flushes
    # number of cards
  HAND_TYPE_POSSIBLE_FLUSHES = {}
  [2, 3, 4].each { |i| HAND_TYPE_POSSIBLE_FLUSHES[i] = "possible_flush_#{i}_cards" }
  
  # matches
  HAND_TYPE_ONE_PAIR = "one_pair"
  HAND_TYPE_TWO_PAIR = "two_pair"
  HAND_TYPE_THREE_OF_A_KIND = "three_of_a_kind"
  HAND_TYPE_FOUR_OF_A_KIND = "four_of_a_kind"
    # number of cards, match type
  HAND_TYPE_POSSIBLE_MATCHES = {}
  [
    [2, HAND_TYPE_ONE_PAIR],
    [3, HAND_TYPE_ONE_PAIR],
    [4, HAND_TYPE_ONE_PAIR],
    [4, HAND_TYPE_TWO_PAIR],
    [3, HAND_TYPE_THREE_OF_A_KIND],
    [4, HAND_TYPE_THREE_OF_A_KIND],
    [4, HAND_TYPE_FOUR_OF_A_KIND]
  ].each { |pair| HAND_TYPE_POSSIBLE_MATCHES[pair] = "#{pair[0]}_cards_#{pair[1]}" }
  
  HAND_TYPE_COMPLETE = "complete"
  HAND_TYPE_NOTHING = {}
  [2,3,4].each { |i| HAND_TYPE_NOTHING[i] = "nothing_#{i}_cards"}
  
  PARTIAL_HAND_TYPES = [
      HAND_TYPE_STARTING,
      HAND_TYPE_COMPLETE,
    ] + 
    HAND_TYPE_POSSIBLE_STRAIGHTS.values + 
    HAND_TYPE_POSSIBLE_STRAIGHT_FLUSHES.values + 
    HAND_TYPE_POSSIBLE_FLUSHES.values + 
    HAND_TYPE_POSSIBLE_MATCHES.values + 
    HAND_TYPE_NOTHING.values
  
  def self.train(n)
    partial_hand_type_values = {}
    (PARTIAL_HAND_TYPES - [HAND_TYPE_COMPLETE]).each do |partial_hand_type|
      partial_hand_type_values[partial_hand_type] = {
        :n => 0,
        :total_score => 0,
        :average => nil
      }
    end
    
    last_puts = Time.now
    puts_count = 0
    require 'pp'
    average_score, time_elapsed = PokerSolitaire.play_n_games(self::Trainer, n, [partial_hand_type_values]) do |game, average_score, percent_complete|
      
      game.rows_and_columns.each do |row_or_column|
        row_or_column.history.each do |row_or_column_state|
          cards = row_or_column_state.map(&:card)
          partial_hand = PokerSolitaire::Hand.new(cards)
          partial_hand_type = self.partial_hand_type(partial_hand)
          next if partial_hand_type == HAND_TYPE_COMPLETE
          entry = partial_hand_type_values.fetch(partial_hand_type)
          entry[:n] += 1
          entry[:total_score] += row_or_column.hand.score
          entry[:average] = entry[:total_score].to_f / entry[:n]
        end
      end
      
      if Time.now - last_puts > 2.seconds
        puts "#{"%02d" % percent_complete}% complete. Average score = #{"%.2f" % average_score}"
        if puts_count == 10
          pp partial_hand_type_values
          puts_count = 0
        end
        puts_count += 1
        last_puts = Time.now
      end
      
    end
    
    pp partial_hand_type_values
  end
  
  def self.partial_hand_type(partial_hand)
    if partial_hand.size < 2
      HAND_TYPE_STARTING
    elsif partial_hand.complete?
      HAND_TYPE_COMPLETE
    elsif partial_hand.possible_straight_flush?
      HAND_TYPE_POSSIBLE_STRAIGHT_FLUSHES[[partial_hand.size, partial_hand.spaces_between_straight]]
    elsif partial_hand.possible_straight?
      HAND_TYPE_POSSIBLE_STRAIGHTS[[partial_hand.size, partial_hand.spaces_between_straight]]
    elsif partial_hand.possible_flush?
      HAND_TYPE_POSSIBLE_FLUSHES[partial_hand.size]
    elsif partial_hand.four_of_a_kind?
      HAND_TYPE_POSSIBLE_MATCHES[[partial_hand.size, HAND_TYPE_FOUR_OF_A_KIND]]
    elsif partial_hand.three_of_a_kind?
      HAND_TYPE_POSSIBLE_MATCHES[[partial_hand.size, HAND_TYPE_THREE_OF_A_KIND]]
    elsif partial_hand.two_pair?
      HAND_TYPE_POSSIBLE_MATCHES[[partial_hand.size, HAND_TYPE_TWO_PAIR]]
    elsif partial_hand.one_pair?
      HAND_TYPE_POSSIBLE_MATCHES[[partial_hand.size, HAND_TYPE_ONE_PAIR]]
    else
      HAND_TYPE_NOTHING[partial_hand.size]
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
        if partial_hand_type == HAND_TYPE_COMPLETE
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
  
  class Player < PokerSolitaire::Players::TwoWayRLearner::AllPartialHands
    
    def initialize
      @partial_hand_type_values = {"starting"=>{:n=>200000, :total_score=>667732, :average=>3.33866},
       "possible_straight_2_cards_0_spaces"=>
        {:n=>25915, :total_score=>103583, :average=>3.9970287478294426},
       "possible_straight_2_cards_1_spaces"=>
        {:n=>21584, :total_score=>82055, :average=>3.8016586360266866},
       "possible_straight_2_cards_2_spaces"=>
        {:n=>5985, :total_score=>15999, :average=>2.6731829573934838},
       "possible_straight_2_cards_3_spaces"=>
        {:n=>3932, :total_score=>7725, :average=>1.9646490335707019},
       "possible_straight_3_cards_0_spaces"=>
        {:n=>16074, :total_score=>87760, :average=>5.459748662436232},
       "possible_straight_3_cards_1_spaces"=>
        {:n=>21234, :total_score=>100087, :average=>4.71352547800697},
       "possible_straight_3_cards_2_spaces"=>
        {:n=>8458, :total_score=>22026, :average=>2.604161740364152},
       "possible_straight_4_cards_0_spaces"=>
        {:n=>13066, :total_score=>100323, :average=>7.6781723557324355},
       "possible_straight_4_cards_1_spaces"=>
        {:n=>17946, :total_score=>101846, :average=>5.675136520673131},
       "possible_straight_flush_2_cards_0_spaces"=>
        {:n=>8923, :total_score=>37181, :average=>4.166872128208002},
       "possible_straight_flush_2_cards_1_spaces"=>
        {:n=>2854, :total_score=>8922, :average=>3.1261387526278908},
       "possible_straight_flush_2_cards_2_spaces"=>
        {:n=>2032, :total_score=>5617, :average=>2.764271653543307},
       "possible_straight_flush_2_cards_3_spaces"=>
        {:n=>1568, :total_score=>3296, :average=>2.1020408163265305},
       "possible_straight_flush_3_cards_0_spaces"=>
        {:n=>1031, :total_score=>6453, :average=>6.258971871968962},
       "possible_straight_flush_3_cards_1_spaces"=>
        {:n=>822, :total_score=>3909, :average=>4.755474452554744},
       "possible_straight_flush_3_cards_2_spaces"=>
        {:n=>745, :total_score=>2672, :average=>3.5865771812080536},
       "possible_straight_flush_4_cards_0_spaces"=>
        {:n=>180, :total_score=>1841, :average=>10.227777777777778},
       "possible_straight_flush_4_cards_1_spaces"=>
        {:n=>266, :total_score=>2102, :average=>7.902255639097745},
       "possible_flush_2_cards"=>
        {:n=>5083, :total_score=>8994, :average=>1.7694275034428486},
       "possible_flush_3_cards"=>
        {:n=>2771, :total_score=>4619, :average=>1.6669072536990257},
       "possible_flush_4_cards"=>
        {:n=>1531, :total_score=>4004, :average=>2.6152841280209014},
       "2_cards_one_pair"=>
        {:n=>11847, :total_score=>44364, :average=>3.7447455051911875},
       "3_cards_one_pair"=>
        {:n=>24263, :total_score=>73233, :average=>3.018299468326258},
       "4_cards_one_pair"=>
        {:n=>33345, :total_score=>67923, :average=>2.0369770580296898},
       "4_cards_two_pair"=>
        {:n=>3193, :total_score=>14675, :average=>4.595991230817413},
       "3_cards_three_of_a_kind"=>
        {:n=>1678, :total_score=>11628, :average=>6.929678188319428},
       "4_cards_three_of_a_kind"=>
        {:n=>4650, :total_score=>30936, :average=>6.652903225806452},
       "4_cards_four_of_a_kind"=>{:n=>54, :total_score=>864, :average=>16.0},
       "nothing_2_cards"=>
        {:n=>10277, :total_score=>16130, :average=>1.569524180208232},
       "nothing_3_cards"=>
        {:n=>22924, :total_score=>21479, :average=>0.9369656255452801},
       "nothing_4_cards"=>
        {:n=>25769, :total_score=>9352, :average=>0.3629166828359657}}
    end
    
    def take_turn(state, card)
      position = best_move(state, card)
      [position.row_index, position.column_index]
    end
    
  end
  
  class Trainer < PokerSolitaire::Players::TwoWayRLearner::AllPartialHands
    
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
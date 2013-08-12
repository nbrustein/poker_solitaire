class PokerSolitaire::Hand
  
  ROYAL_FLUSH = "royal flush"
  STRAIGHT_FLUSH = "straight flush"
  FOUR_OF_A_KIND = "four of a kind"
  STRAIGHT = "straight"
  FULL_HOUSE = "full house"
  THREE_OF_A_KIND = "three of a kind"
  FLUSH = "flush"
  TWO_PAIRS = "two pairs"
  ONE_PAIR = "one pair"
  
  attr_reader :cards
  delegate :size, :<<, :to => :cards
  
  def initialize(cards)
    raise ArgumentError unless cards.is_a?(Array)
    classes = cards.map(&:class).uniq
    raise(ArgumentError.new("Invalid card class: #{classes.inspect}")) unless classes.empty? || classes == [PokerSolitaire::CardDeck::Card]
    @cards = cards
  end
  
  def complete?
    cards.size == 5
  end
  
  def score
    raise "Incomplete hand" unless cards.size == 5
    {
      ROYAL_FLUSH => 50,
      STRAIGHT_FLUSH => 30,
      FOUR_OF_A_KIND => 16,
      STRAIGHT => 12,
      FULL_HOUSE => 10,
      THREE_OF_A_KIND => 6,
      FLUSH => 5,
      TWO_PAIRS => 3,
      ONE_PAIR => 1
    }[best_hand] || 0
  end
  
  def possible_straight?(ace_high = nil)
    if ace_high.nil?
      return possible_straight?(true) || possible_straight?(false)
    end
    
    sorted = cards.sort
    
    0.upto(sorted.size - 2).each do |i|
      return false unless sorted[i+1].rank.to_i(ace_high) - sorted[i].rank.to_i(ace_high) == 1
    end
    
    return true
  end
  
  def possible_flush?
    cards.map(&:suit).uniq.size == 1
  end
  
  def four_of_a_kind?
    matches.map(&:size).include?(4)
  end
  
  def three_of_a_kind?
    matches.map(&:size).include?(3)
  end
  
  def two_pair?
    matches.map(&:size).count(2) == 2
  end
  
  def one_pair?
    matches.map(&:size).count(2) == 1
  end
  
  def inspect
    cards.map(&:abbreviation).join(", ")
  end
  
  private
  def best_hand
    if flush? && straight? && ranks.min == 10
      ROYAL_FLUSH
    elsif flush? && straight? 
      STRAIGHT_FLUSH
    elsif matches.map(&:size) == [4]
      FOUR_OF_A_KIND
    elsif straight?
      STRAIGHT
    elsif matches.map(&:size).sort == [2, 3]
      FULL_HOUSE
    elsif matches.map(&:size) == [3]
      THREE_OF_A_KIND
    elsif flush?
      FLUSH
    elsif matches.map(&:size) == [2, 2]
      TWO_PAIRS
    elsif matches.map(&:size) == [2]
      ONE_PAIR
    else
      ranks.max 
    end
  end
  
  private
  def flush?
    complete? && possible_flush?
  end
  
  private
  def straight?
    complete? && possible_straight?
  end
  
  private
  def ranks
    cards.map(&:rank)
  end
  
  private
  def matches
    arr = []
    ranks.uniq.each do |rank|
      cards_of_rank = cards.select { |c| c.rank == rank }
      if cards_of_rank.size > 1
        arr << cards_of_rank
      end
    end
    arr
  end
  
end
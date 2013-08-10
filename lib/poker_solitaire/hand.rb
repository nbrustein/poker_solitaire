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
  
  def initialize(cards)
    raise ArgumentError unless cards.is_a?(Array)
    raise (ArgumentError.new("expecting 5 cards. Got #{cards.inspect.size}: #{cards.inspect}")) unless cards.size == 5
    classes = cards.map(&:class).uniq
    raise(ArgumentError.new("Invalid card class: #{classes.inspect}")) unless classes == [PokerSolitaire::CardDeck::Card]
    @cards = cards
  end
  
  def score
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
    cards.map(&:suit).uniq.size == 1
  end
  
  private
  def straight?
    sorted = cards.sort
    return true if sorted.map(&:rank) == [2, 3, 4, 5, PokerSolitaire::CardDeck::ACE]
    0.upto(3).each do |i|
      return false unless sorted[i+1].rank.to_i - sorted[i].rank.to_i == 1
    end
    return true
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
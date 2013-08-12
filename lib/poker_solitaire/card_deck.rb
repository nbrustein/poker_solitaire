class PokerSolitaire::CardDeck
  
  class Card
    include Comparable
    attr_reader :suit, :rank
    
    def initialize(suit, rank)
      @suit, @rank = suit, rank
    end
    
    def inspect
      name
    end
    
    def name
      "#{rank.name} of #{suit.name}"
    end
    
    def abbreviation
      "#{rank.abbreviation}#{suit.abbreviation}"
    end
    
    def <=>(other)
      rank <=> other.rank
    end
    
  end
  
  class Suit
    
    attr_reader :name
    
    def initialize(name)
      @name = name
    end
    
    def abbreviation
      name.slice(0, 1).upcase
    end
    
  end
  
  class Rank
    
    attr_reader :name
    
    def initialize(name)
      @name = name
    end
    
    def abbreviation
      if name == 10
        "T"
      elsif name.is_a?(Integer)
        name.to_s
      else
        name.slice(0, 1).upcase
      end
    end
    
    def <=>(other)
      to_i <=> other.to_i  
    end
    
    def to_i(ace_high = true)
      if name.is_a?(Integer)
        name
      else
        {
          JACK => 11,
          QUEEN  => 12,
          KING => 13,
          ACE => ace_high ? 14 : 1
        }[name]
      end
    end
    
  end
  
  SPADES = "spades"
  DIAMONDS = "diamonds"
  HEARTS = "hearts"
  CLUBS = "clubs"
  
  JACK = "jack"
  QUEEN = "queen"
  KING = "king"
  ACE = "ace"
  
  SUITS = [SPADES, DIAMONDS, HEARTS, CLUBS].map { |suit_name| Suit.new(suit_name) }
  RANKS = (2.upto(10).to_a + [JACK, QUEEN, KING, ACE]).map { |rank_name| Rank.new(rank_name) }
  
  def initialize
    @cards = []
    SUITS.each do |suit|
      RANKS.each do |rank|
        @cards << Card.new(suit, rank)  
      end
    end
    @cards.shuffle!
  end
  
  def draw
    @cards.pop
  end
  
end
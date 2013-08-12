class PokerSolitaire::Game
  
  attr_reader :player, :cards, :game_state
  delegate :rows_and_columns, :to => :game_state
  
  def initialize(options)
    @player = options['player']
    raise ArgumentError.new("Invalid player: #{@player.inspect}") unless @player.is_a?(PokerSolitaire::Player)
    @cards = PokerSolitaire::CardDeck.new
    @game_state = PokerSolitaire::GameState.new
  end
  
  def play
    1.upto(25) do 
      take_turn
    end
  end
  
  def inspect
    game_state.rows.each do |positions|
      card_abbreviations = positions.map { |position| position.card.abbreviation}
      score = "%02d" % PokerSolitaire::Hand.new(positions.map(&:card)).score
      puts((card_abbreviations+[score]).join(" "))
    end
    puts(game_state.columns.map { |positions|
      "%02d" % PokerSolitaire::Hand.new(positions.map(&:card)).score
    }.join(" "))
    "score: #{score}"
  end
  
  def score
    raise "Cannot determine score until game is over" unless finished?
    return @score if defined? @score
    score = 0
    (game_state.rows + game_state.columns).each do |positions|
      score += PokerSolitaire::Hand.new(positions.map(&:card)).score
    end
    @score = score
  end
  
  private
  def finished?
    game_state.open_positions.empty?
  end
  
  private
  def take_turn
    card = cards.draw
    row, column = player.take_turn(game_state, card)
    game_state.update(row, column, card)
  end
  
end
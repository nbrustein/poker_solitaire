class PokerSolitaire::Game
  
  attr_reader :player, :cards, :state
  
  def initialize(options)
    @player = options['player']
    raise ArgumentError.new("Invalid player: #{@player.inspect}") unless @player.is_a?(PokerSolitaire::Player)
    @cards = PokerSolitaire::CardDeck.new
    @state = PokerSolitaire::GameState.new
  end
  
  def play
    1.upto(25) do 
      take_turn
    end
  end
  
  def inspect
    state.inspect
    "score: ??"
  end
  
  private
  def take_turn
    card = cards.draw
    row, column = player.take_turn(state, card)
    state.update(row, column, card)
  end
  
end
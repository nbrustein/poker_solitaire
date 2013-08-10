class PokerSolitaire::GameState
  
  attr_reader :rows
  
  class Position
    
    attr_reader :game_state, :row_index, :column_index, :card
    
    def initialize(game_state, row_index, column_index)
      @row_index, @column_index = row_index, column_index
      @card = nil
      @game_state = game_state
    end
    
    def place_card(card)
      @card = card
    end
    
    def empty?
      card.nil?
    end
    
    def cards_in(row_or_column)
      if row_or_column == :row
        cards = game_state.rows[row_index].map(&:card)
      else
        cards = game_state.columns[column_index].map(&:card)
      end
      cards.compact 
    end
    
  end
  
  def initialize
    @rows = []
    
    0.upto(4) do |row_index|
      @rows[row_index] = []
      0.upto(4) do |column_index|
        @rows[row_index][column_index] = Position.new(self, row_index, column_index)
      end
    end
    
  end
  
  def open_positions
    all_positions.select(&:empty?)
  end
  
  def update(row_index, column_index, card)
    row = @rows.fetch(row_index)
    position = row.fetch(column_index)
    raise "Non-empty position" unless position.empty?
    position.place_card(card)
  end
  
  def inspect
    @rows.each do |row|
      puts(row.map { |position| position.card.abbreviation}.join(" "))
    end
  end
  
  def columns
    cols = [[],[],[],[],[]]
    rows.each_with_index do |row, row_index|
      row.each_with_index do |position, column_index|
        cols[column_index] << position
      end
    end
    cols
  end
  
  private
  def all_positions
    # require 'pp'
    # pp rows
    # puts "************"
    # pp rows.values
    # puts "************"
    # pp rows.values.map(&:values).flatten
    rows.flatten
  end
  
end
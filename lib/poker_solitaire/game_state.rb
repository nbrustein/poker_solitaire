class PokerSolitaire::GameState
  
  attr_reader :rows, :columns, :rows_and_columns, :move_index
  
  class Position
    
    attr_reader :game_state, :row_index, :column_index, :card, :move_index
    
    def initialize(game_state, row_index, column_index)
      @row_index, @column_index = row_index, column_index
      @card = nil
      @game_state = game_state
    end
    
    def place_card(card, move_index)
      @card = card
      @move_index = move_index
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
    
    def row_and_column
      [
        game_state.rows[row_index],
        game_state.columns[column_index]
      ]
    end
    
  end
  
  class RowOrColumn
    
    attr_reader :positions
    
    delegate :fetch, :<<, :[], :[]=, :each_with_index, :map, :compact, :to => :positions
    
    def initialize
      @positions = []  
    end
    
    def hand
      PokerSolitaire::Hand.new(positions.map(&:card).compact)
    end
    
    def history
      state = []
      [state.clone] + @positions.sort_by(&:move_index).map do |position|
        state << position
        state.clone
      end
    end
    
  end
  
  def initialize
    @rows = []
    @columns = []
    @move_index = -1
    
    0.upto(4) do |row_index|
      @rows[row_index] = RowOrColumn.new
      0.upto(4) do |column_index|
        position = Position.new(self, row_index, column_index)
        @rows[row_index][column_index] = position
        @columns[column_index] ||= RowOrColumn.new
        @columns[column_index][row_index] = position
      end
    end
    
    @rows_and_columns = @rows + @columns
    
  end
  
  def open_positions
    all_positions.select(&:empty?)
  end
  
  def update(row_index, column_index, card)
    row = @rows.fetch(row_index)
    position = row.fetch(column_index)
    raise "Non-empty position" unless position.empty?
    position.place_card(card, @move_index += 1)
  end
  
  def inspect
    @rows.each do |row|
      puts(row.map { |position| position.card.abbreviation}.join(" "))
    end
  end
  
  private
  def all_positions
    rows.map(&:positions).flatten
  end
  
end
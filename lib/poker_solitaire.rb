require "poker_solitaire/version"
require 'active_support/all'

module PokerSolitaire
  module Players; end
  
  def self.play_game(player, player_args = [])
    game = PokerSolitaire::Game.new({
      'player' => player.new(*player_args)
    })
    game.play
    game
  end
  
  def self.play_n_games(player, n, player_args = [], &on_progress)
    average = Proc.new do |arr|
      arr.inject{ |sum, el| sum + el }.to_f / arr.size
    end
    scores = []
    start = Time.now
    1.upto(n.to_i) do |i|
      game = PokerSolitaire::Game.new({
        'player' => player.new(*player_args)
      })
      game.play
      scores << game.score
      
      if block_given?
        yield(game, average.call(scores), 100*i.to_f/n.to_f)
      end
      
    end
    elapsed = Time.now - start
    [average.call(scores), elapsed]
  end
end

require File.expand_path("../poker_solitaire/card_deck", __FILE__)
require File.expand_path("../poker_solitaire/hand", __FILE__)
require File.expand_path("../poker_solitaire/game", __FILE__)
require File.expand_path("../poker_solitaire/game_state", __FILE__)
require File.expand_path("../poker_solitaire/version", __FILE__)

require File.expand_path("../poker_solitaire/players/random", __FILE__)
require File.expand_path("../poker_solitaire/players/match_chaser", __FILE__)
require File.expand_path("../poker_solitaire/players/two_way_r_learner/simple_partial_hands", __FILE__)
require File.expand_path("../poker_solitaire/players/two_way_r_learner/all_partial_hands", __FILE__)
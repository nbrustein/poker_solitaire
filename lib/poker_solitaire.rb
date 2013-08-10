require "poker_solitaire/version"
require 'active_support/all'

module PokerSolitaire
  module Players; end
  
  def self.play_game(player)
    game = PokerSolitaire::Game.new({
      'player' => player.new
    })
    game.play
    game
  end
  
  def self.play_n_games(player, n, progress_interval = 2.seconds, &on_progress)
    average = Proc.new do |arr|
      arr.inject{ |sum, el| sum + el }.to_f / arr.size
    end
    scores = []
    start = Time.now
    last_progress = Time.now
    1.upto(n.to_i) do |i|
      game = PokerSolitaire::Game.new({
        'player' => player.new
      })
      game.play
      scores << game.score
      
      if block_given? && last_progress < Time.now - progress_interval
        yield(average.call(scores), 100*i.to_f/n.to_f)
        last_progress = Time.now
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
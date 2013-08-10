require File.expand_path("../../poker_solitaire", __FILE__) #FIXME: I shouldn't need this
 
namespace :poker_solitaire do
  desc "play one game with the player indicated by p=PLAYER"
  task :play_one_game do
    player = ENV['p'].constantize
    game = PokerSolitaire::Game.new({
      'player' => player.new
    })
    game.play
    puts game.inspect
  end
  
  desc "play n game with the player indicated by p=PLAYER and number of games by n=###"
  task :play_n_games do
    player = ENV['p'].constantize
    n = ENV['n']
    scores = []
    start = Time.now
    1.upto(n.to_i) do 
      game = PokerSolitaire::Game.new({
        'player' => player.new
      })
      game.play
      scores << game.score
    end
    elapsed = Time.now - start
    puts "played #{n} games in #{"%02f" % elapsed} seconds"
    puts "average score: #{scores.inject{ |sum, el| sum + el }.to_f / scores.size}"
  end
end
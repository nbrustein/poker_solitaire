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
    average = Proc.new do |arr|
      arr.inject{ |sum, el| sum + el }.to_f / arr.size
    end
    player = ENV['p'].constantize
    n = ENV['n']
    scores = []
    start = Time.now
    last_puts = Time.now
    1.upto(n.to_i) do |i|
      game = PokerSolitaire::Game.new({
        'player' => player.new
      })
      game.play
      scores << game.score
      if last_puts < Time.now - 2.seconds
        comp = "%02d" % (100*i.to_f/n.to_f)
        puts "#{comp}% complete. Average score = #{"%.2f" % average.call(scores)}"
        last_puts = Time.now
      end
    end
    elapsed = Time.now - start
    puts "played #{n} games in #{"%02f" % elapsed} seconds"
    puts "average score: #{average.call(scores)}"
  end
end
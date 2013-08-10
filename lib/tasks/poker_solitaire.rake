require File.expand_path("../../poker_solitaire", __FILE__) #FIXME: I shouldn't need this
 
namespace :poker_solitaire do
  desc "play one game with the player indicated by p=PLAYER"
  task :play_one_game do
    player = ENV['p'].constantize
    PokerSolitaire.play_game(player).inspect
  end
  
  desc "play n game with the player indicated by p=PLAYER and number of games by n=###"
  task :play_n_games do
    player = ENV['p'].constantize
    n = ENV['n']
    
    average_score, time_elapsed = PokerSolitaire.play_n_games(player, n, 2.seconds) do |average_score, percent_complete|
      puts "#{"%02d" % percent_complete}% complete. Average score = #{"%.2f" % average_score}"
    end
    
    puts "played #{n} games in #{"%02f" % time_elapsed} seconds"
    puts "average score: #{average_score}"
  end
end
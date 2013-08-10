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
end
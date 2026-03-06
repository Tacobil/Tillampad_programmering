# thanks to https://www.jeffreythompson.org/collision-detection
require_relative "settings.rb"

require_relative "player.rb"
require_relative "elevator.rb"
require_relative "map.rb"



class Game
    attr_accessor :world_x, :world_y, :map, :player
    def initialize()
        @map = Map.new(0,0, nil, $map)
        Map.set_map(@map.x, @map.y)

        @coins = 0

        @player = Player.new(self, @map.spawn_x, @map.spawn_y)
        @player.set_scale(@map.zoom)
    end

    def update(dt)
        @map.update(dt)
        @player.input($keys)
        @player.update(dt)
        # coin_check($player)
    
        # txt.text = "coins: #{$player.coins} / #{COIN_AMOUNT}"
    end

end



def coin_check(player)
    coins = player.map["coins"]

    coins.each_with_index do |coin, i|
        if rect_circle(player.rect, coin)
            coin.remove
            Sound.new('sfx/coin.mp3').play
            coins.delete_at(i)

            $player.coins += 1
        end
    end
end


game = Game.new()

last_time = Time.now

update do
    # delta time math
    now = Time.now
    dt = now - last_time
    last_time = now
    if dt > 0.1
        dt = 0.1
    end
    
    game.update(dt)
end

on :key_down do |event|
    if event.key == "w" or event.key == "space"
        game.player.jump
    end
end

show
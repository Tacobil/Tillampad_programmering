# thanks to https://www.jeffreythompson.org/collision-detection
require_relative "settings.rb"

require_relative "player.rb"
require_relative "map.rb"
require_relative "speaker.rb"

class Game
    attr_accessor :map, :maps, :player
    def initialize()
        @maps = [
            Map.new(0,0,$map1),
            Map.new(1,0,$map2),
            Map.new(2,0,$map3),
        ]
        @narrator = Speaker.new("Narrator", "textures/speaker/narrator.png", 0.7, nil, 100)
        # @narrator = Speaker.new("Narrator", "textures/speaker/unknown.png", 0.5, nil, 100)

        @map = @maps[0]
        Map.set_map(@map.x, @map.y)

        @player = Player.new(self, @map.spawn_x, @map.spawn_y)
        @player.set_scale(@map.zoom)
        @narrator.speak("hi!", nil)
    end

    def update(dt)
        @map.update(dt)
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

map = 0

on :key_down do |event|
    case event.key
    when "w"
        game.player.jump
    when "space"
        game.player.jump
    when "r"
        clear
        game = Game.new
    when "e"
        map = (map + 1) % 3
        game.map = Map.set_map(map,0)
        game.player.set_scale(game.map.zoom)
        game.player.rect.x = game.map.spawn_x
        game.player.rect.y = game.map.spawn_y

    end
end

show
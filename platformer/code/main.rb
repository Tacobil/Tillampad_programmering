# thanks to https://www.jeffreythompson.org/collision-detection
require_relative "settings.rb"

require_relative "player.rb"
require_relative "map.rb"
require_relative "speaker.rb"

class Game
    attr_accessor :player
    def initialize()
        @narrator = Speaker.new("Narrator", "textures/speaker/narrator.png", 0.7, "sfx/voice_toriel.wav")
        @player = Player.new(self)

        Map.set_map(0, 0)
        @player.set_scale(@map.zoom)

        @narrator.speak("hi! i am narrator", nil)

    end

    def set_map

    end

    def key_down(key)
        case key
        when "w"
            @player.jump
        when "space"
            @player.jump
        end
        @narrator.skip
    end

    def mouse_down(event)
        @narrator.skip
    end

    def update(dt)
        @map.update(dt)
        @player.update(dt)
        @narrator.update(dt)
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

@maps = [
    Map.new(0,0,$map1),
    Map.new(1,0,$map2),
    Map.new(2,0,$map3),
]

on :key_down do |event|
    game.key_down(event.key)
    # debugging events
    case event.key
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

on :mouse_down do |event|
    game.mouse_down(event)
end

show
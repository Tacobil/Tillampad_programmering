# thanks to https://www.jeffreythompson.org/collision-detection
require_relative "settings.rb"

require_relative "player.rb"
require_relative "map.rb"
require_relative "dialogue.rb"

class Game
    attr_accessor :player
    def initialize()
        @narrator = Dialogue.new("Narrator", "textures/speaker/narrator.png", 0.7, "sfx/voice_toriel.wav")
        @player = Player.new(self)
        @maps = [
            Map.new(0,0,$map1),
            Map.new(1,0,$map2),
            Map.new(2,0,$map3),
        ]
        
        self.set_map(0,0)
    end

    def set_map(x, y)
        map = Map.set_map(x, y)
        
        @player.set_scale(map.zoom)
        @player.rect.x = map.spawn_x
        @player.rect.y = map.spawn_y
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
        map = Map.current_map
        
        map.update(dt)
        @player.update(dt, map.tiles + map.objects)
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



on :key_down do |event|
    game.key_down(event.key)
    # debugging events
    case event.key
    when "r"
        clear
        game = Game.new
    when "e"
        map = (map + 1) % 3
        game.set_map(map, 0)
    end
end

on :mouse_down do |event|
    game.mouse_down(event)
end

show
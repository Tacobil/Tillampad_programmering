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
            Map.new("data/maps/start.tmx",0,0),
            Map.new("data/maps/plains.tmx",1,0),
        ]
        set_map(@maps.first)
        respawn()
    end

    def get_map(x, y)
        the_map = nil
        # Find the corresponding map
        @maps.each do |map|
            if map.x == x and map.y == y
                return map
            end
        end

        return nil
    end
    
    def respawn()
        @player.rect.x = @map.spawn_x
        @player.rect.y = @map.spawn_y
        @player.health = 100
    end

    def set_map(map)
        if @map
            @map.hide
        end
        @map = map
        @map.show
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
        @player.update(dt, @map.collisions)
        @map.update(dt, @player)
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

on :key_down do |event|
    game.key_down(event.key)
    # debugging events
    case event.key
    when "r"
        clear
        game = Game.new
    when "t"
        game.player.god_mode = !game.player.god_mode
    end
end

on :mouse_down do |event|
    game.mouse_down(event)
end

show
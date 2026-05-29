# Name: An Average Platformer
# Author: Simon Bukvic
# Date: 2026-05-08
# Description: An unfinished platformer game

require_relative "utility.rb"
include Collision
include Utility

require_relative "settings.rb"
require_relative "player.rb"
require_relative "map.rb"
require_relative "dialogue.rb"

class Game
    attr_accessor :player, :map, :narrator

    # Creates Game Object

    # @return void
    def initialize()
        @player = Player.new(self)
        @map = nil
        @maps = [
            Map.new(self, "data/maps/0.tmx",0,0),
            Map.new(self, "data/maps/1.tmx",1,0),
            Map.new(self, "data/maps/2.tmx",2,0),
            Map.new(self, "data/maps/3.tmx",3,0),
            Map.new(self, "data/maps/4.tmx",4,0),
            Map.new(self, "data/maps/5.tmx",5,0),
        ]
        @narrator = Dialogue.new("The final boss", "textures/speaker/narrator.png",359/470, "sfx/voice_toriel.wav")
        
        @narrator.speak("Welcome!")
        @narrator.add_to_queue("Move around with the keys A and D")

        @last_time = Time.now

        set_map(@maps.first)
        @player.respawn()
    end

    # Returns the map at the given coordinates. Returns nil if map isn't found
    #
    # @param x [Integer] X-coordinate
    # @param y [Integer] Y-coordinate
    # @return [Map] | [nil] the map at the coordinate, or nil
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
    
    # Sets the current map to the given map and hides the previous map
    # 
    # @param map [Map] The map to be set.
    # @return void
    def set_map(map)
        if @map
            @map.hide
        end
        @map = map
        @map.show
    end

    # Handle key down events
    # 
    # @param key [String] The key that was pressed
    # @return void
    def key_down(key)
        case key
        when "w"
            @player.jump
        when "space"
            @player.jump
        end
        @narrator.skip
    end

    # Handle mouse button events
    # 
    # @param event
    # @return void
    def mouse_down(event)
        @narrator.skip
    end

    # Get the deltatime between the previous frame.
    # 
    # @return [Float] deltatime
    def get_dt()
        now = Time.now
        dt = now - @last_time
        @last_time = now
        if dt > 0.1
            dt = 0.1
        end
        return dt
    end

    # Update the game. Called every frame
    # 
    # @return void
    def update()
        dt = self.get_dt()
        @player.update(dt)
        @map.update(dt, @player)
        @narrator.update(dt)
    end

end

game = Game.new()

update do
    game.update()
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
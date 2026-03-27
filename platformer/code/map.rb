require_relative "elevator.rb"
require_relative "jump_orb.rb"
require_relative "coin.rb"

class Map
    attr_accessor :x, :y, :objects, :tiles
    attr_reader :spawn_x, :spawn_y, :zoom
    
    @@all = []
    @@current_map = nil

    def initialize(x, y, map)
        @x = x
        @y = y

        @height = map.length
        @width = 0

        map.each do |row|
            if row.length > @width
                @width = row.length
            end
        end
        
        @aspect_ratio = @height / @width.to_f
        screen_aspect_ratio = VH / VW.to_f

        if @aspect_ratio < screen_aspect_ratio # tiles cover full width
            @tile_size = VW / @width
            remaining_height = VH - @height * @tile_size
            @offset_x = 0
            @offset_y = remaining_height / 2
        else # tiles cover full height
            @tile_size = VH / @height
            remaining_width = VW - @width * @tile_size
            @offset_x = remaining_width / 2
            @offset_y = 0
        end
        @zoom = @tile_size / UNIT.to_f


        @objects = [
            Elevator.new(posx(0), posy(-1), @tile_size*3, @tile_size, "green", posx(0), posy(-9), 1.5, 0.1, "quint"),
            Elevator.new(posx(5), posy(-12), @tile_size, @tile_size, "green", posx(15), posy(-15), 3, 1, "sine"),
            JumpOrb.new(posx(6.5), posy(-18.5), @zoom, 3),
            JumpOrb.new(posx(3.5), posy(-20.5), @zoom, 3),
            JumpOrb.new(posx(3.5), posy(-22.5), @zoom, 3),
            JumpOrb.new(posx(6.5), posy(-24.5), @zoom, 3),
            JumpOrb.new(posx(3.5), posy(-3.5), @zoom, 3),
            

        ]
        @tiles = []
        @background = Rectangle.new(
            x: @offset_x, y: @offset_y,
            width: @width * @tile_size,
            height: @height * @tile_size,
            color: [0.2,0.3,0.9,1],
            z: -10
        )

        @spawn_x = 0
        @spawn_y = 0

        map.each_with_index do |row, ty|
            row.each_with_index do |tile, tx|
                px = tx*@tile_size + @offset_x
                py = ty*@tile_size + @offset_y


                c_o = ((tx + ty) % 2) * -0.03
                case tile
                when G
                    a = Rectangle.new(
                        x: px, y: py,
                        width: @tile_size, height: @tile_size,
                        color: [0.5+c_o, 0.5+c_o, 1+c_o, 1],
                        )
=begin
                        a = Image.new(
                        "textures/grass/grass.png",
                        x: px, y: py, z: 1,
                        width: @tile_size, height: @tile_size,
                        rotate: 90,
                        )
=end
                    @tiles << a
                when C
                    @objects << Coin.new(px, py, @tile_size)
                when P
                    @spawn_x = px
                    @spawn_y = py
                end
            end
        end


        self.hide
        
        @@all << self
    end

    def posx(tile_pos)
        if tile_pos < 0
            tile_pos = @width + tile_pos
        end

        return tile_pos * @tile_size + @offset_x
    end
    def posy(tile_pos)
        if tile_pos < 0
            tile_pos = @height + tile_pos
        end
        return tile_pos * @tile_size + @offset_y
    end

    def update(dt)
        objects.each do |obj|
            if obj.respond_to? :update
                obj.update(dt)
            end
        end

    end

    def show()
        @objects.each do |obj|
            obj.add
        end
        @tiles.each do |tile|
            tile.add
        end
        @background.add
    end

    def hide()
        @objects.each do |obj|
            obj.remove
        end
        @tiles.each do |obj|
            obj.remove
        end
        @background.remove
    end
    
    def Map.get_map(x, y)
        @@all.each do |map|
            if map.x == x and map.y == y
                return map
            end
        end
    end

    def Map.set_map(x, y)
        puts x, y
        map = Map.get_map(x, y)
        if map == nil
            raise "Invalid map coordinate"
        end

        
        if @@current_map
            @@current_map.hide
        end
        
        map.show
        
        @@current_map = map
        return map
    end

    # getters
    def Map.current_map
        return @@current_map
    end
    def Map.all
        return @@all
    end
end


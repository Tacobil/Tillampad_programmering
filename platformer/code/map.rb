class Map
    attr_accessor :x, :y, :objects, :tiles
    attr_reader :spawn_x, :spawn_y, :zoom

    @@all = []
    @@current_map = nil

    def initialize(x, y, tileset, map)
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

        @objects = [
            Elevator.new(posx(0), posy(-1), @tile_size*3, @tile_size, "green", posx(0), posy(-9), 2, 0.2, "quint"),
            Elevator.new(posx(5), posy(-12), @tile_size, @tile_size, "green", posx(15), posy(-15), 3, 1, "sine"),
        ]
        @tiles = []
        @background = Rectangle.new(
            x: @offset_x, y: @offset_y,
            width: @width * @tile_size,
            height: @height * @tile_size,
            color: [0.2,0.3,0.9,1],
            z: 0
        )

        @spawn_x = 0
        @spawn_y = 0

        map.each_with_index do |row, y|
            row.each_with_index do |tile, x|
                c_o = ((x + y) % 2) * -0.03
                case tile
                when 1
                    @tiles << Rectangle.new(
                        x: x*@tile_size + @offset_x, y: y*@tile_size + @offset_y, 
                        width: @tile_size, height: @tile_size,
                        color: [0.5+c_o, 0.5+c_o, 1+c_o, 1]
                    )

                when 2
                    @tiles << Rectangle.new(
                        x: x*@tile_size + @offset_x, y: y*@tile_size + @offset_y, 
                        width: @tile_size, height: @tile_size,
                        color: [0.5, 1, 1, 1]
                    )
                when P
                    @spawn_x = @offset_x + x * @tile_size
                    @spawn_y = @offset_y + y * @tile_size
                end
            end
        end

        @zoom = @tile_size / UNIT.to_f

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
            obj.update(dt)
        end

    end

    def show()
        @objects.each do |obj|
            obj.add
        end
        @tiles.each do |tile|
            tile.add
        end
    end

    def hide()
        @objects.each do |obj|
            obj.remove
        end
        @tiles.each do |obj|
            obj.remove
        end

    end
    
    def Map.get_map(x, y)
        @@all.each do |map|
            p map.class
            if map.x == x and map.y == y
                return map
            end
        end
    end

    def Map.set_map(x, y)
        map = Map.get_map(x, y)
        if map == nil
            raise "Invalid map coordinate"
        end

        if @@current_map
            @@current_map.hide
        end

        map.show
        
        @@current_map = map

    end
end



class Map
    attr_accessor :x, :y, :objects, :tiles

    @@all = []

    def initialize(x, y, tileset, map)
        @x = 0
        @y = 0
        @zoom = 1

        @objects = []
        @tiles = []

        @@all << self
    end

    def show()
        @objects.each do |obj|
            obj.remove
        end
    end

    def hide()
        @objects.each do |obj|
            obj.add
        end
        @tiles.each do |obj|
            obj.add
        end

    end
    
    def Map.get_map(x, y)
        @@all.each do |map|
            if map.x == x and map.y == y
                return map
            end
        end
    end
end

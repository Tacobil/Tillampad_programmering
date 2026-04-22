# pixels: 320x180
# tiles: 40x22.5
# aspect ratio: 16:9

require_relative "settings.rb"

require "tmx"

class Coin < Circle
	RADIUS = UNIT/2.0
	COLOR = [1,1,0.3,0.9]
	FADE_TIME = 0.5

	def initialize(x, y, scale)
		super(x: (x+RADIUS)*scale, y: (y+RADIUS)*scale, z:2, radius: RADIUS*scale, color: COLOR)

		@sprite = Sprite.new(
			"data/graphics/tilesets/pixelated-coin.png",
			clip_width: 8,
			x: (x*scale).to_i, y: (y*scale).to_i, # offset by size/2
			width: self.radius*2, height: self.radius*2,
			time: 100,
			loop: true
		)
		@particles = []
		@sprite.play
		@collected = false
		@time = 0
	end

	def add
		if @sprite
			@sprite.add
		end
	end

	def remove
		if @sprite
			@sprite.remove
		end
	end

	def update(dt, player)
		if rect_circle(player.rect, self)
        	self.interact(player)
      	end

		if @collected
			@time += dt
			if @time < FADE_TIME
				i = @time / FADE_TIME.to_f
				@sprite.color = [1,1,1,1-i]
				@sprite.y -= dt * @sprite.height * i * 5
				@particles.each do |p|
					dx = p.x - self.x
					dy = p.y - self.y
					p.x += sign(dx) * dt * p.size * 2
					p.y += sign(dy) * dt * p.size * 2
					p.color = [COLOR[0],COLOR[1],COLOR[2],0.5-i*0.5]
				end
			else
				@sprite.remove
				@particles.each do |p|
					p.remove
				end
			end
		end

	end

	def interact(player)
		if @collected
			return
		end
		@collected = true

		player.coins += 1
		sfx = Sound.new("sfx/coin.mp3")

		# Replace sprite when fading out because you cannot change time attribute
		@sprite.remove

		@sprite = Sprite.new(
			@sprite.path,
			clip_width: @sprite.clip_width,
			x: @sprite.x, y: @sprite.y,
			width: @sprite.width, height: @sprite.height,
			time: 10,
			loop: true
		)

		# Create Particles
		5.times do |i|
			s = Square.new(
				x: self.x+rand(-3..3), y: self.y+rand(-6..2), size: @sprite.width/3.0*rand(0.5..1.5), color: COLOR
			)
			@particles << s
		end

		@sprite.play
		
		sfx.volume = 50
		sfx.play
	end

end

class JumpOrb < Circle
	RADIUS = UNIT / 4.0
	COLOR = [1,0.5,0.5,0.8]

	def initialize(x, y, scale, respawn_time)
		super(x: x, y: y, radius: RADIUS*scale, color: COLOR, z:2)
		@respawn_time = respawn_time
		@timer = 0
		@hidden = false
		
	end

	def update(dt)
		if @hidden
			@timer += dt
			if @timer >= @respawn_time
				self.add
				@hidden = false
				@timer = 0
			end
		end
	end

	def interact(player)
		if @hidden
			return
		end
		player.set_jumps(player.jumps + 1)
		@hidden = true
		self.remove
	end

end

class Elevator < Rectangle
    attr_reader :velocity_x, :velocity_y
    def initialize(ax, ay, w, h, color, bx, by, time, delay, style)
        super(x: ax, y: ay, width: w, height: h, color: color, z:2)
        
        @ax = ax
        @ay = ay
        
        @bx = bx
        @by = by

        @style = style
        @time = time
        @delay = delay

        @i = 0.0
        @mul = 1 / time.to_f

        @waiting = true
        @wait_time = 0

        @velocity_x = 0
        @velocity_y = 0
    end

    def get_percentage(i)
        case @style
        when "linear"
            return i
        when "sine"
            return -Math.cos(i*Math::PI/2) + 1
        when "quad"
            return i ** 2
        when "cubic"
            return i ** 3
        when "quart"
            return i ** 4
        when "quint"
            return i ** 5
        end
    end

    def update(dt)
        if @waiting
            @velocity_x = 0
            @velocity_y = 0

            @wait_time += dt
            if @wait_time > @delay
                # p "#{self.x}, #{self.y}"
                @waiting = false
                @wait_time = 0
            end
            return
        end

        @i += @mul * dt

        if @i > 1
            @i = 1
        elsif @i < 0
            @i = 0
        end
        
        if @mul < 0
            p = 1-self.get_percentage(1-@i)
        else
            p = self.get_percentage(@i)
        end

        if @i >= 1 or @i <= 0
            @mul = -@mul
            @waiting = true

            # make elevator stop perfectly in place
            new_x = (@ax + (@bx - @ax) * p).to_i
            new_y = (@ay + (@by - @ay) * p).to_i
        else
            new_x = @ax + (@bx - @ax) * p
            new_y = @ay + (@by - @ay) * p
        end

        @velocity_x = (new_x - self.x) / dt
        @velocity_y = (new_y - self.y) / dt
        # p "#{velocity_x}, #{velocity_y}"

        self.x = new_x
        self.y = new_y
    end
end

class Map
  SCALE = 3.2
  
  attr_reader :spawn_x, :spawn_y, :collisions, :x, :y

  def initialize(tmx_path, x, y)
    @tmx_map = Tmx.load(tmx_path)
    @zoom = SCALE
    @x = x
    @y = y
    
    # Create tilesets from the map's tilesets
    @tilesets = []
    @coins = []
    @spikes = []

    tile_id = 1

    @tmx_map.tilesets.each do |ts|
      new_tileset = Tileset.new(
        ts.image.sub("../", "data/"), # replace ../ in the path for data/
        tile_width: ts.tilewidth,
        tile_height: ts.tileheight,
        spacing: ts.spacing,
        padding: ts.margin,
        scale: SCALE
      )

      columns = (ts.imagewidth / ts.tilewidth)
      rows = (ts.imageheight / ts.tileheight)
      
      rows.times do |y|
        columns.times do |x|
          new_tileset.define_tile(tile_id, x, y)
          tile_id += 1
        end
      end
      @tilesets << new_tileset
    end
    
    # Build map

    @tmx_map.layers.each do |layer|
      if layer.visible == false
        next
      end
      layer.data.each_with_index do |tile_id, i|
        if tile_id == 0 # skip air tiles
          next
        end

        # calculate x and y from the one-dimensional array of ids
        x = i % layer.width
        y = i / layer.width

        # Load coin
        if layer.name == "Coins"
          @coins << Coin.new(x*8, y*8, SCALE)
          next
        end

        # Load tile from the corresponding tileset
        max_id = 0
        @tilesets.each_with_index do |ts, i|
          columns = (ts.width / ts.tile_width)
          rows = (ts.height / ts.tile_height)
          tiles = columns * rows

          max_id += tiles
          if tile_id < max_id
            ts.set_tile(tile_id, [{x: x*8*SCALE, y: y*8*SCALE}])
            break
          end
        end

      end
    end

    # Load objects
    @collisions = []
    @tmx_map.object_groups.each do |object_group|
      if object_group.name == "Collision"
        object_group.objects.each do |object|

          r = Rectangle.new(
            x: object.x*SCALE, y: object.y*SCALE, z: 1000,
            width: object.width*SCALE, height: object.height*SCALE,
            color: [1,0,0,0]
          )

          @collisions << r
        end
      end
    end

    # Find player spawn
    @tmx_map.objects.each do |object|
      if object.name == "Player"
        @spawn_x = object.x * SCALE
        @spawn_y = object.y * SCALE
      end
    end

    self.hide
  end

  def update(dt, player)
    @coins.each do |coin|
      coin.update(dt, player)
    end
  end

  def show
    @tilesets.each do |ts|
      ts.add
    end
    @collisions.each do |c|
      c.add
    end
    @coins.each do |c|
      c.add
    end
  end

  def hide
    @tilesets.each do |ts|
      ts.remove
    end
    @collisions.each do |c|
      c.remove
    end
    @coins.each do |c|
      c.remove
    end
  end
end

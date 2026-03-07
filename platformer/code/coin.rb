class Coin < Circle
	RADIUS = UNIT * 2/3.0 / 2
	SPRITE_SIZE = RADIUS*2
	COLOR = [0.5,0.5,1,0]
	FADE_TIME = 0.5
	P_COLOR = [206/255.0, 147/255.0, 216/255.0, 0.5]

	def initialize(x, y, tile_size)
		scale = tile_size/UNIT
		super(x: x+tile_size/2, y: y+tile_size/2, z:2, radius: RADIUS*scale, color: COLOR)

		sprite_size = SPRITE_SIZE*scale
		@sprite = Sprite.new(
			"textures/purple_coin.png",
			clip_width: 48,
			x: (self.x-sprite_size/2).to_i, y: (self.y-sprite_size/2).to_i,
			width: sprite_size, height: sprite_size,
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

	def update(dt)
		if @collected == false
			return
		end

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
				p.color = [P_COLOR[0],P_COLOR[1],P_COLOR[2],P_COLOR[3]-i*0.5]
			end
		else
			@sprite.color = [1,1,1,0]
		end


	end

	def interact(player)
		if @collected
			return
		end
		@collected = true

		player.coins += 1
		sfx = Sound.new("sfx/coin.mp3")
		# p @sprite.instance_variables

		# Replace sprite when fading out because you cannot change time attribute
		@sprite.remove
		@sprite = Sprite.new(
			"textures/purple_coin.png",
			clip_width: 48,
			x: @sprite.x, y: @sprite.y,
			width: @sprite.width, height: @sprite.height,
			time: 10,
			loop: true
		)

		# Create Particles
		5.times do |i|
			s = Square.new(
				x: self.x+rand(-3..3), y: self.y+rand(-6..2), size: @sprite.width/3.0*rand(0.5..1.5), color: P_COLOR
			)
			@particles << s
		end

		@sprite.play
		
		sfx.volume = 50
		sfx.play
	end

end
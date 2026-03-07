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
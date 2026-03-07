class JumpOrb < Circle
	RADIUS = UNIT * 0.5
	COLOR = [1,0.5,0.5,0.8]

	def initialize(x, y, respawn_time)
		r = JumpOrb::RADIUS # for simplicity
        super(x: x, y: y, radius: r, color: COLOR, z:2)

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
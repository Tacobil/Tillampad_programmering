

class Dialogue
	WIDTH = VW * 0.8
	HEIGHT = VH * 0.3
	X = center(VW*0.5, WIDTH)
	Y = center(VH*0.8, HEIGHT)
	COLOR = [0.2, 0.2, 0.3, 1]

	PADDING = 10
	IMAGE_PADDING = 10

	def initialize(name, icon_path, icon_aspect_ratio, sound_path)
		@sound = Sound.new(sound_path)
		@delays = {
			"" => 0.03, # any character
			"," => 0.08,
			"." => 0.2,
			" " => 0.06,
		}
		
		@letter_i = 0
		@current_message = ""
		@timer = 0
		@current_delay = 0
		@typing = false
		
		@text_queue = []
		
		
		@rect = Rectangle.new(width: WIDTH, height: HEIGHT, x: X, y: Y, z: 100, color: COLOR)
		
		@icon_frame = Rectangle.new(
			height: HEIGHT - PADDING * 2,
			width: (HEIGHT - PADDING * 2) * icon_aspect_ratio,

			x: X + PADDING, y: Y + PADDING, z: 101,
			color: [0,0,0,0.2]
		)

		@name_frame = Rectangle.new(
			width: WIDTH - @icon_frame.width - PADDING * 3, height: HEIGHT*0.2,

			x: @icon_frame.x + @icon_frame.width + PADDING, y: @icon_frame.y, z: 101,
			color: [0,0,0,0.2]
		)

		@text_frame = Rectangle.new(
			width: @name_frame.width, height: HEIGHT - @name_frame.height - PADDING * 3,

			x: @name_frame.x, y: @name_frame.y + @name_frame.height + PADDING, z: 101,
			color: [0,0,0,0.2]
		)

		@icon = Image.new(
			icon_path,
			height: @icon_frame.height - IMAGE_PADDING * 2, 
			width: (@icon_frame.height - IMAGE_PADDING * 2) * icon_aspect_ratio, 
			z: 102,
		)

		@name = Text.new(
			name,
			font: "fonts/ByteBounce.ttf",
			size: 48,
			z: 101
		)

		@text = Text.new(
			"",
			font: "fonts/ByteBounce.ttf",
			size: 32,
			z: 101,
		)

		@hint = Text.new(
			"Press any key to continue",
			font: "fonts/ByteBounce.ttf",
			z: 102,
			size: 16,
			color: [1,1,1,0]
		)
		
		
		@elements = [@rect, @icon_frame, @name_frame, @text_frame, @icon, @name, @text, @hint]
		
		centerize(@icon, @icon_frame)
		centerize(@name, @name_frame)
		centerize(@text, @text_frame)
		centerize(@hint, @text_frame)
		@hint.y = Y + HEIGHT * 0.85
		
		self.set_visibility(false)
	end

	def set_visibility(visible)
		@elements.each do |element|
			if visible
				element.add
			else
				element.remove
			end
		end
	end
	
	def speak(text, attributes)
		# attributes: skippable, unknown

		self.set_visibility(true)
		@text.text = ""
		@current_message = text
		@typing = true
		@letter_i = 0
		@timer = 0
		@current_delay = 0
		@hint.color.opacity = 0
	end

	def add_to_queue(text)
		@text_queue << @text
	end

	def skip
		if @typing
			# fast forward this line
			@text.text = @current_message
			centerize(@text, @text_frame)
			@typing = false

		elsif @text_queue.length > 0
			# next line
			self.speak(@text_queue.delete_at(0), nil) # remove element from queue and start speaking
		else
			# hide
			self.set_visibility(false)
		end
	end

	def update(dt)
		if @text.text == @current_message && @timer > 1 && @hint.color.opacity < 1
			@hint.color.opacity += dt
		end

		@timer += dt
		if @typing
			while @timer > @current_delay
				@timer -= @current_delay
				
				if @letter_i < @current_message.length
					this_letter = @current_message[@letter_i]
					@text.text += this_letter
					centerize(@text, @text_frame)

					if @delays[this_letter]
						@current_delay = @delays[this_letter]
					else
						@current_delay = @delays[""]
					end
					@sound.play
				else
					@typing = false
					
					break
				end

				@letter_i += 1
			end
		end
	end
end

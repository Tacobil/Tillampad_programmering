require 'word_wrap'
require 'word_wrap/core_ext'

class Speaker
	WIDTH = VW * 0.8
	HEIGHT = VH * 0.3
	X = center(VW*0.5, WIDTH)
	Y = center(VH*0.8, HEIGHT)
	COLOR = [0.2, 0.2, 0.3, 1]

	PADDING = 10
	IMAGE_PADDING = 10

	def initialize(name, icon_path, icon_aspect_ratio, sound, cpm)
		@rect = Rectangle.new(width: WIDTH, height: HEIGHT, x: X, y: Y, z: 100, color: COLOR)
		@sound = sound
		@cpm = 100

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

		centerize(@icon, @icon_frame)
		centerize(@name, @name_frame)
		centerize(@text, @text_frame)

		self.set_visibility(false)
	end

	def set_visibility(visible)
		if visible
			@rect.add
			@icon.add
			@icon_frame.add
			@name.add
			@text.add
		else
			@rect.remove
			@icon.remove
			@icon_frame.remove
			@name.remove
			@text.remove
		end
	end
	
	def speak(text, attributes)
		# attributes: skippable, unknown
		@text.text = text
		self.set_visibility(true)
		


	end
end
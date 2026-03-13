class Speaker
	WIDTH = VW * 0.8
	HEIGHT = VH * 0.3
	X = center(VW*0.5, WIDTH)
	Y = center(VH*0.8, HEIGHT)
	COLOR = [0.2, 0.2, 0.3, 1]

	PADDING = 10
	IMAGE_PADDING = 10

	def initialize(name, icon_path, icon_aspect_ratio, voice_path)
		@rect = Rectangle.new(width: WIDTH, height: HEIGHT, x: X, y: Y, z: 100, color: COLOR)
		@voice = Sound.new(voice_path)

    @visible = false

    @delays = {
      "" => 0.03,
      " " => 0.06,
      "," => 0.1,
      "." => 0.4,
      "!" => 0.2,
      "?" => 0.6,
    }

    @letter_i = 0
    @timer = 0
    @current_delay = 0
    @full_message = ""
    @speaking = false
    

    @text_queue = [
      "ooo ooo aa ! aa !",
      "press some keys to move idk which tho",
      "Hi! Welcome to this game. Move with your keys: WASD, or arrow keys :>",
      "This is a really long message. I really hope it scales well, otherwise I'll be pissed. Please work so I can go to sleep!",
    ]


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
			"Press any key to proceed",
			font: "fonts/ByteBounce.ttf",
			size: 16,
			z: 101,
      color: [1,1,1,0]
		)
		centerize(@icon, @icon_frame)
		centerize(@name, @name_frame)
		centerize(@text, @text_frame)
    centerize(@hint, @text_frame)
    @hint.y = Y + HEIGHT * 0.8
    
    @elements = [@rect, @icon_frame, @name_frame, @text_frame, @icon, @name, @text, @hint]
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
    @timer = 0
    @letter_i = 0
    @current_delay = 0
    @full_message = text
    @speaking = true
    @text.text = ""
    @hint.color.opacity = 0
    @text.size = 32
	end

  def continue
    if @speaking # skip
      @speaking = false
      @text.text = @full_message

      while @text.width > @text_frame.width * 0.9
        @text.size -= 1
      end

      centerize(@text, @text_frame)
    elsif @text_queue.length > 0
      self.speak(@text_queue.delete_at(0), nil)
    else # close
      self.set_visibility(false)
    end
  end

  def update(dt)
    @timer += dt



    if @speaking == false and @timer > 1 and @hint.color.opacity < 1
      @hint.color.opacity += dt
    end

    if @speaking
      if @timer >= @current_delay
        @timer -= @current_delay
        # load next character
        if @letter_i < @full_message.length
          next_char = @full_message[@letter_i]

          if @delays[next_char]
            @current_delay = @delays[next_char]
          else
            @current_delay = @delays[""]
          end

          @text.text += next_char
          
          while @text.width > @text_frame.width * 0.9
            @text.size -= 1
          end

          centerize(@text, @text_frame)

          @voice.play

          @letter_i += 1
        else
          @speaking = false
        end
      end
    end
  end
  
end

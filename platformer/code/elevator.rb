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
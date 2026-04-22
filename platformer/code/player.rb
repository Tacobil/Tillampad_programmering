
class Player

    # Celeste
    # Movement
=begin
    MOVE_SPEED = 9
    ACCELERATION = 13
    DECCELERATION = 16
    VEL_POWER = 0.96

    FRICTION_AMOUNT = 0.22

    # Jump
    JUMP_FORCE = 13
    JUMP_CUT_MUL = 0.4

    JUMP_COYOTE_TIME = 0.15
    JUMP_BUFFER_TIME = 0.1
    
    FALL_GRAVITY_MUL = 2
=end

    # Super Meat Boy
    # Movement
    MOVE_SPEED = 14
    ACCELERATION = 8
    DECCELERATION = 24
    VEL_POWER = 0.87

    FRICTION_AMOUNT = 0.25

    # Jump
    JUMP_FORCE = 10
    JUMP_CUT_MUL = 0.1

    JUMP_COYOTE_TIME = 0.15
    JUMP_BUFFER_TIME = 0.1
    
    FALL_GRAVITY_MUL = 1.9

=begin
    # Hollow Knight
    # Movement
    MOVE_SPEED = 9
    ACCELERATION = 9
    DECCELERATION = 9
    VEL_POWER = 1.2

    FRICTION_AMOUNT = 0.2

    # Jump
    JUMP_FORCE = 12
    JUMP_CUT_MUL = 0.1

    JUMP_COYOTE_TIME = 0.15
    JUMP_BUFFER_TIME = 0.1
    
    FALL_GRAVITY_MUL = 1.9
=end

    # Other
    JUMPPOWER = 280
    GRAVITY = 1200

    MAX_HEALTH = 100

    WIDTH = UNIT * 1.2
    HEIGHT = UNIT * 2

    AIR_JUMPS = 0
    ABC = 10

    JUMP_COLORS = [
        'teal',
        [1, 0.3, 0.3, 1],
        [0.6, 0.3, 1, 1],
    ]

    SCALE = 3.2

    attr_accessor :rect, :jumps, :coins, :health, :god_mode

    def initialize(game)
        @game = game

        @input_x = 0
        @input_y = 0

        @velocity_x = 0
        @velocity_y = 0
        @acceleration_x = 0
        @acceleration_y = GRAVITY

        @world_x = 0
        @world_y = 0
                
        @air_time = 0.0
        @jumps = AIR_JUMPS + 1
        @has_jumped = false

        @scale = SCALE

        @rect = Rectangle.new(
            width: WIDTH * @scale, height: HEIGHT * @scale,
            color: 'teal',
            z: 20
        )

        @god_mode = false

        @coins = 0
        @health = 100

        @health = MAX_HEALTH
    end

    def set_scale(scale)
        if scale <= 0
            return
        end

        @scale = scale
        @rect.width = WIDTH * scale
        @rect.height = HEIGHT * scale
    end

    def jump
        if @jumps <= 0 # don't jump if player has no jumps left
            return
        end

        if @velocity_y >= 0
            @velocity_y = -JUMPPOWER * @scale
        else
            @velocity_y *= 0.8
            @velocity_y += -JUMPPOWER * @scale
        end
        self.set_jumps(@jumps-1)
        @has_jumped = true
    end

    def set_jumps(jumps)
        @jumps = jumps
        if jumps >= JUMP_COLORS.length
            @rect.color = JUMP_COLORS[-1]
        else
            @rect.color = JUMP_COLORS[jumps]
        end
    end

    def input(keys)
        @input_x = (keys["d"] - keys["a"])
        @input_y = (keys["s"] - keys["w"])
        # self.set_scale(@scale + (keys["i"] - keys["o"])*0.1)
    end

    def collision(objects, direction, dt)
        objects.each do |r| # iterate all hitbox_rects
            if rect_rect?(r, @rect)
                if direction == "horizontal"
                    @velocity_x = 0
                    if @rect.x + @rect.width / 2.0 < r.x + r.width / 2.0 # player is to the left
                        @rect.x = r.x - @rect.width # set player's right edge to object's left edge
                    else
                        @rect.x = r.x + r.width # set player's left edge to object's right edge
                    end
                end

                if direction == "vertical"
                    @velocity_y = 0
                    if @rect.y + @rect.height / 2.0 > r.y + r.height / 2.0 # player is below
                        @rect.y = r.y + r.height + 1 # set player's top edge to object's bottom edge
                    else
                        @rect.y = r.y - @rect.height # set player's bottom edge to object's top edge
                        if @air_time > 0.1
                            # p @air_time
                        end
                        @air_time = 0
                        self.set_jumps(AIR_JUMPS + 1)
                        @has_jumped = false

                        # apply velocity if object is moving
                        if r.respond_to?(:velocity_x) and r.respond_to?(:velocity_y)
                            # @velocity_x += r.velocity_x
                            @velocity_y += r.velocity_y
                        end
                    end
                end

            end
        end
    end

    def wall_collision()
        change_map = false
        # map change
        if @rect.x2 < 0 # player is at left part of screen       
            @rect.x = VW - ABC
            @world_x -= 1
            change_map = true
        end
        if @rect.x > VW # player is at right part of screen
            @rect.x = -@rect.width + ABC
            @world_x += 1
            change_map = true
        end
        if @rect.y3 < 0 # player is at top part of screen
            @rect.y = VH - ABC
            @world_y -= 1
            change_map = true
        end
        if @rect.y > VH
            @rect.y = -@rect.height + ABC
            @world_y += 1
            change_map = true
        end
        if change_map
            @game.set_map(@game.get_map(@world_x, @world_y))
        end
    end

    def update(dt, objects)
        self.input($keys)
        self.wall_collision
        if @god_mode
            @velocity_y = @input_y * MOVE_SPEED * @scale * 10
            @velocity_x = @input_x * MOVE_SPEED * @scale * 10
            @rect.x += @velocity_x * dt
            @rect.y += @velocity_y * dt
            return
        end

        # Movement, https://youtu.be/KbtcEVCM7bw?si=sFKXjFfIVndh50TN&t=108
        target_speed = @input_x * MOVE_SPEED * MOVE_SPEED * @scale # get direction and desired velocity
        speed_dif = target_speed - @velocity_x # get difference between current speed and desired velocity
        
        if target_speed == 0
            accel_rate = DECCELERATION
        else
            accel_rate = ACCELERATION
        end
        
        movement = ((speed_dif.abs * accel_rate).to_f ** VEL_POWER) * sign(speed_dif)
        @acceleration_x = movement

        # Friction
        if @air_time == 0 && @input_x == 0
            amount = [@velocity_x.abs, FRICTION_AMOUNT].min
            amount *= sign(@velocity_x)
            @velocity_x -= amount
        end


        @velocity_x += @acceleration_x * dt
        @velocity_y += @acceleration_y * @scale * dt

        @air_time += dt

        @rect.y += @velocity_y * dt
        self.collision(objects, "vertical", dt)

        @rect.x += @velocity_x * dt
        
        self.collision(objects, "horizontal", dt)

        # player is airborne and haven't jumped; remove one jump.
        if @has_jumped == false && @air_time > JUMP_COYOTE_TIME && @jumps == AIR_JUMPS + 1
            @has_jumped = true
            self.set_jumps(@jumps - 1)
        end
            

        if @rect.y > VH
            # Death
            self.die
            @rect.y *= -1
        end

    end

    def die
        
    end
end
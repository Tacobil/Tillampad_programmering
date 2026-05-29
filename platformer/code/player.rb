
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

    AIR_JUMPS = 1
    MAP_CHANGE_MARGIN = 10

    SCALE = 3.2

    RESPAWN_TIME = 2

    attr_accessor :rect, :jumps, :coins, :health, :god_mode

    # Initialize a new player
    # 
    # @param game [Game] the game object
    # @return void
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
        @jumps = 0
        @has_jumped = false

        @rect = Rectangle.new(
            width: WIDTH * SCALE, height: HEIGHT * SCALE,
            color: 'teal',
            z: 20
        )
        @death_screen = Image.new("textures/you-died.png", x:0, y:0, z:100, width:VW, height:VH)
        @death_screen.remove
        @death_counter = 0
        
        @god_mode = false

        @coins = 0
        @health = 100

        @health = MAX_HEALTH
    end

    # Respawn the player
    # 
    # @return void
    def respawn()
        @rect.x = @game.map.spawn_x
        @rect.y = @game.map.spawn_y - @rect.height
        @velocity_x = 0
        @velocity_y = 0
        @health = 100
        
        @death_counter = 0
        @death_screen.remove
        @rect.add
    end

    # Make the player jump
    # 
    # @return void
    def jump
        if @jumps > AIR_JUMPS # don't jump if player has no jumps left
            return
        end

        if @velocity_y >= 0
            @velocity_y = -JUMPPOWER * SCALE
        else
            @velocity_y *= 0.8
            @velocity_y += -JUMPPOWER * SCALE
        end

        @jumps += 1
        @has_jumped = true
    end

    # Handle inputs
    # 
    # @param keys [Hash] hash containing the pressed keys
    # @return void
    def input(keys)
        @input_x = (keys["d"] - keys["a"])
        @input_y = (keys["s"] - keys["w"])
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
                        @jumps = 0
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

    # Handle map changes when player goes off-screen
    # 
    # @return void
    def map_check
        change_map = false

        # map change
        if @rect.x2 < 0 # player is at left part of screen
            @rect.x = VW - MAP_CHANGE_MARGIN
            @world_x -= 1
            change_map = true
        end
        if @rect.x > VW # player is at right part of screen
            @rect.x = -@rect.width + MAP_CHANGE_MARGIN
            @world_x += 1
            change_map = true
        end
        if change_map
            map = @game.get_map(@world_x, @world_y)
            if map != nil
                @game.set_map(map)
            end
        end
    end

    # Update the player
    # @param dt [float]
    # @return void
    def update(dt)
        self.input($keys)
        self.map_check

        if @health == 0
            @death_counter += dt
            if @death_counter > RESPAWN_TIME
                self.respawn
            end

            return
        end

        if @god_mode
            @velocity_y = @input_y * MOVE_SPEED * SCALE * 40
            @velocity_x = @input_x * MOVE_SPEED * SCALE * 40
            @rect.x += @velocity_x * dt
            @rect.y += @velocity_y * dt
            return # Skip collision-checking, gravity, etc.
        end

        # Movement, https://youtu.be/KbtcEVCM7bw?si=sFKXjFfIVndh50TN&t=108
        target_speed = @input_x * MOVE_SPEED * MOVE_SPEED * SCALE # get direction and desired velocity
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
        @velocity_y += @acceleration_y * SCALE * dt

        @air_time += dt

        @rect.y += @velocity_y * dt
        self.collision(@game.map.collisions, "vertical", dt)

        @rect.x += @velocity_x * dt
        self.collision(@game.map.collisions, "horizontal", dt)

        # player is airborne and haven't jumped; remove one jump.
        if @has_jumped == false && @air_time > JUMP_COYOTE_TIME && @jumps == 0
            @has_jumped = true
            @jumps += 1
        end
            

        if @rect.y > VH
            self.die
        end

    end

    # Kill the player
    # 
    # @return void
    def die
        @rect.remove
        @death_screen.add
        @health = 0
        sfx = Sound.new("sfx/you-died.mp3")
        sfx.volume = 100
        sfx.play
    end
end
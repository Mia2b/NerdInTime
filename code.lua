-- Controller, World, Player, Flags


Controller = {
    Up = {
        pressed = false,
        down = false,
        released = false,
    },
    Down = {
        pressed = false,
        down = false,
        released = false,
    },
    Left = {
        pressed = false,
        down = false,
        released = false,
    },
    Right = {
        pressed = false,
        down = false,
        released = false,
    },
    A = {
        pressed = false,
        down = false,
        released = false,
    },
    B = {
        pressed = false,
        down = false,
        released = false,
    },
    Select = {
        pressed = false,
        down = false,
        released = false,
    },
    Start = {
        pressed = false,
        down = false,
        released = false,
    },
    update = function(self)
        self.Up.pressed      = Button(Buttons.Up, InputState.Down) and not self.Up.down
        self.Up.down         = Button(Buttons.Up, InputState.Down)
        self.Up.released     = Button(Buttons.Up, InputState.Released)

        self.Down.pressed    = Button(Buttons.Down, InputState.Down) and not self.Down.down
        self.Down.down       = Button(Buttons.Down, InputState.Down)
        self.Down.released   = Button(Buttons.Down, InputState.Released)

        self.Left.pressed    = Button(Buttons.Left, InputState.Down) and not self.Left.down
        self.Left.down       = Button(Buttons.Left, InputState.Down)
        self.Left.released   = Button(Buttons.Left, InputState.Released)

        self.Right.pressed   = Button(Buttons.Right, InputState.Down) and not self.Right.down
        self.Right.down      = Button(Buttons.Right, InputState.Down)
        self.Right.released  = Button(Buttons.Right, InputState.Released)

        self.A.pressed       = Button(Buttons.A, InputState.Down) and not self.A.down
        self.A.down          = Button(Buttons.A, InputState.Down)
        self.A.released      = Button(Buttons.A, InputState.Released)

        self.B.pressed       = Button(Buttons.B, InputState.Down) and not self.B.down
        self.B.down          = Button(Buttons.B, InputState.Down)
        self.B.released      = Button(Buttons.B, InputState.Released)

        self.Select.pressed  = Button(Buttons.Select, InputState.Down) and not self.Select.down
        self.Select.down     = Button(Buttons.Select, InputState.Down)
        self.Select.released = Button(Buttons.Select, InputState.Released)

        self.Start.pressed   = Button(Buttons.Start, InputState.Down) and not self.Start.down
        self.Start.down      = Button(Buttons.Start, InputState.Down)
        self.Start.released  = Button(Buttons.Start, InputState.Released)
    end,
}

Flags = {
    solid = 0,
}

Player = {
    position = {
        x = 0.0,
        y = 0.0,
    },
    velocity = {
        x = 0.0,
        y = 0.0,
        maxX = 2,
    },
    hitbox = {
        -- Assuming top left 0,0 start
        left = 1,
        right = 7,
        top = 1,
        bot = 8,
    },
    sprite = {
        frame = 1,
        width = 8,
        height = 8,
    },
    isLeft = false,
    onGround = false,
    acceleration = 0.3,
    decceleration = 0.25,
    jumpPower = 1.75,

    -- Player functions
    update = function(self, delta)
        local startx = self.position.x
        local starty = self.position.y
        local accel = 0
        local deccel = 0


        if Controller.Up.pressed then
            World.camera.x = World.camera.x + 32
            World.camera.y = World.camera.y + 32
        end

        -- Change the accelaration influence based on if you are in the air or on the ground
        if not self.onGround then
            accel = self.acceleration / 2
            deccel = self.decceleration / 4
        else
            accel = self.acceleration
            deccel = self.decceleration
        end

        -- Apply jump velocity
        if Controller.A.pressed and self.onGround  then
            PlaySound(6, 6)
            self.velocity.y = -self.jumpPower - math.abs(self.velocity.x) / 4
        end

        -- Player movement
        if Controller.Left.down and not Controller.Right.down then
            -- Move to the left
            self.velocity.x = self.velocity.x - accel
        elseif not Controller.Left.down and Controller.Right.down then
            -- Move to the right
            self.velocity.x = self.velocity.x + accel
        else
            -- Decelerate the player when no inputs or conflicting inputs
            if self.velocity.x > deccel then
                self.velocity.x = self.velocity.x - deccel
            elseif self.velocity.x < -deccel then
                self.velocity.x = self.velocity.x + deccel
            else
                self.velocity.x = 0
            end
        end

        -- Set the player facing direction, changes based on the players velocity
        if self.velocity.x > 0 then
            self.isLeft = false
        elseif self.velocity.x < 0 then
            self.isLeft = true
        end

        -- Make sure the player isn't too fast in the x axis
        if self.velocity.x > self.velocity.maxX then
            self.velocity.x = self.velocity.maxX
        elseif self.velocity.x < -self.velocity.maxX then
            self.velocity.x = -self.velocity.maxX
        end

        -- Change gravity based on if holding jump or not
        local grav = World.rules.gravity
        if Controller.A.down then
            grav = grav / 2
        end

        -- Acclerate player down
        self.velocity.y = self.velocity.y + grav

        -- Move the player
        self.position.x = self.position.x + self.velocity.x
        self.position.y = self.position.y + self.velocity.y

        self.onGround = false -- Assume off the ground until officially checked


        -- Left collision check
        if self.velocity.x < 0 then
            local flagTop = Flag((self.position.x + self.hitbox.left) / 8, (self.position.y + self.hitbox.top) / 8)
            local flagBot = Flag((self.position.x + self.hitbox.left) / 8, (self.position.y + self.hitbox.bot - 3) / 8)
            if flagTop == Flags.solid or flagBot == Flags.solid then
                self.position.x = startx -- TODO: Make this hug the wall instead of just resetting the X position
                self.velocity.x = 0
            end
        end

        -- Right collision check
        if self.velocity.x > 0 then
            local flagTop = Flag((self.position.x + self.hitbox.right) / 8, (self.position.y + self.hitbox.top) / 8)
            local flagBot = Flag((self.position.x + self.hitbox.right) / 8, (self.position.y + self.hitbox.bot - 3) / 8)
            if flagTop == Flags.solid or flagBot == Flags.solid then
                self.position.x = startx -- TODO: Make this hug the wall instead of just resetting the X position
                self.velocity.x = 0
            end
        end

        -- Up collision check
        if self.velocity.y < 0 then
            local flagL = Flag((self.position.x + self.hitbox.left ) / 8,(self.position.y + self.hitbox.top) / 8)
            local flagR = Flag((self.position.x + self.hitbox.right) / 8,(self.position.y + self.hitbox.top) / 8)
            if flagL == Flags.solid or flagR == Flags.solid then
                self.position.y = math.floor((self.position.y + self.hitbox.bot) / 8) * 8 -- TODO: Make this hug the top of the head
                self.velocity.y = 0
            end
        end

        -- Down collision check
        if self.velocity.y > 0 then
            local flagL = Flag((self.position.x + self.hitbox.left ) / 8, (self.position.y + self.hitbox.bot) / 8)
            local flagR = Flag((self.position.x + self.hitbox.right) / 8, (self.position.y + self.hitbox.bot) / 8)
            if flagL == Flags.solid or flagR == Flags.solid then
                self.position.y = math.floor(self.position.y / 8) * 8
                self.velocity.y = 0
                self.onGround = true
            end
        end
    end
}
function Player:new(plyr, x, y)
    plyr = plyr or {} -- create object if user does not provide one
    setmetatable(plyr, self)
    self.__index = self
    plyr.position.x = x
    plyr.position.y = y
    return plyr
end


World = {
    camera = {
        x = 0,
        y = 0,
    },
    entities = {},
    player = Player:new(nil,64,64),
    rules = {
        gravity = 0.2,
        acceleration = 0.2,
        decceleration = 0.2,
    },
    isFuture = {

    },
    update = function(self)
        ScrollPosition ( self.camera.x, self.camera.y )
        -- for i, entity in ipairs(self.entities) do
        --     entity.update()
        -- end
        self.player:update()
    end,
    draw = function(self)
        -- Draw all entities
        -- for i, entity in ipairs(self.entities) do
        --     -- entity.update()
        --     DrawSprite( entity.sprite,
        --                 entity.position.x - self.camera.x,
        --                 entity.position.y - self.camera.y,
        --                 false,
        --                 false,
        --                 DrawMode.Sprite,
        --                 0)
        -- end

        -- Draw the player
        DrawSprite( self.player.sprite.frame,
                    self.player.position.x - self.camera.x,
                    self.player.position.y - self.camera.y,
                    self.player.isLeft,
                    false,
                    DrawMode.Sprite,
                    0)
    end,
}

local time = 0

function Init()
    BackgroundColor(0)
    PlaySong(0, true)
end


function Update(timeDelta)
    Controller:update()
    World:update()

    time = time + timeDelta


    -- -- Plant pot collision x
    -- if math.abs(player.position.x + player.velocity.x - plantPot.position.x) < 8 and math.abs(player.position.y - plantPot.position.y) == 0 then
    --     player.position.x = startx
    --     player.velocity.x = 0
    -- end



    -- -- Plant pot collision y
    -- if math.abs(player.position.y - plantPot.position.y) < 4 and math.abs(player.position.x - plantPot.position.x) < 8 and not plantPot.pickedUp then
    --     player.position.y = plantPot.position.y - 4
    --     player.velocity.y = 0
    --     player.onGround = true
    -- end

    -- -- Pick up
    -- if Button(Buttons.B, InputState.Down)  and not bHeldDown then
    --     -- Plant pot
    --     if math.abs(player.position.x + player.velocity.x - plantPot.position.x) < 10 and math.abs(player.position.y - plantPot.position.y) < 8 then
    --         -- Put down pot
    --         PlaySound(7, 5)
    --         if plantPot.pickedUp then
    --             plantPot.position.y = player.position.y
    --         end
    --         plantPot.pickedUp = not plantPot.pickedUp
    --         bHeldDown = true
    --     end
    -- end

    -- if Button(Buttons.B, InputState.Released) then
    --     bHeldDown = false
    -- end

    -- -- Update Plant pot position
    -- if plantPot.pickedUp then
    --     local plantOffset = (player.isLeft and -8 or 8)
    --     plantPot.position.x = player.position.x + plantOffset
    --     plantPot.position.y = player.position.y - 3
    -- end

    -- -- Change time
    -- if Button(Buttons.Up, InputState.Down) and not upHeldDown then
    --     isFuture = not isFuture
    --     local bgColor = (isFuture and 1 or 0)
    --     BackgroundColor( bgColor )
    --     upHeldDown = true
    -- end

    -- if isFuture then
    --     camera.x = 32
    --     camera.y = 32
    -- else
    --     camera.x = 0
    --     camera.y = 0
    -- end

    -- if Button(Buttons.Up, InputState.Released) then
    --     upHeldDown = false
    -- end

end

function Draw()
    RedrawDisplay()
    World:draw()

    -- Some debug text
    DrawText(tostring(time), 1, 1, DrawMode.Tile, "large", 5)
    -- DrawSprite( player.sprite, player.position.x -  camera.x, player.position.y - camera.y, player.isLeft, false, DrawMode.Sprite, 0)
    -- DrawSprite( plantPot.sprite, plantPot.position.x - camera.x, plantPot.position.y - camera.y, false, false, DrawMode.Sprite, 0)
    -- DrawSprite( timeStone.sprite, timeStone.position.x - camera.x, timeStone.position.y - camera.y, false, false, DrawMode.Sprite, 0)
end
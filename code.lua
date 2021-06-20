
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
        corner = 3,
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
    currentRoom = {
        x = 0,
        y = 0,
    },

    -- Player functions
    update = function(self, delta)
        local startx = self.position.x
        local starty = self.position.y
        local accel = 0
        local deccel = 0

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
            local flagTop = Flag((self.position.x + self.hitbox.left) / 8, (self.position.y + self.hitbox.top + self.hitbox.corner) / 8)
            local flagBot = Flag((self.position.x + self.hitbox.left) / 8, (self.position.y + self.hitbox.bot - self.hitbox.corner) / 8)
            if flagTop == Flags.solid or flagBot == Flags.solid then
                self.position.x = startx -- TODO: Make this hug the wall instead of just resetting the X position
                self.velocity.x = 0
            end
        end

        -- Right collision check
        if self.velocity.x > 0 then
            local flagTop = Flag((self.position.x + self.hitbox.right) / 8, (self.position.y + self.hitbox.top + self.hitbox.corner) / 8)
            local flagBot = Flag((self.position.x + self.hitbox.right) / 8, (self.position.y + self.hitbox.bot - self.hitbox.corner) / 8)
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
    end,

    timeTravel = function(self, newRoom)
        local newX = self.position.x + (newRoom.x - self.currentRoom.x) * 8 * 32
        local newY = self.position.y + (newRoom.y - self.currentRoom.y) * 8 * 32

        -- Check the player can tp
        local flag1 = Flag((newX + self.hitbox.left)  / 8, (newY + self.hitbox.top) / 8)
        local flag2 = Flag((newX + self.hitbox.right) / 8, (newY + self.hitbox.top) / 8)
        local flag3 = Flag((newX + self.hitbox.left)  / 8, (newY + self.hitbox.bot - self.hitbox.corner) / 8)
        local flag4 = Flag((newX + self.hitbox.right) / 8, (newY + self.hitbox.bot - self.hitbox.corner) / 8)

        if flag1 == Flags.solid or flag2 == Flags.solid or flag3 == Flags.solid or flag4 == Flags.solid then
            PlaySound(8, 3)
            return false
        else
            PlaySound(9, 4)
            self.currentRoom = newRoom
            self.position.x = newX
            self.position.y = newY
            return true
        end
    end,
}
function Player:new(plyr, x, y)
    plyr = plyr or {} -- create object if user does not provide one
    setmetatable(plyr, self)
    self.__index = self
    plyr.position.x = x
    plyr.position.y = y
    return plyr
end

TimeStone = {
    position = {
        x = 0.0,
        y = 0.0
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
        corner = 3,
    },
    sprite = 6,
    pickedUp = false,

    update = function(self, delta)
        local startx = self.position.x
        local starty = self.position.y
        local accel = 0
        local deccel = 0

        -- Check for interaction
        if self.pickedUp and Controller.Up.pressed then
            if World.isFuture then
                if World.player:timeTravel(Levels.one.past.room) then
                    World.camera:goToRoom(Levels.one.past.room)
                end
            else
                if World.player:timeTravel(Levels.one.future.room) then
                    World.camera:goToRoom(Levels.one.future.room)
                end
            end
            World.isFuture = not World.isFuture
        end

        -- Pick up stone
        if (Controller.B.pressed
                and math.abs(World.player.position.x + World.player.velocity.x - self.position.x) < 10
                and math.abs(World.player.position.y - self.position.y) < 8) then
            PlaySound(7, 5)
            if self.pickedUp then
                self.position.y = World.player.position.y
            end
            self.pickedUp = not self.pickedUp
        end

        -- Accelerate the stone towards the ground
        self.velocity.y = self.velocity.y + World.rules.gravity
        self.position.y = self.position.y + self.velocity.y

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
            end
        end

        -- collision with player
        if (math.abs(World.player.position.x + World.player.velocity.x - self.position.x) < 8
                and math.abs(World.player.position.y - self.position.y) == 0) then
            World.player.position.x = startx -- TODO: startx needs to be the previous player position
            World.player.velocity.x = 0
        end

        if (math.abs(World.player.position.y - self.position.y) < 4
                and math.abs(World.player.position.x - self.position.x) < 8 and not self.pickedUp) then
            World.player.position.y = self.position.y - 4
            World.player.velocity.y = 0
            World.player.onGround = true
        end
    end,

    -- TODO: add move on time switching
}

function TimeStone:new(timeStone, x, y)
    timeStone = timeStone or {}
    setmetatable(timeStone, self)
    self.__index = self
    timeStone.position.x = x
    timeStone.position.y = y
    return timeStone
end

PlantPot = {
    position = {
        x = 0.0,
        y = 0.0
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
        corner = 3,
    },
    sprite = 5,
    pickedUp = false,

    update = function(self, delta)
        local startx = self.position.x
        local starty = self.position.y
        local accel = 0
        local deccel = 0

        -- Pick up pot
        if (Controller.B.pressed
                and math.abs(World.player.position.x + World.player.velocity.x - self.position.x) < 10
                and math.abs(World.player.position.y - self.position.y) < 8) then
            PlaySound(7, 5)
            if self.pickedUp then
                self.position.y = World.player.position.y
            end
            self.pickedUp = not self.pickedUp
        end

        -- Accelerate the stone towards the ground
        self.velocity.y = self.velocity.y + World.rules.gravity
        self.position.y = self.position.y + self.velocity.y

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
            end
        end

        -- collision with player
        if (math.abs(World.player.position.x + World.player.velocity.x - self.position.x) < 8
                and math.abs(World.player.position.y - self.position.y) == 0) then
            World.player.position.x = startx -- TODO: startx needs to be the previous player position
            World.player.velocity.x = 0
        end

        if (math.abs(World.player.position.y - self.position.y) < 4
                and math.abs(World.player.position.x - self.position.x) < 8 and not self.pickedUp) then
            World.player.position.y = self.position.y - 4
            World.player.velocity.y = World.isFuture and -5 or 0
            World.player.velocity.y = -5 -- TODO: remove this line once we have the past/future implemented
            World.player.onGround = true
        end
    end,

    -- TODO: add move on time switching
}

function PlantPot:new(plantPot, x, y)
    plantPot = plantPot or {}
    setmetatable(plantPot, self)
    self.__index = self
    plantPot.position.x = x
    plantPot.position.y = y
    return plantPot
end


Levels = {
    one = {
        past = {
            room = {
                x = 0,
                y = 0,
            }
        },
        future = {
            room = {
                x = 0,
                y = 1,
            }
        },
    }
}


World = {
    camera = {
        x = 0,
        y = 0,
        room = {
            x = 0,
            y = 0,
        },
        goToRoom = function(self, room)
            self.room.x = room.x
            self.room.y = room.y
            self.x = room.x * 32 * 8
            self.y = room.y * 32 * 8

        end,
    },
    entities = {},
    player = Player:new(nil,64,64),
    rules = {
        gravity = 0.2,
        acceleration = 0.2,
        decceleration = 0.2,
    },
    isFuture = false,
    update = function(self)
        ScrollPosition ( self.camera.x, self.camera.y )
        if next(self.entities) then
            for i, entity in ipairs(self.entities) do
                entity:update()
            end
        end
        self.player:update()
    end,
    draw = function(self)
        -- Draw all entities
        if next(self.entities) then
            for i, entity in ipairs(self.entities) do
                DrawSprite( entity.sprite,
                            entity.position.x - self.camera.x,
                            entity.position.y - self.camera.y,
                            false,
                            false,
                            DrawMode.Sprite,
                            0)
            end
        end

        -- Draw the player
        DrawSprite( self.player.sprite.frame,
                    self.player.position.x - self.camera.x,
                    self.player.position.y - self.camera.y,
                    self.player.isLeft,
                    false,
                    DrawMode.Sprite,
                    0)
    end,

    parseRoom = function(self)
    end,
}

local time = 0

function SpawnSprites()
    local ts = TimeStone:new(nil, 200, 200)
    local pot = PlantPot:new(nil, 100, 100)
    table.insert(World.entities, ts)
    table.insert(World.entities, pot)
end

function Init()
    BackgroundColor(0)
    PlaySong(0, true)
    SpawnSprites()
end


function Update(timeDelta)
    Controller:update()
    World:update()

    time = time + timeDelta

    if Controller.Start.pressed then
        if not World.isFuture then
            if World.player:timeTravel(Levels.one.future.room) then
                World.camera:goToRoom(Levels.one.future.room)
                World.isFuture = true
            end
        elseif World.isFuture then
            if World.player:timeTravel(Levels.one.past.room) then
                World.camera:goToRoom(Levels.one.past.room)
                World.isFuture = false
            end
        end
    end

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
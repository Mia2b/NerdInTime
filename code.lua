local gameRules = {
    gravity = 0.2,
    acceleration = 0.2,
    decceleration = 0.2,
}

local player = {
    position = {
        x = 64.0,
        y = 64.0,
    },
    velocity = {
        x = 0.0,
        y = 0.0,
        max = 2,
    },
    isLeft = false,
    onGround = false,
    jumpPower = 3.0,
    acceleration = 0.5,
    decceleration = 0.5,
    sprite = 1
}

local plantPot = {
    position = {
        x = 50.0,
        y = 112.0,
    },
    pickedUp = false,
    sprite = 5
}

local flags = {
    solid = 0,
}

local upHeldDown = false
local bHeldDown = false
local isFuture = false

-- Based on https://www.lexaloffle.com/bbs/?tid=27626

function Init()
    BackgroundColor(0)
    PlaySong(0, true)
    local display = Display()
end

function Update(timeDelta)
    local startx = player.position.x
    local starty = player.position.y

    if not player.onGround then
        player.acceleration = gameRules.acceleration / 2
        player.decceleration = gameRules.decceleration / 2
    else
        player.acceleration = gameRules.acceleration
        player.decceleration = gameRules.decceleration
    end

    -- Apply player jump velocity when they press A and are grounded
    if Button(Buttons.A, InputState.Down) and player.onGround then
        PlaySound(6, 6)
        player.velocity.y = -player.jumpPower
    end

    -- Apply velocity to the player based on movement keys
    if Button(Buttons.Left, InputState.Down) and not Button(Buttons.Right, InputState.Down) then
        player.velocity.x = player.velocity.x - player.acceleration
    elseif not Button(Buttons.Left, InputState.Down) and Button(Buttons.Right, InputState.Down) then
        player.velocity.x = player.velocity.x + player.acceleration
    else
        if player.onGround then
            if player.velocity.x > player.decceleration then
                player.velocity.x = player.velocity.x - player.decceleration
            elseif player.velocity.x < -player.decceleration then
                player.velocity.x = player.velocity.x + player.decceleration
            else
                player.velocity.x = 0
            end
        else
            if player.velocity.x > player.decceleration then
                player.velocity.x = player.velocity.x - player.decceleration / 1.5
            elseif player.velocity.x < -player.decceleration then
                player.velocity.x = player.velocity.x + player.decceleration / 1.5
            else
                player.velocity.x = 0
            end
        end
    end

    if player.velocity.x > 0 then
        player.isLeft = false
    elseif player.velocity.x < 0 then
        player.isLeft = true
    end
    -- Cap the player velocity
    if player.velocity.x > player.velocity.max then
        player.velocity.x = player.velocity.max
    elseif player.velocity.x < -player.velocity.max then
        player.velocity.x = -player.velocity.max
    end

    -- Plant pot collision x
    if math.abs(player.position.x + player.velocity.x - plantPot.position.x) < 8 and math.abs(player.position.y - plantPot.position.y) == 0 then
        player.position.x = startx
        player.velocity.x = 0
    end

    -- Move the player
    player.position.x = player.position.x + player.velocity.x

    local xoffset = 0
    if player.velocity.x > 0 then
        xoffset = 7
    end

    local flag = Flag((player.position.x + xoffset) / 8, (player.position.y + 7) / 8)

    if flag == 0 then
        player.position.x = startx
        player.velocity.x = 0
    end

    player.velocity.y = player.velocity.y + gameRules.gravity
    player.position.y = player.position.y + player.velocity.y
    player.onGround = false

    if player.velocity.y >= 0 then
        local flag = Flag((player.position.x + 4) / 8, (player.position.y + 8) / 8)
        if flag == flags.solid then
            player.position.y = math.floor(player.position.y / 8) * 8
            player.velocity.y = 0
            player.onGround = true
        end
    end

    if player.velocity.y <= 0 then
        local flag = Flag((player.position.x + 4) / 8,(player.position.y ) / 8)
        if flag == flags.solid then
            player.position.y = math.floor((player.position.y + 8) / 8) * 8
            player.velocity.y = 0
        end
    end

    -- Plant pot collision y
    if math.abs(player.position.y - plantPot.position.y) < 4 and math.abs(player.position.x - plantPot.position.x) < 8 and not plantPot.pickedUp then
        player.position.y = plantPot.position.y - 4
        player.velocity.y = 0
        player.onGround = true
    end

    -- Pick up pot
    if Button(Buttons.B, InputState.Down) and math.abs(player.position.x + player.velocity.x - plantPot.position.x) < 10 and not bHeldDown then
        -- Put down pot
        PlaySound(7, 5)
        if plantPot.pickedUp then
            plantPot.position.y = player.position.y
        end
        plantPot.pickedUp = not plantPot.pickedUp
        bHeldDown = true
    end

    if Button(Buttons.B, InputState.Released) then
        bHeldDown = false
    end

    -- Update Plant pot position
    if plantPot.pickedUp then
        local plantOffset = (player.isLeft and -8 or 8)
        plantPot.position.x = player.position.x + plantOffset
        plantPot.position.y = player.position.y - 3
    end

    -- Change time
    if Button(Buttons.Up, InputState.Down) and not upHeldDown then
        isFuture = not isFuture
        local bgColor = (isFuture and 1 or 0)
        BackgroundColor( bgColor )
        upHeldDown = true
    end

    if Button(Buttons.Up, InputState.Released) then
        upHeldDown = false
    end

end

function Draw()
    RedrawDisplay()
    DrawSprite( player.sprite, player.position.x, player.position.y , player.isLeft, false, DrawMode.Sprite, 0)
    DrawSprite( plantPot.sprite, plantPot.position.x, plantPot.position.y, false, false, DrawMode.Sprite, 0)
end
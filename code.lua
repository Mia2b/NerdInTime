local gameRules = {
    gravity = 0.2,
    acceleration = 0.5,
    decceleration = 0.5,
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

local flags = {
    solid = 0,
}

-- Based on https://www.lexaloffle.com/bbs/?tid=27626

function Init()
    BackgroundColor(0)
    local display = Display()
end

function Update(timeDelta)
    local startx = player.position.x

    if not player.onGround then
        player.acceleration = gameRules.acceleration / 2
        player.decceleration = gameRules.decceleration / 2
    else
        player.acceleration = gameRules.acceleration
        player.decceleration = gameRules.decceleration
    end

    -- Apply player jump velocity when they press up and are grounded
    if (Button(Buttons.A, InputState.Down) or Button(Buttons.B, InputState.Down) or Button(Buttons.Up, InputState.Down)) and player.onGround then
        player.velocity.y = -player.jumpPower
    end

    -- Apply velocity to the player based on movement keys
    if Button(Buttons.Left, InputState.Down) and not Button(Buttons.Right, InputState.Down) then
        player.velocity.x = player.velocity.x - player.acceleration
    elseif not Button(Buttons.Left, InputState.Down) and Button(Buttons.Right, InputState.Down) then
        player.velocity.x = player.velocity.x + player.acceleration
    else
        if player.velocity.x > player.decceleration then
            player.velocity.x = player.velocity.x - player.decceleration
        elseif player.velocity.x < -player.decceleration then
            player.velocity.x = player.velocity.x + player.decceleration
        else
            player.velocity.x = 0
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

    -- Move the player
    player.position.x = player.position.x + player.velocity.x

    local xoffset = 0
    if player.velocity.x > 0 then
        xoffset = 7
    end

    local flag = Flag((player.position.x + xoffset) / 8, (player.position.y + 7) / 8)

    if flag == 0 then
        player.position.x = startx
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
end

function Draw()
    RedrawDisplay()
    DrawSprite ( player.sprite, player.position.x, player.position.y , player.isLeft, false, DrawMode.Sprite, 0)
end
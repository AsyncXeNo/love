
constants = require 'constants'


-- Bullet model

local Bullet = {}
Bullet.__index = Bullet

function Bullet:new(posX, posY, radius, speed, direction, damage)
    obj = {}

    obj.spawnPos = { x = posX, y = posY }  -- Spawn position of the bullet
    obj.pos = { x = posX, y = posY }  -- Current position of the bullet
    obj.radius = radius  -- Radius (in pixels) of the bullet
    obj.speed = speed  -- Speed of the Bullet
    obj.direction = direction  -- Direction of the bullet
    obj.damage = damage

    setmetatable(obj, self)
    return obj
end

function Bullet:update(bulletsTable, enemiesTable, dt)
    self:move(dt)
    if utils.distanceBetweenVectors(self.pos, self.spawnPos) > constants.BULLET_DROP_OFF_DISTANCE then
        bulletsTable[self] = nil
    end
    for enemy,_ in pairs(enemiesTable) do
        if utils.collisionDetectionCC(self, enemy) then
            enemy.hp = enemy.hp - self.damage
            bulletsTable[self] = nil
            return
        end
    end
end

function Bullet:move(dt)
    moveX = self.direction.x * self.speed * dt  -- Mutiplying by deltatime to make it consistent across all frame rates
    moveY = self.direction.y * self.speed * dt  -- ^^

    self.pos.x = self.pos.x + moveX
    self.pos.y = self.pos.y + moveY
end

function Bullet:draw()
    love.graphics.setColor(1, 0.7, 0)
    love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
    love.graphics.setColor(1, 1, 1)
end


-- Player model

local Player = {
    maxHp = constants.MAX_HP,
    regen = constants.REGEN,
    speed = constants.PLAYER_SPEED,
    bulletSpeed = constants.BASE_BULLET_SPEED,
    damage = constants.BASE_DAMAGE,
    lastBullet = 0,
}
Player.__index = Player

function Player:new(posX, posY, side)
    obj = {}

    obj.pos = { x = posX, y = posY }  -- Position of the player
    obj.side = side  -- Length (in pixels) of one side of the player square
    obj.hp = self.maxHp  -- HP of the player, initially set to Max HP of the player

    setmetatable(obj, self)
    return obj
end

function Player:move(direction, dt)
    moveX = direction.x * self.speed * dt  -- Mutiplying by deltatime to make it consistent across all frame rates
    moveY = direction.y * self.speed * dt  -- ^^

    self.pos.x = self.pos.x + moveX
    self.pos.y = self.pos.y + moveY

    if self.pos.x < self.side / 2 + 5 then
        self.pos.x = self.side / 2 + 5
    end
    if self.pos.x > love.graphics.getWidth() - self.side / 2 then
        self.pos.x = love.graphics.getWidth() - self.side / 2 - 5
    end
    if self.pos.y < self.side / 2 then
        self.pos.y = self.side / 2 + 5
    end
    if self.pos.y > love.graphics.getHeight() - self.side / 2 then
        self.pos.y = love.graphics.getHeight() - self.side / 2 - 5
    end
end

function Player:keypressed(key)
    
end

function Player:update(bulletsTable, enemiesTable, dt)
    if love.mouse.isDown(constants.SHOOT_MOUSE_BUTTON) then  -- Shooting using mouse here, can change to keyboard if needed
        if os.clock() - self.lastBullet > constants.BULLET_DELAY then
            mouseX, mouseY = love.mouse.getPosition()
            direction = utils.direction(self.pos, { x = mouseX, y = mouseY })
            bullet = Bullet:new(self.pos.x, self.pos.y, constants.BULLET_RADIUS, self.bulletSpeed, direction, self.damage)
            bulletsTable[bullet] = true
            self.lastBullet = os.clock()
        end
    end

    for enemy,_ in pairs(enemiesTable) do
        if utils.collisionDetectionCS(enemy, self) then
            self.hp = self.hp - 1
        end
    end

    up = utils.boolToInt(love.keyboard.isDown(constants.UP_KEY))
    down = utils.boolToInt(love.keyboard.isDown(constants.DOWN_KEY))
    left = utils.boolToInt(love.keyboard.isDown(constants.LEFT_KEY))
    right = utils.boolToInt(love.keyboard.isDown(constants.RIGHT_KEY))

    direction = utils.normalize(right - left, down - up)

    self:move(direction, dt)

    if self.pos.x == self.side / 2 + 5 or self.pos.x == love.graphics.getWidth() - self.side / 2 - 5 or self.pos.y == self.side / 2 + 5 or self.pos.y == love.graphics.getHeight() - self.side / 2 - 5 then
        self.hp = self.hp - 1
    end

    self.hp = self.hp + self.regen * dt
    if self.hp > self.maxHp then
        self.hp = self.maxHp
    end
end

function Player:draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.pos.x - self.side / 2, self.pos.y - self.side / 2, self.side, self.side)
    love.graphics.setColor(1, 1, 1)
end


-- Enemy model

local Enemy = {
    
}
Enemy.__index = Enemy

function Enemy:new(posX, posY, radius, speed, maxHp)
    obj = {}

    obj.pos = { x = posX, y = posY }  -- Position of the enemy
    obj.radius = radius  -- Radius (in pixels) of the enemy circle
    obj.speed = speed  -- Speed of the enemy
    obj.hp = maxHp  -- HP of the enemy, initially set to Max HP

    setmetatable(obj, self)
    return obj
end

function Enemy:move(direction, dt)
    moveX = direction.x * self.speed * dt  -- Mutiplying by deltatime to make it consistent across all frame rates
    moveY = direction.y * self.speed * dt  -- ^^

    self.pos.x = self.pos.x + moveX
    self.pos.y = self.pos.y + moveY
end

function Enemy:update(playerPos, enemiesTable, score, dt)
    if self.hp < 0 then
        enemiesTable[self] = nil
        score[1] = score[1] + 1
        return
    end
    direction = utils.direction(self.pos, playerPos)
    self:move(direction, dt)
end

function Enemy:draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("line", self.pos.x, self.pos.y, self.radius)
    love.graphics.setColor(1, 1, 1)
end


return {
    Player = Player,
    Enemy = Enemy,
    Bullet = Bullet
}

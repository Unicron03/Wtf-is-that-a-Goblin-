
local Light = {}
Light.__index = Light 
local ActiveLights = {}
local Goblin = require("goblin")

function Light.new(x,y)
    instance = setmetatable({}, Light)
    instance.x = x 
    instance.y = y
    instance.direction = "back"
    instance.r = 270
    instance.rad = 0.01745329
    instance.scale = 0.08
    instance.offsetX = 0
    instance.offsetY = 0

    instance.toBeRemoved = false

    instance.img = love.graphics.newImage("assets/guard/light.png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    local lightWidth, lightHeight = instance.width * instance.scale, instance.height * instance.scale
    instance.physics.shape = love.physics.newRectangleShape(lightWidth, lightHeight)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setFixedRotation(true)
    instance.physics.body:setGravityScale(0)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveLights, instance)
end

function Light:returnTable()
    return ActiveLights
end

function Light:remove()
    for i, instance in ipairs(ActiveLights) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveLights, i)
        end
    end
end

function Light.removeAll()
    for i,v in ipairs(ActiveLights) do
        v.physics.body:destroy()
    end

    ActiveLights = {}
end

function Light:update(dt)
    self:checkRemove()
    self:syncPhysics()
    self:syncRotation()
    -- print(self.x, self.y, self:getDistanceToGoblin())
end

function Light:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Light:syncRotation()
    if self.direction == "front" then
        self.r = 0
        self.offsetX = 4
        self.offsetY = 65
    elseif self.direction == "right" then
        self.r = 270
        self.offsetX = 63
        self.offsetY = 0
    elseif self.direction == "left" then
        self.r = 90
        self.offsetX = -63
        self.offsetY = 8.5
    elseif self.direction == "back" then
        self.r = 180
        self.offsetX = -4
        self.offsetY = -65
    end
end

function Light:getDistanceToGoblin()
    if self.x and self.y then
        return math.sqrt((Goblin.x - self.x)^2 + (Goblin.y - self.y)^2)
    end
end

function Light:syncPhysics()
    self.physics.body:setPosition(self.x + self.offsetX, self.y + self.offsetY)

    self.physics.fixture:destroy()  -- Détruisez l'ancienne fixture

    local lightWidth, lightHeight = self.width * self.scale, self.height * self.scale

    local points = {
        front = { -lightWidth * 0.1, -lightWidth * 0.5, lightWidth * 0.025, -lightWidth * 0.5, -lightWidth * 0.37, lightHeight * 0.17, lightWidth * 0.345, lightHeight * 0.17},
        back = { lightWidth * 0.1, lightWidth * 0.5, -lightWidth * 0.025, lightWidth * 0.5, lightWidth * 0.37, -lightHeight * 0.17, -lightWidth * 0.345, -lightHeight * 0.17},
        right = {-lightHeight * 0.48, lightWidth * 0.1, -lightHeight * 0.48, -lightWidth * 0.025, lightHeight * 0.19, lightWidth * 0.37, lightHeight * 0.19, -lightWidth * 0.345},
        left = {lightHeight * 0.48, -lightWidth * 0.1, lightHeight * 0.48, lightWidth * 0.025, -lightHeight * 0.19, -lightWidth * 0.37, -lightHeight * 0.19, lightWidth * 0.345}
    }

    self.physics.shape = love.physics.newPolygonShape(points[self.direction])
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.fixture:setSensor(true)
end

function Light:draw()
    love.graphics.draw(self.img, self.x + self.offsetX, self.y + self.offsetY, self.r * self.rad, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitBox()
end

function Light:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Light.updateAll(dt)
    for i,instance in ipairs(ActiveLights) do
        instance:update(dt)
    end
end

function Light.drawAll()
    for i,instance in ipairs(ActiveLights) do
        instance:draw()
    end
end

function Light.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveLights) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Goblin.physics.fixture or b == Goblin.physics.fixture then
                Goblin.death = true
                Goblin.deathPlaySong = true
            end
        end
    end
end

return Light


local Guard = {}
Guard.__index = Guard

local ActiveGuards = {}
local Light = require("light")

function Guard.removeAll()
    for i,v in ipairs(ActiveGuards) do
        v.physics.body:destroy()
    end

    ActiveGuards = {}
end

function Guard.new(x, y, roundPoints)
    instance = setmetatable({}, Guard)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 1.3
    instance.scaleX = 1

    instance.prevX = x
    instance.prevY = y

    instance.speed = 65
    instance.xVel = 0
    instance.yVel = 0

    instance.roundPoints = roundPoints
    instance.currentRoundPoint = 1
    instance.forward = true  -- Variable pour savoir si le garde va en avant ou en arrière sur sa ronde

    instance.state = "front"

    instance:loadAssets()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.animation.width, instance.animation.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setFixedRotation(true)
    instance.physics.body:setGravityScale(0)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveGuards, instance)
end

function Guard:returnTable()
    return ActiveGuards
end

function Guard:loadAssets()
    self.animation = {timer = 0, rate = 0.12}

    self.animation.idle = {total = 4, current = 1, img = {}}
    for i=1,self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/guard/idle/"..i..".png")        
    end

    self.animation.front = {total = 6, current = 1, img = {}}
    for i=1,self.animation.front.total do
        self.animation.front.img[i] = love.graphics.newImage("assets/guard/run/front/"..i..".png")        
    end

    self.animation.back = {total = 6, current = 1, img = {}}
    for i=1,self.animation.back.total do
        self.animation.back.img[i] = love.graphics.newImage("assets/guard/run/back/"..i..".png")        
    end

    self.animation.right = {total = 6, current = 1, img = {}}
    for i=1,self.animation.right.total do
        self.animation.right.img[i] = love.graphics.newImage("assets/guard/run/side/"..i..".png")        
    end

    self.animation.left = {total = 6, current = 1, img = {}}
    for i=1,self.animation.left.total do
        self.animation.left.img[i] = love.graphics.newImage("assets/guard/run/side/"..i..".png")        
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()

    self.imgShadow = love.graphics.newImage("assets/guard/shadow.png")
    self.widthShadow = self.imgShadow:getWidth()
    self.heightShadow = self.imgShadow:getHeight()
end

function Guard:update(dt)
    self:sysRonde()
    self:syncPhysics()
    self:animate(dt)
    self:getMovingDirection()

    local currentPoint = self.roundPoints[self.currentRoundPoint]
    local dx, dy = currentPoint.x - self.x, currentPoint.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance < 1 then
        -- Si le garde est arrivé au point actuel, passez au suivant
        if self.forward then
            self.currentRoundPoint = self.currentRoundPoint + 1
            if self.currentRoundPoint > #self.roundPoints then
                self.currentRoundPoint = self.currentRoundPoint - 2
                self.forward = false
            end
        else
            self.currentRoundPoint = self.currentRoundPoint - 1
            if self.currentRoundPoint < 1 then
                self.currentRoundPoint = self.currentRoundPoint + 2
                self.forward = true
            end
        end
    end
end

function Guard:getMovingDirection()
    local dx = self.x - self.prevX
    local dy = self.y - self.prevY
    local direction

    if math.abs(dx) > math.abs(dy) then
        if dx > 0 then
            direction = "right"
        else
            direction = "left"
        end
    else
        if dy > 0 then
            direction = "front"
        else
            direction = "back"
        end
    end

    self.prevX = self.x
    self.prevY = self.y

    self.state = direction
end

function Guard:sysRonde()
    local targetX, targetY = self.roundPoints[self.currentRoundPoint].x, self.roundPoints[self.currentRoundPoint].y
    local dx, dy = targetX - self.x, targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance > 1 then
        local normalizedX, normalizedY = dx / distance, dy / distance
        self.xVel = normalizedX * self.speed
        self.yVel = normalizedY * self.speed
    else
        -- Passez au point de ronde suivant
        self.currentRoundPoint = self.currentRoundPoint % #self.roundPoints + 1
        self.xVel = 0
        self.yVel = 0
    end
end

function Guard:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()        
    end
end

function Guard:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1 
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Guard:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Guard:draw()
    --Affichage Guard
    if self.state == "left" then
        self.scaleX = -1
    else
        self.scaleX = 1 
    end

    if self.state ~= "front" then
        Light.drawAll()
    end

    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scale * self.scaleX, self.scale, self.animation.width / 2, self.animation.height / 2)
    --Affichage Shadow
    love.graphics.draw(self.imgShadow, self.x - 3, self.y + 42, self.r, self.scale, self.scale, self.animation.width / 2, self.animation.height / 2)

    if self.state == "front" then
        Light.drawAll()
    end

    -- self:drawHitBox()
end

function Guard:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Guard.updateAll(dt)
    for i,instance in ipairs(ActiveGuards) do
        instance:update(dt)
    end
end

function Guard.drawAll()
    for i,instance in ipairs(ActiveGuards) do
        instance:draw()
    end
end

function Guard.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveGuards) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Goblin.physics.fixture or b == Goblin.physics.fixture then
            end
        end
    end
end

return Guard


local Goblin = {}

function Goblin:load()
    self.x = 448
    self.y = 1088
    self.startX = self.x
    self.startY = self.y
    self.width = 20
    self.height = 60
    self.r = 0
    self.rVelocity = 3
    self.xVel = 0
    self.yVel = 0
    self.maxSpeed = 60
    self.maxSpeedBase = self.maxSpeed
    self.acceleration = 750
    self.friction = 3500
    self.scaleBase = 0.08
    self.offsetShadowSide = 0
    self.coin = 0
    self.state = "idle"

    self.home = true
    self.begin = false
    self.death = false
    self.deathPlaySong = false

    self.key = {
        top = "z",
        bottom = "s",
        right = "d",
        left = "q"
    }

    self:loadAssets()

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    local goblinWidth, goblinHeight = self.animation.width * self.scaleBase, self.animation.height * self.scaleBase
    self.physics.shape = love.physics.newRectangleShape(goblinWidth, goblinHeight)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setFixedRotation(true)
    self.physics.body:setGravityScale(0)
end


function Goblin:loadAssets()
    self.animation = {timer = 0, rate = 0.15}

    self.animation.idle = {total = 4, current = 1, img = {}}
    for i=1,self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/goblin/idle/"..i..".png")        
    end

    self.animation.right = {total = 4, current = 1, img = {}}
    for i=1,self.animation.right.total do
        self.animation.right.img[i] = love.graphics.newImage("assets/goblin/run/right/"..i..".png")        
    end

    self.animation.left = {total = 4, current = 1, img = {}}
    for i=1,self.animation.left.total do
        self.animation.left.img[i] = love.graphics.newImage("assets/goblin/run/left/"..i..".png")        
    end

    self.animation.bottom = {total = 4, current = 1, img = {}}
    for i=1,self.animation.bottom.total do
        self.animation.bottom.img[i] = love.graphics.newImage("assets/goblin/run/bottom/"..i..".png")        
    end

    self.animation.top = {total = 4, current = 1, img = {}}
    for i=1,self.animation.top.total do
        self.animation.top.img[i] = love.graphics.newImage("assets/goblin/run/top/"..i..".png")        
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()

    self.imgShadow = love.graphics.newImage("assets/guard/shadow.png")
    self.widthShadow = self.imgShadow:getWidth()
    self.heightShadow = self.imgShadow:getHeight()
end

function Goblin:update(dt)
    self:syncPhysics()
    self:animate(dt)
    self:handleInput(dt)
    self:applyFriction(dt)
end

function Goblin:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()     
    end 
end

function Goblin:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1 
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Goblin:isTopKeyPressed()
    return love.keyboard.isDown(self.key.top)
end

function Goblin:isLeftKeyPressed()
    return love.keyboard.isDown(self.key.left)
end

function Goblin:isBottomKeyPressed()
    return love.keyboard.isDown(self.key.bottom)
end

function Goblin:isRightKeyPressed()
    return love.keyboard.isDown(self.key.right)
end

function Goblin:changeState(state)
    if self.state ~= state then
        self.state = state
        self.width, self.height = self.animation.draw:getWidth(), self.animation.draw:getHeight()

        self:syncHitBox()
    end
end

function Goblin:handleInput(dt)
    if self:isTopKeyPressed() then
        self:changeState("top")
        self.yVel = math.max(self.yVel - self.acceleration * dt, -self.maxSpeed)
        self.xVel = 0
        self.offsetShadowSide = 0
    elseif self:isLeftKeyPressed() then
        self:changeState("left")
        self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed)
        self.yVel = 0
        self.offsetShadowSide = -3.5
    elseif self:isBottomKeyPressed() then
        self:changeState("bottom")
        self.yVel = math.min(self.yVel + self.acceleration * dt, self.maxSpeed)
        self.xVel = 0
        self.offsetShadowSide = 0
    elseif self:isRightKeyPressed() then
        self:changeState("right")
        self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
        self.yVel = 0
        self.offsetShadowSide = -5
    else
        self:changeState("idle")
        self.offsetShadowSide = 0
    end
end

function Goblin:applyFriction(dt)
    if not (self:isTopKeyPressed() or self:isLeftKeyPressed() or self:isBottomKeyPressed() or self:isRightKeyPressed()) then
        if self.xVel > 0 then
            self.xVel = math.max(self.xVel - self.friction * dt, 0)
        elseif self.xVel < 0 then
            self.xVel = math.max(self.xVel + self.friction * dt, 0)
        elseif self.yVel > 0 then
            self.yVel = math.max(self.yVel - self.friction * dt, 0)
        elseif self.yVel < 0 then
            self.yVel = math.max(self.yVel + self.friction * dt, 0)
        end
    end
end

function Goblin:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Goblin:syncHitBox()
    self.physics.fixture:destroy()  -- Détruisez l'ancienne fixture

    local goblinWidth, goblinHeight = self.animation.width * self.scaleBase, self.animation.height * self.scaleBase

    local points
    if self.state == "left" then
        points = { -goblinWidth * 0.5, -goblinWidth * 0.5, goblinWidth * 0.25, -goblinWidth * 0.5, -goblinWidth * 0.5, goblinHeight * 0.5, goblinWidth * 0.25, goblinHeight * 0.5}
    elseif self.state == "right" then
        points = { -goblinWidth * 0.5, -goblinWidth * 0.5, goblinWidth * 0.25, -goblinWidth * 0.5, -goblinWidth * 0.5, goblinHeight * 0.5, goblinWidth * 0.25, goblinHeight * 0.5}
    else
        points = { -goblinWidth * 0.5, -goblinWidth * 0.5, goblinWidth * 0.5, -goblinWidth * 0.5, -goblinWidth * 0.5, goblinHeight * 0.5, goblinWidth * 0.5, goblinHeight * 0.5}
    end

    self.physics.shape = love.physics.newPolygonShape(points)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function Goblin:draw()
    if not self.death then
        local shadowOffsetX = 161.5 + self.offsetShadowSide
        local shadowOffsetY = 144  -- Vous pouvez ajuster cette valeur en fonction de l'apparence souhaitée

        --Affichage Goblin
        love.graphics.setColor(0.5, 1, 0.5)
        love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scaleBase, self.scaleBase, self.animation.width/2, self.animation.height/2)
        love.graphics.setColor(1, 1, 1)

        --Affichage Shadow
        love.graphics.draw(self.imgShadow, self.x - self.animation.width * self.scaleBase / 2 + shadowOffsetX, self.y + self.animation.height * self.scaleBase / 2 + shadowOffsetY, self.r, self.scaleBase * 10, self.scaleBase * 10, self.animation.width / 2, self.animation.height / 2)

        -- self:drawHitBox()
    end
end

function Goblin:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Goblin:beginContact(a, b, collision)
    if self.grounded == true then return end
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny < 0 then
            self.yVel = 0
        end
    elseif b == self.physics.fixture then
        if ny > 0 then
            self.yVel = 0
        end
    end
end

return Goblin
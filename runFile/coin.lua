

local Coin = {
    disappearedLocations = {}  -- Table pour stocker les emplacements de pièces disparues avec un délai
}
Coin.__index = Coin 
local ActiveCoins = {}
local Goblin = require("goblin")

function Coin.new(x,y)
    instance = setmetatable({}, Coin)
    instance.x = x 
    instance.y = y
    instance.scale = 0.3

    instance.toBeRemoved = false

    instance:loadAssets()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.animation.width, instance.animation.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveCoins, instance)
end

function Coin:returnNbCoin()
    return #ActiveCoins
end

function Coin:returnTable()
    return ActiveCoins
end

function Coin:loadAssets()
    self.animation = {timer = 0, rate = 0.12}

    self.animation.spin = {total = 8, current = 1, img = {}}
    for i=1,self.animation.spin.total do
        self.animation.spin.img[i] = love.graphics.newImage("assets/coin/"..i..".png")        
    end

    self.animation.draw = self.animation.spin.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function Coin:remove()
    for i, instance in ipairs(ActiveCoins) do
        if instance == self then
            Goblin.coin = Goblin.coin + 1
            coin:play()
            self.physics.body:destroy()
            table.insert(Coin.disappearedLocations, {x = self.x, y = self.y, respawnTime = love.timer.getTime() + 5})  -- Ajoute l'emplacement avec un délai de 5 secondes
            table.remove(ActiveCoins, i)
        end
    end
end

function Coin.removeAll()
    for i,v in ipairs(ActiveCoins) do
        v.physics.body:destroy()
    end

    ActiveCoins = {}
end

function Coin:update(dt)
    self:checkRemove()
    self:animate(dt)
    -- print(self.x, self.y, #ActiveCoins)
end

function Coin:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Coin:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()        
    end
end

function Coin:setNewFrame()
    local anim = self.animation["spin"]
    if anim.current < anim.total then
        anim.current = anim.current + 1 
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Coin:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.scale, self.scale, self.animation.width / 2, self.animation.height / 2)
end

function Coin.updateAll(dt)
    for i,instance in ipairs(ActiveCoins) do
        instance:update(dt)
    end
end

function Coin.drawAll()
    for i,instance in ipairs(ActiveCoins) do
        instance:draw()
    end
end

function Coin.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveCoins) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Goblin.physics.fixture or b == Goblin.physics.fixture then
                instance.toBeRemoved = true
                return true
            end
        end
    end
end

return Coin
local Map = {}
local STI = require("sti")
local Guard = require("guard")
local Coin = require("coin")
local Light = require("light")
local Camera = require("camera")
local Goblin = require("goblin")
local Sound = require("sound")

function Map:load()
   self.currentLevel = 1
   World = love.physics.newWorld(0,0)
   World:setCallbacks(beginContact, endContact)

   self:init()
   self:initAnimation()
end

function Map:init()
   self.level = STI("map/"..self.currentLevel..".lua", {"box2d"})

   self.level:box2d_init(World)
   self.solidLayer = self.level.layers.solid
   self.groundLayer = self.level.layers.ground
   self.entityLayer = self.level.layers.entity
   self.animationLayer = self.level.layers.animation -- Assurez-vous que le nom est correct

   self.solidLayer.visible = false
   self.entityLayer.visible = false
   MapWidth = self.groundLayer.width * 16
   MapHeight = self.groundLayer.height * 16

   self:spawnEntities()
end

function Map:initAnimation()
   self.animatedTiles = {}
   for i, tile in ipairs(self.level.tiles) do
      self.animatedTiles[tile.id] = tile
   end

   self.frame = 0
   self.clock = {timer = 0, rate = 0.1}
end

function Map:clean()
   self.level:box2d_removeLayer("solid")
   Guard.removeAll()
   Coin.removeAll()
   Light.removeAll()
end

function Map:update(dt)
   self:respawnCoin()
   self:sysLight()

   -- if self.clock.timer > self.clock.rate then
   --    self.frame = self.frame + 1
   --    self.clock.timer = 0
   -- end

   -- self.clock.timer = self.clock.timer + dt
   -- print(self.frame)
end

function Map:sysLight()
   local lights = Light:returnTable() -- Récupérer la table d'instances de lumière
   local guards = Guard:returnTable() -- Récupérer la table d'instances de lumière

   for _, light in ipairs(lights) do
      for _, guard in ipairs(guards) do
         light.x, light.y, light.direction = guard.x, guard.y, guard.state
         -- print(guard.state)
      end
   end
end

function Map:draw()
   if not Goblin.death then
      self.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)

      -- if self.animatedTiles[tid - 1] ~= nil then
      --    local anim = self.animatedTiles[tid - 1].animation
      --    local nbFrames = #anim
      --    local index = self.frame % nbFrames

      --    print(index)
      -- end
   else
      self:clean()
      Sound:stopSound()
      if Goblin.deathPlaySong then
         gameOver:play()
         Goblin.deathPlaySong = false
      end
   end
end

function Map:spawnEntities()
   local cheminGuard = {}
   tableCoins = {}  -- Déclarez tableCoins comme une variable locale

   for i, v in ipairs(self.entityLayer.objects) do
      if v.type == "guardPoint" then
         cheminGuard[v.properties.pos] = v
      elseif v.type == "coin" then
         table.insert(tableCoins, v)  -- Ajoutez chaque instance Coin à la table tableCoins
      end
   end

   self:respawnCoin(tableCoins)  -- Passez tableCoins comme argument à respawnCoin

   -- for i, v in ipairs(tableCoins) do
   --    print("coins[" .. i .. "] - x: " .. v.x .. ", y: " .. v.y)
   -- end

   Guard.new(704, 416, cheminGuard)
   Light.new(704, 416)
end

function Map:respawnCoin()
   local currentTime = love.timer.getTime()

   while Coin:returnNbCoin() < 5 do
      local ind = math.random(1, #tableCoins)
      local newCoin = tableCoins[ind]

      local isNewCoordValid = true
      for _, coin in ipairs(Coin.returnTable()) do
         if coin.x == newCoin.x and coin.y == newCoin.y then
            isNewCoordValid = false
            break
         end
      end

      if isNewCoordValid then
         local canRespawn = true

         for _, location in ipairs(Coin.disappearedLocations) do
            if location.x == newCoin.x and location.y == newCoin.y and currentTime < location.respawnTime then
               canRespawn = false
               break
            end
         end

         if canRespawn then
            Coin.new(newCoin.x, newCoin.y)
         end
      end
   end
end

return Map
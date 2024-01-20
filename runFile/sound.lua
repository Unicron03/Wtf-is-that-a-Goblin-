

local Sound = {active = {}, source = {}}

local Goblin = require("goblin")

function Sound:init(id,source,soundType)
    assert(self.source[id] == nil, "Sound with that ID already exists!")
    self.source[id] = love.audio.newSource(source, soundType)
end

function Sound:loadSong()
    coin = love.audio.newSource("assets/sfx/coin.ogg", "stream")
    coin:setVolume(0.3)
    theme = love.audio.newSource("assets/sfx/Memoraphile - Spooky Dungeon.ogg", "stream")
    theme:setVolume(0.1)
    gameOver = love.audio.newSource("assets/sfx/gameOver.ogg", "stream")
    gameOver:setVolume(0.2)
    menuEntrant = love.audio.newSource("assets/sfx/menuEntrant.ogg", "stream")
    menuEntrant:setVolume(0.1)
    menuSortant = love.audio.newSource("assets/sfx/menuSortant.ogg", "stream")
    menuSortant:setVolume(0.1)
    menuAttente = love.audio.newSource("assets/sfx/Menu Music.ogg", "stream")
    menuAttente:setVolume(0.2)
    home = love.audio.newSource("assets/sfx/Mysterious.ogg", "stream")
    home:setVolume(0.2)
end

function Sound:stopSound()
    love.audio.stop(coin)
    love.audio.stop(theme)
end

function Sound:stopMenu()
    love.audio.stop(menuEntrant)
    love.audio.stop(menuSortant)
end

function Sound:update(dt)
    self:redoTheme()
end

function Sound:redoTheme()
    if not theme:isPlaying() and not Goblin.death then
		love.audio.play(theme)
	end
end

function Sound:play(id, channel)
    local channel = channel or "default"
    local clone = Sound.source[id]:clone()
    clone:play()

    if Sound.active[channel] == nil then
        Sound.active[channel] = {}
    end

    table.insert(Sound.active[channel], clone)
end

return Sound
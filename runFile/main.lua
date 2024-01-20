love.graphics.setDefaultFilter("nearest","nearest")
local Map = require("map")
local Goblin = require("goblin")
local Camera = require("camera")
local Guard = require("guard")
local Coin = require("coin")
local Sound = require("sound")
local GUI = require("gui")
local Light = require("light")
local Button = require("button")
-- require "map/1"

-- Chargement des ressources
function love.load()
    local iconImageData = love.image.newImageData("assets/background/icon.jpeg")
    love.window.setIcon(iconImageData)

    math.randomseed(os.time())
    
    -- _G.map = loadTiledMap("map/1")
    Map:load()
    Goblin:load()
    Sound:loadSong()
    GUI:load()  
end

-- Mise à jour du jeu
function love.update(dt)
    if not Goblin.begin and not Goblin.home and not GUI.button.pauseMenu and not GUI.button.creditsDisplay then
        World:update(dt)
        Goblin:update(dt)
        Sound:update(dt)
        Guard.updateAll(dt)
        Coin.updateAll(dt)
        Light.updateAll(dt)
        Camera:setPosition(Goblin.x, Goblin.y)
        Map:update(dt)
    end
    Button.updateAll(dt)
    GUI:update(dt)
end

-- Affichage du jeu
function love.draw()
    if not Goblin.begin and not Goblin.home then
        -- _G.map:draw()
        Map:draw()
        
        Camera:apply()
        Coin.drawAll()
        Guard.drawAll()
        --Affichage de Light dans Guard
        Goblin:draw()
        Camera:clear()
    end
    
    GUI:draw()
    Button.drawAll()

    if not Goblin.home then
        -- Activer l'effet de voile noir
        love.graphics.setColor(0, 0, 0, 0.5)  -- Noir avec une certaine transparence (0.7 par défaut)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)  -- Rétablir la couleur par défaut
    end
end

function beginContact(a, b, collision)
    if Coin.beginContact(a, b, collision) then return end
    if Light.beginContact(a, b, collision) then return end
    Goblin:beginContact(a, b, collision)
end

function love.mousepressed(x, y, button, istouch, presses)
    Button:mousepressed(x, y, button)
end

function love.keypressed(key)
    if key == "space" and Goblin.begin then
        GUI.wordDelay = 0.01
        GUI.begin.opacityFrame = 0.8
    end

    if key == "escape" and not Goblin.begin and not Goblin.death and not Goblin.home then
        if not GUI.button.pauseMenu and not GUI.button.creditsDisplay then
            theme:pause()
            menuAttente:play()
            menuEntrant:play()
            GUI.buttonWebSite = nil
            GUI.button.pauseMenu = true
        elseif GUI.button.pauseMenu then
            menuSortant:play()
            menuAttente:pause()
            GUI.buttonWebSite = nil
            GUI.button.pauseMenu = false
            Button.removeAll()
        elseif GUI.button.creditsDisplay then
            menuSortant:play()
            GUI.button.creditsDisplay = false
            Button.removeAll()
            GUI.buttonWebSite = nil
            GUI.button.pauseMenu = true
        end
    end
end
local GUI = {}

local Goblin = require("goblin")
local Button = require("button")
local Light = require("light")

function GUI:load()
    self.coin = {}
    self.coin.img = love.graphics.newImage("assets/coin/1.png")
    self.coin.width = self.coin.img:getWidth()
    self.coin.height = self.coin.img:getHeight()
    self.coin.scale = 1.5
    self.coin.x = love.graphics.getWidth() - 170
    self.coin.y = 50

    self.mansion = {}
    self.mansion.img = love.graphics.newImage("assets/background/illustrationMansion.png")
    self.mansion.width = self.mansion.img:getWidth()
    self.mansion.height = self.mansion.img:getHeight()
    self.mansion.scale = 1.915
    self.mansion.x = love.graphics:getWidth() * 0.5 - (self.mansion.width * self.mansion.scale) * 0.5
    self.mansion.y = 0

    self.homePage = {}
    self.homePage.img = love.graphics.newImage("assets/background/menuAccueil.png")
    self.homePage.width = self.homePage.img:getWidth()
    self.homePage.height = self.homePage.img:getHeight()
    self.homePage.scale = 0.9
    self.homePage.x = love.graphics:getWidth() * 0.5 - (self.homePage.width * self.homePage.scale) * 0.5
    self.homePage.y = 0

    self.button = {}
    self.button.img = love.graphics.newImage("assets/ui/button_up.png")
    self.button.width = self.button.img:getWidth()
    self.button.height = self.button.img:getHeight()
    self.button.scale = 1.4
    self.button.x1 = love.graphics:getWidth() * 0.5 - (self.button.width * self.button.scale) * 1.5
    self.button.x2 = love.graphics:getWidth() * 0.5 - (self.button.width * self.button.scale) * 0.5
    self.button.x3 = love.graphics:getWidth() * 0.5 + (self.button.width * self.button.scale) * 0.5
    self.button.y = 0
    self.button.creditsDisplay = false

    self.begin = {
        opacity = 0,
        opacityFrame = 0.3
    }
    self.opacityFade = 0
    self.beginRectangleHeight = 0.45

    self.buttonHome = nil
    self.buttonHomeScale = 1.4
    self.buttonMaxScale = 2
    self.buttonMinScale = 1.4
    self.buttonX = self.button.x2
    self.buttonY = love.graphics:getHeight() * 0.6
    self.scaleChangeSpeed = 0.6
    self.isScalingUp = true
    self.buttonWebSite = nil

    self.text = ""
    self.words = {}
    self.currentWordIndex = 1
    self.currentWordTimer = 0
    self.wordDelay = 0.1  -- Délai entre chaque mot (en secondes)

    self.font = love.graphics.newFont("assets/bit.ttf", 36)
    self.icon = love.graphics.newImage("assets/background/icon.jpeg")
    self.gameVersion = "Version : 1.0.1"

    self.textAff = "Hello my friend, times are hard these days ! Your family can no longer live with dignity like in the good old days... You are their only hope, so you've got to find a way to get back to that good life. To do that, you have to go and steal from the mansion of the old caretaker (yes, the one who raises his hand against goblins...). He has a lots of coins that he scatters all over his property. But be careful ! This man is a real vulture, he is prowling night and day to protect his wealth. So you are going to have to be nimble and keep up the pace... Good luck !"
    self:displayTextWithAnimation(self.textAff, self.font, self:getRectOfTextBegin())
end

function GUI:update(dt)
    self:beginning(dt)
    self:agrandissementButton(dt)
    self:sysFade(dt)
end

function GUI:sysFade(dt)
    if not Goblin.death then
        local lights = Light:returnTable()

        for _, light in ipairs(lights) do
            local distanceToGoblin = light:getDistanceToGoblin()

            local minDistance = 150
            local maxDistance = 300

            -- On s'assure que la distance est limitée entre minDistance et maxDistance
            distanceToGoblin = math.min(maxDistance, math.max(minDistance, distanceToGoblin))

            -- On calcul l'opacité en utilisant une interpolation linéaire inverse
            self.opacityFade = 1 - (distanceToGoblin - minDistance) / (maxDistance - minDistance)
        end
    end
end


function GUI:agrandissementButton(dt)
    if Goblin.home then
        if self.isScalingUp then
            self.buttonHomeScale = self.buttonHomeScale + self.scaleChangeSpeed * dt
            self.buttonX = self.buttonX - self.scaleChangeSpeed * 0.3
            -- self.buttonY = self.buttonY - self.scaleChangeSpeed + 10 * dt
        else
            self.buttonHomeScale = self.buttonHomeScale - self.scaleChangeSpeed * dt
            self.buttonX = self.buttonX + self.scaleChangeSpeed * 0.3
            -- self.buttonY = self.buttonY + self.scaleChangeSpeed + 10 * dt
        end

            -- Vérifiez si la valeur a atteint le max et inversez l'état si nécessaire
        if self.buttonHomeScale >= self.buttonMaxScale then
            self.isScalingUp = false
        elseif self.buttonHomeScale <= self.buttonMinScale then
            self.isScalingUp = true
        end

        if self.buttonHome then
            self.buttonHome.scale = self.buttonHomeScale
            self.buttonHome.x = self.buttonX
            self.buttonHome.y = self.buttonY
            -- print(self.buttonHome.y, Button:returnNbEntities())
        end
    end
end

function GUI:getRectOfTextBegin()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local rectWidth = love.graphics:getWidth() * 0.47 -- Largeur du rectangle
    local rectHeight = love.graphics:getHeight() * self.beginRectangleHeight -- Hauteur du rectangle

    -- Calcul des coordonnées pour centrer le rectangle
    local rectX = (screenWidth - rectWidth) / 2
    local rectY = (screenHeight - rectHeight) / 2

    local textRect = {
        x = rectX,
        y = rectY,
        width = rectWidth,
        height = rectHeight
    }

    return textRect
end

function GUI:beginning(dt)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local rectWidth = love.graphics:getWidth() * 0.47 -- Largeur du rectangle
    local rectHeight = love.graphics:getHeight() * self.beginRectangleHeight -- Hauteur du rectangle

    -- Calcul des coordonnées pour centrer le rectangle
    local rectX = (screenWidth - rectWidth) / 2
    local rectY = (screenHeight - rectHeight) / 2

    local textRect = {
        x = rectX,
        y = rectY,
        width = rectWidth,
        height = rectHeight
    }

    if Goblin.begin then
        self.begin.opacity = math.min(self.begin.opacity + self.begin.opacityFrame * dt, 1)

        if self.begin.opacity >= 1 then
            if self.currentWordIndex <= #self.words then
                self.currentWordTimer = self.currentWordTimer + dt
                if self.currentWordTimer >= self.wordDelay then
                    self.currentWordTimer = 0
                    self.text = self.text .. self.words[self.currentWordIndex] .. " "
                    self.currentWordIndex = self.currentWordIndex + 1
                end
            else
                offsetY = rectY + rectHeight - self.button.height * 2
                Button.new(self.button.x2, self.button.y + offsetY, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Play", function() menuEntrant:play() Goblin.begin = false Button.removeAll() end)
            end
        end 
        home:play()
    else
        home:stop()
    end
end

function GUI:draw()
    if Goblin.home then
        self:displayHomePage()
    elseif Goblin.begin then
        self:displayBeginning()
    else
        self:displayCoin()
        self:displayEvo()
        self:displayRedFadeEffect()
    end
end

-- Fonction pour afficher un effet de fondu rougeâtre sur les bords de l'écran
function GUI:displayRedFadeEffect()
    if not Goblin.death then
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()

        -- Largeur du fondu sur les bords (par exemple, 20 pixels)
        local fadeWidth = 20

        -- Couleur du fondu rougeâtre (rouge avec une faible composante alpha)
        local redFadeColor = {1, 0, 0, self.opacityFade}  -- Rouge avec une transparence de 50%

        -- Dessinez des rectangles semi-transparents sur les bords de l'écran
        -- Haut
        love.graphics.setColor(unpack(redFadeColor))
        love.graphics.rectangle("fill", 0, 0, screenWidth, fadeWidth)

        -- Bas
        love.graphics.rectangle("fill", 0, screenHeight - fadeWidth, screenWidth, fadeWidth)

        -- Gauche
        love.graphics.rectangle("fill", 0, fadeWidth, fadeWidth, screenHeight - 2 * fadeWidth)

        -- Droite
        love.graphics.rectangle("fill", screenWidth - fadeWidth, fadeWidth, fadeWidth, screenHeight - 2 * fadeWidth)

        -- Réinitialisez la couleur
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function GUI:displayHomePage()
    menuAttente:play()
    love.graphics.draw(self.homePage.img, self.homePage.x, self.homePage.y, 0, self.homePage.scale, self.homePage.scale)

    love.graphics.setFont(self.font)
    if Button:returnNbEntities() < 1 then
        self.buttonHome = Button.new(self.button.x2, self.button.y, self.button.img:getWidth(), self.button.img:getHeight(), self.buttonHomeScale, self.button.img, "Enter", function() menuAttente:stop() menuEntrant:play() Goblin.home = false Goblin.begin = true Button.removeAll() end)
    end
end

function GUI:displayTextWithAnimation(inputText, font, rect)
    self.text = ""
    self.words = {}  -- Réinitialisez les mots
    self.currentWordIndex = 1
    self.currentWordTimer = 0
    self.wordDelay = 0.1

    for word in inputText:gmatch("%S+") do
        table.insert(self.words, word)
    end

    self.displayTextRect = rect  -- Enregistrez le rectangle de destination
end

function GUI:displayBeginning()
    love.graphics.draw(self.mansion.img, self.mansion.x, self.mansion.y, 0, self.mansion.scale, self.mansion.scale)

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local rectWidth = love.graphics:getWidth() * 0.5 -- Largeur du rectangle
    local rectHeight = love.graphics:getHeight() * self.beginRectangleHeight -- Hauteur du rectangle

    -- Calcul des coordonnées pour centrer le rectangle
    local rectX = (screenWidth - rectWidth) / 2
    local rectY = (screenHeight - rectHeight) / 2

    -- Couleur du rectangle (gris)
    love.graphics.setColor(0.5, 0.5, 0.5, self.begin.opacity - 0.2) -- Couleur grise avec une transparence

    -- Dessin du rectangle rempli
    love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight)

    -- Couleur des contours (noirs)
    love.graphics.setColor(0, 0, 0, self.begin.opacity)

    -- Dessin des contours du rectangle
    love.graphics.rectangle("line", rectX, rectY, rectWidth, rectHeight)

    -- Réinitialisation de la couleur (blanc)
    love.graphics.setColor(1, 1, 1)

    if self.displayTextRect then
        local formattedText = self:wrapText(self.text, self.font, self.displayTextRect)

        love.graphics.setFont(self.font)

        -- Dessinez chaque ligne de texte dans le rectangle spécifié
        love.graphics.setColor(0, 0, 0, 0.65)
        for i, line in ipairs(formattedText) do
            local textWidth = self.font:getWidth(line)
            local x = self.displayTextRect.x + (self.displayTextRect.width - textWidth) / 2
            local y = self.displayTextRect.y + (i - 1) * self.font:getHeight()
            love.graphics.print(line, x + 2, y + 2)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end

    local x = 10
    local y = love.graphics.getHeight() - self.font:getHeight() - 10

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Skip : [Space]", x, y)
end

function GUI:displayPause(text)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local rectWidth = love.graphics:getWidth() * 0.5 -- Largeur du rectangle
    local rectHeight = love.graphics:getHeight() * 0.4 -- Hauteur du rectangle

    -- Calcul des coordonnées pour centrer le rectangle
    local rectX = (screenWidth - rectWidth) / 2
    local rectY = (screenHeight - rectHeight) / 2

    -- Couleur du rectangle (gris)
    love.graphics.setColor(0.5, 0.5, 0.5, 0.8) -- Couleur grise avec une transparence

    -- Dessin du rectangle rempli
    love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight)

    -- Couleur des contours (noirs)
    love.graphics.setColor(0, 0, 0)

    -- Dessin des contours du rectangle
    love.graphics.rectangle("line", rectX, rectY, rectWidth, rectHeight)

    -- Réinitialisation de la couleur (blanc)
    love.graphics.setColor(1, 1, 1)

    -- Utilisez la police actuelle
    local font = love.graphics.newFont("assets/bit.ttf", 48)
    love.graphics.setFont(font)

    -- Obtenez la rectangle dans lequel le texte doit s'inscrire
    local textRect = {
        x = rectX,
        y = rectY,
        width = rectWidth,
        height = rectHeight
    }

    -- Divisez le texte en lignes en fonction de sa largeur et du rectangle
    local formattedText = self:wrapText(text, font, textRect)

    -- Calculez la hauteur totale du texte rendu
    local textHeight = #formattedText * font:getHeight()

    -- Calculez les coordonnées y pour centrer le texte verticalement
    local y = rectY + (rectHeight - textHeight) * 0.2

    -- Couleur du texte (noir)
    love.graphics.setColor(0, 0, 0, 0.65)

    -- Dessinez chaque ligne de texte
    for i, line in ipairs(formattedText) do
    -- Obtenez la largeur de cette ligne
    local textWidth = font:getWidth(line)

    -- Calculez les coordonnées x pour centrer la ligne horizontalement
    local x = rectX + (rectWidth - textWidth) / 2

    -- Dessinez la ligne de texte
    love.graphics.print(line, x + 2, y + 2)

    -- Passez à la ligne suivante
    y = y + font:getHeight()
    end

    -- Réinitialisation de la couleur (blanc)
    love.graphics.setColor(1, 1, 1, 1)

    --Affichage des boutons
    offsetX = (rectWidth - (3 * self.button.width * self.button.scale)) * 0.25
    offsetY = rectY + rectHeight - self.button.height * 2.5
    
    Button.new(self.button.x1 - offsetX, self.button.y + offsetY, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Credits", function() menuEntrant:play() self.button.creditsDisplay = true self.button.pauseMenu = false Button.removeAll() end)
    if self.buttonWebSite == nil then
        self.buttonWebSite = Button.new(self.button.x2, self.button.y + offsetY, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Website", function() menuEntrant:play() love.system.openURL("https://unicron03.github.io/") end)
    end
    Button.new(self.button.x3 + offsetX, self.button.y + offsetY, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Exit", function() menuSortant:play() love.event.quit() end)
    if not Goblin.death then
        Button.new(self.button.x2, self.button.y + offsetY * 0.85, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Back", function() menuSortant:play() menuAttente:pause() self.button.pauseMenu = false Button.removeAll() self.buttonWebSite = nil end)
    end

    if not Goblin.death then
        love.graphics.draw(self.icon, rectX + 10, rectY + 10, 0, 0.15, 0.15)
        love.graphics.print(self.gameVersion, rectX + rectWidth - font:getWidth(self.gameVersion) - 10, rectY + 10)
    end
end

function GUI:displayEvo()
    if Goblin.death and not self.button.creditsDisplay then        
        love.graphics.draw(self.mansion.img, self.mansion.x, self.mansion.y, 0, self.mansion.scale, self.mansion.scale)

        -- Texte à afficher
        local text = nil
        local text1 = "You have been caught ! So you had to get out of the house. But you still had time to retrieve "..Goblin.coin.." coins ! Good job, that's really impressive ! Your family has a bright future ahead of it... well... for now..."
        local text2 = "You have been caught ! So you had to get out of the house. But you still had time to retrieve "..Goblin.coin.." coins ! Not bad at all ! I'm sure the cat will love these new kibbles ! ...Right ? Why are you laughing man...?"
        local text3 = "You have been caught ! So you had to get out of the house. But you still had time to retrieve "..Goblin.coin.." coins ! Ugh... Still better than nothing, you will have other opportunities... (It's below the developer's score, by the way...)"
        local text4 = "You have been caught ! So you had to get out of the house. But you still had time to retrieve "..Goblin.coin.." coins ! Did you feel pity for this infamous creature ?! Any way... you will have other opportunities..."
        local text42 = "...Bro. Is your name Douglas or...? You're probably a smart guy... If you see this message, please contact me anywhere by simply send 'My favourite game is Zelda' (yes I'm crazy about Zelda). Check my website for that."

        if Goblin.coin == 42 then
            text = text42
        elseif Goblin.coin == 0 then
            text = text4
        elseif Goblin.coin > 0 and Goblin.coin < 10 then
            text = text3
        elseif Goblin.coin >= 10 and Goblin.coin < 30 then
            text = text2
        else
            text = text1
        end
        
        self:displayPause(text)
    elseif Goblin.death and self.button.creditsDisplay then
        love.graphics.draw(self.mansion.img, self.mansion.x, self.mansion.y, 0, self.mansion.scale, self.mansion.scale)
        self:displayCredits()
    elseif not Goblin.home and not Goblin.death and not Goblin.begin and not self.button.creditsDisplay and self.button.pauseMenu then
        self:displayPause("Menu (Pause)")
    elseif not Goblin.home and not Goblin.death and not Goblin.begin and self.button.creditsDisplay and not self.button.pauseMenu then
        self:displayCredits()
    end
end

function GUI:displayCredits()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local rectWidth = love.graphics:getWidth() * 0.5 -- Largeur du rectangle
    local rectHeight = love.graphics:getHeight() * 0.75 -- Hauteur du rectangle

    -- Calcul des coordonnées pour centrer le rectangle
    local rectX = (screenWidth - rectWidth) / 2
    local rectY = (screenHeight - rectHeight) / 2

    -- Couleur du rectangle (gris)
    love.graphics.setColor(0.5, 0.5, 0.5, 0.8) -- Couleur grise avec une transparence

    -- Dessin du rectangle rempli
    love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight)

    -- Couleur des contours (noirs)
    love.graphics.setColor(0, 0, 0)

    -- Dessin des contours du rectangle
    love.graphics.rectangle("line", rectX, rectY, rectWidth, rectHeight)

    -- Réinitialisation de la couleur (blanc)
    love.graphics.setColor(1, 1, 1)

    -- Texte à afficher
    local text = "Assets UI : T. Ricardo, Nectanebo, Lanea Zimmerman (AKA Sharm), Tuomo Untinen, Daniel Eddeland, Hyptosis, Manuel Riecke (AKA MrBeast), Matthew Krohn, Johannes Sjölund, William Thompson, Puddin, GotMop, Buch (https://opengameart.org/users/buch). Assets SFX : Memoraphile @ You’re Perfect Studio, Oiboo. Some of the sounds in this project were created by ViRiX Dreamcore (David McKee) soundcloud.com/virix. Thank you to them for creating free assets for everyone. It's thanks to their contribution that this game has a soul and was able to be created."

    -- Utilisez la police actuelle
    local font = love.graphics.newFont("assets/bit.ttf", 48)
    love.graphics.setFont(font)

    -- Obtenez la rectangle dans lequel le texte doit s'inscrire
    local textRect2 = {
        x = rectX,
        y = rectY,
        width = rectWidth,
        height = rectHeight
    }

    -- Divisez le texte en lignes en fonction de sa largeur et du rectangle
    local formattedText = self:wrapText(text, font, textRect2)

    -- Calculez la hauteur totale du texte rendu
    local textHeight = #formattedText * font:getHeight()

    -- Calculez les coordonnées y pour centrer le texte verticalement
    local y = rectY + (rectHeight - textHeight) * 0.2

    -- Couleur du texte (noir)
    love.graphics.setColor(0, 0, 0, 0.65)

    -- Dessinez chaque ligne de texte
    for i, line in ipairs(formattedText) do
    -- Obtenez la largeur de cette ligne
    local textWidth = font:getWidth(line)

    -- Calculez les coordonnées x pour centrer la ligne horizontalement
    local x = rectX + (rectWidth - textWidth) / 2

    -- Dessinez la ligne de texte
    love.graphics.print(line, x + 2, y + 2)

    -- Passez à la ligne suivante
    y = y + font:getHeight()
    end

    -- Réinitialisation de la couleur (blanc)
    love.graphics.setColor(1, 1, 1, 1)

    --Affichage des boutons
    offsetY = rectY + rectHeight - self.button.height * 2.5
    
    Button.new(self.button.x2, self.button.y + offsetY, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Back", function() menuSortant:play() self.button.creditsDisplay = false self.button.pauseMenu = true Button.removeAll() self.buttonWebSite = nil end)
end

-- Fonction pour diviser le texte en lignes en fonction de la largeur du rectangle
function GUI:wrapText(text, font, rect)
    local lines = {}
    local words = {}

    for word in text:gmatch("%S+") do
       table.insert(words, word)
    end
 
    local line = ""
 
    for i, word in ipairs(words) do
       local testLine = line .. word
       local testLineWidth = font:getWidth(testLine)
 
       if testLineWidth <= rect.width then
          line = testLine .. " "  -- Ajoutez un espace après chaque mot
       else
          table.insert(lines, line)
          line = word .. " "
       end
    end
 
    table.insert(lines, line)
 
    return lines
end
 

function GUI:displayCoin()
    if not Goblin.death then
        --Affichage Image
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.draw(self.coin.img, self.coin.x + 2, self.coin.y + 2, 0, self.coin.scale, self.coin.scale)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.coin.img, self.coin.x, self.coin.y, 0, self.coin.scale, self.coin.scale)

        --Affichage Text
        love.graphics.setFont(self.font)
        local x =  self.coin.x + self.coin.width * self.coin.scale
        local y = self.coin.y + self.coin.height / 2 * self.coin.scale - self.font:getHeight() / 2
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.print(" : "..Goblin.coin, x + 2, y + 2)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(" : "..Goblin.coin, x, y)
    end
end

return GUI

utils = require 'utils'
constants = require 'constants'
models = require 'models'

require 'simple-slider'


StateMachine = {
    currentState = "gamemenu",
    options = {"New Game", "How To Play", "High Scores", "Options", "Exit"},
    states = {
        "gamemenu",
        "gameover",
        ["How To Play"] = "howtoplay",
        ["High Scores"] = "highscores",
        ["Options"] = "optionsMenu",
        ["New Game"] = "game",
    }
}


-- Game Menu

StateMachine["gamemenu"] = {

    textinput = function(text)
        
    end,

    keypressed = function(key)
        if key == 'up' then
            StateMachine["gamemenu"]["selectedoption"] = StateMachine["gamemenu"]["selectedoption"] - 1
        end
        if key == 'down' then
            StateMachine["gamemenu"]["selectedoption"] = StateMachine["gamemenu"]["selectedoption"] + 1
        end
        if key == 'return' then
            option = (StateMachine["gamemenu"]["selectedoption"] % 5) + 1
            if option == 5 then
                love.event.quit()
            end
            StateMachine.currentState = StateMachine.states[StateMachine.options[option]]
        end
    end,

    update = function(dt)

    end,
    
    draw = function()
        w, h = love.graphics.getWidth(), love.graphics.getHeight()
        y = h / 6
        for i=1,#StateMachine.options do
            if i - 1 == StateMachine["gamemenu"]["selectedoption"] % 5 then
                pre = "-> "
                -- x_offset = 46
            else 
                pre = ""
                -- x_offset = 0
            end
            love.graphics.printf({{1, 0, 0}, pre, {1, 1, 1}, StateMachine.options[i]}, 0, y, w, "center")
            y = y + (h / 6)
        end
    end
}

StateMachine["gamemenu"]["selectedoption"] = 0


-- How to Play

StateMachine["howtoplay"] = {

    textinput = function(text)
        
    end,

    keypressed = function(key)
        if key == 'escape' then
            StateMachine.currentState = "gamemenu"
        end
    end,

    update = function(dt)
        
    end,

    draw = function()
        w, h = love.graphics.getWidth(), love.graphics.getHeight()
        y = h / 6
        utils.largeFont()
        love.graphics.printf({{1, 0, 0}, "How to Play"}, 0, y, w, "center")
        utils.mediumFont()
        love.graphics.printf("", 0, h / 4, w, "center")  -- Edit here for HOW TO PLAY
        utils.mediumFont()
    end
    
}


-- High Scores

StateMachine["highscores"] = {

    textinput = function(text)
        
    end,

    updateHighScore = function(newScore, name)
        for i=1,5 do
            if newScore > StateMachine["highscores"].highscores[i][1] then
                if i == 5 then
                    StateMachine["highscores"].highscores[i] = {newScore, name}
                else
                    for j=4,i,-1 do
                        StateMachine["highscores"].highscores[j+1] = StateMachine["highscores"].highscores[j]
                    end
                    StateMachine["highscores"].highscores[i] = {newScore, name}
                end
                utils.serialize(StateMachine["highscores"].highscores, constants.HIGHSCORES_FILE)
                return
            end
        end
    end,

    keypressed = function(key)
        if key == 'escape' then
            StateMachine.currentState = "gamemenu"
        end

        if key == 'space' then
            StateMachine["highscores"].updateHighScore(math.random(1, 100), "Kavya")
        end
    end,

    update = function(dt)
        
    end,

    draw = function()
        w, h = love.graphics.getWidth(), love.graphics.getHeight()
        y = h / 7
        utils.largeFont()
        love.graphics.printf({{1, 0, 0}, "High Scores"}, 0, y, w, "center")
        utils.mediumFont()
        for i, info in ipairs(StateMachine["highscores"].highscores) do
            y = y + h / 7
            love.graphics.printf({{1, 0, 0}, "#" .. i .. "   ", {1, 1, 1}, info[2] .. " - " .. info[1]}, 0, y, w, "center")
        end
    end

}

highscores = {}
i = 1
for line in io.lines(constants.HIGHSCORES_FILE) do
    score, name = unpack(utils.split(line, ','))
    highscores[i] = {[1] = tonumber(score), [2] = name}
    i = i + 1
end
StateMachine["highscores"].highscores = highscores


-- Options

StateMachine["optionsMenu"] = {

    textinput = function(text)
        
    end,

    keypressed = function(key)
        if key == 'escape' then
            StateMachine.currentState = "gamemenu"
        end   
    end,

    update = function(dt)
        StateMachine["optionsMenu"]["volumeslider"]:update()
    end,

    draw = function()
        utils.largeFont()
        w, h = love.graphics.getWidth(), love.graphics.getHeight()
        utils.mediumFont()
        y = h / 6
        utils.largeFont()
        love.graphics.printf({{1, 0, 0}, "Options"}, 0, y, w, "center")
        utils.mediumFont()
        love.graphics.printf("Volume: " .. math.floor(StateMachine["optionsMenu"]["volume"]+0.5), 0, love.graphics.getHeight() / 2 - 70, w, "center")
        StateMachine["optionsMenu"]["volumeslider"]:draw()
    end

}

StateMachine["optionsMenu"]["volume"] = 0
StateMachine["optionsMenu"]["volumeslider"] = newSlider(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 300, 0, 0, 1, function (v) love.audio.setVolume(v) StateMachine["optionsMenu"]["volume"] = 100 * v end)


-- Game

StateMachine["game"] = {

    textinput = function(text)
        
    end,

    spawnEnemies = function()
        if StateMachine["game"]["player"].pos.x > love.graphics.getWidth() / 2 then
            bounds = {0, love.graphics.getWidth() / 2}
        else
            bounds = {love.graphics.getWidth() / 2, love.graphics.getWidth()}
        end

        for i=1,StateMachine["game"]["enemyCount"] do
            StateMachine["game"]["enemies"][models.Enemy:new(math.random(bounds[1], bounds[2]), math.random(0, love.graphics.getHeight()), constants.ENEMY_RADIUS, StateMachine["game"]["enemySpeed"], StateMachine["game"]["enemyMaxHp"])] = true
        end
    end,

    nextWave = function()
        StateMachine["game"]["wave"] = StateMachine["game"]["wave"] + 1
        StateMachine["game"]["bullets"] = {}
        StateMachine["game"]["enemySpeed"] = StateMachine["game"]["enemySpeed"] + 10
        if StateMachine["game"]["wave"] % 2 == 0 then 
            StateMachine["game"]["enemyMaxHp"] = StateMachine["game"]["enemyMaxHp"] + StateMachine["game"]["enemyMaxHp"] / 5
        end
        if StateMachine["game"]["wave"] % 3 == 0 then
            StateMachine["game"]["enemyCount"] = StateMachine["game"]["enemyCount"] + 1
        end
        StateMachine["game"]["upgrading"] = true
        StateMachine["game"].spawnEnemies()
    end,

    keypressed = function(key)
        if StateMachine["game"]["upgrading"] == false then
            StateMachine["game"]["player"]:keypressed(key)
        else
            if key == 'right' then
                StateMachine["game"]["selectedUpgradeOption"] = StateMachine["game"]["selectedUpgradeOption"] - 1
            end
            if key == 'left' then
                StateMachine["game"]["selectedUpgradeOption"] = StateMachine["game"]["selectedUpgradeOption"] + 1
            end
            if key == 'return' then
                for option,info in pairs(StateMachine["game"]["upgradeOptions"]) do
                    if option == StateMachine["game"]["upgradeOptionIndices"][(StateMachine["game"]["selectedUpgradeOption"] % 3) + 1] then
                        info[2]()
                        StateMachine["game"]["upgrading"] = false
                    end
                end
            end
        end
    end,

    update = function(dt)
        if StateMachine["game"]["upgrading"] == false then
            if StateMachine["game"]["player"].hp <= 0 then
                StateMachine.currentState = "gameover"
                return
            end
            if StateMachine["game"]["wave"] == 0 then
                StateMachine["game"]["wave"] = 1
                StateMachine["game"]["enemyCount"] = 3
                StateMachine["game"].spawnEnemies()
            end
            if utils.setLength(StateMachine["game"]["enemies"]) == 0 then
                StateMachine["game"].nextWave()
            end
            StateMachine["game"]["player"]:update(StateMachine["game"]["bullets"], StateMachine["game"]["enemies"], dt)
            for enemy,_ in pairs(StateMachine["game"]["enemies"]) do
                enemy:update(StateMachine["game"]["player"].pos, StateMachine["game"]["enemies"], StateMachine["game"]["score"], dt)
            end
            for bullet,_ in pairs(StateMachine["game"]["bullets"]) do
                bullet:update(StateMachine["game"]["bullets"], StateMachine["game"]["enemies"], dt)
            end
        else
            
        end
    end,

    drawPlayerHp = function()
        width = constants.HEALTH_BAR_WIDTH
        height = constants.HEALTH_BAR_HEIGHT

        fill_width = width * (StateMachine["game"]["player"].hp / StateMachine["game"]["player"].maxHp)

        utils.smallFont()
        love.graphics.printf({{1, 0.3, 0}, "Hp: " .. math.floor(StateMachine["game"]["player"].hp+0.5)}, 0, love.graphics.getHeight() - 75, love.graphics.getWidth(), "center")
        utils.mediumFont()

        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("line", love.graphics.getWidth() / 2 - width / 2, love.graphics.getHeight() - 50, width, height)
        love.graphics.setColor(1, 0.3, 0)
        love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - width / 2 + 2, love.graphics.getHeight() - 48, fill_width - 4, height - 4)
        love.graphics.setColor(1, 1, 1)
    end,

    draw = function()
        if StateMachine["game"]["upgrading"] == false then
            fps = love.timer.getFPS()
            utils.smallFont()
            love.graphics.printf({{1, 1, 1}, 'FPS: ', {1, 1, 0}, tostring(fps)}, 10, 10, love.graphics.getWidth(), 'left')
            love.graphics.printf({{1, 1, 1}, 'Score: ', {0, 1, 0}, tostring(StateMachine["game"]["score"][1])}, 10, 30, love.graphics.getHeight(), 'left')
            utils.mediumFont()
            for enemy,_ in pairs(StateMachine["game"]["enemies"]) do
                enemy:draw()
            end
            for bullet,_ in pairs(StateMachine["game"]["bullets"]) do
                bullet:draw()
            end
            StateMachine["game"]["player"]:draw()
            StateMachine["game"].drawPlayerHp()
        else
            x = love.graphics.getWidth() / 4
            y = love.graphics.getHeight() / 2

            for option,info in pairs(StateMachine["game"]["upgradeOptions"]) do
                text = info[1]
                if option == StateMachine["game"]["upgradeOptionIndices"][(StateMachine["game"]["selectedUpgradeOption"] % 3) + 1] then
                    love.graphics.setColor(0, 1, 0)
                end

                love.graphics.rectangle("line", x - 125, y - 150, 250, 300)
                love.graphics.printf(text, x - 125, y - 20, 250, 'center')

                love.graphics.setColor(1, 1, 1)
                x = x + love.graphics.getWidth() / 4
            end
        end
    end

}

StateMachine["game"]["setup"] = function()
    StateMachine["game"]["enemies"] = {}
    StateMachine["game"]["bullets"] = {}
    StateMachine["game"]["score"] = {0}

    StateMachine["game"]["player"] = models.Player:new(love.graphics.getWidth() * 3 / 4, love.graphics.getHeight() / 2, constants.PLAYER_SIDE_LENGTH)

    StateMachine["game"]["wave"] = 0

    StateMachine["game"]["enemyCount"] = 0
    StateMachine["game"]["enemySpeed"] = constants.ENEMY_SPEED
    StateMachine["game"]["enemyMaxHp"] = constants.ENEMY_MAX_HP

    StateMachine["game"]["upgrading"] = false
    StateMachine["game"]["upgradeOptions"] = {
        ["hp"] = {
            "Increase\nMax HP",
            function()
                StateMachine["game"]["player"].maxHp = StateMachine["game"]["player"].maxHp + StateMachine["game"]["player"].maxHp / 5
                StateMachine["game"]["player"].maxHp = math.floor(StateMachine["game"]["player"].maxHp+0.5)
            end
        },
        ["speed"] = {
            "Increase\nMovement\nSpeed",
            function()
                StateMachine["game"]["player"].speed = StateMachine["game"]["player"].speed + StateMachine["game"]["player"].speed / 50
                StateMachine["game"]["player"].speed = math.floor(StateMachine["game"]["player"].speed+0.5)
            end
        },
        ["damage"] = {
            "Increase\nDamage",
            function()
                StateMachine["game"]["player"].damage = StateMachine["game"]["player"].damage + StateMachine["game"]["player"].damage / 4
                StateMachine["game"]["player"].damage = math.floor(StateMachine["game"]["player"].damage+0.5)
            end
        },
    }
    StateMachine["game"]["upgradeOptionIndices"] = {
        "hp",
        "speed",
        "damage"
    }
    StateMachine["game"]["selectedUpgradeOption"] = 0
end
StateMachine["game"]["setup"]()

-- Game over
StateMachine["gameover"] = {
    textinput = function(text)
        StateMachine["gameover"]["name"] = StateMachine["gameover"]["name"] .. text
    end,
    
    keypressed = function(key)
        if key == 'return' then
            StateMachine["highscores"].updateHighScore(StateMachine["game"]["score"][1], StateMachine["gameover"]["name"])
            StateMachine["game"]["setup"]()
            StateMachine.currentState = "gamemenu"
        end
        if key == 'backspace' then
            StateMachine["gameover"]["name"] = string.sub(StateMachine["gameover"]["name"], 1, #StateMachine["gameover"]["name"] - 1)
        end
    end,

    update = function(dt)
        
    end,

    draw = function()
        w, h = love.graphics.getWidth(), love.graphics.getHeight()
        utils.largeFont()
        love.graphics.printf({{1, 0, 0}, "Game Over!"}, 0, h / 2, w, "center")
        utils.mediumFont()
        love.graphics.printf({{1, 1, 1}, "Your Score: ", {0, 1, 0}, StateMachine["game"]["score"][1]}, 0, h - h / 4 - 50, w, "center")
        love.graphics.printf("Enter Your Name", 0, h - h / 4, w, "center")
        love.graphics.printf(StateMachine["gameover"]["name"], 0, h - h / 4 + 30, w, "center")
    end
}

StateMachine["gameover"]["name"] = ""


return StateMachine

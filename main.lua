
stateMachine = require 'stateMachine'


function love.load()
    love.window.setTitle(constants.TITLE)  -- setting title
    love.mouse.setGrabbed(true)  -- prevents the cursor from going outside window

    love.graphics.setDefaultFilter( "nearest", "nearest" )  -- fixes blurriness when scaling text and images

    font = love.graphics.newFont('font.ttf', 15)
    font:setLineHeight(1.5)
    love.graphics.setFont(font)
end


function love.keypressed(key)
    StateMachine[StateMachine.currentState].keypressed(key)  -- Calls the keypressed function of the current state
end


function love.textinput(text)
    StateMachine[StateMachine.currentState].textinput(text)  -- Calls the textinput function of the current state
end


function love.update(dt)
    StateMachine[StateMachine.currentState].update(dt)  -- Calls the update function of the current state
end


function love.draw()
    StateMachine[StateMachine.currentState].draw()  -- Calls the draw function of the current state
end

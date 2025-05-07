local suits = {"hearts", "diamonds", "clubs", "spades"}
local ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

local cardValues = {
    ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7,
    ["8"] = 8, ["9"] = 9, ["10"] = 10 , ["J"] = 11, ["Q"] = 12, ["K"] = 13, ["A"] = 14
}

local diamondSuit = {}
local heartSuit = {}
local blackSuit = {}
local cardImages = {}
local selectionHand = {}
local opponentHand = {}
local playertHand = {}
local distance = {}

local fillHand = false
local dragging = false
local flipTime = false

local draggingCard = nil

local offsetX, offsetY = 0, 0
local life = 20
local timer = 0
local flipTimer = 3
love.graphics.setDefaultFilter("nearest", "nearest")

local function loadCardImages()
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local cardName = rank .. suit 
            cardImages[cardName] = love.graphics.newImage("sprites/cardImages/" .. cardName .. ".png")
        end
    end
end

local function createDeck()
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            if (suit == "diamonds") then
                local cardName = rank .. suit
                local cardValue = cardValues[rank]
                table.insert(diamondSuit, {name = cardName, value = cardValue})
            end
            if (suit == "hearts") then
                local cardName = rank .. suit
                local cardValue = cardValues[rank]
                table.insert(heartSuit, {name = cardName, value = cardValue})
            end
            if (suit == "clubs" or suit == "spades") then
                local cardName = rank .. suit
                local cardValue = cardValues[rank]
                table.insert(blackSuit, {name = cardName, value = cardValue})
            end
        end
    end
end


local function shuffleDeck()
    for i = #blackSuit, 2, -1 do
        local j = math.random(i)
        blackSuit[i], blackSuit[j] = blackSuit[j], blackSuit[i]
    end

    for i = #diamondSuit, 2, -1 do
        local j = math.random(i)
        diamondSuit[i], diamondSuit[j] = diamondSuit[j], diamondSuit[i]
    end
    
    for i = #heartSuit, 2, -1 do
        local j = math.random(i)
        heartSuit[i], heartSuit[j] = heartSuit[j], heartSuit[i]
    end
end

local function pickRedCards()
    local xOffset = 35
    local yOffset = 400
    local spacing = 150
    local card
    for i = 1, 5 do
        card = table.remove(diamondSuit)
        card.x = xOffset
        card.y = yOffset
        card.originalX = xOffset
        card.originalY = yOffset
        card.width = 105
        card.height = 150
        card.xText = card.originalX + 5
        card.yText = card.originalY - 5
        table.insert(selectionHand, card)
        xOffset = xOffset + spacing
        table.remove(card)
    end
end


local function pickBlackCards()
    local xOffset = 35
    local yOffset = 200
    local spacing = 150
    local card
    for i = 1, 5 do
        card = table.remove(blackSuit)
        card.x = xOffset
        card.y = yOffset
        card.originalX = xOffset
        card.originalY = yOffset
        card.width = 105
        card.height = 150
        card.xText = card.originalX + 5
        card.yText = card.originalY - 5
        table.insert(selectionHand, card)
        xOffset = xOffset + spacing
        table.remove(card)
    end
end

local function distanceCheck()
    if draggingCard then
        distance = {}
        for i = 1, #opponentHand do
            local dist = math.abs(draggingCard.x - opponentHand[i].x)
            if dist > 0 then
                distance[i] = dist
            else
                distance[i] = math.huge
            end
        end
    end
end

local function activeDragging()
    for i, card in ipairs(playertHand) do
        if card == draggingCard then
            table.remove(playertHand, i)
            break
        end
    end
end

local function battle()
    local damage = 0
    if dragging then
        for i = 1, #opponentHand do
            if distance[i] <= 10 then
                if opponentHand[i].value > draggingCard.value then
                    damage = math.abs(opponentHand[i].value - draggingCard.value)
                    table.remove(opponentHand,i)
                    activeDragging()
                else
                    table.remove(opponentHand,i)
                    activeDragging()
                end
                life = life - damage
                damage = 0
            end
        end
    end
end

function love.load()
    math.randomseed(os.time())
    loadCardImages()
    createDeck()
    shuffleDeck()
    pickBlackCards()
    pickRedCards()
end

function love.update(dt)
    if not flipTime then
        timer = timer + dt
        if timer >= flipTimer then
            flipTime = true
        end
    end

    distanceCheck()
    if life > 20 then
        life = 20
    elseif life < 0 then
        life = 0
    end

    if draggingCard then
        local mouseX, mouseY = love.mouse.getPosition()
        draggingCard.x = mouseX - offsetX
        draggingCard.y = mouseY - offsetY
    end

    if #opponentHand == 3 and #playertHand == 3 then
        fillHand = true
    end
end

function love.draw()
    love.graphics.print("Total card: " .. #heartSuit, 10, 35)
    love.graphics.print("Total card: " .. #diamondSuit, 10, 50 )
    love.graphics.print("Total card: " .. #blackSuit, 10, 65)
    love.graphics.print("OpponentIndex: " .. #opponentHand, 10, 80)
    love.graphics.print("PlayerIndex: " .. #playertHand, 10, 95)
    love.graphics.print("Life: " .. life, 10, 10)
    local yOffset = 20
    for i, card in ipairs(selectionHand) do
        if not flipTime then
            local cardImage = cardImages[card.name]
            love.graphics.draw(cardImage, card.x, card.y, nil, 2, 2)
        else
            love.graphics.draw(love.graphics.newImage("sprites/cardImages/redBase.png"), card.x, card.y, nil, 2, 2)
            love.graphics.print(card.value, card.xText, card.yText)
        end
        love.graphics.print(card.value, card.xText, card.yText)
    end
    if fillHand then
        selectionHand = {}
        for i, card in ipairs(opponentHand) do
            love.graphics.draw(love.graphics.newImage("sprites/cardImages/redBase.png"), card.x, card.y, nil, 2, 2)
            love.graphics.print(card.value, card.xText, card.yText)
        end
        for i, card in ipairs(playertHand) do
            love.graphics.draw(love.graphics.newImage("sprites/cardImages/blackBase.png"), card.x, card.y, nil, 2, 2)
            love.graphics.print(card.value, card.xText, card.yText)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        dragging = true
        for i, card in ipairs(selectionHand) do
            if x >= card.x and x <= card.x + card.width and y >= card.y and y <= card.y + card.height then
                draggingCard = card
                if not card.name:find("diamonds") and #opponentHand < 3 then
                    table.insert(opponentHand, table.remove(selectionHand, i))
                    opponentHand.cardImages = love.graphics.newImage("sprites/cardImages/blackBase.png")
                    canPick = false
                end
                if  card.name:find("diamonds") and #playertHand < 3 then
                    table.insert(playertHand, table.remove(selectionHand, i))
                    canPick = false
                end
                break
            end
        end

        for i, card in ipairs(playertHand) do
            if x >= card.x and x <= card.x + card.width and y >= card.y and y <= card.y + card.height then
                draggingCard = card
                offsetX = x - card.x
                offsetY = y - card.y
            end
        end
    end
end
function love.mousereleased(x, y, button)
    if button == 1 and draggingCard then
        if fillHand then
            battle()
        end
        draggingCard.x = draggingCard.originalX
        draggingCard.y = draggingCard.originalY
        draggingCard = nil
        dragging = false
    end
end

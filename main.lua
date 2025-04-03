local suits = {"hearts", "diamonds", "clubs", "spades"}
local ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

local cardValues = {
    ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7,
    ["8"] = 8, ["9"] = 9, ["10"] = 10, ["J"] = 11, ["Q"] = 12, ["K"] = 13, ["A"] = 14
}

local diamondSuit = {}
local heartSuit = {}
local blackSuit = {}
local cardImages = {}
local randomCards = {}
local distance = {}

local canRunAway = false
local fillHand = false
local start = true

local draggingCard = nil

local offsetX, offsetY = 0, 0
love.graphics.setDefaultFilter("nearest", "nearest")

function loadCardImages()
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local cardName = rank .. suit 
            cardImages[cardName] = love.graphics.newImage("sprites/cardImages/" .. cardName .. ".png")
        end
    end
end

function createDeck()
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


function shuffleDeck()
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

function pickRedCards()
    local xOffset = 75
    local yOffset = 150
    local spacing = 100
    local card
    for i = 1, 4 do
        card = table.remove(diamondSuit)
        card.x = xOffset
        card.y = yOffset
        card.originalX = xOffset
        card.originalY = yOffset
        card.width = 105
        card.height = 150
        card.xText = card.originalX + 5
        card.yText = card.originalY - 15
        table.insert(randomCards, card)
        xOffset = xOffset + spacing
        table.remove(card)
    end
    for i = 1, 2 do
        card = table.remove(heartSuit)
        card.x = xOffset
        card.y = yOffset
        card.originalX = xOffset
        card.originalY = yOffset
        card.width = 105
        card.height = 150
        card.xText = card.originalX + 5
        card.yText = card.originalY - 15
        table.insert(randomCards, card)
        xOffset = xOffset + spacing
        table.remove(card)
    end
end

function pickBlackCards()
    local xOffset = 75
    local yOffset = 300
    local spacing = 100
    local card
    for i = 1, 4 do
        card = table.remove(blackSuit)
        card.x = xOffset
        card.y = yOffset
        card.originalX = xOffset
        card.originalY = yOffset
        card.width = 105
        card.height = 150
        card.xText = card.originalX + 5
        card.yText = card.originalY - 15
        table.insert(randomCards, card)
        xOffset = xOffset + spacing
        table.remove(card)
    end
end

function runAway()
    canRunAway = false
    for _, card in ipairs(randomCards) do
        if card.suit == "diamonds" then
            table.insert(diamondSuit, table.remove(randomCards))
        end
        if card.suit == "hearts" then
            table.insert(heartSuit, table.remove(randomCards))
        end
        if card.suit == "clubs" or card.suit == "spades" then
            table.insert(blackSuit, table.remove(randomCards))
        end
        shuffleDeck()
    end
    fillHand = true
    if fillHand then
        pickRedCards()
        pickBlackCards()
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
    if love.keyboard.isDown('s') and canRunAway then
        runAway()
        print("working")
    end
    if love.keyboard.isDown('r') and not canRunAway then
        canRunAway = true
    end
    if draggingCard then
        local mouseX, mouseY = love.mouse.getPosition()
        draggingCard.x = mouseX - offsetX
        draggingCard.y = mouseY - offsetY
    end
end

function love.draw()
    love.graphics.print("Total card: " .. #heartSuit, 10, 10 )
    love.graphics.print("Total card: " .. #diamondSuit, 10, 20 )
    love.graphics.print("Total card: " .. #blackSuit, 10, 30)
    local yOffset = 20
    for i, card in ipairs(randomCards) do
        local cardImage = cardImages[card.name]
        love.graphics.draw(cardImage, card.x, card.y, nil, 3, 3)
        love.graphics.print(card.value, card.xText, card.yText)
    end
    if draggingCard then
        for i, distances in ipairs(distance) do
            love.graphics.print('distance = ' .. distances , 10, yOffset)
            yOffset = yOffset + 10
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        for i, card in ipairs(randomCards) do
            if x >= card.x and x <= card.x + card.width and y >= card.y and y <= card.y + card.height then
                draggingCard = card
                offsetX = x - card.x
                offsetY = y - card.y
                break
            end
        end
    end
end
function love.mousereleased(x, y, button)
    if button == 1 and draggingCard then
        draggingCard.x = draggingCard.originalX
        draggingCard.y = draggingCard.originalY
        draggingCard = nil
        draggingCard = nil
        
    end
end

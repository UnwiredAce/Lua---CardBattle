local suits = {"hearts", "diamonds", "clubs", "spades"}
local ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

local cardValues = {
    ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7,
    ["8"] = 8, ["9"] = 9, ["10"] = 10, ["J"] = 11, ["Q"] = 12, ["K"] = 13, ["A"] = 14
}

local deck = {}
local cardImages = {}
local randomCards = {}
local distance = {}

local canRunAway = true
local fillHand = false

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
            if not ((suit == "diamonds" or suit == "hearts") and (rank == "A" or rank == "K" or rank == "Q" or rank == "J")) then
                local cardName = rank .. suit
                local cardValue = cardValues[rank]
                table.insert(deck, {name = cardName, value = cardValue})
            end
        end
    end
end

function shuffleDeck()
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

function pickUniqueCards()
    local xOffset = 150
    local yOffset = 150
    local spacing = 150
    local card
    for i = 1, 4 do
        card = table.remove(deck)
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
    for i = 1, 4 do
        table.insert(deck, table.remove(randomCards))
        shuffleDeck()
    end
    fillHand = true
    if fillHand then
        pickUniqueCards()
    end
end

function love.load()
    math.randomseed(os.time())
    loadCardImages()
    createDeck()
    shuffleDeck()
    pickUniqueCards()
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

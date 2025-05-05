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

local canPick = true
local fillHand = false
local dragging = false

local draggingCard = nil

local offsetX, offsetY = 0, 0
local life = 20
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

local function pickHearts()
    local card
    card = table.remove(heartSuit)
    card.x = 650
    card.y = 10
    card.originalX = card.x
    card.originalY = card.y
    card.width = 105
    card.height = 150
    card.xText = card.x + 5
    card.yText = card.y - 5
    table.insert(selectionHand, card)
    table.remove(card)
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
        for i = 1, #selectionHand do
            local dist = math.abs(draggingCard.x - selectionHand[i].x)
            if dist > 0 then
                distance[i] = dist
            else
                distance[i] = math.huge
            end
        end
    end
end

local function activeDragging()
    for i, card in ipairs(selectionHand) do
        if card == draggingCard then
            table.remove(selectionHand, i)
            break
        end
    end
end

local function addHealth()
    local heartsCheck = "hearts"
    if dragging then
        if draggingCard.y > 400 and draggingCard.name:find(heartsCheck) and life < 20 then
            life = life + draggingCard.value
            activeDragging()
        end
    end
end

local function battle()
    local damage = 0
    local check = "diamonds"
    local heartsCheck = "hearts"
    if dragging then
        for i = 1, #randomCards do
            if distance[i] <= 10 then
                if draggingCard.name:find(check) and not randomCards[i].name:find(heartsCheck) and not selectionHand[i].name:find(check) then
                    if selectionHand[i].value > draggingCard.value then
                        damage = math.abs(selectionHand[i].value - draggingCard.value)
                        table.remove(randomCards,i)
                        activeDragging()
                    else
                        table.remove(selectionHand,i)
                        activeDragging()
                    end
                    life = life - damage
                    damage = 0
                end
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
    pickHearts()
    pickRedCards()
end

function love.update(dt)
    distanceCheck()
    if life > 20 then
        life = 20
    elseif life < 0 then
        life = 0
    end
    
    if canPick and love.keyboard.isDown('r') then
        canPick = false

    end

    if draggingCard then
        local mouseX, mouseY = love.mouse.getPosition()
        draggingCard.x = mouseX - offsetX
        draggingCard.y = mouseY - offsetY
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
        local cardImage = cardImages[card.name]
        love.graphics.draw(cardImage, card.x, card.y, nil, 2, 2)
    end
    if #opponentHand == 3 and #playertHand == 3 then
        selectionHand = {}
        for i, card in ipairs(opponentHand) do
            local cardImage = cardImages[card.name]
            love.graphics.draw(cardImage, card.x, card.y, nil, 2, 2)
        end
        for i, card in ipairs(playertHand) do
            local cardImage = cardImages[card.name]
            love.graphics.draw(cardImage, card.x, card.y, nil, 2, 2)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        dragging = true
        for i, card in ipairs(selectionHand) do
            if x >= card.x and x <= card.x + card.width and y >= card.y and y <= card.y + card.height then
                draggingCard = card
                offsetX = x - card.x
                offsetY = y - card.y
                if not card.name:find("diamonds") and #opponentHand < 3 then
                    table.insert(opponentHand, table.remove(selectionHand, i))
                end
                if  card.name:find("diamonds") and #playertHand < 3 then
                    table.insert(playertHand, table.remove(selectionHand, i))
                end
                break
            end
        end
    end
end
function love.mousereleased(x, y, button)
    if button == 1 and draggingCard then
        if not canPick then
            addHealth()
            battle()
        end
        draggingCard.x = draggingCard.originalX
        draggingCard.y = draggingCard.originalY
        draggingCard = nil
        dragging = false
    end
end

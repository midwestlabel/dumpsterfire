local CardClient = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

function CardClient:CreateMainUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CardGameUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	self:CreateTopBar(mainFrame)
	self:CreatePackShop(mainFrame)
	self:CreateCollection(mainFrame)

	return screenGui
end

function CardClient:CreateTopBar(parent)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 60)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
	topBar.BorderSizePixel = 0
	topBar.Parent = parent

	local coinsLabel = Instance.new("TextLabel")
	coinsLabel.Name = "CoinsLabel"
	coinsLabel.Size = UDim2.new(0, 200, 1, 0)
	coinsLabel.Position = UDim2.new(0, 20, 0, 0)
	coinsLabel.BackgroundTransparency = 1
	coinsLabel.Text = "Coins: 500"
	coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	coinsLabel.TextSize = 20
	coinsLabel.Font = Enum.Font.GothamBold
	coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
	coinsLabel.Parent = topBar

	-- GardenLevel label removed for cleaner UI

	-- Add mutation counter
	local mutationLabel = Instance.new("TextLabel")
	mutationLabel.Name = "MutationLabel"
	mutationLabel.Size = UDim2.new(0, 200, 1, 0)
	mutationLabel.Position = UDim2.new(0, 470, 0, 0)
	mutationLabel.BackgroundTransparency = 1
	mutationLabel.Text = "⚠️ Mutations: 0"
	mutationLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	mutationLabel.TextSize = 16
	mutationLabel.Font = Enum.Font.GothamBold
	mutationLabel.TextXAlignment = Enum.TextXAlignment.Left
	mutationLabel.Parent = topBar

	local dailyButton = Instance.new("TextButton")
	dailyButton.Name = "DailyButton"
	dailyButton.Size = UDim2.new(0, 120, 0, 40)
	dailyButton.Position = UDim2.new(1, -270, 0, 10)
	dailyButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	dailyButton.Text = "Daily Reward"
	dailyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	dailyButton.TextSize = 14
	dailyButton.Font = Enum.Font.GothamBold
	dailyButton.Parent = topBar

	self:CreateButtonStyle(dailyButton)

	-- Add click handler for daily reward
	dailyButton.MouseButton1Click:Connect(function()
		self:ClaimDailyReward()
	end)

	-- Add close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 120, 0, 40)
	closeButton.Position = UDim2.new(1, -140, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
	closeButton.Text = "❌ Close"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 14
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = topBar

	self:CreateButtonStyle(closeButton)

	-- Add click handler for close
	closeButton.MouseButton1Click:Connect(function()
		self:CloseUI()
	end)
end

function CardClient:CreatePackShop(parent)
	local shopFrame = Instance.new("ScrollingFrame")
	shopFrame.Name = "PackShop"
	shopFrame.Size = UDim2.new(0.55, 0, 0.85, 0)
	shopFrame.Position = UDim2.new(0, 20, 0, 80)
	shopFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
	shopFrame.BorderSizePixel = 0
	shopFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
	shopFrame.ScrollBarThickness = 6
	shopFrame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = shopFrame

	local title = Instance.new("TextLabel")
	title.Name = "ShopTitle"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "Card Packs"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 22
	title.Font = Enum.Font.GothamBold
	title.Parent = shopFrame

	self:CreatePackButton(shopFrame, "Basic", "Basic Pack", "5 Cards - 100 Coins", UDim2.new(0, 15, 0, 60))
	self:CreatePackButton(shopFrame, "Premium", "Premium Pack", "8 Cards + Guaranteed Rare - 250 Coins", UDim2.new(0, 15, 0, 180))
	self:CreatePackButton(shopFrame, "Special", "Special Pack", "12 Cards + Guaranteed Ultra Rare - 500 Coins", UDim2.new(0, 15, 0, 300))
end

function CardClient:CreatePackButton(parent, packType, name, description, position)
	local button = Instance.new("TextButton")
	button.Name = packType .. "Pack"
	button.Size = UDim2.new(1, -30, 0, 100)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(50, 60, 85)
	button.Text = ""
	button.Parent = parent

	-- Pack Image
	local packImage = Instance.new("ImageLabel")
	packImage.Size = UDim2.new(0, 70, 0, 70)
	packImage.Position = UDim2.new(0, 10, 0, 15)
	packImage.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	packImage.Image = self.PackImages[packType] or "rbxassetid://0"
	packImage.ScaleType = Enum.ScaleType.Fit
	packImage.Parent = button

	local imageCorner = Instance.new("UICorner")
	imageCorner.CornerRadius = UDim.new(0, 6)
	imageCorner.Parent = packImage

	-- Pack placeholder if no image
	if packImage.Image == "rbxassetid://0" then
		local placeholder = Instance.new("TextLabel")
		placeholder.Size = UDim2.new(1, 0, 1, 0)
		placeholder.BackgroundTransparency = 1
		placeholder.Text = "📦"
		placeholder.TextColor3 = Color3.fromRGB(150, 150, 150)
		placeholder.TextSize = 32
		placeholder.Font = Enum.Font.Gotham
		placeholder.Parent = packImage
	end

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -100, 0, 30)
	nameLabel.Position = UDim2.new(0, 90, 0, 20)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -100, 0, 40)
	descLabel.Position = UDim2.new(0, 90, 0, 50)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextSize = 12
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = button

	self:CreateButtonStyle(button)

	button.MouseButton1Click:Connect(function()
		self:OpenPack(packType)
	end)
end

CardClient.PlayerCards = {} -- Store opened cards

-- Pack Images - Replace with your uploaded pack image IDs
CardClient.PackImages = {
	Basic = "rbxassetid://0", -- Replace with Basic pack image ID
	Premium = "rbxassetid://0", -- Replace with Premium pack image ID  
	Special = "rbxassetid://0" -- Replace with Special pack image ID
}

-- Wild West Card Images - Replace the 0s with your uploaded image asset IDs
CardClient.CardImages = {
	-- Common Cards - IMG_1649 to IMG_1656
	["Desert Coyote"] = "rbxassetid://122471920219026", -- IMG_1649.JPG
	["Rusty Horseshoe"] = "rbxassetid://105550062204789", -- IMG_1650.JPG
	["Prairie Dog"] = "rbxassetid://121621510857544", -- IMG_1651.JPG
	["Tumbling Tumbleweeds"] = "rbxassetid://71478245491680", -- IMG_1652.JPG
	["Old Mining Cart"] = "rbxassetid://129245591148577", -- IMG_1653.JPG
	["Cactus Flower"] = "rbxassetid://83885185002749", -- IMG_1654.JPG
	["Desert Scorpion"] = "rbxassetid://121621510857544", -- IMG_1655.JPG
	["Weathered Fence Post"] = "rbxassetid://73263129017757", -- IMG_1656.JPG

	-- Uncommon Cards - IMG_1657 to IMG_1662
	["Wild Mustang"] = "rbxassetid://79442219211195", -- IMG_1657.JPG
	["Prospector's Pan"] = "rbxassetid://114632290978110", -- IMG_1658.JPG
	["Saloon Piano"] = "rbxassetid://103300007340149", -- IMG_1659.JPG
	["Desert Rattlesnake"] = "rbxassetid://120667197070178", -- IMG_1660.JPG
	["Covered Wagon"] = "rbxassetid://78663627401944", -- IMG_1661.JPG
	["Sheriff's Badge"] = "rbxassetid://97028720086959", -- IMG_1662.JPG

	-- Rare Cards - IMG_1663 to IMG_1666
	["Legendary Gunslinger"] = "rbxassetid://101642100560754", -- IMG_1663.JPG
	["Golden Revolver"] = "rbxassetid://113446676320218", -- IMG_1664.JPG
	["Frontier Locomotive"] = "rbxassetid://129386178616319", -- IMG_1665.JPG
	["Native Chief"] = "rbxassetid://83126350710033", -- IMG_1666.JPG

	-- Ultra Rare Card - IMG_1667
	["Ghost Town Saloon"] = "rbxassetid://78522395956380", -- IMG_1667.JPG

	-- Secret Card - IMG_1669
	["Lost Gold Mine"] = "rbxassetid://88747556494528", -- IMG_1669.JPG

	["default"] = "rbxassetid://0" -- Default placeholder
}

function CardClient:CreateCollection(parent)
	local collectionFrame = Instance.new("ScrollingFrame")
	collectionFrame.Name = "Collection"
	collectionFrame.Size = UDim2.new(0.4, -30, 0.85, 0)
	collectionFrame.Position = UDim2.new(0.6, 0, 0, 80)
	collectionFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
	collectionFrame.BorderSizePixel = 0
	collectionFrame.CanvasSize = UDim2.new(0, 0, 3, 0)
	collectionFrame.ScrollBarThickness = 6
	collectionFrame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = collectionFrame

	-- Header with title and sell mode toggle
	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "Header"
	headerFrame.Size = UDim2.new(1, 0, 0, 40)
	headerFrame.Position = UDim2.new(0, 0, 0, 10)
	headerFrame.BackgroundTransparency = 1
	headerFrame.Parent = collectionFrame

	local title = Instance.new("TextLabel")
	title.Name = "CollectionTitle"
	title.Size = UDim2.new(0.4, 0, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "My Collection (0/20)"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = headerFrame

	local sellCompleteSetButton = Instance.new("TextButton")
	sellCompleteSetButton.Name = "SellCompleteSetButton"
	sellCompleteSetButton.Size = UDim2.new(0.25, 0, 0.8, 0)
	sellCompleteSetButton.Position = UDim2.new(0.42, 0, 0.1, 0)
	sellCompleteSetButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	sellCompleteSetButton.Text = "🎯 Sell Set"
	sellCompleteSetButton.TextColor3 = Color3.fromRGB(50, 50, 50)
	sellCompleteSetButton.TextSize = 11
	sellCompleteSetButton.Font = Enum.Font.GothamBold
	sellCompleteSetButton.Parent = headerFrame

	self:CreateButtonStyle(sellCompleteSetButton)

	-- Add click handler for selling complete set
	sellCompleteSetButton.MouseButton1Click:Connect(function()
		self:SellCompleteSet()
	end)

	local sellModeButton = Instance.new("TextButton")
	sellModeButton.Name = "SellModeButton"
	sellModeButton.Size = UDim2.new(0.25, 0, 0.8, 0)
	sellModeButton.Position = UDim2.new(0.7, 0, 0.1, 0)
	sellModeButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
	sellModeButton.Text = "💰 Sell Mode"
	sellModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sellModeButton.TextSize = 12
	sellModeButton.Font = Enum.Font.GothamBold
	sellModeButton.Parent = headerFrame

	self:CreateButtonStyle(sellModeButton)

	-- Toggle sell mode
	sellModeButton.MouseButton1Click:Connect(function()
		self.sellMode = not self.sellMode
		if self.sellMode then
			sellModeButton.Text = "❌ Exit Sell"
			sellModeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			title.Text = "💰 Sell Cards (Click to Sell)"
		else
			sellModeButton.Text = "💰 Sell Mode"  
			sellModeButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
			title.Text = "My Collection"
		end
		self:UpdateCollection()
	end)

	local cardGrid = Instance.new("Frame")
	cardGrid.Name = "CardGrid"
	cardGrid.Size = UDim2.new(1, -20, 1, -60)
	cardGrid.Position = UDim2.new(0, 10, 0, 50)
	cardGrid.BackgroundTransparency = 1
	cardGrid.Parent = collectionFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 80, 0, 110)
	gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = cardGrid

	self.sellMode = false
	self:UpdateCollection()
end

function CardClient:UpdateCollection()
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	local collection = screenGui.MainFrame.Collection
	if not collection then return end

	local cardGrid = collection:FindFirstChild("CardGrid")
	if not cardGrid then return end

	-- Update collection progress (count unique cards by ID, not name)
	local uniqueCards = {}
	for _, card in ipairs(self.PlayerCards) do
		uniqueCards[card.id] = true -- Use card ID for uniqueness, not name
	end
	local uniqueCount = 0
	for _ in pairs(uniqueCards) do
		uniqueCount = uniqueCount + 1
	end

	-- Level up messages disabled per user request
	-- self:CheckSetProgression(uniqueCount)

	local title = collection.Header.CollectionTitle
	if self.sellMode then
		title.Text = "💰 Sell Cards (Click to Sell)"
	else
		title.Text = "My Collection (" .. uniqueCount .. "/20)"

		-- Add progress indicator color and set selling hint
		if uniqueCount >= 20 then
			title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold for complete
			title.Text = "My Collection (" .. uniqueCount .. "/20) - 🎯 Complete Set! Sell for 2x value!"
		elseif uniqueCount >= 15 then
			title.TextColor3 = Color3.fromRGB(255, 100, 255) -- Purple for near complete
		else
			title.TextColor3 = Color3.fromRGB(255, 255, 255) -- White for normal
		end

		-- Check for mutated cards and add indicator
		local mutatedCardCount = 0
		for _, card in ipairs(self.PlayerCards) do
			if card.mutation and card.mutation == "Error" then
				mutatedCardCount = mutatedCardCount + 1
			end
		end

		if mutatedCardCount > 0 then
			title.Text = title.Text .. " ⚠️ " .. mutatedCardCount .. " MUTATED!"
			title.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red for mutated cards
		end

		-- Update mutation counter in top bar
		local screenGui = playerGui:FindFirstChild("CardGameUI")
		if screenGui then
			local mutationLabel = screenGui.MainFrame.TopBar:FindFirstChild("MutationLabel")
			if mutationLabel then
				if mutatedCardCount > 0 then
					mutationLabel.Text = "⚠️ Mutations: " .. mutatedCardCount
					mutationLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
				else
					mutationLabel.Text = "Mutations: 0"
					mutationLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
				end
			end
		end

		-- Show total card count (including duplicates) if different from unique count
		if #self.PlayerCards > uniqueCount then
			title.Text = title.Text .. " (Total: " .. #self.PlayerCards .. " cards)"
		end
	end

	-- Clear ALL existing children to ensure clean slate
	for _, child in pairs(cardGrid:GetChildren()) do
		child:Destroy()
	end

	-- Recreate the grid layout
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 80, 0, 110)
	gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = cardGrid

	-- Add cards to collection with consecutive layout order starting from 1
	for i, card in ipairs(self.PlayerCards) do
		self:CreateCollectionCard(cardGrid, card, i)
	end
end

function CardClient:CreateCollectionCard(parent, card, index)
	local cardFrame = Instance.new("TextButton")
	cardFrame.Name = "Card" .. index
	cardFrame.Size = UDim2.new(0, 80, 0, 110)
	cardFrame.BackgroundColor3 = Color3.fromRGB(60, 70, 95)
	cardFrame.Text = ""
	cardFrame.LayoutOrder = index
	cardFrame.Parent = parent

	-- Add sell mode visual indicator
	if self.sellMode then
		cardFrame.BackgroundColor3 = Color3.fromRGB(100, 60, 60) -- Reddish tint for sell mode
	end

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = cardFrame

	-- Card Image
	local cardImage = Instance.new("ImageLabel")
	cardImage.Size = UDim2.new(1, -6, 0, 60)
	cardImage.Position = UDim2.new(0, 3, 0, 3)
	cardImage.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	cardImage.Image = self.CardImages[card.name] or self.CardImages["default"]
	cardImage.ScaleType = Enum.ScaleType.Fit
	cardImage.Parent = cardFrame

	local imageCorner = Instance.new("UICorner")
	imageCorner.CornerRadius = UDim.new(0, 4)
	imageCorner.Parent = cardImage

	-- If no image, show placeholder text
	if cardImage.Image == "rbxassetid://0" then
		local placeholder = Instance.new("TextLabel")
		placeholder.Size = UDim2.new(1, 0, 1, 0)
		placeholder.BackgroundTransparency = 1
		placeholder.Text = "📄"
		placeholder.TextColor3 = Color3.fromRGB(150, 150, 150)
		placeholder.TextSize = 24
		placeholder.Font = Enum.Font.Gotham
		placeholder.Parent = cardImage
	end

	-- Card Name
	local cardName = Instance.new("TextLabel")
	cardName.Size = UDim2.new(1, -4, 0, 25)
	cardName.Position = UDim2.new(0, 2, 0, 65)
	cardName.BackgroundTransparency = 1
	cardName.Text = card.name
	cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
	cardName.TextSize = 10
	cardName.Font = Enum.Font.GothamBold
	cardName.TextScaled = true
	cardName.TextWrapped = true
	cardName.Parent = cardFrame

	-- Rarity indicator
	local rarityColor = self:GetRarityColor(card.rarity)
	local rarityBar = Instance.new("Frame")
	rarityBar.Size = UDim2.new(1, 0, 0, 3)
	rarityBar.Position = UDim2.new(0, 0, 1, -3)
	rarityBar.BackgroundColor3 = rarityColor
	rarityBar.BorderSizePixel = 0
	rarityBar.Parent = cardFrame

	-- Add glowing effect for rare cards
	if card.rarity == "Rare" or card.rarity == "UltraRare" or card.rarity == "Secret" then
		self:AddGlowEffect(cardFrame, rarityColor)
	end

	-- Add mutation effects for Error mutation cards
	if card.mutation and card.mutation == "Error" then
		self:AddMutationEffect(cardFrame, card)
	end

	-- Card Value
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, -4, 0, 17)
	valueLabel.Position = UDim2.new(0, 2, 0, 90)
	valueLabel.BackgroundTransparency = 1
	if self.sellMode then
		local sellPrice = card.value -- Sell for full value
		valueLabel.Text = "Sell: " .. sellPrice .. " coins"
		valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	else
		-- Show mutation info if card has Error mutation
		if card.mutation and card.mutation == "Error" then
			valueLabel.Text = card.value .. " coins ⚠️"
			valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red for mutated cards
		else
			valueLabel.Text = card.value .. " coins"
			valueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		end
	end
	valueLabel.TextSize = 8
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.Parent = cardFrame

	-- Add click handler for selling or viewing
	cardFrame.MouseButton1Click:Connect(function()
		if self.sellMode then
			self:SellCard(index, card)
		else
			self:ShowCardDetail(card)
		end
	end)
end

function CardClient:SellCard(cardIndex, card)
	local sellPrice = card.value

	print("🔍 Selling card:", card.name, "instanceId:", card.instanceId, "value:", card.value, "sellPrice:", sellPrice)

	-- Send sell request to server using the card's instanceId
	local remoteEvent = ReplicatedStorage:WaitForChild("SellCardEvent", 5)
	if not remoteEvent then
		print("❌ SellCardEvent not found - this should not happen!")
		return
	end

	print("✅ Found SellCardEvent, sending sell request...")
	remoteEvent:FireServer(card.instanceId, card.name)
	print("📤 Sell request sent to server")
end

function CardClient:SellCompleteSet()
	print("🎯 Attempting to sell complete set...")

	local remoteEvent = ReplicatedStorage:WaitForChild("SetSellEvent", 5)
	if not remoteEvent then
		print("❌ SetSellEvent not found - this should not happen!")
		return
	end

	print("✅ Found SetSellEvent, sending set sell request...")
	remoteEvent:FireServer()
	print("📤 Set sell request sent to server")
end

function CardClient:GetRarityColor(rarity)
	local colors = {
		Common = Color3.fromRGB(200, 200, 200),
		Uncommon = Color3.fromRGB(100, 255, 100),
		Rare = Color3.fromRGB(100, 100, 255),
		UltraRare = Color3.fromRGB(255, 100, 255),
		Secret = Color3.fromRGB(255, 215, 0)
	}
	return colors[rarity] or colors.Common
end

function CardClient:AddGlowEffect(cardFrame, glowColor)
	-- Create glow frame behind the card
	local glowFrame = Instance.new("Frame")
	glowFrame.Name = "GlowEffect"
	glowFrame.Size = UDim2.new(1, 8, 1, 8)
	glowFrame.Position = UDim2.new(0, -4, 0, -4)
	glowFrame.BackgroundColor3 = glowColor
	glowFrame.BackgroundTransparency = 0.3
	glowFrame.BorderSizePixel = 0
	glowFrame.ZIndex = cardFrame.ZIndex - 1
	glowFrame.Parent = cardFrame -- Parent to the card frame instead of the grid

	-- Add corner radius to match card
	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(0, 10)
	glowCorner.Parent = glowFrame

	-- Create pulsing glow animation
	local glowTween1 = TweenService:Create(glowFrame,
		TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{BackgroundTransparency = 0.7, Size = UDim2.new(1, 12, 1, 12), Position = UDim2.new(0, -6, 0, -6)}
	)

	glowTween1:Play()

	-- Clean up glow when card is destroyed (glow is now parented to card)
	cardFrame.AncestryChanged:Connect(function()
		if not cardFrame.Parent then
			if glowFrame and glowFrame.Parent then
				glowFrame:Destroy()
			end
		end
	end)

	return glowFrame
end

-- Function to add mutation effects to cards
function CardClient:AddMutationEffect(cardFrame, card)
	if not card.mutation or card.mutation ~= "Error" then
		return
	end

	-- Simple mutation indicator - just add a warning symbol
	local errorSymbol = Instance.new("TextLabel")
	errorSymbol.Size = UDim2.new(0, 18, 0, 18)
	errorSymbol.Position = UDim2.new(1, -23, 0, 3)
	errorSymbol.BackgroundTransparency = 1
	errorSymbol.Text = "⚠️"
	errorSymbol.TextColor3 = Color3.fromRGB(255, 255, 0)
	errorSymbol.TextSize = 14
	errorSymbol.Font = Enum.Font.GothamBold
	errorSymbol.ZIndex = cardFrame.ZIndex + 1
	errorSymbol.Parent = cardFrame

	-- Simple pulsing animation
	local errorTween = TweenService:Create(errorSymbol,
		TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{TextTransparency = 0.4, Size = UDim2.new(0, 20, 0, 20)}
	)
	errorTween:Play()

	return cardFrame
end

function CardClient:CreateButtonStyle(button)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	button.MouseEnter:Connect(function()
		local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = button.BackgroundColor3:lerp(Color3.fromRGB(255, 255, 255), 0.1)})
		tween:Play()
	end)

	button.MouseLeave:Connect(function()
		local originalColor = button.BackgroundColor3
		local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor})
		tween:Play()
	end)
end

function CardClient:OpenPack(packType)
	print("🎁 Attempting to open", packType, "pack...")

	local remoteEvent = ReplicatedStorage:WaitForChild("OpenPackEvent", 5)
	if not remoteEvent then
		print("❌ OpenPackEvent not found - this should not happen!")
		return
	end

	print("✅ Found OpenPackEvent, sending pack opening request...")
	remoteEvent:FireServer(packType)
	print("📤 Pack opening request sent to server")
end

function CardClient:ClaimDailyReward()
	local remoteEvent = ReplicatedStorage:WaitForChild("DailyRewardEvent")
	remoteEvent:FireServer()
end

function CardClient:CloseUI()
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if screenGui then
		screenGui.Enabled = false
	end
end

function CardClient:OpenUI()
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if screenGui then
		screenGui.Enabled = true
	else
		self:CreateMainUI()
	end
end

function CardClient:CreateNavigationButton()
	local navGui = Instance.new("ScreenGui")
	navGui.Name = "CardNavigation"
	navGui.ResetOnSpawn = false
	navGui.Parent = playerGui

	local navButton = Instance.new("TextButton")
	navButton.Name = "OpenCardsButton"
	navButton.Size = UDim2.new(0, 150, 0, 40)
	navButton.Position = UDim2.new(0.5, -75, 0, 10)
	navButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
	navButton.Text = "🎴 Open Cards"
	navButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	navButton.TextSize = 16
	navButton.Font = Enum.Font.GothamBold
	navButton.Parent = navGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = navButton

	self:CreateButtonStyle(navButton)

	navButton.MouseButton1Click:Connect(function()
		self:OpenUI()
	end)

	-- Add display table button (always visible)
	local displayButton = Instance.new("TextButton")
	displayButton.Name = "DisplayTableButton"
	displayButton.Size = UDim2.new(0, 150, 0, 40)
	displayButton.Position = UDim2.new(0.5, -75, 0, 60)
	displayButton.BackgroundColor3 = Color3.fromRGB(200, 150, 100)
	displayButton.Text = "🏠 Display Table"
	displayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	displayButton.TextSize = 16
	displayButton.Font = Enum.Font.GothamBold
	displayButton.Visible = true -- Always visible
	displayButton.Parent = navGui

	-- Store reference for updating table info
	self.DisplayTableButton = displayButton

	local displayCorner = Instance.new("UICorner")
	displayCorner.CornerRadius = UDim.new(0, 8)
	displayCorner.Parent = displayButton

	self:CreateButtonStyle(displayButton)

	displayButton.MouseButton1Click:Connect(function()
		self:OpenDisplayTable()
	end)

	-- Add server status display
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "ServerStatusLabel"
	statusLabel.Size = UDim2.new(0, 200, 0, 20)
	statusLabel.Position = UDim2.new(0.5, -100, 0, 110)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "🔄 Connecting to server..."
	statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statusLabel.TextSize = 12
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.Parent = navGui

	-- Store reference for updating status
	self.ServerStatusLabel = statusLabel

	-- Test connection button removed for cleaner UI

	-- Set initial status to show we're ready
	spawn(function()
		wait(3) -- Wait for server to be ready
		if not self.ServerStatusLabel.Text:find("✅") and not self.ServerStatusLabel.Text:find("👥") then
			self:UpdateServerStatus("🔄 Waiting for table assignment...", Color3.fromRGB(255, 200, 100))
		end

		-- Additional check after 10 seconds
		wait(7)
		if not self.ServerStatusLabel.Text:find("✅") and not self.ServerStatusLabel.Text:find("👥") then
			self:UpdateServerStatus("⏰ Still waiting for server connection...", Color3.fromRGB(255, 150, 100))
		end

		-- Debug: Check what remote events are available
		wait(5)
		print("🔍 Debug: Checking available remote events in ReplicatedStorage...")
		local replicatedStorage = game:GetService("ReplicatedStorage")
		for _, child in pairs(replicatedStorage:GetChildren()) do
			if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
				print("📡 Found remote:", child.Name, "Type:", child.ClassName)
			end
		end
	end)

	return navGui
end

-- Function to update display table button text with table assignment
function CardClient:UpdateDisplayTableButton(tableNumber)
	if self.DisplayTableButton then
		if tableNumber then
			self.DisplayTableButton.Text = "🏠 Table " .. tableNumber
			print("🏠 Updated display table button to show table", tableNumber)
		else
			self.DisplayTableButton.Text = "🏠 Display Table"
			print("🏠 Reset display table button text")
		end
	else
		print("❌ Display table button is nil! Cannot update text")
	end
end

-- Function to show/hide display table button (kept for compatibility)
function CardClient:SetDisplayTableButtonVisible(visible)
	if self.DisplayTableButton then
		self.DisplayTableButton.Visible = visible
		print("🏠 Display table button visibility set to:", visible, "Button exists:", self.DisplayTableButton ~= nil)
	else
		print("❌ Display table button is nil! Cannot set visibility to:", visible)
	end
end

-- Function to update server status display
function CardClient:UpdateServerStatus(status, color)
	if self.ServerStatusLabel then
		self.ServerStatusLabel.Text = status
		if color then
			self.ServerStatusLabel.TextColor3 = color
		end
		print("🔄 Updated server status to:", status)
	else
		print("❌ Server status label is nil! Cannot update status")
	end
end

function CardClient:ShowCardDetail(card)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	-- Create card detail popup
	local detailFrame = Instance.new("Frame")
	detailFrame.Name = "CardDetailPopup"
	detailFrame.Size = UDim2.new(0, 400, 0, 500)
	detailFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
	detailFrame.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
	detailFrame.BorderSizePixel = 0
	detailFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = detailFrame

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = detailFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		detailFrame:Destroy()
	end)

	-- Card image (large)
	local cardImage = Instance.new("ImageLabel")
	cardImage.Size = UDim2.new(1, -40, 0, 280)
	cardImage.Position = UDim2.new(0, 20, 0, 40)
	cardImage.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	cardImage.Image = self.CardImages[card.name] or self.CardImages["default"]
	cardImage.ScaleType = Enum.ScaleType.Fit
	cardImage.Parent = detailFrame

	local imageCorner = Instance.new("UICorner")
	imageCorner.CornerRadius = UDim.new(0, 8)
	imageCorner.Parent = cardImage

	-- Placeholder if no image
	if cardImage.Image == "rbxassetid://0" then
		local placeholder = Instance.new("TextLabel")
		placeholder.Size = UDim2.new(1, 0, 1, 0)
		placeholder.BackgroundTransparency = 1
		placeholder.Text = "🎴"
		placeholder.TextColor3 = Color3.fromRGB(150, 150, 150)
		placeholder.TextSize = 80
		placeholder.Font = Enum.Font.Gotham
		placeholder.Parent = cardImage
	end

	-- Card name
	local cardName = Instance.new("TextLabel")
	cardName.Size = UDim2.new(1, -40, 0, 40)
	cardName.Position = UDim2.new(0, 20, 0, 330)
	cardName.BackgroundTransparency = 1
	cardName.Text = card.name
	cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
	cardName.TextSize = 24
	cardName.Font = Enum.Font.GothamBold
	cardName.TextScaled = true
	cardName.Parent = detailFrame

	-- Rarity and value info
	local infoFrame = Instance.new("Frame")
	infoFrame.Size = UDim2.new(1, -40, 0, 80)
	infoFrame.Position = UDim2.new(0, 20, 0, 380)
	infoFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
	infoFrame.Parent = detailFrame

	local infoCorner = Instance.new("UICorner")
	infoCorner.CornerRadius = UDim.new(0, 8)
	infoCorner.Parent = infoFrame

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, -20, 0, 25)
	rarityLabel.Position = UDim2.new(0, 10, 0, 10)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = "Rarity: " .. card.rarity
	rarityLabel.TextColor3 = self:GetRarityColor(card.rarity)
	rarityLabel.TextSize = 16
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
	rarityLabel.Parent = infoFrame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, -20, 0, 25)
	valueLabel.Position = UDim2.new(0, 10, 0, 35)
	valueLabel.BackgroundTransparency = 1

	-- Show mutation info if card has Error mutation
	if card.mutation and card.mutation == "Error" then
		valueLabel.Text = "Value: " .. card.value .. " coins ⚠️ (MUTATED - 2x Value!)"
		valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red for mutated cards
	else
		valueLabel.Text = "Value: " .. card.value .. " coins"
		valueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	end

	valueLabel.TextSize = 16
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.Parent = infoFrame

	local conditionLabel = Instance.new("TextLabel")
	conditionLabel.Size = UDim2.new(1, -20, 0, 25)
	conditionLabel.Position = UDim2.new(0, 10, 0, 55)
	conditionLabel.BackgroundTransparency = 1
	conditionLabel.Text = "Condition: " .. (card.condition or "Mint")
	conditionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	conditionLabel.TextSize = 14
	conditionLabel.Font = Enum.Font.Gotham
	conditionLabel.TextXAlignment = Enum.TextXAlignment.Left
	conditionLabel.Parent = infoFrame

	-- Add mutation indicator if card has Error mutation
	if card.mutation and card.mutation == "Error" then
		local mutationLabel = Instance.new("TextLabel")
		mutationLabel.Size = UDim2.new(1, -20, 0, 25)
		mutationLabel.Position = UDim2.new(0, 10, 0, 80)
		mutationLabel.BackgroundTransparency = 1
		mutationLabel.Text = "⚠️ MUTATION: Error - 2x Value!"
		mutationLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		mutationLabel.TextSize = 14
		mutationLabel.Font = Enum.Font.GothamBold
		mutationLabel.TextXAlignment = Enum.TextXAlignment.Left
		mutationLabel.Parent = infoFrame
	end

	-- Add glow effect for rare cards
	if card.rarity == "Rare" or card.rarity == "UltraRare" or card.rarity == "Secret" then
		self:AddGlowEffect(detailFrame, self:GetRarityColor(card.rarity))
	end
end

function CardClient:CheckSetProgression(uniqueCount)
	-- Define progression thresholds
	local progressionThresholds = {
		{level = 2, required = 5, message = "Collect 5 unique cards to advance to Level 2!"},
		{level = 3, required = 10, message = "Collect 10 unique cards to advance to Level 3!"},
		{level = 4, required = 15, message = "Collect 15 unique cards to advance to Level 4!"},
		{level = 5, required = 20, message = "Collect all 20 cards to become a Legend of the West!"}
	}

	-- Initialize if needed
	if not self.shownThresholds then
		self.shownThresholds = {}
	end

	-- Reset shown thresholds for levels we no longer meet
	for _, threshold in ipairs(progressionThresholds) do
		if uniqueCount < threshold.required and self.shownThresholds[threshold.level] then
			self.shownThresholds[threshold.level] = nil
		end
	end

	-- Check if player meets any threshold they haven't seen yet
	for _, threshold in ipairs(progressionThresholds) do
		if uniqueCount >= threshold.required and not self.shownThresholds[threshold.level] then
			self.shownThresholds[threshold.level] = true
			self:ShowLevelUpScreen(threshold.level, uniqueCount)
			return
		end
	end

	-- Show wait screen if player is close to next threshold
	for _, threshold in ipairs(progressionThresholds) do
		if uniqueCount < threshold.required and uniqueCount >= threshold.required - 3 then
			local remaining = threshold.required - uniqueCount
			if remaining > 0 then
				self:ShowWaitScreen(threshold.message, remaining, uniqueCount, threshold.required)
				return
			end
		end
	end
end

function CardClient:ShowWaitScreen(message, remaining, current, required)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	-- Don't show if already showing
	if screenGui:FindFirstChild("WaitScreen") then return end

	local waitFrame = Instance.new("Frame")
	waitFrame.Name = "WaitScreen"
	waitFrame.Size = UDim2.new(0, 450, 0, 250)
	waitFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
	waitFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
	waitFrame.BorderSizePixel = 0
	waitFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = waitFrame

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = waitFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		waitFrame:Destroy()
	end)

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 40)
	title.Position = UDim2.new(0, 10, 0, 15)
	title.BackgroundTransparency = 1
	title.Text = "📚 Set Collection Progress"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.Parent = waitFrame

	-- Progress bar background
	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(1, -40, 0, 20)
	progressBg.Position = UDim2.new(0, 20, 0, 70)
	progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = waitFrame

	local progressBgCorner = Instance.new("UICorner")
	progressBgCorner.CornerRadius = UDim.new(0, 10)
	progressBgCorner.Parent = progressBg

	-- Progress bar fill
	local progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.new(current / required, 0, 1, 0)
	progressFill.Position = UDim2.new(0, 0, 0, 0)
	progressFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBg

	local progressFillCorner = Instance.new("UICorner")
	progressFillCorner.CornerRadius = UDim.new(0, 10)
	progressFillCorner.Parent = progressFill

	-- Progress text
	local progressText = Instance.new("TextLabel")
	progressText.Size = UDim2.new(1, 0, 1, 0)
	progressText.Position = UDim2.new(0, 0, 0, 0)
	progressText.BackgroundTransparency = 1
	progressText.Text = current .. " / " .. required .. " cards"
	progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
	progressText.TextSize = 14
	progressText.Font = Enum.Font.GothamBold
	progressText.Parent = progressBg

	-- Message
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Size = UDim2.new(1, -40, 0, 60)
	messageLabel.Position = UDim2.new(0, 20, 0, 110)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = message .. "\n\nOnly " .. remaining .. " more cards needed!"
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.TextSize = 16
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextWrapped = true
	messageLabel.Parent = waitFrame

	-- Tip
	local tipLabel = Instance.new("TextLabel")
	tipLabel.Size = UDim2.new(1, -40, 0, 40)
	tipLabel.Position = UDim2.new(0, 20, 0, 180)
	tipLabel.BackgroundTransparency = 1
	tipLabel.Text = "💡 Tip: Open more packs or claim daily rewards to get new cards!"
	tipLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
	tipLabel.TextSize = 14
	tipLabel.Font = Enum.Font.Gotham
	tipLabel.TextWrapped = true
	tipLabel.Parent = waitFrame

	-- Auto-close after 8 seconds
	game:GetService("Debris"):AddItem(waitFrame, 8)
end

function CardClient:ShowLevelUpScreen(level, uniqueCount)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	local levelFrame = Instance.new("Frame")
	levelFrame.Name = "LevelUpScreen"
	levelFrame.Size = UDim2.new(0, 500, 0, 300)
	levelFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
	levelFrame.BackgroundColor3 = Color3.fromRGB(85, 50, 60)
	levelFrame.BorderSizePixel = 0
	levelFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = levelFrame

	-- Glow effect
	local glow = Instance.new("Frame")
	glow.Size = UDim2.new(1, 10, 1, 10)
	glow.Position = UDim2.new(0, -5, 0, -5)
	glow.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	glow.BackgroundTransparency = 0.8
	glow.Parent = levelFrame
	glow.ZIndex = levelFrame.ZIndex - 1

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(0, 15)
	glowCorner.Parent = glow

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Position = UDim2.new(0, 0, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = "🌟 LEVEL UP! 🌟"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.TextSize = 32
	title.Font = Enum.Font.GothamBold
	title.Parent = levelFrame

	local levelText = Instance.new("TextLabel")
	levelText.Size = UDim2.new(1, -40, 0, 40)
	levelText.Position = UDim2.new(0, 20, 0, 90)
	levelText.BackgroundTransparency = 1
	levelText.Text = "You reached Level " .. level .. "!"
	levelText.TextColor3 = Color3.fromRGB(255, 255, 255)
	levelText.TextSize = 24
	levelText.Font = Enum.Font.GothamBold
	levelText.Parent = levelFrame

	local progressText = Instance.new("TextLabel")
	progressText.Size = UDim2.new(1, -40, 0, 60)
	progressText.Position = UDim2.new(0, 20, 0, 140)
	progressText.BackgroundTransparency = 1
	progressText.Text = "Collected " .. uniqueCount .. " unique Wild West cards!\n\nKeep collecting to unlock more levels!"
	progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
	progressText.TextSize = 16
	progressText.Font = Enum.Font.Gotham
	progressText.TextWrapped = true
	progressText.Parent = levelFrame

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 120, 0, 35)
	closeButton.Position = UDim2.new(0.5, -60, 1, -55)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	closeButton.Text = "Awesome!"
	closeButton.TextColor3 = Color3.fromRGB(50, 50, 50)
	closeButton.TextSize = 16
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = levelFrame

	self:CreateButtonStyle(closeButton)

	closeButton.MouseButton1Click:Connect(function()
		levelFrame:Destroy()
	end)

	-- Auto-close after 10 seconds
	game:GetService("Debris"):AddItem(levelFrame, 10)
end

function CardClient:ShowPackOpeningAnimation(cards)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	local animFrame = Instance.new("Frame")
	animFrame.Name = "PackAnimation"
	animFrame.Size = UDim2.new(1, 0, 1, 0)
	animFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	animFrame.BackgroundTransparency = 0.3
	animFrame.Parent = screenGui

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, 400, 0, 50)
	titleLabel.Position = UDim2.new(0.5, -200, 0, 50)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🎁 Pack Opened! 🎁"
	titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	titleLabel.TextSize = 28
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = animFrame

	wait(1)

	for i, card in ipairs(cards) do
		local cardFrame = Instance.new("Frame")
		cardFrame.Size = UDim2.new(0, 250, 0, 350)
		cardFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
		cardFrame.BackgroundColor3 = Color3.fromRGB(60, 70, 95)
		cardFrame.Parent = animFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = cardFrame

		-- Card Image
		local cardImage = Instance.new("ImageLabel")
		cardImage.Size = UDim2.new(1, -20, 0, 200)
		cardImage.Position = UDim2.new(0, 10, 0, 10)
		cardImage.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		cardImage.Image = self.CardImages[card.name] or self.CardImages["default"]
		cardImage.ScaleType = Enum.ScaleType.Fit
		cardImage.Parent = cardFrame

		local imageCorner = Instance.new("UICorner")
		imageCorner.CornerRadius = UDim.new(0, 8)
		imageCorner.Parent = cardImage

		-- Placeholder if no image
		if cardImage.Image == "rbxassetid://0" then
			local placeholder = Instance.new("TextLabel")
			placeholder.Size = UDim2.new(1, 0, 1, 0)
			placeholder.BackgroundTransparency = 1
			placeholder.Text = "🎴"
			placeholder.TextColor3 = Color3.fromRGB(150, 150, 150)
			placeholder.TextSize = 64
			placeholder.Font = Enum.Font.Gotham
			placeholder.Parent = cardImage
		end

		-- Card Name
		local cardName = Instance.new("TextLabel")
		cardName.Size = UDim2.new(1, -20, 0, 40)
		cardName.Position = UDim2.new(0, 10, 0, 220)
		cardName.BackgroundTransparency = 1
		cardName.Text = card.name
		cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
		cardName.TextSize = 20
		cardName.Font = Enum.Font.GothamBold
		cardName.TextScaled = true
		cardName.TextWrapped = true
		cardName.Parent = cardFrame

		-- Rarity
		local rarityLabel = Instance.new("TextLabel")
		rarityLabel.Size = UDim2.new(1, -20, 0, 30)
		rarityLabel.Position = UDim2.new(0, 10, 0, 270)
		rarityLabel.BackgroundTransparency = 1

		-- Show mutation info if card has Error mutation
		if card.mutation and card.mutation == "Error" then
			rarityLabel.Text = card.rarity .. " • " .. card.value .. " coins ⚠️ MUTATED!"
			rarityLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red for mutated cards
		else
			rarityLabel.Text = card.rarity .. " • " .. card.value .. " coins"
			rarityLabel.TextColor3 = self:GetRarityColor(card.rarity)
		end

		rarityLabel.TextSize = 16
		rarityLabel.Font = Enum.Font.Gotham
		rarityLabel.Parent = cardFrame

		-- Rarity glow effect
		local rarityBar = Instance.new("Frame")
		rarityBar.Size = UDim2.new(1, 0, 0, 4)
		rarityBar.Position = UDim2.new(0, 0, 1, -4)
		rarityBar.BackgroundColor3 = self:GetRarityColor(card.rarity)
		rarityBar.BorderSizePixel = 0
		rarityBar.Parent = cardFrame

		-- Add glowing effect for rare cards in pack opening
		if card.rarity == "Rare" or card.rarity == "UltraRare" or card.rarity == "Secret" then
			self:AddGlowEffect(cardFrame, self:GetRarityColor(card.rarity))
		end

		-- Add mutation effects for Error mutation cards in pack opening
		if card.mutation and card.mutation == "Error" then
			self:AddMutationEffect(cardFrame, card)
		end

		-- Animate card appearance
		cardFrame.BackgroundTransparency = 1
		local tween = game:GetService("TweenService"):Create(cardFrame, 
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
			{BackgroundTransparency = 0})
		tween:Play()

		wait(1.2)
		cardFrame:Destroy()
	end

	animFrame:Destroy()
end

function CardClient:ShowDailyReward(reward)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	-- Create reward popup
	local rewardFrame = Instance.new("Frame")
	rewardFrame.Name = "DailyRewardPopup"
	rewardFrame.Size = UDim2.new(0, 300, 0, 200)
	rewardFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
	rewardFrame.BackgroundColor3 = Color3.fromRGB(50, 60, 85)
	rewardFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = rewardFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = "Daily Reward!"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.Parent = rewardFrame

	local rewardText = Instance.new("TextLabel")
	rewardText.Size = UDim2.new(1, -40, 0, 80)
	rewardText.Position = UDim2.new(0, 20, 0, 70)
	rewardText.BackgroundTransparency = 1
	rewardText.Text = "+" .. reward.coins .. " Coins\n+" .. reward.packs .. " Free Pack\nStreak Day " .. reward.day
	rewardText.TextColor3 = Color3.fromRGB(255, 255, 255)
	rewardText.TextSize = 16
	rewardText.Font = Enum.Font.Gotham
	rewardText.Parent = rewardFrame

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 100, 0, 30)
	closeButton.Position = UDim2.new(0.5, -50, 1, -50)
	closeButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	closeButton.Text = "Claim"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 16
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = rewardFrame

	self:CreateButtonStyle(closeButton)

	closeButton.MouseButton1Click:Connect(function()
		rewardFrame:Destroy()
	end)

	-- Auto-close after 5 seconds
	game:GetService("Debris"):AddItem(rewardFrame, 5)
end

function CardClient:ShowSaleNotification(saleData)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	-- Create sale notification
	local notificationFrame = Instance.new("Frame")
	notificationFrame.Name = "SaleNotification"
	notificationFrame.Size = UDim2.new(0, 250, 0, 80)
	notificationFrame.Position = UDim2.new(1, -270, 0, 100)
	notificationFrame.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	notificationFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notificationFrame

	local saleText = Instance.new("TextLabel")
	saleText.Size = UDim2.new(1, -20, 1, -20)
	saleText.Position = UDim2.new(0, 10, 0, 10)
	saleText.BackgroundTransparency = 1
	saleText.Text = "💰 SOLD!\n" .. saleData.cardName .. "\n+" .. saleData.sellPrice .. " coins"
	saleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	saleText.TextSize = 14
	saleText.Font = Enum.Font.GothamBold
	saleText.TextWrapped = true
	saleText.Parent = notificationFrame

	-- Animate notification
	notificationFrame.Position = UDim2.new(1, 20, 0, 100)
	local tweenIn = game:GetService("TweenService"):Create(notificationFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(1, -270, 0, 100)})

	tweenIn:Play()

	-- Auto-remove after 3 seconds
	game:GetService("Debris"):AddItem(notificationFrame, 3)
end

function CardClient:ShowCollectionReward(reward)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	-- Create collection reward popup (larger for special rewards)
	local rewardFrame = Instance.new("Frame")
	rewardFrame.Name = "CollectionRewardPopup"
	if reward.special then
		rewardFrame.Size = UDim2.new(0, 500, 0, 350)
		rewardFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
		rewardFrame.BackgroundColor3 = Color3.fromRGB(85, 50, 60) -- Special golden/red background
	else
		rewardFrame.Size = UDim2.new(0, 400, 0, 250)
		rewardFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
		rewardFrame.BackgroundColor3 = Color3.fromRGB(50, 60, 85)
	end
	rewardFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = rewardFrame

	-- Glow effect
	local glow = Instance.new("Frame")
	glow.Size = UDim2.new(1, 10, 1, 10)
	glow.Position = UDim2.new(0, -5, 0, -5)
	glow.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	glow.BackgroundTransparency = 0.8
	glow.Parent = rewardFrame
	glow.ZIndex = rewardFrame.ZIndex - 1

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(0, 15)
	glowCorner.Parent = glow

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0, 0, 0, 20)
	title.BackgroundTransparency = 1
	if reward.special then
		title.Text = "🌟 COLLECTION COMPLETE! 🌟"
		title.TextSize = 32
	else
		title.Text = "🏆 Collection Milestone! 🏆"
		title.TextSize = 24
	end
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.Font = Enum.Font.GothamBold
	title.Parent = rewardFrame

	local achievementName = Instance.new("TextLabel")
	achievementName.Size = UDim2.new(1, -40, 0, 30)
	achievementName.Position = UDim2.new(0, 20, 0, 80)
	achievementName.BackgroundTransparency = 1
	achievementName.Text = reward.name
	achievementName.TextColor3 = Color3.fromRGB(255, 255, 255)
	achievementName.TextSize = 20
	achievementName.Font = Enum.Font.GothamBold
	achievementName.Parent = rewardFrame

	local rewardText = Instance.new("TextLabel")
	if reward.special then
		rewardText.Size = UDim2.new(1, -40, 0, 120)
		rewardText.Position = UDim2.new(0, 20, 0, 120)
		rewardText.Text = "ALL " .. reward.threshold .. " WILD WEST CARDS COLLECTED!\n\nYou are now a TRUE LEGEND OF THE WEST!\n\n💰 +" .. reward.coins .. " Coins\n🎁 +" .. reward.packs .. " Free Packs\n🏆 Eternal Glory!"
		rewardText.TextSize = 18
	else
		rewardText.Size = UDim2.new(1, -40, 0, 60)
		rewardText.Position = UDim2.new(0, 20, 0, 120)
		rewardText.Text = reward.threshold .. " Unique Cards Collected!\n+" .. reward.coins .. " Coins\n+" .. reward.packs .. " Free Packs"
		rewardText.TextSize = 16
	end
	rewardText.BackgroundTransparency = 1
	rewardText.TextColor3 = Color3.fromRGB(255, 255, 255)
	rewardText.Font = Enum.Font.Gotham
	rewardText.Parent = rewardFrame

	local claimButton = Instance.new("TextButton")
	claimButton.Size = UDim2.new(0, 120, 0, 35)
	claimButton.Position = UDim2.new(0.5, -60, 1, -55)
	claimButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	claimButton.Text = "Awesome!"
	claimButton.TextColor3 = Color3.fromRGB(50, 50, 50)
	claimButton.TextSize = 16
	claimButton.Font = Enum.Font.GothamBold
	claimButton.Parent = rewardFrame

	self:CreateButtonStyle(claimButton)

	claimButton.MouseButton1Click:Connect(function()
		rewardFrame:Destroy()
	end)

	-- Auto-close after 8 seconds
	game:GetService("Debris"):AddItem(rewardFrame, 8)

	-- Animate appearance
	rewardFrame.BackgroundTransparency = 1
	local tween = game:GetService("TweenService"):Create(rewardFrame, 
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
		{BackgroundTransparency = 0})
	tween:Play()
end

function CardClient:ShowSetSaleNotification(result)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	-- Create set sale notification popup
	local notificationFrame = Instance.new("Frame")
	notificationFrame.Name = "SetSaleNotification"
	notificationFrame.Size = UDim2.new(0, 400, 0, 300)
	notificationFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
	notificationFrame.BackgroundColor3 = Color3.fromRGB(85, 50, 60)
	notificationFrame.BorderSizePixel = 0
	notificationFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notificationFrame

	-- Glow effect
	local glow = Instance.new("Frame")
	glow.Size = UDim2.new(1, 10, 1, 10)
	glow.Position = UDim2.new(0, -5, 0, -5)
	glow.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	glow.BackgroundTransparency = 0.8
	glow.Parent = notificationFrame
	glow.ZIndex = notificationFrame.ZIndex - 1

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(0, 15)
	glowCorner.Parent = glow

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Position = UDim2.new(0, 0, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = "🎯 COMPLETE SET SOLD! 🎯"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.TextSize = 28
	title.Font = Enum.Font.GothamBold
	title.Parent = notificationFrame

	local rewardText = Instance.new("TextLabel")
	rewardText.Size = UDim2.new(1, -40, 0, 120)
	rewardText.Position = UDim2.new(0, 20, 0, 90)
	rewardText.BackgroundTransparency = 1
	rewardText.Text = "You sold one complete Wild West set for 2x value!\n\n💰 Set Value: " .. result.setValue .. " coins\n🎯 Sale Price: " .. result.sellValue .. " coins\n📊 Duplicate cards preserved\n🏆 Total Sets Sold: " .. result.totalSetsSold .. "\n💎 Lifetime Set Value: " .. result.setSellingValue .. " coins"
	rewardText.TextColor3 = Color3.fromRGB(255, 255, 255)
	rewardText.TextSize = 16
	rewardText.Font = Enum.Font.Gotham
	rewardText.TextWrapped = true
	rewardText.Parent = notificationFrame

	local claimButton = Instance.new("TextButton")
	claimButton.Size = UDim2.new(0, 120, 0, 35)
	claimButton.Position = UDim2.new(0.5, -60, 1, -55)
	claimButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	claimButton.Text = "Awesome!"
	claimButton.TextColor3 = Color3.fromRGB(50, 50, 50)
	claimButton.TextSize = 16
	claimButton.Font = Enum.Font.GothamBold
	claimButton.Parent = notificationFrame

	self:CreateButtonStyle(claimButton)

	claimButton.MouseButton1Click:Connect(function()
		notificationFrame:Destroy()
	end)

	-- Auto-close after 8 seconds
	game:GetService("Debris"):AddItem(notificationFrame, 8)

	-- Force close after 12 seconds as backup
	spawn(function()
		wait(12)
		if notificationFrame and notificationFrame.Parent then
			notificationFrame:Destroy()
		end
	end)

	-- Animate appearance
	notificationFrame.BackgroundTransparency = 1
	local tween = game:GetService("TweenService"):Create(notificationFrame, 
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
		{BackgroundTransparency = 0})
	tween:Play()
end

function CardClient:ShowSetSellError(message, currentCards, requiredCards)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	-- Create error notification popup
	local notificationFrame = Instance.new("Frame")
	notificationFrame.Name = "SetSellError"
	notificationFrame.Size = UDim2.new(0, 350, 0, 200)
	notificationFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
	notificationFrame.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
	notificationFrame.BorderSizePixel = 0
	notificationFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notificationFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 15)
	title.BackgroundTransparency = 1
	title.Text = "❌ Cannot Sell Set"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.Parent = notificationFrame

	local errorText = Instance.new("TextLabel")
	errorText.Size = UDim2.new(1, -40, 0, 80)
	errorText.Position = UDim2.new(0, 20, 0, 65)
	errorText.BackgroundTransparency = 1
	errorText.Text = message .. "\n\nCurrent: " .. currentCards .. "/" .. requiredCards .. " unique cards"
	errorText.TextColor3 = Color3.fromRGB(255, 255, 255)
	errorText.TextSize = 14
	errorText.Font = Enum.Font.Gotham
	errorText.TextWrapped = true
	errorText.Parent = notificationFrame

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 100, 0, 30)
	closeButton.Position = UDim2.new(0.5, -50, 1, -40)
	closeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	closeButton.Text = "OK"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 14
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = notificationFrame

	self:CreateButtonStyle(closeButton)

	closeButton.MouseButton1Click:Connect(function()
		notificationFrame:Destroy()
	end)

	-- Auto-close after 8 seconds
	game:GetService("Debris"):AddItem(notificationFrame, 8)

	-- Force close after 12 seconds as backup
	spawn(function()
		wait(12)
		if notificationFrame and notificationFrame.Parent then
			notificationFrame:Destroy()
		end
	end)

	-- Animate appearance
	notificationFrame.BackgroundTransparency = 1
	local tween = game:GetService("TweenService"):Create(notificationFrame, 
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
		{BackgroundTransparency = 0})
	tween:Play()
end

-- Show loading screen first
function CardClient:ShowLoadingScreen()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LoadingScreen"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Create a compact centered frame instead of fullscreen
	local loadingFrame = Instance.new("Frame")
	loadingFrame.Name = "LoadingFrame"
	loadingFrame.Size = UDim2.new(0, 500, 0, 250)  -- Compact size
	loadingFrame.Position = UDim2.new(0.5, -250, 0.5, -125)  -- Centered
	loadingFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
	loadingFrame.BorderSizePixel = 2
	loadingFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
	loadingFrame.Parent = screenGui

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = loadingFrame

	-- Add a subtle background overlay
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.Parent = screenGui
	overlay.ZIndex = loadingFrame.ZIndex - 1

	local overlayCorner = Instance.new("UICorner")
	overlayCorner.CornerRadius = UDim.new(1, 0)
	overlayCorner.Parent = overlay

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 60)
	titleLabel.Position = UDim2.new(0, 10, 0, 20)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🤠 Wild West Card Collection 🤠"
	titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	titleLabel.TextSize = 24  -- Smaller text
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.Parent = loadingFrame

	local cardIcon = Instance.new("TextLabel")
	cardIcon.Size = UDim2.new(0, 40, 0, 40)
	cardIcon.Position = UDim2.new(0.5, -20, 0, 85)
	cardIcon.BackgroundTransparency = 1
	cardIcon.Text = "🃏"
	cardIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
	cardIcon.TextSize = 35
	cardIcon.Font = Enum.Font.GothamBold
	cardIcon.Parent = loadingFrame

	local loadingLabel = Instance.new("TextLabel")
	loadingLabel.Size = UDim2.new(1, -20, 0, 30)
	loadingLabel.Position = UDim2.new(0, 10, 0, 135)
	loadingLabel.BackgroundTransparency = 1
	loadingLabel.Text = "Loading your collection..."
	loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	loadingLabel.TextSize = 16
	loadingLabel.Font = Enum.Font.Gotham
	loadingLabel.Parent = loadingFrame

	local tipLabel = Instance.new("TextLabel")
	tipLabel.Size = UDim2.new(1, -20, 0, 40)
	tipLabel.Position = UDim2.new(0, 10, 0, 175)
	tipLabel.BackgroundTransparency = 1
	tipLabel.Text = "Collect cards • Battle NPCs • Build your display"
	tipLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	tipLabel.TextSize = 14
	tipLabel.Font = Enum.Font.Gotham
	tipLabel.TextWrapped = true
	tipLabel.Parent = loadingFrame

	-- Add subtle pulsing animation to the card icon
	local pulseTween = game:GetService("TweenService"):Create(cardIcon, 
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
		{TextTransparency = 0.3})
	pulseTween:Play()

	return screenGui
end

-- Initialize the UI when the script runs
local loadingScreen = CardClient:ShowLoadingScreen()

-- Create main UI but keep it disabled initially
local mainUI = CardClient:CreateMainUI()
mainUI.Enabled = false  -- Hide the main UI initially

-- Create navigation button but keep it hidden initially
CardClient:CreateNavigationButton()
local navGui = playerGui:FindFirstChild("CardNavigation")
if navGui then
	navGui.Enabled = false  -- Hide navigation initially
end

-- Load player's saved data
local function loadPlayerData()
	local getPlayerDataEvent = ReplicatedStorage:WaitForChild("GetPlayerDataEvent", 10)
	if getPlayerDataEvent then
		local playerData = getPlayerDataEvent:InvokeServer()
		if playerData then
			-- Load saved cards
			CardClient.PlayerCards = playerData.cards or {}

			-- Update UI with loaded data
			CardClient:UpdateCollection()

			-- Update coin display
			local screenGui = playerGui:FindFirstChild("CardGameUI")
			if screenGui then
				local coinsLabel = screenGui.MainFrame.TopBar.CoinsLabel
				coinsLabel.Text = "Coins: " .. (playerData.coins or 500)

				-- Update mutation counter
				local mutationLabel = screenGui.MainFrame.TopBar:FindFirstChild("MutationLabel")
				if mutationLabel then
					local mutatedCardCount = 0
					for _, card in ipairs(CardClient.PlayerCards) do
						if card.mutation and card.mutation == "Error" then
							mutatedCardCount = mutatedCardCount + 1
						end
					end

					if mutatedCardCount > 0 then
						mutationLabel.Text = "⚠️ Mutations: " .. mutatedCardCount
						mutationLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
					else
						mutationLabel.Text = "Mutations: 0"
						mutationLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
					end
				end
			end

			print("📊 Loaded", #CardClient.PlayerCards, "saved cards and", (playerData.coins or 500), "coins")
		end
	end

	-- Wait a moment to let players see the welcome screen, then transition
	wait(2)

	-- Remove loading screen with fade out animation
	if loadingScreen then
		local fadeOut = game:GetService("TweenService"):Create(loadingScreen.LoadingFrame, 
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
			{BackgroundTransparency = 1})
		fadeOut:Play()
		
		fadeOut.Completed:Connect(function()
			loadingScreen:Destroy()
		end)
	end

	-- Show navigation buttons after welcome screen fades
	local navGui = playerGui:FindFirstChild("CardNavigation")
	if navGui then
		navGui.Enabled = true
	end

	-- Keep main card UI hidden until player clicks "Open Cards" button
	-- The main UI will be shown when they click the navigation button
end

-- Load data after a short delay to ensure UI is ready
wait(1)
loadPlayerData()

-- Set up event listeners for server responses
local packOpenedEvent = ReplicatedStorage:WaitForChild("PackOpenedEvent", 10)
if packOpenedEvent then
	packOpenedEvent.OnClientEvent:Connect(function(result)
		-- Add cards to collection
		for _, card in ipairs(result.cards) do
			table.insert(CardClient.PlayerCards, card)
		end

		CardClient:ShowPackOpeningAnimation(result.cards)
		CardClient:UpdateCollection()

		-- Check for mutated cards and show notifications
		for _, card in ipairs(result.cards) do
			if card.mutation and card.mutation == "Error" then
				-- Small delay to show after pack opening animation
				wait(2)
				CardClient:ShowMutationNotification(card)
			end
		end

		-- Update UI with new coin count
		local screenGui = playerGui:FindFirstChild("CardGameUI")
		if screenGui then
			local coinsLabel = screenGui.MainFrame.TopBar.CoinsLabel
			coinsLabel.Text = "Coins: " .. result.newCoins
		end


	end)
end

local dailyRewardEvent = ReplicatedStorage:WaitForChild("DailyRewardReceivedEvent", 10)
if dailyRewardEvent then
	dailyRewardEvent.OnClientEvent:Connect(function(reward)
		print("Daily reward received:", reward.coins, "coins and", reward.packs, "packs")
		CardClient:ShowDailyReward(reward)

		-- Check for mutated cards in daily reward and show notifications
		if reward.freeCards then
			for _, card in ipairs(reward.freeCards) do
				if card.mutation and card.mutation == "Error" then
					-- Small delay to show after daily reward
					wait(1)
					CardClient:ShowMutationNotification(card)
				end
			end
		end

		-- Update coin display
		local screenGui = playerGui:FindFirstChild("CardGameUI")
		if screenGui then
			local coinsLabel = screenGui.MainFrame.TopBar.CoinsLabel
			coinsLabel.Text = "Coins: " .. reward.newCoins
		end
	end)
end

local cardSoldEvent = ReplicatedStorage:WaitForChild("CardSoldEvent", 10)
if cardSoldEvent then
	cardSoldEvent.OnClientEvent:Connect(function(saleData)
		-- Check if this is a claimed card or sold card
		if saleData and saleData.action == "claimed" then
			print("🎴 Card claimed client received:", saleData.cardName)

			-- Create a new card object using server data and add it to local collection immediately
			local newCard = saleData.cardData or {
				name = saleData.cardName,
				instanceId = saleData.instanceId or "claimed_" .. tick(),
				rarity = 1, -- Default rarity for claimed cards
				value = 10, -- Default value
				owner = game.Players.LocalPlayer.Name,
				timestamp = tick()
			}

			-- Ensure instanceId is set
			if not newCard.instanceId then
				newCard.instanceId = saleData.instanceId or "claimed_" .. tick()
			end

			-- Add to local collection
			table.insert(CardClient.PlayerCards, newCard)
			print("🎴 Added claimed card to local collection. Total cards:", #CardClient.PlayerCards)
			print("🎴 New card details:", newCard.name, "Rarity:", newCard.rarity, "Value:", newCard.value)

			-- Debug: Print first few cards in collection
			print("🎴 First 3 cards in collection:")
			for i = 1, math.min(3, #CardClient.PlayerCards) do
				local card = CardClient.PlayerCards[i]
				print("  ", i, ":", card.name, "(ID:", card.instanceId, ")")
			end

			-- Update UI immediately
			print("🎴 About to call UpdateCollection() with", #CardClient.PlayerCards, "cards")
			CardClient:UpdateCollection()
			print("🎴 UpdateCollection() completed")

			-- Force refresh the collection view
			local screenGui = playerGui:FindFirstChild("CardGameUI")
			if screenGui then
				local collection = screenGui.MainFrame:FindFirstChild("Collection")
				if collection then
					print("🎴 Collection frame found, forcing refresh...")
					-- Trigger a small delay then refresh again to ensure it updates
					spawn(function()
						wait(0.1)
						CardClient:UpdateCollection()
						print("🎴 Forced collection refresh completed")

						-- Debug: Print collection status
						print("🎴 Collection status after refresh:")
						print("  - Total cards in PlayerCards:", #CardClient.PlayerCards)
						print("  - Collection frame children:", collection:GetChildren())
						local cardGrid = collection:FindFirstChild("CardGrid")
						if cardGrid then
							print("  - CardGrid children:", #cardGrid:GetChildren())
						end
					end)
				else
					print("🎴 Collection frame not found")
				end
			else
				print("🎴 CardGameUI not found")
			end

			-- Update coin display
			local screenGui = playerGui:FindFirstChild("CardGameUI")
			if screenGui then
				local coinsLabel = screenGui.MainFrame.TopBar.CoinsLabel
				if saleData.newCoins then
					coinsLabel.Text = "Coins: " .. saleData.newCoins
				end

				-- Also update collection count in top bar if it exists
				local collectionLabel = screenGui.MainFrame.TopBar:FindFirstChild("CollectionLabel")
				if collectionLabel then
					collectionLabel.Text = "Collection: " .. #CardClient.PlayerCards .. " cards"
				end
			end

			-- Show claim notification
			if CardClient.ShowClaimNotification then
				CardClient:ShowClaimNotification(saleData.cardName)
			else
				-- Simple fallback notification
				print("🎴 SUCCESS: Claimed", saleData.cardName, "!")
			end

			-- Show a visible success message in the game world
			local successMessage = Instance.new("Message")
			successMessage.Text = "🎴 SUCCESS! Claimed " .. saleData.cardName .. " - Added to your collection!"
			successMessage.Parent = workspace

			-- Remove message after 5 seconds
			spawn(function()
				wait(5)
				if successMessage and successMessage.Parent then
					successMessage:Destroy()
				end
			end)

			-- Also try to refresh from server as backup (but don't wait for it)
			local getPlayerDataEvent = ReplicatedStorage:FindFirstChild("GetPlayerDataEvent")
			if getPlayerDataEvent then
				-- Fire and forget - don't wait for response
				spawn(function()
					local success, result = pcall(function()
						return getPlayerDataEvent:InvokeServer()
					end)
					if success and result then
						print("🎴 Server refresh completed as backup")
						-- Update local collection with server data
						if result.cards then
							print("🎴 Updating local collection with server data:", #result.cards, "cards")
							CardClient.PlayerCards = result.cards
							CardClient:UpdateCollection()
						end
					end
				end)
			end

			-- Request refresh of display table data
			local getDisplayCardsEvent = ReplicatedStorage:FindFirstChild("GetDisplayCardsEvent")
			if getDisplayCardsEvent then
				spawn(function()
					local success, result = pcall(function()
						return getDisplayCardsEvent:InvokeServer()
					end)
					if success then
						print("🎴 Display table refresh requested")
					end
				end)
			end
		else
			-- Handle sold cards (existing logic)
			print("🔍 Card sold client received:", saleData.cardName, "for", saleData.sellPrice, "coins")
			print("🔍 Looking for instanceId:", saleData.instanceId)
			print("🔍 Collection has", #CardClient.PlayerCards, "cards")

			-- Remove card from local collection using instanceId
			local foundCard = false
			for i, card in ipairs(CardClient.PlayerCards) do
				print("🔍 Checking card", i, ":", card.name, "instanceId:", card.instanceId)
				if card.instanceId == saleData.instanceId then
					print("✅ Found matching card! Removing from position", i)
					table.remove(CardClient.PlayerCards, i)
					foundCard = true
					break
				end
			end

			if not foundCard then
				print("❌ Could not find card with instanceId:", saleData.instanceId)
			end

			print("🔍 Collection now has", #CardClient.PlayerCards, "cards")

			-- Update UI
			CardClient:UpdateCollection()

			-- Update coin display
			local screenGui = playerGui:FindFirstChild("CardGameUI")
			if screenGui then
				local coinsLabel = screenGui.MainFrame.TopBar.CoinsLabel
				coinsLabel.Text = "Coins: " .. saleData.newCoins
			end

			-- Show sale notification
			CardClient:ShowSaleNotification(saleData)
		end
	end)
end

local collectionRewardEvent = ReplicatedStorage:WaitForChild("CollectionRewardEvent", 10)
if collectionRewardEvent then
	collectionRewardEvent.OnClientEvent:Connect(function(reward)
		print("Collection reward earned:", reward.name, "for", reward.threshold, "unique cards")
		CardClient:ShowCollectionReward(reward)

		-- Update coin display
		local screenGui = playerGui:FindFirstChild("CardGameUI")
		if screenGui then
			local coinsLabel = screenGui.MainFrame.TopBar.CoinsLabel
			local currentCoins = tonumber(coinsLabel.Text:match("%d+")) or 0
			coinsLabel.Text = "Coins: " .. (currentCoins + reward.coins)
		end
	end)
end

local setSoldEvent = ReplicatedStorage:WaitForChild("SetSoldEvent", 10)
if setSoldEvent then
	setSoldEvent.OnClientEvent:Connect(function(result)
		print("🎯 SetSoldEvent received:", result)

		if result.success == false then
			-- Set selling failed - show error message
			print("❌ Set selling failed:", result.message)
			CardClient:ShowSetSellError(result.message, result.currentCards, result.requiredCards)
		else
			-- Set selling successful
			print("🎯 Set sold successfully for", result.sellValue, "coins!")
			print("📊 Total sets sold:", result.totalSetsSold, "Total value from set selling:", result.setSellingValue)

			-- Remove only one copy of each unique card from local collection
			local uniqueCardIds = {}
			local cardsToRemove = {}

			-- First pass: identify which unique cards to remove
			for _, card in ipairs(CardClient.PlayerCards) do
				if not uniqueCardIds[card.id] then
					uniqueCardIds[card.id] = true
					table.insert(cardsToRemove, card.id)
				end
			end

			-- Second pass: remove one copy of each unique card
			for i = #CardClient.PlayerCards, 1, -1 do
				local card = CardClient.PlayerCards[i]
				for j, cardIdToRemove in ipairs(cardsToRemove) do
					if card.id == cardIdToRemove then
						table.remove(CardClient.PlayerCards, i)
						table.remove(cardsToRemove, j)
						break
					end
				end
			end

			print("📊 Removed", 20, "unique cards from client, kept", #CardClient.PlayerCards, "duplicate cards")

			-- Show special set sale notification
			CardClient:ShowSetSaleNotification(result)

			-- Update coin display immediately after set sale
			local screenGui = playerGui:FindFirstChild("CardGameUI")
			if screenGui then
				local coinsLabel = screenGui.MainFrame.TopBar.CoinsLabel
				if coinsLabel then
					-- Use the newCoins value from the server result
					coinsLabel.Text = "Coins: " .. result.newCoins
					print("💰 Updated coins display after set sale to:", result.newCoins)
				end
			end

			-- Update UI
			CardClient:UpdateCollection()
		end
	end)
end

-- Handle display table updates
local getDisplayCardsEvent = ReplicatedStorage:WaitForChild("GetDisplayCardsEvent", 10)
if getDisplayCardsEvent then
	getDisplayCardsEvent.OnClientEvent:Connect(function(displayedCards)
		print("🏠 Received display table update with", #displayedCards, "cards")
		CardClient.DisplayedCards = displayedCards

		-- Update display if currently open
		if CardClient.UpdateDisplayFunction then
			print("🔄 Calling update function for open display table")
			CardClient.UpdateDisplayFunction()
		else
			print("📱 Display table not currently open, stored data for later")
		end
	end)
end

-- Handle table assignment with retry system
local function connectToTableAssignment()
	local tableAssignmentEvent = ReplicatedStorage:FindFirstChild("TableAssignmentEvent")
	if tableAssignmentEvent then
		print("✅ TableAssignmentEvent found, connecting...")
		tableAssignmentEvent.OnClientEvent:Connect(function(tableNumber)
			print("🎯 Received table assignment:", tableNumber)
			CardClient:UpdateDisplayTableButton(tableNumber)

			-- Update server status
			if tableNumber then
				CardClient:UpdateServerStatus("✅ Connected to Table " .. tableNumber, Color3.fromRGB(100, 255, 100))
				-- Hide request button when table is assigned
				if CardClient.RequestTableButton then
					CardClient.RequestTableButton.Visible = false
				end
			else
				CardClient:UpdateServerStatus("⚠️ Overflow table assigned", Color3.fromRGB(255, 200, 100))
				-- Hide request button when table is assigned
				if CardClient.RequestTableButton then
					CardClient.RequestTableButton.Visible = false
				end
			end
		end)

		-- Fallback: if no assignment received within 15 seconds, show waiting status
		spawn(function()
			wait(15)
			if not CardClient.DisplayTableButton or CardClient.DisplayTableButton.Text == "🏠 Display Table" then
				print("⏰ No table assignment received, showing waiting status")
				CardClient:UpdateServerStatus("⏰ Waiting for table assignment...", Color3.fromRGB(255, 200, 100))
			end
		end)

		return true
	else
		print("❌ TableAssignmentEvent not found, will retry...")
		return false
	end
end

-- Try to connect immediately, then retry every 5 seconds
spawn(function()
	local connected = false
	local attempts = 0
	local maxAttempts = 12 -- Try for 1 minute total

	while not connected and attempts < maxAttempts do
		if attempts == 0 then
			print("🔄 Attempting to connect to TableAssignmentEvent...")
		else
			print("🔄 Retry attempt", attempts, "for TableAssignmentEvent...")
		end

		connected = connectToTableAssignment()
		attempts = attempts + 1

		if not connected then
			wait(5) -- Wait 5 seconds before retry
		end
	end

	if not connected then
		print("❌ Failed to connect to TableAssignmentEvent after", maxAttempts, "attempts")
		CardClient:UpdateServerStatus("❌ Connection failed after 1 minute", Color3.fromRGB(255, 100, 100))

		-- Show manual request button prominently
		if CardClient.RequestTableButton then
			CardClient.RequestTableButton.Visible = true
			CardClient.RequestTableButton.Text = "🆘 MANUAL TABLE REQUEST"
			CardClient.RequestTableButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		end
	end
end)

-- Handle server capacity updates with retry system
local function connectToServerCapacity()
	local serverCapacityEvent = ReplicatedStorage:FindFirstChild("ServerCapacityEvent")
	if serverCapacityEvent then
		print("✅ ServerCapacityEvent found, connecting...")
		serverCapacityEvent.OnClientEvent:Connect(function(capacityData)
			print("📊 Received server capacity update")

			-- Update status with capacity info (removed player count display)
			if capacityData.isFull then
				CardClient:UpdateServerStatus("Server Full", Color3.fromRGB(255, 100, 100))
			else
				CardClient:UpdateServerStatus("Server Available", Color3.fromRGB(100, 255, 100))
			end
		end)
		return true
	else
		print("❌ ServerCapacityEvent not found, will retry...")
		return false
	end
end

-- Try to connect to server capacity updates
spawn(function()
	local connected = false
	local attempts = 0
	local maxAttempts = 12 -- Try for 1 minute total

	while not connected and attempts < maxAttempts do
		if attempts == 0 then
			print("🔄 Attempting to connect to ServerCapacityEvent...")
		else
			print("🔄 Retry attempt", attempts, "for ServerCapacityEvent...")
		end

		connected = connectToServerCapacity()
		attempts = attempts + 1

		if not connected then
			wait(5) -- Wait 5 seconds before retry
		end
	end

	if not connected then
		print("❌ Failed to connect to ServerCapacityEvent after", maxAttempts, "attempts")
	end
end)

function CardClient:ShowMutationNotification(card)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	-- Create mutation notification popup
	local notificationFrame = Instance.new("Frame")
	notificationFrame.Name = "MutationNotification"
	notificationFrame.Size = UDim2.new(0, 400, 0, 200)
	notificationFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
	notificationFrame.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
	notificationFrame.BorderSizePixel = 0
	notificationFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notificationFrame

	-- Glow effect
	local glow = Instance.new("Frame")
	glow.Size = UDim2.new(1, 10, 1, 10)
	glow.Position = UDim2.new(0, -5, 0, -5)
	glow.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	glow.BackgroundTransparency = 0.8
	glow.Parent = notificationFrame
	glow.ZIndex = notificationFrame.ZIndex - 1

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(0, 15)
	glowCorner.Parent = glow

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0, 0, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = "⚠️ MUTATION DETECTED! ⚠️"
	title.TextColor3 = Color3.fromRGB(255, 255, 0)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.Parent = notificationFrame

	local cardName = Instance.new("TextLabel")
	cardName.Size = UDim2.new(1, -40, 0, 30)
	cardName.Position = UDim2.new(0, 20, 0, 80)
	cardName.BackgroundTransparency = 1
	cardName.Text = card.name
	cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
	cardName.TextSize = 18
	cardName.Font = Enum.Font.GothamBold
	cardName.Parent = notificationFrame

	local mutationText = Instance.new("TextLabel")
	mutationText.Size = UDim2.new(1, -40, 0, 60)
	mutationText.Position = UDim2.new(0, 20, 0, 120)
	mutationText.BackgroundTransparency = 1
	mutationText.Text = "This card has the ERROR mutation!\nValue increased from " .. (card.originalValue or card.value/2) .. " to " .. card.value .. " coins!\n(2x Value Multiplier)"
	mutationText.TextColor3 = Color3.fromRGB(255, 255, 255)
	mutationText.TextSize = 14
	mutationText.Font = Enum.Font.Gotham
	mutationText.TextWrapped = true
	mutationText.Parent = notificationFrame

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 120, 0, 35)
	closeButton.Position = UDim2.new(0.5, -60, 1, -45)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	closeButton.Text = "Incredible!"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 16
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = notificationFrame

	self:CreateButtonStyle(closeButton)

	closeButton.MouseButton1Click:Connect(function()
		notificationFrame:Destroy()
	end)

	-- Auto-close after 8 seconds
	game:GetService("Debris"):AddItem(notificationFrame, 8)

	-- Force close after 10 seconds as backup
	spawn(function()
		wait(10)
		if notificationFrame and notificationFrame.Parent then
			notificationFrame:Destroy()
		end
	end)

	-- Animate appearance
	notificationFrame.BackgroundTransparency = 1
	local tween = game:GetService("TweenService"):Create(notificationFrame, 
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
		{BackgroundTransparency = 0})
	tween:Play()
end

function CardClient:ShowSetSaleNotification(result)
	local screenGui = playerGui:FindFirstChild("CardGameUI")
	if not screenGui then return end

	-- Create set sale celebration notification
	local notificationFrame = Instance.new("Frame")
	notificationFrame.Name = "SetSaleNotification"
	notificationFrame.Size = UDim2.new(0, 500, 0, 300)
	notificationFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
	notificationFrame.BackgroundColor3 = Color3.fromRGB(85, 50, 60)
	notificationFrame.BorderSizePixel = 0
	notificationFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notificationFrame

	-- Glow effect
	local glow = Instance.new("Frame")
	glow.Size = UDim2.new(1, 10, 1, 10)
	glow.Position = UDim2.new(0, -5, 0, -5)
	glow.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	glow.BackgroundTransparency = 0.8
	glow.Parent = notificationFrame
	glow.ZIndex = notificationFrame.ZIndex - 1

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(0, 15)
	glowCorner.Parent = glow

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Position = UDim2.new(0, 0, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = "🎯 COMPLETE SET SOLD! 🎯"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.TextSize = 28
	title.Font = Enum.Font.GothamBold
	title.Parent = notificationFrame

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, 0, 0, 40)
	subtitle.Position = UDim2.new(0, 0, 0, 80)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Congratulations! You sold a complete Wild West set for 2x value!"
	subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	subtitle.TextSize = 18
	subtitle.Font = Enum.Font.GothamBold
	subtitle.Parent = notificationFrame

	local detailsFrame = Instance.new("Frame")
	detailsFrame.Size = UDim2.new(1, -40, 0, 120)
	detailsFrame.Position = UDim2.new(0, 20, 0, 130)
	detailsFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
	detailsFrame.Parent = notificationFrame

	local detailsCorner = Instance.new("UICorner")
	detailsCorner.CornerRadius = UDim.new(0, 8)
	detailsCorner.Parent = detailsFrame

	local setValueLabel = Instance.new("TextLabel")
	setValueLabel.Size = UDim2.new(1, -20, 0, 25)
	setValueLabel.Position = UDim2.new(0, 10, 0, 10)
	setValueLabel.BackgroundTransparency = 1
	setValueLabel.Text = "💰 Set Value: " .. result.setValue .. " coins"
	setValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	setValueLabel.TextSize = 16
	setValueLabel.Font = Enum.Font.Gotham
	setValueLabel.TextXAlignment = Enum.TextXAlignment.Left
	setValueLabel.Parent = detailsFrame

	local saleValueLabel = Instance.new("TextLabel")
	saleValueLabel.Size = UDim2.new(1, -20, 0, 25)
	saleValueLabel.Position = UDim2.new(0, 10, 0, 40)
	saleValueLabel.BackgroundTransparency = 1
	saleValueLabel.Text = "🎯 Sale Price: " .. result.sellValue .. " coins (2x Value!)"
	saleValueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	saleValueLabel.TextSize = 16
	saleValueLabel.Font = Enum.Font.GothamBold
	saleValueLabel.TextXAlignment = Enum.TextXAlignment.Left
	saleValueLabel.Parent = detailsFrame

	local totalSetsLabel = Instance.new("TextLabel")
	totalSetsLabel.Size = UDim2.new(1, -20, 0, 25)
	totalSetsLabel.Position = UDim2.new(0, 10, 0, 70)
	totalSetsLabel.BackgroundTransparency = 1
	totalSetsLabel.Text = "🏆 Total Sets Sold: " .. result.totalSetsSold
	totalSetsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	totalSetsLabel.TextSize = 16
	saleValueLabel.Font = Enum.Font.Gotham
	totalSetsLabel.TextXAlignment = Enum.TextXAlignment.Left
	totalSetsLabel.Parent = detailsFrame

	local lifetimeValueLabel = Instance.new("TextLabel")
	lifetimeValueLabel.Size = UDim2.new(1, -20, 0, 25)
	lifetimeValueLabel.Position = UDim2.new(0, 10, 0, 100)
	lifetimeValueLabel.BackgroundTransparency = 1
	lifetimeValueLabel.Text = "💎 Lifetime Set Value: " .. result.setSellingValue .. " coins"
	lifetimeValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	lifetimeValueLabel.TextSize = 16
	lifetimeValueLabel.Font = Enum.Font.Gotham
	lifetimeValueLabel.TextXAlignment = Enum.TextXAlignment.Left
	lifetimeValueLabel.Parent = detailsFrame

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 120, 0, 35)
	closeButton.Position = UDim2.new(0.5, -60, 1, -45)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	closeButton.Text = "Incredible!"
	closeButton.TextColor3 = Color3.fromRGB(50, 50, 50)
	closeButton.TextSize = 16
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = notificationFrame

	self:CreateButtonStyle(closeButton)

	closeButton.MouseButton1Click:Connect(function()
		notificationFrame:Destroy()
	end)

	-- Auto-close after 10 seconds
	game:GetService("Debris"):AddItem(notificationFrame, 10)

	-- Force close after 12 seconds as backup
	spawn(function()
		wait(12)
		if notificationFrame and notificationFrame.Parent then
			notificationFrame:Destroy()
		end
	end)

	-- Animate appearance
	notificationFrame.BackgroundTransparency = 1
	local tween = game:GetService("TweenService"):Create(notificationFrame, 
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
		{BackgroundTransparency = 0})
	tween:Play()

	-- Add some celebration particles
	for i = 1, 10 do
		local particle = Instance.new("Frame")
		particle.Size = UDim2.new(0, 4, 0, 4)
		particle.Position = UDim2.new(0, math.random(20, 480), 0, math.random(20, 280))
		particle.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
		particle.BorderSizePixel = 0
		particle.ZIndex = notificationFrame.ZIndex + 1
		particle.Parent = notificationFrame

		local particleCorner = Instance.new("UICorner")
		particleCorner.CornerRadius = UDim.new(0.5, 0)
		particleCorner.Parent = particle

		-- Animate particle floating up
		local particleTween = TweenService:Create(particle,
			TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{Position = UDim2.new(0, math.random(20, 480), 0, -50), BackgroundTransparency = 1}
		)
		particleTween:Play()

		-- Remove particle after animation
		particleTween.Completed:Connect(function()
			particle:Destroy()
		end)
	end
end

function CardClient:OpenDisplayTable()
	print("🏠 Opening display table. Current displayed cards:", self.DisplayedCards and #self.DisplayedCards or 0)

	-- Create display table popup as independent ScreenGui
	local displayGui = Instance.new("ScreenGui")
	displayGui.Name = "DisplayTableGUI"
	displayGui.ResetOnSpawn = false
	displayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	displayGui.Parent = playerGui

	local displayFrame = Instance.new("Frame")
	displayFrame.Name = "DisplayTablePopup"
	displayFrame.Size = UDim2.new(0, 800, 0, 600)
	displayFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
	displayFrame.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
	displayFrame.BorderSizePixel = 0
	displayFrame.Parent = displayGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = displayFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0, 0, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "🏠 Card Display Table"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.Parent = displayFrame

	-- Money earning display
	local moneyDisplay = Instance.new("TextLabel")
	moneyDisplay.Size = UDim2.new(0, 300, 0, 30)
	moneyDisplay.Position = UDim2.new(0, 20, 0, 60)
	moneyDisplay.BackgroundTransparency = 1
	moneyDisplay.Text = "💰 Earning: 0 coins/sec (0 cards displayed)"
	moneyDisplay.TextColor3 = Color3.fromRGB(100, 255, 100)
	moneyDisplay.TextSize = 16
	moneyDisplay.Font = Enum.Font.Gotham
	moneyDisplay.Parent = displayFrame

	-- Store reference for updates
	self.MoneyDisplayLabel = moneyDisplay

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = displayFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		displayFrame:Destroy()
	end)

	-- Display area for cards
	local displayArea = Instance.new("ScrollingFrame")
	displayArea.Name = "DisplayArea"
	displayArea.Size = UDim2.new(1, -40, 1, -100)
	displayArea.Position = UDim2.new(0, 20, 0, 70)
	displayArea.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
	displayArea.BorderSizePixel = 0
	displayArea.CanvasSize = UDim2.new(0, 0, 2, 0)
	displayArea.ScrollBarThickness = 6
	displayArea.Parent = displayFrame
	print("📦 Display area created. Size:", displayArea.Size, "Position:", displayArea.Position, "CanvasSize:", displayArea.CanvasSize)

	local displayCorner = Instance.new("UICorner")
	displayCorner.CornerRadius = UDim.new(0, 8)
	displayCorner.Parent = displayArea

	-- Grid layout for displayed cards
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 120, 0, 160)
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = displayArea

	-- Update display function
	local function updateDisplay()
		print("🔄 Updating display table with", self.DisplayedCards and #self.DisplayedCards or 0, "cards")

		-- Clear existing cards and layouts
		for _, child in pairs(displayArea:GetChildren()) do
			child:Destroy()
		end

		-- Recreate grid layout
		local newGridLayout = Instance.new("UIGridLayout")
		newGridLayout.CellSize = UDim2.new(0, 120, 0, 160)
		newGridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
		newGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		newGridLayout.Parent = displayArea

		-- Force layout update
		displayArea.CanvasSize = UDim2.new(0, 0, 2, 0)
		print("📐 Grid layout created, canvas size set")

		-- Add displayed cards
		if self.DisplayedCards and #self.DisplayedCards > 0 then
			print("📋 Adding", #self.DisplayedCards, "displayed cards")
			for i, displayCard in ipairs(self.DisplayedCards) do
				print("📋 Creating display card", i, ":", displayCard.card.name, "by", displayCard.playerName)
				self:CreateDisplayCard(displayArea, displayCard, i)
			end
			print("📋 Finished adding cards. Display area now has", #displayArea:GetChildren(), "children")
		else
			print("📋 No displayed cards to show")
		end

		-- Add "Add Card" button if player has cards and space
		if self.PlayerCards and #self.PlayerCards > 0 then
			local currentDisplayCount = self.DisplayedCards and #self.DisplayedCards or 0
			if currentDisplayCount < 10 then
				print("➕ Adding 'Add Card' button (current:", currentDisplayCount, "/10)")
				self:CreateAddCardButton(displayArea, currentDisplayCount + 1)
			end
		end

		-- Test frame removed for cleaner UI
	end

	-- Initial update
	updateDisplay()

	-- Store reference for updates
	self.CurrentDisplayFrame = displayFrame
	self.UpdateDisplayFunction = updateDisplay

	-- Update money display
	self:UpdateMoneyDisplay()
end

-- Handle physical display table interaction
local function setupDisplayTableInteraction()
	-- Wait for all display tables to be created
	wait(5) -- Give server time to create tables

	-- Find all display tables
	for i = 1, 10 do
		local tableName = "CardDisplayTable" .. i
		local displayTable = workspace:FindFirstChild(tableName)

		if displayTable then
			local clickDetector = displayTable:FindFirstChild("ClickDetector")
			if clickDetector then
				clickDetector.MouseClick:Connect(function(player)
					if player == game.Players.LocalPlayer then
						print("🏠 Display table", i, "clicked - opening display table UI")
						CardClient:OpenDisplayTable()
					end
				end)
				print("✅ Set up interaction for table", i)
			end
		else
			print("❌ Could not find table:", tableName)
		end
	end
end

-- Set up display table interaction when player loads
spawn(function()
	wait(3) -- Wait for workspace to load
	setupDisplayTableInteraction()
end)

function CardClient:CreateDisplayCard(parent, displayCard, index)
	print("🎴 Creating display card frame for:", displayCard.card.name)
	local cardFrame = Instance.new("Frame")
	cardFrame.Name = "DisplayCard" .. index
	cardFrame.Size = UDim2.new(0, 120, 0, 160)
	cardFrame.BackgroundColor3 = Color3.fromRGB(60, 70, 95)
	cardFrame.LayoutOrder = index
	cardFrame.Parent = parent
	print("🎴 Card frame parented to display area. Frame visible:", cardFrame.Visible, "Size:", cardFrame.Size)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = cardFrame

	-- Card image
	local cardImage = Instance.new("ImageLabel")
	cardImage.Size = UDim2.new(1, -10, 0, 80)
	cardImage.Position = UDim2.new(0, 5, 0, 5)
	cardImage.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	cardImage.Image = self.CardImages[displayCard.card.name] or self.CardImages["default"]
	cardImage.ScaleType = Enum.ScaleType.Fit
	cardImage.Parent = cardFrame

	local imageCorner = Instance.new("UICorner")
	imageCorner.CornerRadius = UDim.new(0, 4)
	imageCorner.Parent = cardImage

	-- Card name
	local cardName = Instance.new("TextLabel")
	cardName.Size = UDim2.new(1, -10, 0, 30)
	cardName.Position = UDim2.new(0, 5, 0, 90)
	cardName.BackgroundTransparency = 1
	cardName.Text = displayCard.card.name
	cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
	cardName.TextSize = 10
	cardName.Font = Enum.Font.GothamBold
	cardName.TextScaled = true
	cardName.TextWrapped = true
	cardName.Parent = cardFrame

	-- Player name
	local playerName = Instance.new("TextLabel")
	playerName.Size = UDim2.new(1, -10, 0, 20)
	playerName.Position = UDim2.new(0, 5, 0, 125)
	playerName.BackgroundTransparency = 1
	playerName.Text = "by " .. displayCard.playerName
	playerName.TextColor3 = Color3.fromRGB(200, 200, 200)
	playerName.TextSize = 8
	playerName.Font = Enum.Font.Gotham
	playerName.TextScaled = true
	playerName.Parent = cardFrame

	-- Value
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, -10, 0, 15)
	valueLabel.Position = UDim2.new(0, 5, 0, 145)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = displayCard.card.value .. " coins"
	valueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	valueLabel.TextSize = 8
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.Parent = cardFrame

	-- Mutation indicator
	if displayCard.card.mutation and displayCard.card.mutation == "Error" then
		local mutationLabel = Instance.new("TextLabel")
		mutationLabel.Size = UDim2.new(0, 20, 0, 20)
		mutationLabel.Position = UDim2.new(1, -25, 0, 5)
		mutationLabel.BackgroundTransparency = 1
		mutationLabel.Text = "⚠️"
		mutationLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		mutationLabel.TextSize = 12
		mutationLabel.Font = Enum.Font.GothamBold
		mutationLabel.Parent = cardFrame
	end

	-- Remove button (only for own cards)
	if displayCard.playerName == player.Name then
		local removeButton = Instance.new("TextButton")
		removeButton.Size = UDim2.new(0, 20, 0, 20)
		removeButton.Position = UDim2.new(0, 5, 0, 5)
		removeButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
		removeButton.Text = "×"
		removeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		removeButton.TextSize = 14
		removeButton.Font = Enum.Font.GothamBold
		removeButton.Parent = cardFrame

		local removeCorner = Instance.new("UICorner")
		removeCorner.CornerRadius = UDim.new(0, 4)
		removeCorner.Parent = removeButton

		removeButton.MouseButton1Click:Connect(function()
			self:RemoveCardFromDisplay(displayCard.card.instanceId)
		end)
	end

	print("✅ Display card frame created successfully for:", displayCard.card.name)
end

function CardClient:CreateAddCardButton(parent, index)
	local addButton = Instance.new("TextButton")
	addButton.Name = "AddCardButton"
	addButton.Size = UDim2.new(0, 120, 0, 160)
	addButton.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
	addButton.Text = "➕ Add Card\n(" .. (#self.PlayerCards) .. " available)"
	addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	addButton.TextSize = 12
	addButton.Font = Enum.Font.GothamBold
	addButton.TextWrapped = true
	addButton.LayoutOrder = index
	addButton.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = addButton

	addButton.MouseButton1Click:Connect(function()
		self:ShowAddCardMenu()
	end)
end

function CardClient:ShowAddCardMenu()
	print("🎴 ShowAddCardMenu called. PlayerCards count:", self.PlayerCards and #self.PlayerCards or 0)

	-- Create add card menu as independent GUI
	local menuFrame = Instance.new("Frame")
	menuFrame.Name = "AddCardMenu"
	menuFrame.Size = UDim2.new(0, 600, 0, 400)
	menuFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
	menuFrame.BackgroundColor3 = Color3.fromRGB(50, 60, 85)
	menuFrame.BorderSizePixel = 0
	menuFrame.ZIndex = 1000 -- High Z-index to appear above other UI

	-- Create independent ScreenGui for the add card menu
	local addCardGUI = Instance.new("ScreenGui")
	addCardGUI.Name = "AddCardGUI"
	addCardGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	addCardGUI.Parent = playerGui

	menuFrame.Parent = addCardGUI

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	-- corner.ZIndex = 1001 -- Higher than menu frame (UICorner doesn't support ZIndex)
	corner.Parent = menuFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "Select a card to display:"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.ZIndex = 1001 -- Higher than menu frame
	title.Parent = menuFrame

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.ZIndex = 1001 -- Higher than menu frame
	closeButton.Parent = menuFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	-- closeCorner.ZIndex = 1001 -- Higher than close button (UICorner doesn't support ZIndex)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		print("🎴 Close button clicked, destroying AddCardGUI")
		addCardGUI:Destroy()
	end)

	-- Scrollable card list
	local cardList = Instance.new("ScrollingFrame")
	cardList.Size = UDim2.new(1, -20, 1, -60)
	cardList.Position = UDim2.new(0, 10, 0, 50)
	cardList.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
	cardList.BorderSizePixel = 0
	cardList.CanvasSize = UDim2.new(0, 0, 2, 0)
	cardList.ScrollBarThickness = 6
	cardList.ZIndex = 1001 -- Higher than menu frame
	cardList.Parent = menuFrame

	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 8)
	-- listCorner.ZIndex = 1001 -- Higher than card list (UICorner doesn't support ZIndex)
	listCorner.Parent = cardList

	-- Grid layout
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 100, 0, 120)
	gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	-- gridLayout.ZIndex = 1001 -- Higher than card list (UIGridLayout doesn't support ZIndex)
	gridLayout.Parent = cardList

	-- Add player's cards
	if self.PlayerCards and #self.PlayerCards > 0 then
		print("🎴 Adding", #self.PlayerCards, "cards to the menu")
		print("🎴 First card sample:", self.PlayerCards[1] and self.PlayerCards[1].name or "nil")
		for i, card in ipairs(self.PlayerCards) do
			print("🎴 Creating card button", i, "for card:", card.name, "instanceId:", card.instanceId)
			local cardButton = Instance.new("TextButton")
			cardButton.Size = UDim2.new(0, 100, 0, 120)
			cardButton.BackgroundColor3 = Color3.fromRGB(60, 70, 95)
			cardButton.Text = ""
			cardButton.LayoutOrder = i
			cardButton.ZIndex = 1002 -- Higher than card button
			cardButton.Parent = cardList

			local cardCorner = Instance.new("UICorner")
			cardCorner.CornerRadius = UDim.new(0, 6)
			-- cardCorner.ZIndex = 1002 -- Higher than card button (UICorner doesn't support ZIndex)
			cardCorner.Parent = cardButton

			-- Card image
			local cardImage = Instance.new("ImageLabel")
			cardImage.Size = UDim2.new(1, -6, 0, 60)
			cardImage.Position = UDim2.new(0, 3, 0, 3)
			cardImage.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
			cardImage.Image = self.CardImages[card.name] or self.CardImages["default"]
			cardImage.ScaleType = Enum.ScaleType.Fit
			cardImage.ZIndex = 1003 -- Higher than card image
			cardImage.Parent = cardButton

			local imageCorner = Instance.new("UICorner")
			imageCorner.CornerRadius = UDim.new(0, 4)
			-- imageCorner.ZIndex = 1003 -- Higher than card image (UICorner doesn't support ZIndex)
			imageCorner.Parent = cardImage

			-- Card name
			local cardName = Instance.new("TextLabel")
			cardName.Size = UDim2.new(1, -6, 0, 25)
			cardName.Position = UDim2.new(0, 3, 0, 68)
			cardName.BackgroundTransparency = 1
			cardName.Text = card.name
			cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
			cardName.TextSize = 8
			cardName.Font = Enum.Font.GothamBold
			cardName.TextScaled = true
			cardName.TextWrapped = true
			cardName.ZIndex = 1003 -- Higher than card button
			cardName.Parent = cardButton

			-- Value
			local valueLabel = Instance.new("TextLabel")
			valueLabel.Size = UDim2.new(1, -6, 0, 15)
			valueLabel.Position = UDim2.new(0, 3, 0, 98)
			valueLabel.BackgroundTransparency = 1
			valueLabel.Text = card.value .. " coins"
			valueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
			valueLabel.TextSize = 7
			valueLabel.Font = Enum.Font.Gotham
			valueLabel.ZIndex = 1003 -- Higher than card button
			valueLabel.Parent = cardButton

			-- Mutation indicator
			if card.mutation and card.mutation == "Error" then
				local mutationLabel = Instance.new("TextLabel")
				mutationLabel.Size = UDim2.new(0, 15, 0, 15)
				mutationLabel.Position = UDim2.new(1, -18, 0, 3)
				mutationLabel.BackgroundTransparency = 1
				mutationLabel.Text = "⚠️"
				mutationLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
				mutationLabel.TextSize = 10
				mutationLabel.Font = Enum.Font.GothamBold
				mutationLabel.ZIndex = 1003 -- Higher than card button
				mutationLabel.Parent = cardButton
			end

			-- Click to add to display
			cardButton.MouseButton1Click:Connect(function()
				print("🎴 Card button clicked for:", card.name)
				self:AddCardToDisplay(card.instanceId)
				addCardGUI:Destroy()
			end)
		end
		print("🎴 Finished creating", #self.PlayerCards, "card buttons")
		print("🎴 CardList now has", #cardList:GetChildren(), "children")
	else
		print("❌ No PlayerCards found or empty PlayerCards array")
		-- Add a message when no cards are available
		local noCardsLabel = Instance.new("TextLabel")
		noCardsLabel.Size = UDim2.new(1, -20, 0, 100)
		noCardsLabel.Position = UDim2.new(0, 10, 0.5, -50)
		noCardsLabel.BackgroundTransparency = 1
		noCardsLabel.Text = "No cards available to display.\nOpen some packs first!"
		noCardsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		noCardsLabel.TextSize = 16
		noCardsLabel.Font = Enum.Font.Gotham
		noCardsLabel.TextScaled = true
		noCardsLabel.TextWrapped = true
		noCardsLabel.ZIndex = 1001
		noCardsLabel.Parent = cardList
	end

	print("🎴 AddCardMenu created successfully with", cardList:GetChildren() and #cardList:GetChildren() or 0, "children")
end

function CardClient:AddCardToDisplay(cardInstanceId)
	local remoteEvent = ReplicatedStorage:WaitForChild("DisplayCardEvent", 5)
	if remoteEvent then
		remoteEvent:FireServer(cardInstanceId)
		print("🎴 Adding card to display table:", cardInstanceId)

		-- Optimistically update local display
		if not self.DisplayedCards then
			self.DisplayedCards = {}
		end

		-- Find the card in player's collection
		local cardToAdd = nil
		for _, card in ipairs(self.PlayerCards) do
			if card.instanceId == cardInstanceId then
				cardToAdd = card
				break
			end
		end

		if cardToAdd then
			table.insert(self.DisplayedCards, {
				playerName = game.Players.LocalPlayer.Name,
				card = cardToAdd,
				displayTime = os.time()
			})
			print("✅ Added card locally:", cardToAdd.name)

			-- Update display if open
			if self.UpdateDisplayFunction then
				self.UpdateDisplayFunction()
			end

			-- Update money display
			self:UpdateMoneyDisplay()
		end
	end
end

function CardClient:RemoveCardFromDisplay(cardInstanceId)
	local remoteEvent = ReplicatedStorage:WaitForChild("RemoveDisplayCardEvent", 5)
	if remoteEvent then
		remoteEvent:FireServer(cardInstanceId)
		print("🗑️ Removing card from display table:", cardInstanceId)

		-- Optimistically update local display
		if self.DisplayedCards then
			for i, displayCard in ipairs(self.DisplayedCards) do
				if displayCard.card.instanceId == cardInstanceId then
					table.remove(self.DisplayedCards, i)
					print("✅ Removed card locally:", displayCard.card.name)
					break
				end
			end

			-- Update display if open
			if self.UpdateDisplayFunction then
				self.UpdateDisplayFunction()
			end

			-- Update money display
			self:UpdateMoneyDisplay()
		end
	end
end

-- Function to update money earning display
function CardClient:UpdateMoneyDisplay()
	if self.MoneyDisplayLabel then
		local displayCount = self.DisplayedCards and #self.DisplayedCards or 0
		local coinsPerSecond = displayCount -- 1 coin per second per card
		local totalEarning = displayCount * coinsPerSecond

		self.MoneyDisplayLabel.Text = string.format("💰 Earning: %d coins/sec (%d cards displayed)", totalEarning, displayCount)

		-- Update color based on earning amount
		if totalEarning > 0 then
			self.MoneyDisplayLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green
		else
			self.MoneyDisplayLabel.TextColor3 = Color3.fromRGB(200, 200, 200) -- Gray
		end

		print("💰 Updated money display:", totalEarning, "coins/sec from", displayCount, "cards")
	end
end

-- Connect to server capacity events
local serverCapacityEvent = ReplicatedStorage:WaitForChild("ServerCapacityEvent")
serverCapacityEvent.OnClientEvent:Connect(function(capacityData)
	print("📊 Received server capacity update")
	if self.UpdateServerStatus then
		self:UpdateServerStatus("Server Available", Color3.fromRGB(100, 255, 100))
	end
end)

-- NPC Proximity and Battle System
local npcDetectionEvent = ReplicatedStorage:WaitForChild("NPCDetectionEvent")
local startBattleEvent = ReplicatedStorage:WaitForChild("StartBattleEvent")

local npcProximityActive = false
local proximityPrompt = nil

-- Handle NPC proximity detection
npcDetectionEvent.OnClientEvent:Connect(function(isNear, message)
	if isNear and not npcProximityActive then
		npcProximityActive = true
		print("🎴 NPC proximity detected:", message)

		-- Create proximity prompt
		proximityPrompt = Instance.new("ScreenGui")
		proximityPrompt.Name = "NPCProximityPrompt"
		proximityPrompt.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

		local promptFrame = Instance.new("Frame")
		promptFrame.Size = UDim2.new(0, 300, 0, 80)
		promptFrame.Position = UDim2.new(0.5, -150, 0.8, 0)
		promptFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
		promptFrame.BorderSizePixel = 0
		promptFrame.Parent = proximityPrompt

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = promptFrame

		local promptText = Instance.new("TextLabel")
		promptText.Size = UDim2.new(1, 0, 1, 0)
		promptText.BackgroundTransparency = 1
		promptText.Text = message
		promptText.TextColor3 = Color3.fromRGB(255, 255, 255)
		promptText.TextSize = 18
		promptText.Font = Enum.Font.GothamBold
		promptText.Parent = promptFrame

		-- Set up E key detection
		local userInputService = game:GetService("UserInputService")


		-- Simple E key press detection
		local eKeyConnection = userInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.E and not gameProcessed and npcProximityActive then
				print("🎴 E key pressed - claiming card!")
				startBattleEvent:FireServer()

				-- Remove prompt after use
				if proximityPrompt then
					proximityPrompt:Destroy()
					proximityPrompt = nil
				end
				npcProximityActive = false

				-- Disconnect E key listener
				if eKeyConnection then
					eKeyConnection:Disconnect()
				end
			end
		end)

	elseif not isNear and npcProximityActive then
		npcProximityActive = false
		print("🎴 Left NPC proximity zone")

		-- Remove proximity prompt
		if proximityPrompt then
			proximityPrompt:Destroy()
			proximityPrompt = nil
		end
	end
end)

-- Money Collection System
local collectMoneyEvent = ReplicatedStorage:WaitForChild("CollectMoneyEvent")
collectMoneyEvent.OnClientEvent:Connect(function(result)
	if result.coinsCollected and result.coinsCollected > 0 then
		-- Show money collected notification
		local notification = Instance.new("ScreenGui")
		notification.Name = "MoneyCollectedNotification"
		notification.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

		local notificationFrame = Instance.new("Frame")
		notificationFrame.Size = UDim2.new(0, 300, 0, 100)
		notificationFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
		notificationFrame.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		notificationFrame.BorderSizePixel = 0
		notificationFrame.Parent = notification

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = notificationFrame

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 50)
		title.Position = UDim2.new(0, 0, 0, 0)
		title.BackgroundTransparency = 1
		title.Text = "💰 Money Collected! 💰"
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.TextSize = 20
		title.Font = Enum.Font.GothamBold
		title.Parent = notificationFrame

		local amount = Instance.new("TextLabel")
		amount.Size = UDim2.new(1, 0, 0, 50)
		amount.Position = UDim2.new(0, 0, 0, 50)
		amount.BackgroundTransparency = 1
		amount.Text = "+" .. result.coinsCollected .. " coins"
		amount.TextColor3 = Color3.fromRGB(255, 255, 255)
		amount.TextSize = 18
		amount.Font = Enum.Font.Gotham
		amount.Parent = notificationFrame

		-- Auto-remove notification after 3 seconds
		spawn(function()
			wait(3)
			if notification then
				notification:Destroy()
			end
		end)

		print("💰 Money collected notification shown:", result.coinsCollected, "coins")
	else
		-- Show no money message
		local message = Instance.new("Message")
		message.Text = result.message or "No money to collect yet!"
		message.Parent = workspace

		spawn(function()
			wait(3)
			if message then
				message:Destroy()
			end
		end)
	end
end)

return CardClient
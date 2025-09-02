-- Card Server with Custom Image System
print("🎮 Card Server Starting...")
print("🔧 Script is running successfully")
print("🔧 Current time:", os.date())
print("🔧 CUSTOM IMAGE SYSTEM ACTIVE")
print("🔧 About to define global variables...")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local TeleportService = game:GetService("TeleportService")

-- Global variables (moved to top for function access)
local PlayerDataCache = {}
local DisplayTableData = {}
local NPCCards = {
	{name = "Desert Rattlesnake", rarity = "Common", value = 1},
	{name = "Cactus Flower", rarity = "Common", value = 1},
	{name = "Golden Revolver", rarity = "Rare", value = 5},
	{name = "Legendary Gunslinger", rarity = "Epic", value = 10}
}
local PlayerBattleCards = {}
local BattleInProgress = false
local PlayersNearNPC = {}
local BattleCooldowns = {} -- Track when players can battle again (5 minute cooldown)

-- Money earning system for displayed cards (tycoon style)
local DisplayCardEarnings = {} -- Track money earned by each player's displayed cards
local MoneyCollectionMats = {} -- Store references to money collection mats
local MaxDisplayCards = 4 -- Maximum cards a player can display (reduced for visual table layout)
-- MoneyEarningRate removed - now each card has its own earningsPerSecond value
local MoneyCollectionCooldown = 10 -- Seconds between money collections

-- Table system configuration
MaxTables = 10 -- Total number of tables
TableCapacity = 10 -- Maximum players per table
TablePlayerCounts = {} -- Track how many players are at each table
TableAssignments = {} -- Track which table each player is assigned to

print("🔧 DEBUG: Global variables defined successfully!")
print("🔧 DEBUG: MaxTables =", MaxTables)
print("🔧 DEBUG: TableCapacity =", TableCapacity)
print("🔧 DEBUG: TablePlayerCounts type =", type(TablePlayerCounts))
print("🔧 DEBUG: TableAssignments type =", type(TableAssignments))

-- CLEAN UP ANY EXISTING TABLES FIRST
print("🧹 Cleaning up any existing tables and displays...")
for i = 1, 20 do -- Check for up to 20 tables to be safe
	-- Remove old display tables
	local oldTable = workspace:FindFirstChild("CardDisplayTable" .. i)
	if oldTable then
		print("🧹 Removing old table:", oldTable.Name)
		oldTable:Destroy()
	end

	-- Remove old money mats
	local oldMat = workspace:FindFirstChild("MoneyCollectionMat" .. i)
	if oldMat then
		print("🧹 Removing old money mat:", oldMat.Name)
		oldMat:Destroy()
	end

	-- Remove old money displays (various names)
	local oldDisplay1 = workspace:FindFirstChild("MoneyValueDisplay" .. i)
	if oldDisplay1 then
		print("🧹 Removing old money display:", oldDisplay1.Name)
		oldDisplay1:Destroy()
	end

	local oldDisplay2 = workspace:FindFirstChild("FloatingMoneyDisplay" .. i)
	if oldDisplay2 then
		print("🧹 Removing old floating display:", oldDisplay2.Name)
		oldDisplay2:Destroy()
	end

	local oldAnchor = workspace:FindFirstChild("FloatingTextAnchor" .. i)
	if oldAnchor then
		print("🧹 Removing old text anchor:", oldAnchor.Name)
		oldAnchor:Destroy()
	end

	-- Remove old signs
	local oldSign = workspace:FindFirstChild("MoneyMatSign" .. i)
	if oldSign then
		print("🧹 Removing old mat sign:", oldSign.Name)
		oldSign:Destroy()
	end
end

-- Also remove any standalone tables that might be at spawn or other locations
local testTable = workspace:FindFirstChild("TestTable")
if testTable then
	print("🧹 Removing test table")
	testTable:Destroy()
end

-- Remove any other stray table parts
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Part") then
		-- Check for ANY table-like objects (more aggressive cleanup)
		if obj.Name:match("Table") or obj.Name:match("Mat") or obj.Name:match("Display") or 
			obj.Name:match("Card") or obj.Name:match("Money") or obj.Name:match("Floating") then
			if not obj.Name:match("CardDisplayTable") and not obj.Name:match("MoneyCollectionMat") and 
				not obj.Name:match("FloatingTextAnchor") then -- Don't remove our new tables
				print("🧹 Removing stray object:", obj.Name, "at position", obj.Position)
				obj:Destroy()
			end
		end

		-- Also check for objects at spawn location (0, 1, 0) or near it
		if obj.Position.Y >= 0.5 and obj.Position.Y <= 1.5 and 
			math.abs(obj.Position.X) <= 5 and math.abs(obj.Position.Z) <= 5 then
			if not obj.Name:match("CardDisplayTable") and not obj.Name:match("MoneyCollectionMat") and
				not obj.Name:match("FloatingTextAnchor") then
				print("🧹 Removing spawn area object:", obj.Name, "at position", obj.Position)
				obj:Destroy()
			end
		end
	end
end

print("🧹 Cleanup complete!")

-- ADDITIONAL AGGRESSIVE CLEANUP - Search for any objects that look like tables
print("🧹 Performing additional aggressive cleanup...")
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Part") then
		-- Check if this looks like a table (wooden, brown, table-like size)
		if obj.Material == Enum.Material.Wood and 
			obj.BrickColor.Name == "Brown" and
			obj.Size.X >= 6 and obj.Size.X <= 10 and
			obj.Size.Y >= 0.5 and obj.Size.Y <= 2 and
			obj.Size.Z >= 4 and obj.Size.Z <= 8 then

			-- Don't remove our new tables
			if not obj.Name:match("CardDisplayTable") then
				print("🧹 Removing table-like object:", obj.Name, "at position", obj.Position)
				obj:Destroy()
			end
		end

		-- Check for any green mats (old money collection mats)
		if obj.Material == Enum.Material.Neon and 
			obj.BrickColor.Name == "Bright green" then
			if not obj.Name:match("MoneyCollectionMat") then
				print("🧹 Removing old green mat:", obj.Name, "at position", obj.Position)
				obj:Destroy()
			end
		end
	end
end
print("🧹 Additional cleanup complete!")

-- FINAL AGGRESSIVE CLEANUP - Search for any objects in the table area
print("🧹 Performing final aggressive cleanup in table area...")
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Part") then
		-- Check if this object is in the table grid area (between -60 and +60 on X and Z)
		if math.abs(obj.Position.X) <= 60 and math.abs(obj.Position.Z) <= 60 and
			obj.Position.Y >= 0 and obj.Position.Y <= 10 then

			-- Don't remove our new tables, mats, or anchors
			if not obj.Name:match("CardDisplayTable") and 
				not obj.Name:match("MoneyCollectionMat") and
				not obj.Name:match("FloatingTextAnchor") then

				-- Check if it looks like a table or mat
				if (obj.Material == Enum.Material.Wood and obj.BrickColor.Name == "Brown") or
					(obj.Material == Enum.Material.Neon and obj.BrickColor.Name == "Bright green") or
					obj.Name:match("Table") or obj.Name:match("Mat") or obj.Name:match("Display") or
					obj.Name:match("Card") or obj.Name:match("Money") or obj.Name:match("Floating") then

					print("🧹 FINAL CLEANUP: Removing object in table area:", obj.Name, "at position", obj.Position)
					obj:Destroy()
				end
			end
		end
	end
end
print("🧹 Final cleanup complete!")

-- SPECIFIC CLEANUP FOR THE PROBLEM AREA (between mat 1 and mat 6)
print("🧹 SPECIFIC CLEANUP: Targeting the problem area between mat 1 and mat 6...")
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Part") then
		-- Target the specific area where the old table and mat are located
		-- This covers the area between the first few tables where the old objects are
		if obj.Position.X >= -30 and obj.Position.X <= 30 and
			obj.Position.Z >= -15 and obj.Position.Z <= 15 and
			obj.Position.Y >= 0 and obj.Position.Y <= 10 then

			-- Don't remove our new system objects
			if not obj.Name:match("CardDisplayTable") and 
				not obj.Name:match("MoneyCollectionMat") and
				not obj.Name:match("FloatingTextAnchor") then

				-- Remove ANY object in this area that's not part of our new system
				print("🧹 SPECIFIC CLEANUP: Removing object in problem area:", obj.Name, "at position", obj.Position)
				obj:Destroy()
			end
		end
	end
end
print("🧹 Specific cleanup complete!")

-- MIDDLE ROW CLEANUP - Target the empty middle row between table rows
print("🧹 MIDDLE ROW CLEANUP: Targeting the middle row between table 1-5 and 6-10...")
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Part") then
		-- Target the middle row area specifically
		-- The tables are arranged in rows with zSpacing = 15
		-- Row 1 (tables 1-5): Z around -7.5
		-- Row 2 (tables 6-10): Z around 7.5
		-- Middle area: Z around 0 (between -5 and 5)
		if obj.Position.Z >= -5 and obj.Position.Z <= 5 and  -- Middle row Z position
			obj.Position.X >= -40 and obj.Position.X <= 40 and  -- Within table X range
			obj.Position.Y >= 0 and obj.Position.Y <= 10 then   -- Ground to table level

			-- Don't remove our new system objects
			if not obj.Name:match("CardDisplayTable") and 
				not obj.Name:match("MoneyCollectionMat") and
				not obj.Name:match("FloatingTextAnchor") then

				-- Remove ANY object in the middle row
				print("🧹 MIDDLE ROW: Removing object in middle row:", obj.Name, "at position", obj.Position)
				obj:Destroy()
			end
		end
	end
end
print("🧹 Middle row cleanup complete!")

-- CLEANUP OBJECTS WITH DISPLAY BOARDS - Target objects that have SurfaceGui or BillboardGui children
print("🧹 DISPLAY BOARD CLEANUP: Removing objects with display boards...")
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Part") then
		-- Check if this object has any GUI displays (SurfaceGui, BillboardGui)
		local hasDisplayBoard = false
		for _, child in pairs(obj:GetChildren()) do
			if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
				hasDisplayBoard = true
				break
			end
		end

		-- If it has a display board and isn't our new system, remove it
		if hasDisplayBoard then
			if not obj.Name:match("CardDisplayTable") and 
				not obj.Name:match("MoneyCollectionMat") and
				not obj.Name:match("FloatingTextAnchor") then

				print("🧹 DISPLAY BOARD: Removing object with display board:", obj.Name, "at position", obj.Position)
				obj:Destroy()
			end
		end
	end
end
print("🧹 Display board cleanup complete!")

-- AGGRESSIVE CLEANUP FOR PERSISTENT OLD TABLES - Target any remaining old system objects
print("🧹 PERSISTENT OLD TABLES CLEANUP: Removing any remaining old system objects...")
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Part") then
		-- Check for old table naming patterns or characteristics
		local isOldTable = false
		
		-- Check for old naming patterns
		if obj.Name:match("Table") and not obj.Name:match("CardDisplayTable") then
			isOldTable = true
		end
		
		-- Check for old mat naming patterns
		if obj.Name:match("Mat") and not obj.Name:match("MoneyCollectionMat") then
			isOldTable = true
		end
		
		-- Check for old display naming patterns
		if obj.Name:match("Display") and not obj.Name:match("FloatingTextAnchor") then
			isOldTable = true
		end
		
		-- Check for objects that look like old tables (brown wood with display boards)
		if obj.Material == Enum.Material.Wood and obj.BrickColor.Name == "Brown" then
			-- Check if it has display boards (old system characteristic)
			for _, child in pairs(obj:GetChildren()) do
				if child:IsA("SurfaceGui") and child.Name ~= "NPCLabel" and child.Name ~= "SignText" then
					isOldTable = true
					break
				end
			end
		end
		
		-- Check for green neon mats that might be old money mats
		if obj.Material == Enum.Material.Neon and obj.BrickColor.Name == "Bright green" then
			-- If it's not our new system, it's probably old
			if not obj.Name:match("MoneyCollectionMat") then
				isOldTable = true
			end
		end
		
		-- Check for objects positioned on or near the conveyor area (Z between -5 and 5)
		if math.abs(obj.Position.Z) <= 8 and obj.Position.Y >= 0 and obj.Position.Y <= 10 then
			-- If it's not our conveyor system, it might be an old object
			if not obj.Name:match("ConveyorBelt") and not obj.Name:match("ConveyorRail") and
				not obj.Name:match("CardDisplayTable") and not obj.Name:match("MoneyCollectionMat") and
				not obj.Name:match("FloatingTextAnchor") and not obj.Name:match("Base") then
				
				-- Additional check: if it has display boards, it's definitely old
				for _, child in pairs(obj:GetChildren()) do
					if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
						isOldTable = true
						break
					end
				end
			end
		end
		
		if isOldTable then
			print("🧹 PERSISTENT: Removing old system object:", obj.Name, "at position", obj.Position)
			obj:Destroy()
		end
	end
end
print("🧹 Persistent old tables cleanup complete!")

-- FINAL SWEEP - Remove any standalone SurfaceGui or BillboardGui objects
print("🧹 FINAL GUI SWEEP: Removing standalone GUI objects...")
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
		-- Don't remove GUIs that belong to our new system
		if not (obj.Parent and obj.Parent.Name and (
			obj.Parent.Name:match("CardDisplayTable") or
			obj.Parent.Name:match("MoneyCollectionMat") or
			obj.Parent.Name:match("FloatingTextAnchor") or
			obj.Parent.Name:match("ConveyorBelt") or
			obj.Parent.Name:match("CardBattleSign")
		)) then
			print("🧹 FINAL GUI: Removing standalone GUI:", obj.Name, "Type:", obj.ClassName)
			obj:Destroy()
		end
	end
end
print("🧹 Final GUI sweep complete!")

-- CLEANUP FLOATING DISPLAY BOARDS - Remove any SurfaceGui/BillboardGui objects floating in workspace
print("🧹 FLOATING DISPLAY CLEANUP: Removing floating display boards...")
for _, obj in pairs(workspace:GetChildren()) do
	-- Remove any standalone GUI objects
	if obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") or obj:IsA("ScreenGui") then
		print("🧹 FLOATING DISPLAY: Removing floating GUI:", obj.Name, "Type:", obj.ClassName)
		obj:Destroy()
	end

	-- Check for Parts that might be display boards themselves
	if obj:IsA("Part") then
		-- Remove any parts that look like display boards (thin, vertical parts)
		if obj.Size.Y > obj.Size.X and obj.Size.Y > obj.Size.Z and obj.Size.Y >= 3 then
			if not obj.Name:match("CardDisplayTable") and 
				not obj.Name:match("MoneyCollectionMat") and
				not obj.Name:match("FloatingTextAnchor") and
				not obj.Name:match("ConveyorBelt") and
				not obj.Name:match("ConveyorRail") then

				print("🧹 FLOATING DISPLAY: Removing display board part:", obj.Name, "at position", obj.Position)
				obj:Destroy()
			end
		end
	end
end
print("🧹 Floating display cleanup complete!")

-- FINAL AGGRESSIVE TABLE CLEANUP - Remove any remaining table-like objects
print("🧹 FINAL TABLE CLEANUP: One last sweep for old tables...")
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Part") then
		-- Check for any remaining table-like objects (wooden, brown, flat)
		if obj.Material == Enum.Material.Wood and 
			obj.BrickColor.Name == "Brown" and
			obj.Size.Y <= 2 and  -- Flat like a table
			(obj.Size.X >= 6 or obj.Size.Z >= 6) then  -- Table-sized

			-- Don't remove our new system
			if not obj.Name:match("CardDisplayTable") then
				print("🧹 FINAL TABLE: Removing old table:", obj.Name, "at position", obj.Position)
				obj:Destroy()
			end
		end
	end
end
print("🧹 Final table cleanup complete!")



-- DEBUG: Check if we reach this point
print("🔧 DEBUG: About to create conveyor belt system...")

-- CREATE CONVEYOR BELT IN THE MIDDLE
print("🚛 Creating conveyor belt system in the middle space...")
local conveyorLength = 80  -- Length of the conveyor
local conveyorWidth = 8    -- Width of the conveyor
local conveyorHeight = 1   -- Height of the conveyor

-- Create main conveyor belt
local conveyor = Instance.new("Part")
conveyor.Name = "ConveyorBelt"
conveyor.Size = Vector3.new(conveyorLength, conveyorHeight, conveyorWidth)
conveyor.Position = Vector3.new(0, 0.5, 0)  -- Center position between table rows
conveyor.Anchored = true
conveyor.Material = Enum.Material.Metal
conveyor.BrickColor = BrickColor.new("Dark stone grey")
conveyor.Parent = workspace

-- Add conveyor texture/pattern
local conveyorGui = Instance.new("SurfaceGui")
conveyorGui.Face = Enum.NormalId.Top
conveyorGui.Parent = conveyor

local conveyorPattern = Instance.new("Frame")
conveyorPattern.Size = UDim2.new(1, 0, 1, 0)
conveyorPattern.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
conveyorPattern.BorderSizePixel = 0
conveyorPattern.Parent = conveyorGui

-- Add moving stripes pattern
for i = 1, 10 do
	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(0.1, 0, 1, 0)
	stripe.Position = UDim2.new((i-1) * 0.1, 0, 0, 0)
	stripe.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
	stripe.BorderSizePixel = 0
	stripe.Parent = conveyorPattern
end

-- Add conveyor side rails
for side = -1, 1, 2 do
	local rail = Instance.new("Part")
	rail.Name = "ConveyorRail"
	rail.Size = Vector3.new(conveyorLength, 0.5, 0.5)
	rail.Position = Vector3.new(0, 1, side * (conveyorWidth/2 + 0.25))
	rail.Anchored = true
	rail.Material = Enum.Material.Metal
	rail.BrickColor = BrickColor.new("Really black")
	rail.Parent = workspace
end

print("🚛 Conveyor belt system created!")

-- CONVEYOR CARD SYSTEM - Steal a Brainrot style
print("🎴 Setting up conveyor card system...")

-- Global variables for conveyor system
local ConveyorCards = {}  -- Active cards on the conveyor
local ConveyorClaimCosts = {10, 25, 50, 100, 200, 5000}  -- Costs: Common, Uncommon, Rare, UltraRare, Secret, Legendary
local PlayersClaimingCards = {}  -- Players currently claiming cards
local ConveyorSpeed = 0.2  -- Studs per second movement speed (even slower for easier claiming)

-- Function to convert string rarity to numeric rarity for cost calculation
local function getRarityNumber(rarityString)
	local rarityMap = {
		["Common"] = 1,
		["Uncommon"] = 2,
		["Rare"] = 3,
		["UltraRare"] = 4,
		["Secret"] = 5,
		["Legendary"] = 6  -- Added for stretch goal cards
	}
	return rarityMap[rarityString] or 1
end

-- Helper function to get a random card from pool with weighted rarity
-- forConveyor: if true, uses conveyor weights (frequent legendaries), if false uses pack weights (rare legendaries)
local function getRandomCardFromPool(forConveyor)
	if not cardPool or #cardPool == 0 then
		print("❌ ERROR: cardPool is not available or empty")
		return nil
	end

	-- Different rarity weights for conveyor vs packs
	local rarityRoll = math.random(1, 100)
	local targetRarity
	
	if forConveyor then
		-- CONVEYOR WEIGHTS: Legendaries appear frequently but cost full price
		if rarityRoll <= 45 then
			targetRarity = "Common"
		elseif rarityRoll <= 70 then
			targetRarity = "Uncommon" 
		elseif rarityRoll <= 85 then
			targetRarity = "Rare"
		elseif rarityRoll <= 95 then
			targetRarity = "UltraRare"
		elseif rarityRoll <= 98 then
			targetRarity = "Secret"
		else
			targetRarity = "Legendary"  -- 2% chance on conveyor (still rare but accessible)
		end
	else
		-- PACK WEIGHTS: Legendaries are extremely rare in packs
		if rarityRoll <= 65 then
			targetRarity = "Common"
		elseif rarityRoll <= 85 then
			targetRarity = "Uncommon" 
		elseif rarityRoll <= 94 then
			targetRarity = "Rare"
		elseif rarityRoll <= 98 then
			targetRarity = "UltraRare"
		elseif rarityRoll <= 99 then
			targetRarity = "Secret"
		else
			targetRarity = "Legendary"  -- Only 1% chance in packs (extremely rare)
		end
	end
	
	-- Filter cards by target rarity
	local availableCards = {}
	for _, card in pairs(cardPool) do
		if card.rarity == targetRarity then
			table.insert(availableCards, card)
		end
	end
	
	-- If no cards of target rarity, fall back to random selection
	if #availableCards == 0 then
		print("⚠️ No cards found for rarity:", targetRarity, "- using random selection")
		return cardPool[math.random(#cardPool)]
	end
	
	-- Select random card from filtered list
	return availableCards[math.random(#availableCards)]
end

-- Function to generate a single random card with weighted rarity (for conveyor system)
local function generateCard()
	local randomCard = getRandomCardFromPool(true)  -- true = for conveyor (frequent legendaries)
	if not randomCard then
		return nil
	end

	-- Check if this card should get a mutation (1% chance)
	local newCard
	if shouldGetMutation() then
		newCard = generateMutatedCard(randomCard)
		print("🎭 CONVEYOR MUTATION! Card", randomCard.name, "got Error mutation - Value:", randomCard.value, "→", newCard.value)
	else
		newCard = {
			name = randomCard.name,
			rarity = getRarityNumber(randomCard.rarity), -- Convert to numeric rarity
			rarityString = randomCard.rarity, -- Keep original string for display
			value = randomCard.value,
			earningsPerSecond = randomCard.earningsPerSecond or 1, -- Add earnings per second
			condition = "Mint",
			id = randomCard.id, -- Use the card's actual ID
			imageId = randomCard.imageId, -- Add imageId for display
			type = randomCard.type, -- Add type for display
			instanceId = game:GetService("HttpService"):GenerateGUID(false) -- For individual card instances
		}
	end

	return newCard
end

-- Function to create a card on the conveyor
local function spawnConveyorCard()
	print("🎴 Spawning new card on conveyor...")
	print("🎴 DEBUG: generateCard function exists:", generateCard ~= nil)

	-- Generate a random card
	local cardData = generateCard()
	print("🎴 DEBUG: Generated card data:", cardData and "SUCCESS" or "FAILED")
	if not cardData then
		print("❌ Failed to generate card for conveyor")
		return
	end
	print("🎴 DEBUG: Card name:", cardData.name, "Rarity:", cardData.rarity, "RarityString:", cardData.rarityString)

	-- Determine cost based on rarity (use actual card value for Legendary cards)
	local cost
	if cardData.rarityString == "Legendary" then
		cost = cardData.value  -- Use actual card price for stretch goals
	else
		cost = ConveyorClaimCosts[cardData.rarity] or 10
	end
	print("🎴 DEBUG: Card cost determined:", cost, "coins")

	-- Create card object on conveyor (standing upright)
	print("🎴 DEBUG: Creating card object...")
	print("🎴 DEBUG: conveyorLength =", conveyorLength)
	local cardObject = Instance.new("Part")
	cardObject.Name = "ConveyorCard_" .. cardData.name
	cardObject.Size = Vector3.new(0.576, 8.64, 5.76)  -- 40% LARGER: thin, tall, card-width (was 0.4, 6, 4 originally)
	cardObject.Position = Vector3.new(-conveyorLength/2, 5.32, 0)  -- Adjusted for 40% larger card height
	cardObject.Anchored = true
	cardObject.CanCollide = false
	cardObject.Material = Enum.Material.SmoothPlastic
	cardObject.BrickColor = BrickColor.new("White")
	cardObject.Parent = workspace
	print("🎴 DEBUG: DOUBLE SIZE Card object created at position:", cardObject.Position)

	-- Add card display on the flat sides (Left and Right faces since card is standing upright)
	-- The card is oriented as: X=thin, Y=height, Z=width, so Left/Right faces are the flat sides
	local cardGuiLeft = Instance.new("SurfaceGui")
	cardGuiLeft.Face = Enum.NormalId.Left  -- Left flat side
	cardGuiLeft.Parent = cardObject

	local cardGuiRight = Instance.new("SurfaceGui")
	cardGuiRight.Face = Enum.NormalId.Right  -- Right flat side
	cardGuiRight.Parent = cardObject

	local cardFrame = Instance.new("Frame")
	cardFrame.Size = UDim2.new(1, 0, 1, 0)
	cardFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	cardFrame.BorderSizePixel = 2
	cardFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	cardFrame.Parent = cardGuiLeft

	-- Get rarity color for visual appeal
	local rarityColors = {
		[1] = Color3.fromRGB(150, 150, 150), -- Common - Gray
		[2] = Color3.fromRGB(100, 255, 100), -- Uncommon - Green  
		[3] = Color3.fromRGB(100, 100, 255), -- Rare - Blue
		[4] = Color3.fromRGB(255, 100, 255), -- Ultra Rare - Purple
		[5] = Color3.fromRGB(255, 215, 0)    -- Secret - Gold
	}
	local rarityColor = rarityColors[cardData.rarity] or Color3.fromRGB(150, 150, 150)

	-- CURRENT: Custom image system (full-face images with card data)
	local cardImage = Instance.new("ImageLabel")
	cardImage.Size = UDim2.new(1, 0, 0.8, 0)  -- 80% of card face for image
	cardImage.Position = UDim2.new(0, 0, 0, 0)  -- Top of card
	cardImage.BackgroundTransparency = 1  -- Transparent background
	cardImage.Image = cardData.imageId or ""  -- Use the card's custom image
	cardImage.ScaleType = Enum.ScaleType.Stretch  -- Stretch to fill
	cardImage.BorderSizePixel = 2  -- Border for definition
	cardImage.BorderColor3 = rarityColor  -- Rarity-colored border
	cardImage.Parent = cardFrame

	-- Add rounded corners to the image
	local imageCorner = Instance.new("UICorner")
	imageCorner.CornerRadius = UDim.new(0, 8)
	imageCorner.Parent = cardImage

	-- Card info section at bottom (20% of card)
	local infoFrame = Instance.new("Frame")
	infoFrame.Size = UDim2.new(1, 0, 0.2, 0)  -- Bottom 20% for info
	infoFrame.Position = UDim2.new(0, 0, 0.8, 0)
	infoFrame.BackgroundColor3 = rarityColor
	infoFrame.BackgroundTransparency = 0.1  -- Slightly transparent
	infoFrame.BorderSizePixel = 0
	infoFrame.Parent = cardFrame

	local infoCorner = Instance.new("UICorner")
	infoCorner.CornerRadius = UDim.new(0, 8)
	infoCorner.Parent = infoFrame

	-- Card name (larger, more prominent)
	local cardName = Instance.new("TextLabel")
	cardName.Size = UDim2.new(0.6, 0, 0.6, 0)  -- Left side of info area
	cardName.Position = UDim2.new(0.02, 0, 0.1, 0)
	cardName.BackgroundTransparency = 1
	cardName.Text = cardData.name
	cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
	cardName.TextScaled = true
	cardName.Font = Enum.Font.GothamBold
	cardName.TextStrokeTransparency = 0
	cardName.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	cardName.Parent = infoFrame

	-- Cost label (top right)
	local costLabel = Instance.new("TextLabel")
	costLabel.Size = UDim2.new(0.35, 0, 0.6, 0)
	costLabel.Position = UDim2.new(0.63, 0, 0.1, 0)
	costLabel.BackgroundTransparency = 1
	costLabel.Text = "💰 " .. cost
	costLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	costLabel.TextScaled = true
	costLabel.Font = Enum.Font.GothamBold
	costLabel.TextStrokeTransparency = 0
	costLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	costLabel.Parent = infoFrame

	-- Earnings per second label (bottom of info area)
	local earningsLabel = Instance.new("TextLabel")
	earningsLabel.Size = UDim2.new(1, -4, 0.3, 0)
	earningsLabel.Position = UDim2.new(0.02, 0, 0.65, 0)
	earningsLabel.BackgroundTransparency = 1
	earningsLabel.Text = "📈 +" .. (cardData.earningsPerSecond or 1) .. "/sec"
	earningsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	earningsLabel.TextScaled = true
	earningsLabel.Font = Enum.Font.Gotham
	earningsLabel.TextStrokeTransparency = 0
	earningsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	earningsLabel.Parent = infoFrame

	-- OLD: Emoji-based design system (commented out)
	--[[
	local cardIcon = Instance.new("TextLabel")
	cardIcon.Size = UDim2.new(1, 0, 0.65, 0)
	cardIcon.Position = UDim2.new(0, 0, 0.02, 0)
	cardIcon.BackgroundColor3 = rarityColor
	cardIcon.BackgroundTransparency = 0.2
	cardIcon.BorderSizePixel = 2
	cardIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	cardIcon.Parent = cardFrame

	local typeEmojis = {
		["Animal"] = "🐺", ["Item"] = "⚒️", ["Environment"] = "🌵", ["Plant"] = "🌸",
		["Structure"] = "🏠", ["Vehicle"] = "🚂", ["Weapon"] = "🔫", ["Character"] = "🤠", ["Location"] = "🏛️"
	}
	local emoji = typeEmojis[cardData.type or "Item"] or "🎴"
	
	cardIcon.Text = emoji
	cardIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
	cardIcon.TextSize = 120
	cardIcon.Font = Enum.Font.GothamBold
	cardIcon.Parent = cardFrame
	--]]

	-- Create the same design for the right face
	local cardFrameRight = cardFrame:Clone()
	cardFrameRight.Parent = cardGuiRight

	-- Add mutation effects if card is mutated
	if cardData.mutation and cardData.mutation == "Error" then
		-- Add mutation filter to both faces
		for _, gui in pairs({cardGuiLeft, cardGuiRight}) do
			local frame = gui:FindFirstChild("Frame")
			local image = frame and frame:FindFirstChild("ImageLabel")
			if frame and image then
				-- Red corruption filter overlay (as sibling to preserve original image)
				local mutationFilter = Instance.new("Frame")
				mutationFilter.Name = "MutationFilter"
				mutationFilter.Size = image.Size  -- Match image size exactly
				mutationFilter.Position = image.Position  -- Match image position exactly
				mutationFilter.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				mutationFilter.BackgroundTransparency = 0.8  -- More transparent to see image
				mutationFilter.BorderSizePixel = 0
				mutationFilter.ZIndex = 5  -- Higher than image but below other UI
				mutationFilter.Parent = frame  -- Parent to frame, not image

				local filterCorner = Instance.new("UICorner")
				filterCorner.CornerRadius = UDim.new(0, 8)
				filterCorner.Parent = mutationFilter

				-- Glitch pattern
				local glitchPattern = Instance.new("Frame")
				glitchPattern.Size = UDim2.new(1, 0, 1, 0)
				glitchPattern.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
				glitchPattern.BackgroundTransparency = 0.9  -- Very transparent
				glitchPattern.BorderSizePixel = 0
				glitchPattern.ZIndex = 1
				glitchPattern.Parent = mutationFilter

				-- Add static noise rectangles (fewer and more transparent)
				for i = 1, 4 do
					local noise = Instance.new("Frame")
					noise.Size = UDim2.new(math.random(5, 15) / 100, 0, math.random(3, 8) / 100, 0)
					noise.Position = UDim2.new(math.random(0, 85) / 100, 0, math.random(0, 92) / 100, 0)
					noise.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					noise.BackgroundTransparency = math.random(75, 90) / 100  -- More transparent
					noise.BorderSizePixel = 0
					noise.ZIndex = 2
					noise.Parent = glitchPattern
				end

				-- Add scan lines for digital corruption
				for i = 1, 2 do
					local scanLine = Instance.new("Frame")
					scanLine.Size = UDim2.new(1, 0, 0, 1)
					scanLine.Position = UDim2.new(0, 0, math.random(15, 85) / 100, 0)
					scanLine.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
					scanLine.BackgroundTransparency = 0.75
					scanLine.BorderSizePixel = 0
					scanLine.ZIndex = 3
					scanLine.Parent = glitchPattern
				end
			end

			-- Add warning symbol to card frame
			local warningSymbol = Instance.new("TextLabel")
			warningSymbol.Name = "MutationWarning"
			warningSymbol.Size = UDim2.new(0, 25, 0, 25)
			warningSymbol.Position = UDim2.new(1, -30, 0, 5)
			warningSymbol.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			warningSymbol.BackgroundTransparency = 0.3
			warningSymbol.Text = "⚠️"
			warningSymbol.TextColor3 = Color3.fromRGB(255, 255, 0)
			warningSymbol.TextSize = 20
			warningSymbol.Font = Enum.Font.GothamBold
			warningSymbol.ZIndex = 10
			warningSymbol.Parent = frame

			local symbolCorner = Instance.new("UICorner")
			symbolCorner.CornerRadius = UDim.new(0, 12)
			symbolCorner.Parent = warningSymbol
		end

		-- Make the card object itself slightly red-tinted for additional visual cue
		cardObject.Color = Color3.fromRGB(255, 200, 200)
	end

	-- Add proximity detection for claiming (scaled for double-size card)
	local proximityZone = Instance.new("Part")
	proximityZone.Name = "ProximityZone"
	proximityZone.Size = Vector3.new(11.52, 11.52, 11.52)  -- 40% larger claim area to match bigger card
	proximityZone.Position = cardObject.Position + Vector3.new(0, 1, 0)
	proximityZone.Anchored = true
	proximityZone.CanCollide = false
	proximityZone.Transparency = 1
	proximityZone.Parent = cardObject

	-- Store card data
	local conveyorCardData = {
		object = cardObject,
		data = cardData,
		cost = cost,
		position = cardObject.Position,
		claimProgress = {},  -- Track claim progress per player
		startTime = tick()
	}

	table.insert(ConveyorCards, conveyorCardData)

	-- Set up proximity detection
	proximityZone.Touched:Connect(function(hit)
		print("🎴 DEBUG: Proximity zone touched by:", hit.Name, "Parent:", hit.Parent.Name)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			print("🎴 DEBUG: Player", player.Name, "entered conveyor card proximity:", cardData.name)
			-- Send proximity event to client
			local proximityEvent = ReplicatedStorage:FindFirstChild("NPCDetectionEvent")
			if proximityEvent then
				print("🎴 DEBUG: Sending proximity event to", player.Name)
				proximityEvent:FireClient(player, true, "Press E to claim " .. cardData.name .. " for " .. cost .. " coins!")
			else
				print("❌ NPCDetectionEvent not found!")
			end
		end
	end)

	proximityZone.TouchEnded:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			-- Send proximity event to client
			local proximityEvent = ReplicatedStorage:FindFirstChild("NPCDetectionEvent")
			if proximityEvent then
				proximityEvent:FireClient(player, false, "")
			end

			-- Stop any claiming progress
			if PlayersClaimingCards[player.UserId] then
				PlayersClaimingCards[player.UserId] = nil
			end
		end
	end)

	print("🎴 Spawned conveyor card:", cardData.name, "Cost:", cost, "coins")
end

-- Function to move cards down the conveyor
local function moveConveyorCards()
	for i = #ConveyorCards, 1, -1 do
		local cardInfo = ConveyorCards[i]
		if cardInfo and cardInfo.object and cardInfo.object.Parent then
			-- Move card along the conveyor
			local newX = cardInfo.object.Position.X + ConveyorSpeed
			cardInfo.object.Position = Vector3.new(newX, cardInfo.object.Position.Y, cardInfo.object.Position.Z)

			-- Update proximity zone position
			local proximityZone = cardInfo.object:FindFirstChild("ProximityZone")
			if proximityZone then
				proximityZone.Position = cardInfo.object.Position + Vector3.new(0, 1, 0)
			end

			-- Remove card if it reaches the end
			if newX > conveyorLength/2 + 5 then
				print("🎴 Card reached end of conveyor, removing:", cardInfo.data.name)
				cardInfo.object:Destroy()
				table.remove(ConveyorCards, i)
			end
		else
			-- Remove invalid card data
			table.remove(ConveyorCards, i)
		end
	end
end

-- Function to handle card claiming
local function startCardClaim(player, cardInfo)
	local userId = player.UserId

	-- Check if player can afford the card (try multiple methods to get player data)
	print("🎴 DEBUG: Checking if player can afford card costing", cardInfo.cost, "coins")

	-- First try the cache
	local playerData = PlayerDataCache[player.UserId]
	print("🎴 DEBUG: PlayerDataCache lookup:", playerData ~= nil)

	-- If not in cache, try getPlayerData function
	if not playerData then
		local success, data = pcall(function()
			return getPlayerData and getPlayerData(player)
		end)
		if success and data then
			playerData = data
		end
		print("🎴 DEBUG: getPlayerData fallback success:", success, "data exists:", data ~= nil)
	end

	print("🎴 DEBUG: Final playerData exists:", playerData ~= nil)
	if playerData then
		print("🎴 DEBUG: Player has", (playerData.coins or 0), "coins")
	end

	if not playerData or (playerData.coins or 0) < cardInfo.cost then
		-- Send insufficient funds message
		local message = Instance.new("Message")
		message.Text = "❌ Not enough coins! Need " .. cardInfo.cost .. " coins. You have " .. ((playerData and playerData.coins) or 0) .. " coins."
		message.Parent = workspace
		spawn(function()
			wait(3)
			if message then message:Destroy() end
		end)
		print("🎴 DEBUG: Player cannot afford card - insufficient funds")
		return
	end

	-- Start claiming process
	if not cardInfo.claimProgress[userId] then
		cardInfo.claimProgress[userId] = {
			startTime = tick(),
			claimed = false
		}
	end

	PlayersClaimingCards[userId] = cardInfo
	print("🎴 Player", player.Name, "started claiming", cardInfo.data.name, "- Claim in progress...")
end

-- Function to complete card claim
local function completeCardClaim(player, cardInfo)
	local userId = player.UserId
	print("🎴 DEBUG: completeCardClaim called for player:", player.Name, "card:", cardInfo.data.name)

	-- Deduct coins and give card (try multiple methods to get player data)
	-- First try the cache
	local playerData = PlayerDataCache[player.UserId]
	print("🎴 DEBUG: playerData from cache:", playerData ~= nil)

	-- If not in cache, try getPlayerData function
	if not playerData then
		local success, data = pcall(function()
			return getPlayerData and getPlayerData(player)
		end)
		if success and data then
			playerData = data
		end
	end

	print("🎴 DEBUG: playerData exists:", playerData ~= nil, "coins:", playerData and (playerData.coins or 0), "cost:", cardInfo.cost)
	if playerData and (playerData.coins or 0) >= cardInfo.cost then
		print("🎴 DEBUG: Player can afford card, deducting coins...")
		playerData.coins = (playerData.coins or 0) - cardInfo.cost

		-- Add card to player's collection
		if not playerData.cards then
			playerData.cards = {}
		end
		print("🎴 DEBUG: Adding card to collection, current count:", #playerData.cards)
		table.insert(playerData.cards, cardInfo.data)
		print("🎴 DEBUG: Card added, new count:", #playerData.cards)

		-- Save data (use pcall to safely call savePlayerData)
		print("🎴 DEBUG: Attempting to save player data...")
		local saveSuccess = pcall(function()
			return savePlayerData and savePlayerData(player, playerData)
		end)

		print("🎴 DEBUG: Save result:", saveSuccess)
		if not saveSuccess then
			print("❌ ERROR: Failed to save player data after claiming card")
		end

		-- Remove card from conveyor
		print("🎴 DEBUG: Removing card from conveyor, current count:", #ConveyorCards)
		for i, conveyorCard in ipairs(ConveyorCards) do
			if conveyorCard == cardInfo then
				print("🎴 DEBUG: Found card at index", i, "removing...")
				conveyorCard.object:Destroy()
				table.remove(ConveyorCards, i)
				print("🎴 DEBUG: Card removed, new count:", #ConveyorCards)
				break
			end
		end

		-- Clean up claiming data
		PlayersClaimingCards[userId] = nil

		-- Notify player
		local message = Instance.new("Message")
		message.Text = "✅ Claimed " .. cardInfo.data.name .. " for " .. cardInfo.cost .. " coins!"
		message.Parent = workspace
		spawn(function()
			wait(4)
			if message then message:Destroy() end
		end)

		print("🎴 Player", player.Name, "claimed", cardInfo.data.name, "for", cardInfo.cost, "coins")

		-- Update client with complete card claim data
		local cardSoldEvent = ReplicatedStorage:FindFirstChild("CardSoldEvent")
		if cardSoldEvent then
			cardSoldEvent:FireClient(player, {
				cardName = cardInfo.data.name,
				instanceId = cardInfo.data.instanceId,
				sellPrice = 0, -- Not sold, claimed
				newCoins = playerData.coins,
				action = "claimed", -- Distinguish from sold
				-- Send complete card data for immediate display
				cardData = {
					name = cardInfo.data.name,
					rarity = cardInfo.data.rarity or 1,
					value = cardInfo.data.value or 10,
					imageId = cardInfo.data.imageId or "",
					description = cardInfo.data.description or "",
					owner = player.Name,
					timestamp = tick()
				}
			})
		end
	end
end

-- E key handling will be done in the main StartBattleEvent handler below

-- Conveyor systems will start after all critical systems are loaded

-- Move conveyor initialization to after tables are created
print("🎴 Conveyor card system setup complete - will initialize after tables...")

-- IMMEDIATELY CREATE DISPLAY TABLES (before anything else can interfere)
print("🚨 IMMEDIATE TABLE CREATION - Creating", MaxTables, "tables NOW...")
for tableNum = 1, MaxTables do
	print("🚨 Creating table", tableNum, "immediately...")

	-- Calculate position for each table (arrange in a centered grid with more spacing)
	local tablesPerRow = 5
	local xSpacing = 15
	local zSpacing = 30  -- Increased from 15 to 30 to make room for conveyor
	local row = math.ceil(tableNum / tablesPerRow) - 1
	local col = (tableNum - 1) % tablesPerRow

	-- Center the grid on the platform
	local gridWidth = (tablesPerRow - 1) * xSpacing
	local gridHeight = (math.ceil(MaxTables / tablesPerRow) - 1) * zSpacing
	local xOffset = -gridWidth / 2  -- Center horizontally
	local zOffset = -gridHeight / 2 -- Center vertically

	local xPos = col * xSpacing + xOffset
	local zPos = row * zSpacing + zOffset

	-- Create the display table
	local displayTable = Instance.new("Part")
	displayTable.Name = "CardDisplayTable" .. tableNum
	displayTable.Size = Vector3.new(8, 1, 6)
	displayTable.Position = Vector3.new(xPos, 1, zPos)
	displayTable.Anchored = true
	displayTable.Material = Enum.Material.Wood
	displayTable.BrickColor = BrickColor.new("Brown")
	displayTable.Parent = workspace

	-- Create money collection mat next to the table
	local moneyMat = Instance.new("Part")
	moneyMat.Name = "MoneyCollectionMat" .. tableNum
	moneyMat.Size = Vector3.new(4, 1, 4) -- Made much thicker and larger for better detection
	moneyMat.Position = Vector3.new(xPos + 6, 0.5, zPos) -- Raised higher
	moneyMat.Anchored = true
	moneyMat.CanCollide = true
	moneyMat.Material = Enum.Material.Neon
	moneyMat.BrickColor = BrickColor.new("Bright green")
	moneyMat.Transparency = 0.5 -- More transparent so you can see through it
	moneyMat.Parent = workspace

	-- Create floating text display above the mat (no background part)
	local floatingText = Instance.new("Part")
	floatingText.Name = "FloatingTextAnchor" .. tableNum
	floatingText.Size = Vector3.new(0.1, 0.1, 0.1) -- Tiny invisible anchor
	floatingText.Position = Vector3.new(xPos + 6, 4, zPos) -- High above the money mat
	floatingText.Anchored = true
	floatingText.CanCollide = false
	floatingText.Transparency = 1 -- Completely invisible
	floatingText.Parent = workspace

	-- Add BillboardGui for floating text
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "MoneyTextDisplay"
	billboardGui.Size = UDim2.new(0, 200, 0, 100)
	billboardGui.StudsOffset = Vector3.new(0, 2, 0) -- Float 2 studs above the anchor
	billboardGui.Parent = floatingText

	local moneyText = Instance.new("TextLabel")
	moneyText.Size = UDim2.new(1, 0, 1, 0)
	moneyText.BackgroundTransparency = 1
	moneyText.Text = "💰 0"
	moneyText.TextColor3 = Color3.fromRGB(255, 255, 0) -- Bright yellow text
	moneyText.TextSize = 24
	moneyText.Font = Enum.Font.GothamBold
	moneyText.TextStrokeTransparency = 0
	moneyText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	moneyText.TextScaled = true
	moneyText.Parent = billboardGui

	-- Store reference to money mat for later use
	MoneyCollectionMats[tableNum] = moneyMat

	-- Add a simple test touch event to verify it's working
	moneyMat.Touched:Connect(function(hit)
		print("🚨 TOUCH TEST: Money mat", tableNum, "touched by:", hit.Name, "Parent:", hit.Parent and hit.Parent.Name or "nil")
	end)

	print("🚨 Table", tableNum, "created immediately!")
end
print("🚨 IMMEDIATE TABLE CREATION COMPLETE - Created", MaxTables, "tables!")

-- Initialize TablePlayerCounts immediately
for i = 1, MaxTables do
	TablePlayerCounts[i] = 0
end
print("🚨 TablePlayerCounts initialized immediately:", table.concat(TablePlayerCounts, ", "))

-- Define money collection functions immediately
local function calculateMoneyEarned(player)
	local userId = player.UserId
	if not DisplayCardEarnings[userId] then
		return 0
	end

	local displayedCards = DisplayTableData[userId] or {}
	if #displayedCards == 0 then
		return 0
	end

	local currentTime = tick()
	local lastCollection = DisplayCardEarnings[userId].lastCollection or currentTime
	local timeSinceLastCollection = currentTime - lastCollection

	-- Calculate money: flat 1 coin per second per card * time (10-second intervals only)
	local numDisplayedCards = #displayedCards
	
	-- Only award money for complete 10-second intervals (slows down tycoon system)
	-- Each card earns 1 coin per second (not their individual earningsPerSecond)
	local complete10SecondIntervals = math.floor(timeSinceLastCollection / 10)
	local moneyEarned = numDisplayedCards * complete10SecondIntervals * 10 -- 1 coin/sec/card * intervals * 10 sec
	return math.floor(moneyEarned)
end

local function collectMoneyFromDisplay(player)
	local userId = player.UserId
	if not DisplayCardEarnings[userId] then
		return 0
	end

	local currentTime = tick()
	local lastCollection = DisplayCardEarnings[userId].lastCollection or currentTime
	local timeSinceLastCollection = currentTime - lastCollection
	
	-- Calculate money for complete 10-second intervals
	local complete10SecondIntervals = math.floor(timeSinceLastCollection / 10)
	
	if complete10SecondIntervals > 0 then
		local displayedCards = DisplayTableData[userId] or {}
		local numDisplayedCards = #displayedCards
		
		-- Flat rate: 1 coin per second per card (not individual earningsPerSecond)
		local moneyEarned = numDisplayedCards * complete10SecondIntervals * 10
		
		-- Update collection timer to account for consumed intervals (preserve partial time)
		DisplayCardEarnings[userId].lastCollection = lastCollection + (complete10SecondIntervals * 10)
		print("💰 DEBUG: Collected", math.floor(moneyEarned), "coins for", player.Name, "from", complete10SecondIntervals, "intervals")
		
		return math.floor(moneyEarned)
	end

	return 0
end

-- Add touch events to money mats immediately
for tableNum = 1, MaxTables do
	local moneyMat = MoneyCollectionMats[tableNum]
	if moneyMat then
		moneyMat.Touched:Connect(function(hit)
			print("💰 DEBUG: Money mat", tableNum, "touched by:", hit.Name, "Parent:", hit.Parent and hit.Parent.Name or "nil")
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				print("💰 DEBUG: Player detected:", player.Name, "UserId:", player.UserId)
				-- Check if this is the player's assigned table
				local assignedTable = nil
				for userId, tn in pairs(TableAssignments) do
					if userId == player.UserId then
						assignedTable = tn
						break
					end
				end

				print("💰 DEBUG: Player", player.Name, "assigned to table:", assignedTable, "Current mat is for table:", tableNum)

				if assignedTable == tableNum then
					print("💰 DEBUG: Player", player.Name, "stepped on their money collection mat for table", tableNum)

					-- Check if player has displayed cards
					local displayedCards = DisplayTableData[player.UserId] or {}
					print("💰 DEBUG: Player", player.Name, "has", #displayedCards, "displayed cards")

					-- Check DisplayCardEarnings
					print("💰 DEBUG: DisplayCardEarnings for", player.Name, ":", DisplayCardEarnings[player.UserId] and "exists" or "nil")

					local moneyCollected = calculateMoneyEarned(player)
					print("💰 DEBUG: Money calculation result:", moneyCollected, "coins")

					if moneyCollected > 0 then
						-- Store the collection request in a global table to be processed later
						if not _G.PendingMoneyCollections then
							_G.PendingMoneyCollections = {}
						end

						table.insert(_G.PendingMoneyCollections, {
							player = player,
							amount = moneyCollected,
							timestamp = tick()
						})

						print("💰 DEBUG: Queued", moneyCollected, "coins for collection by", player.Name)

						-- REMOVED: Processing notification (was causing duplicate messages)
						-- The actual collection notification will come from the queue processor
					else
						print("💰 DEBUG: No money to collect for", player.Name)
						-- Send no money message
						local collectMoneyEvent = ReplicatedStorage:FindFirstChild("CollectMoneyEvent")
						if collectMoneyEvent then
							local result = {
								coinsCollected = 0,
								message = "Wait for 10-second intervals to complete! Check the display above your mat."
							}
							collectMoneyEvent:FireClient(player, result)
						end
					end
				else
					print("💰 DEBUG: Player", player.Name, "stepped on table", tableNum, "money mat but it's not their table")
				end
			else
				print("💰 DEBUG: Could not get player from character:", hit.Parent and hit.Parent.Name or "nil")
			end
		end)
		print("🚨 Added touch event to money mat", tableNum)
	end
end

print("🚨 ALL IMMEDIATE SETUP COMPLETE - Tables, mats, and touch events ready!")

-- Start money display update loop immediately
spawn(function()
	while wait(1) do -- Update every second
		for tableNum = 1, MaxTables do
			local textAnchor = workspace:FindFirstChild("FloatingTextAnchor" .. tableNum)
			if textAnchor then
				local billboardGui = textAnchor:FindFirstChild("MoneyTextDisplay")
				if billboardGui then
					local moneyText = billboardGui:FindFirstChild("TextLabel")
					if moneyText then
						-- Find the owner of this table
						local tableOwner = nil
						for userId, assignedTable in pairs(TableAssignments) do
							if assignedTable == tableNum then
								tableOwner = Players:GetPlayerByUserId(userId)
								break
							end
						end

						if tableOwner then
							local moneyWaiting = calculateMoneyEarned(tableOwner)
							local displayedCards = DisplayTableData[tableOwner.UserId] or {}
							local cardCount = #displayedCards

							if moneyWaiting > 0 then
								moneyText.Text = "💰 " .. moneyWaiting
								moneyText.TextColor3 = Color3.fromRGB(0, 255, 0) -- Bright green for available money
							elseif cardCount > 0 then
								moneyText.Text = "💰 0"
								moneyText.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow for earning but no money yet
							else
								moneyText.Text = "💰 ---"
								moneyText.TextColor3 = Color3.fromRGB(150, 150, 150) -- Gray for no cards
							end
						else
							moneyText.Text = "💰 ---"
							moneyText.TextColor3 = Color3.fromRGB(100, 100, 100) -- Gray for no owner
						end
					end
				end
			end
		end
	end
end)

print("🚨 MONEY DISPLAY UPDATE LOOP STARTED!")

-- NPC Card Battle System (moved to top to fix function order)

-- Check if player has free packs from battles
local function hasFreePacks(player)
	local playerData = PlayerDataCache[player.UserId]
	if playerData and playerData.packs then
		return #playerData.packs > 0
	end
	return false
end

-- Start a card battle with the NPC (moved to top to fix function order)
local function startCardBattle(player)
	-- Safety check for player parameter
	if not player then
		print("❌ ERROR: startCardBattle called with nil player parameter")
		return
	end

	if not player.Name then
		print("❌ ERROR: startCardBattle called with player that has no Name")
		return
	end

	-- Check battle cooldown (5 minutes)
	local currentTime = tick()
	local lastBattleTime = BattleCooldowns[player.UserId] or 0
	local cooldownTime = 300 -- 5 minutes in seconds

	if currentTime - lastBattleTime < cooldownTime then
		local remainingTime = math.ceil(cooldownTime - (currentTime - lastBattleTime))
		local minutes = math.floor(remainingTime / 60)
		local seconds = remainingTime % 60

		local message = Instance.new("Message")
		message.Text = "⏰ Battle cooldown active! Wait " .. minutes .. "m " .. seconds .. "s before battling again."
		message.Parent = workspace

		spawn(function()
			wait(3)
			if message then
				message:Destroy()
			end
		end)
		return
	end

	if BattleInProgress then
		return
	end

	BattleInProgress = true
	print("⚔️ Starting card battle with", player.Name)

	-- Show battle start message
	local message = Instance.new("Message")
	message.Text = "⚔️ Card Battle Starting! " .. player.Name .. " vs NPC"
	message.Parent = workspace

	-- Get player's cards
	local playerData = PlayerDataCache[player.UserId]
	print("🎴 Player data for", player.Name, ":", playerData and "exists" or "nil")
	print("🎴 DEBUG: PlayerDataCache contents:")
	for userId, data in pairs(PlayerDataCache) do
		print("🎴 DEBUG: UserId:", userId, "Data:", data and "exists" or "nil")
	end
	print("🎴 DEBUG: Looking for UserId:", player.UserId, "in PlayerDataCache")

	if not playerData then
		message.Text = "❌ Player data not loaded yet! Please wait a moment and try again."
		print("🎴 DEBUG: Attempting to load player data...")

		-- Try to load the player data
		local data = getPlayerData(player)
		if data then
			print("🎴 DEBUG: Successfully loaded player data, retrying battle...")
			playerData = data
		else
			print("🎴 DEBUG: Failed to load player data")
			local keys = {}
			for k, _ in pairs(PlayerDataCache) do
				table.insert(keys, tostring(k))
			end
			print("🎴 No player data found for", player.Name, "- PlayerDataCache keys:", table.concat(keys, ", "))
			spawn(function()
				wait(3)
				if message then
					message:Destroy()
				end
				BattleInProgress = false
			end)
			return
		end
	end

	if not playerData.cards then
		message.Text = "❌ No cards found in player data! Please open some packs first."
		local keys = {}
		for k, _ in pairs(playerData) do
			table.insert(keys, tostring(k))
		end
		print("🎴 No cards found for", player.Name, "- playerData keys:", table.concat(keys, ", "))
		spawn(function()
			wait(3)
			if message then
				message:Destroy()
			end
			BattleInProgress = false
		end)
		return
	end

	if #playerData.cards < 3 then
		message.Text = "❌ You need at least 3 cards to battle! You have " .. #playerData.cards .. " cards. Open some packs first."
		print("🎴 Not enough cards for", player.Name, "- has", #playerData.cards, "cards, needs 3")
		spawn(function()
			wait(3)
			if message then
				message:Destroy()
			end
			BattleInProgress = false
		end)
		return
	end

	print("🎴 Player", player.Name, "has", #playerData.cards, "cards available for battle")

	-- Pick 3 random cards for the player
	local playerCards = {}
	local availableCards = {}
	for _, card in pairs(playerData.cards) do
		table.insert(availableCards, card)
	end

	for i = 1, 3 do
		if #availableCards > 0 then
			local randomIndex = math.random(1, #availableCards)
			table.insert(playerCards, availableCards[randomIndex])
			table.remove(availableCards, randomIndex)
		end
	end

	PlayerBattleCards[player.UserId] = playerCards

	-- Generate 3 random NPC cards
	local npcCards = {}
	local cardNames = {"Ghost Town Saloon", "Desert Outlaw", "Mountain Bandit", "Canyon Ranger", "Prairie Sheriff", "Valley Gunslinger", "Ridge Cowboy", "Mesa Marshal", "Butte Deputy", "Plateau Rancher"}

	for i = 1, 3 do
		local randomName = cardNames[math.random(1, #cardNames)]
		local randomRarity = math.random(1, 100)
		local rarity
		local value

		if randomRarity <= 60 then
			rarity = "Common"
			value = math.random(50, 150)
		elseif randomRarity <= 85 then
			rarity = "Rare"
			value = math.random(200, 400)
		elseif randomRarity <= 95 then
			rarity = "Ultra Rare"
			value = math.random(500, 800)
		else
			rarity = "Legendary"
			value = math.random(1000, 2000)
		end

		table.insert(npcCards, {
			name = randomName,
			rarity = rarity,
			value = value
		})
	end

	NPCCards = npcCards

	-- Calculate total values
	local playerTotal = 0
	local npcTotal = 0

	for _, card in pairs(playerCards) do
		playerTotal = playerTotal + (card.value or 100)
	end

	for _, card in pairs(npcCards) do
		npcTotal = npcTotal + card.value
	end

	-- Determine winner
	local winner
	local battleResult

	if playerTotal > npcTotal then
		winner = player.Name
		battleResult = "Victory! 🏆"

		-- Give player a FREE card pack as reward!
		local rewardPack = "Basic"
		if playerTotal > npcTotal * 1.5 then
			rewardPack = "Premium"
		end
		if playerTotal > npcTotal * 2 then
			rewardPack = "Special"
		end

		-- Add FREE pack to player's inventory
		if not playerData.packs then
			playerData.packs = {}
		end

		table.insert(playerData.packs, {
			type = rewardPack,
			name = rewardPack .. " Pack",
			rarity = "Free Reward"
		})

		-- Save the updated data
		savePlayerData(player, playerData)

		message.Text = "🏆 " .. player.Name .. " wins the card battle! Total: " .. playerTotal .. " vs NPC: " .. npcTotal .. "\n🎁 FREE REWARD: " .. rewardPack .. " Pack added to inventory!"

		print("🏆", player.Name, "won card battle! Player:", playerTotal, "NPC:", npcTotal, "FREE Reward:", rewardPack)

		-- Set battle cooldown for this player
		BattleCooldowns[player.UserId] = tick()

	elseif npcTotal > playerTotal then
		winner = "NPC"
		battleResult = "Defeat 💀"
		message.Text = "💀 NPC wins the card battle! Total: " .. npcTotal .. " vs " .. player.Name .. ": " .. playerTotal .. "\n💪 Better luck next time!"

		print("💀 NPC won card battle! NPC:", npcTotal, "Player:", playerTotal)

		-- Set battle cooldown for this player (even on defeat)
		BattleCooldowns[player.UserId] = tick()

	else
		winner = "Tie"
		battleResult = "Tie 🤝"
		message.Text = "🤝 It's a tie! Both scored " .. playerTotal .. "\n🔄 Rematch available!"

		print("🤝 Card battle ended in tie! Score:", playerTotal)

		-- Set battle cooldown for this player (even on tie)
		BattleCooldowns[player.UserId] = tick()
	end

	-- Show battle details
	spawn(function()
		wait(5)
		if message then
			message:Destroy()
		end

		-- Show detailed battle results
		local battleReport = Instance.new("Message")
		battleReport.Text = "📊 Battle Report:\n" .. player.Name .. ": " .. playerTotal .. " points\nNPC: " .. npcTotal .. " points\nResult: " .. battleResult

		spawn(function()
			wait(5)
			if battleReport then
				battleReport:Destroy()
			end
			BattleInProgress = false
		end)
	end)

	-- Clear battle data
	PlayerBattleCards[player.UserId] = nil
	NPCCards = {}
end

-- Create minimal base (you can replace this with a model)
local function createMinimalBase()
	-- Just create a simple base part - you can replace this with a model
	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = Vector3.new(100, 1, 100)
	base.Position = Vector3.new(0, -0.5, 0)
	base.Anchored = true
	base.CanCollide = true
	base.Material = Enum.Material.SmoothPlastic
	base.BrickColor = BrickColor.new("Light gray")
	base.Parent = workspace

	print("📦 Created minimal base - you can replace this with a model")
end

-- DataStore for persistent player data
print("🔧 DEBUG: About to create DataStore...")
local PlayerDataStore = DataStoreService:GetDataStore("PlayerCardData")
print("🔧 DEBUG: DataStore created successfully")

-- Cache player data in memory for performance (moved to top)

-- Display table system - store displayed cards for all players (moved to top)

-- Function to get all displayed cards
local function getAllDisplayedCards()
	return DisplayTableData
end

-- Debug command handler
local function handleDebugCommand(player, message)
	if message:sub(1, 6) == "/debug " then
		local command = message:sub(7)
		if command == "assign" then
			local success = assignPlayerToTable(player)
			if success then
				print("🔧 DEBUG: Manual assignment successful for", player.Name)
			else
				print("🔧 DEBUG: Manual assignment failed for", player.Name)
			end
		elseif command == "status" then
			print("🔧 DEBUG: Current server status:")
			print("🔧 DEBUG: Players in game:", #Players:GetPlayers())
			print("🔧 DEBUG: Table assignments:", (function() local count = 0; for _ in pairs(TableAssignments) do count = count + 1 end; return count end)())
			print("🔧 DEBUG: Table player counts:", table.concat(TablePlayerCounts, ", "))
			print("🔧 DEBUG: Total calculated players:", (function() local total = 0; for _, count in pairs(TablePlayerCounts) do total = total + count end; return total end)())
		elseif command == "force" then
			print("🔧 DEBUG: Force broadcasting server capacity...")
			broadcastServerCapacity()
		elseif command == "reset" then
			print("🔧 DEBUG: Resetting table assignments...")
			TableAssignments = {}
			for i = 1, MaxTables do
				TablePlayerCounts[i] = 0
			end
			print("🔧 DEBUG: Table assignments reset")
		elseif command == "fix" then
			print("🔧 DEBUG: Attempting to fix table assignment for", player.Name)
			-- Force assign player to table 1
			local userId = player.UserId
			TableAssignments[userId] = 1
			TablePlayerCounts[1] = (TablePlayerCounts[1] or 0) + 1
			print("🔧 DEBUG: Manually assigned", player.Name, "to table 1")
			-- Fire the event
			tableAssignmentEvent:FireClient(player, 1)
			-- Broadcast capacity
			broadcastServerCapacity()
		end
	end
end

-- Create the RemoteEvent immediately
print("🔧 DEBUG: About to create RemoteEvents...")
local openPackEvent = Instance.new("RemoteEvent")
openPackEvent.Name = "OpenPackEvent"
openPackEvent.Parent = ReplicatedStorage
print("✅ OpenPackEvent created")

local dailyRewardEvent = Instance.new("RemoteEvent")
dailyRewardEvent.Name = "DailyRewardEvent"
dailyRewardEvent.Parent = ReplicatedStorage
print("✅ DailyRewardEvent created")

local sellCardEvent = Instance.new("RemoteEvent")
sellCardEvent.Name = "SellCardEvent"
sellCardEvent.Parent = ReplicatedStorage
print("✅ SellCardEvent created")

local cardSoldEvent = Instance.new("RemoteEvent")
cardSoldEvent.Name = "CardSoldEvent"
cardSoldEvent.Parent = ReplicatedStorage
print("✅ CardSoldEvent created")

local packOpenedEvent = Instance.new("RemoteEvent")
packOpenedEvent.Name = "PackOpenedEvent"
packOpenedEvent.Parent = ReplicatedStorage
print("✅ PackOpenedEvent created")

local collectionRewardEvent = Instance.new("RemoteEvent")
collectionRewardEvent.Name = "CollectionRewardEvent"
collectionRewardEvent.Parent = ReplicatedStorage
print("✅ CollectionRewardEvent created")

local setSellEvent = Instance.new("RemoteEvent")
setSellEvent.Name = "SetSellEvent"
setSellEvent.Parent = ReplicatedStorage
print("✅ SetSellEvent created")

local setSoldEvent = Instance.new("RemoteEvent")
setSoldEvent.Name = "SetSoldEvent"
setSoldEvent.Parent = ReplicatedStorage
print("✅ SetSoldEvent created")

local displayCardEvent = Instance.new("RemoteEvent")
displayCardEvent.Name = "DisplayCardEvent"
displayCardEvent.Parent = ReplicatedStorage
print("✅ DisplayCardEvent created")

local getDisplayCardsEvent = Instance.new("RemoteEvent")
getDisplayCardsEvent.Name = "GetDisplayCardsEvent"
getDisplayCardsEvent.Parent = ReplicatedStorage
print("✅ GetDisplayCardsEvent created")

local removeDisplayCardEvent = Instance.new("RemoteEvent")
removeDisplayCardEvent.Name = "RemoveDisplayCardEvent"
removeDisplayCardEvent.Parent = ReplicatedStorage
print("✅ RemoveDisplayCardEvent created")

local tableAssignmentEvent = Instance.new("RemoteEvent")
tableAssignmentEvent.Name = "TableAssignmentEvent"
tableAssignmentEvent.Parent = ReplicatedStorage
print("✅ TableAssignmentEvent created")

local serverCapacityEvent = Instance.new("RemoteEvent")
serverCapacityEvent.Name = "ServerCapacityEvent"
serverCapacityEvent.Parent = ReplicatedStorage
print("✅ ServerCapacityEvent created")

local requestTableEvent = Instance.new("RemoteEvent")
requestTableEvent.Name = "RequestTableEvent"
requestTableEvent.Parent = ReplicatedStorage
print("✅ RequestTableEvent created")

local npcDetectionEvent = Instance.new("RemoteEvent")
npcDetectionEvent.Name = "NPCDetectionEvent"
npcDetectionEvent.Parent = ReplicatedStorage
print("✅ NPCDetectionEvent created")

local startBattleEvent = Instance.new("RemoteEvent")
startBattleEvent.Name = "StartBattleEvent"
startBattleEvent.Parent = ReplicatedStorage
print("✅ StartBattleEvent created")

local collectMoneyEvent = Instance.new("RemoteEvent")
collectMoneyEvent.Name = "CollectMoneyEvent"
collectMoneyEvent.Parent = ReplicatedStorage
print("✅ CollectMoneyEvent created")

local getPlayerDataEvent = Instance.new("RemoteFunction")
getPlayerDataEvent.Name = "GetPlayerDataEvent"
getPlayerDataEvent.Parent = ReplicatedStorage
print("✅ GetPlayerDataEvent created")
print("🔧 DEBUG: All RemoteEvents created successfully")

-- Test if we can reach this point
print("🔧 DEBUG: TEST 1: RemoteEvents section completed")
print("🔧 DEBUG: TEST 1: About to define CollectionRewards...")

-- Collection completion rewards
print("🔧 DEBUG: About to define CollectionRewards...")
local CollectionRewards = {
	{threshold = 5, reward = {coins = 200, packs = 1}, name = "First Steps"},
	{threshold = 10, reward = {coins = 500, packs = 2}, name = "Growing Collection"},
	{threshold = 15, reward = {coins = 1000, packs = 3}, name = "Serious Collector"},
	{threshold = 20, reward = {coins = 2000, packs = 5}, name = "🎉 LEGEND OF THE WEST! 🎉", special = true}
}
print("🔧 DEBUG: CollectionRewards defined successfully")
print("🔧 DEBUG: TEST 2: CollectionRewards section completed")
print("🔧 DEBUG: TEST 2: About to define getPlayerData function...")

-- Load player data from DataStore or create default data
print("🔧 DEBUG: About to define getPlayerData function...")
local function getPlayerData(player)
	if not PlayerDataCache[player.UserId] then
		local success, data = pcall(function()
			return PlayerDataStore:GetAsync(player.UserId)
		end)

		if success and data then
			print("📊 Loaded saved data for", player.Name)
			-- Ensure new fields exist for existing players
			if not data.setSellingHistory then data.setSellingHistory = {} end
			if not data.totalSetsSold then data.totalSetsSold = 0 end
			if not data.setSellingValue then data.setSellingValue = 0 end
			PlayerDataCache[player.UserId] = data
		else
			print("📊 Creating new data for", player.Name)
			PlayerDataCache[player.UserId] = {
				coins = 500,
				cards = {},
				dailyStreak = 0,
				lastLogin = "",
				completionRewards = {}, -- Track which rewards have been claimed
				setSellingHistory = {}, -- Track which sets have been sold
				totalSetsSold = 0, -- Count of total sets sold
				setSellingValue = 0 -- Total value from set selling
			}
		end
	end
	return PlayerDataCache[player.UserId]
end
print("🔧 DEBUG: getPlayerData function defined successfully")
print("🔧 DEBUG: TEST 3: getPlayerData function section completed")
print("🔧 DEBUG: TEST 3: About to define other functions...")

-- Save player data to DataStore
local function savePlayerData(player)
	if PlayerDataCache[player.UserId] then
		local success, err = pcall(function()
			PlayerDataStore:SetAsync(player.UserId, PlayerDataCache[player.UserId])
		end)

		if success then
			print("💾 Saved data for", player.Name)
		else
			warn("❌ Failed to save data for", player.Name, ":", err)
		end
	end
end

-- Check for collection completion rewards
local function checkCollectionRewards(player, data)
	local uniqueCards = {}
	for _, card in ipairs(data.cards) do
		uniqueCards[card.id] = true
	end
	local uniqueCount = 0
	for _ in pairs(uniqueCards) do
		uniqueCount = uniqueCount + 1
	end

	local newRewards = {}
	for _, reward in ipairs(CollectionRewards) do
		local rewardId = "completion_" .. reward.threshold
		if uniqueCount >= reward.threshold and not data.completionRewards[rewardId] then
			data.completionRewards[rewardId] = true
			-- DON'T add coins here - we'll do it when sending the reward

			table.insert(newRewards, {
				name = reward.name,
				coins = reward.reward.coins,
				packs = reward.reward.packs,
				threshold = reward.threshold,
				special = reward.special or false,
				newCoins = data.coins + reward.reward.coins -- Calculate what the new total will be
			})
		end
	end

	-- Only add coins if we actually have new rewards
	if #newRewards > 0 then
		for _, reward in ipairs(newRewards) do
			data.coins = data.coins + reward.coins
		end
	end

	return newRewards, uniqueCount
end

-- Check if player has a complete set and calculate value
local function checkCompleteSet(data)
	local uniqueCards = {}
	local totalValue = 0

	-- Count unique cards and calculate total value
	for _, card in ipairs(data.cards) do
		if not uniqueCards[card.id] then
			uniqueCards[card.id] = true
			totalValue = totalValue + card.value
		end
	end

	local uniqueCount = 0
	for _ in pairs(uniqueCards) do
		uniqueCount = uniqueCount + 1
	end

	-- Check if they have all 20 cards (complete set)
	if uniqueCount >= 20 then
		return true, totalValue, uniqueCount
	end

	return false, totalValue, uniqueCount
end

-- Custom Image Card Pool (Brainrot Style)
cardPool = {
	-- Karen - The first custom card
	{
		name = "Karen", 
		rarity = "Uncommon", 
		value = 15, -- Purchase price
		earningsPerSecond = 2, -- Coins per second when displayed
		type = "Character", 
		id = "BR001", 
		imageId = "rbxassetid://114385430622242"
	},
	
	-- Skibidi Toilet - Peak brainrot meme
	{
		name = "Skibidi Toilet", 
		rarity = "Common", 
		value = 8, -- Cheap and common
		earningsPerSecond = 1, -- Basic earnings
		type = "Meme", 
		id = "BR002", 
		imageId = "rbxassetid://119915725273204"
	},
	
	-- Doom Scroll Dave - Social media addiction
	{
		name = "Doom Scroll Dave", 
		rarity = "Uncommon", 
		value = 20, -- Moderate price
		earningsPerSecond = 3, -- Good earnings for social media theme
		type = "Character", 
		id = "BR003", 
		imageId = "rbxassetid://75653783881447"
	},
	
	-- Ohio Final Boss - Ultra rare Ohio meme
	{
		name = "Ohio Final Boss", 
		rarity = "UltraRare", 
		value = 120, -- Expensive boss card
		earningsPerSecond = 6, -- Reduced from 12 for better balance
		type = "Boss", 
		id = "BR004", 
		imageId = "rbxassetid://120257323495301"
	},
	
	-- Rizz King - Charisma meme
	{
		name = "Rizz King", 
		rarity = "Rare", 
		value = 50, -- Premium charisma
		earningsPerSecond = 6, -- Good earnings for rare
		type = "Character", 
		id = "BR005", 
		imageId = "rbxassetid://111197793202364"
	},
	
	-- AI Life Coach - Modern tech anxiety
	{
		name = "AI Life Coach", 
		rarity = "Rare", 
		value = 45, -- Tech premium
		earningsPerSecond = 5, -- Steady AI earnings
		type = "Technology", 
		id = "BR006", 
		imageId = "rbxassetid://138384385514300"
	},
	
	-- Cancelvania Dracula - Cancel culture meets classic horror
	{
		name = "Cancelvania Dracula", 
		rarity = "UltraRare", 
		value = 100, -- Rare crossover meme
		earningsPerSecond = 5, -- Reduced from 10 for better balance
		type = "Character", 
		id = "BR007", 
		imageId = "rbxassetid://134486937300845"
	},
	
	-- Influencer Meltdown - The ultimate brainrot
	{
		name = "Influencer Meltdown", 
		rarity = "Secret", 
		value = 200, -- Expensive but not stretch goal level
		earningsPerSecond = 8, -- Reduced from 25 for better balance
		type = "Event", 
		id = "BR008", 
		imageId = "rbxassetid://127527676106137"
	},
	
	-- Scammy - Classic internet scammer
	{
		name = "Scammy", 
		rarity = "Uncommon", 
		value = 18, -- Moderate scammer price
		earningsPerSecond = 3, -- Decent earnings for scamming theme
		type = "Character", 
		id = "BR009", 
		imageId = "rbxassetid://95161765723028"
	},
	
	-- Lizard Button Slam - Gaming chaos
	{
		name = "Lizard Button Slam", 
		rarity = "Rare", 
		value = 45, -- Gaming themed card
		earningsPerSecond = 7, -- Good earnings for rare card
		type = "Action", 
		id = "BR010", 
		imageId = "rbxassetid://118264526473151"
	},
	
	-- Ball Hog - Sports themed
	{
		name = "Ball Hog", 
		rarity = "Common", 
		value = 25, -- Regular common card
		earningsPerSecond = 3, -- Standard earnings for common
		type = "Sports", 
		id = "BR011", 
		imageId = "rbxassetid://83229260490753"
	},
	
	-- STRETCH GOAL CARDS - Rare and Expensive (appear less frequently)
	-- Kpop Karaoke - Music/Entertainment themed
	{
		name = "Kpop Karaoke", 
		rarity = "Legendary", 
		value = 4500, -- 30+ minute goal (aspirational pricing)
		earningsPerSecond = 15, -- Reduced but still premium (was 50)
		type = "Entertainment", 
		id = "SG001", 
		imageId = "rbxassetid://115085450059148"
	},
	
	-- Admin Abuse Warrior - Gaming/Power themed
	{
		name = "Admin Abuse Warrior", 
		rarity = "Legendary", 
		value = 6000, -- Ultimate 45+ minute goal
		earningsPerSecond = 20, -- Reduced but highest in game (was 75)
		type = "Power", 
		id = "SG002", 
		imageId = "rbxassetid://100633884257174"
	},
	
	-- Drip Lord - From slaps collection, high-value aspirational card
	{
		name = "Drip Lord", 
		rarity = "Legendary", 
		value = 2000, -- Around $2,000 as requested
		earningsPerSecond = 10, -- Good earnings for Legendary
		type = "Style", 
		id = "SG003", 
		imageId = "rbxassetid://110110931369711"
	},
	
	-- Clipped - From Dumpster Fire collection, mid-tier card
	{
		name = "Clipped", 
		rarity = "Rare", 
		value = 55, -- Similar to other mid-tier Dumpster Fire cards
		earningsPerSecond = 6, -- Good earnings for Rare
		type = "Gaming", 
		id = "BR012", 
		imageId = "rbxassetid://79357107988447"
	}
}

-- Function to check if a card should get a mutation (5% chance) - made global for conveyor
function shouldGetMutation()
	return math.random(1, 100) <= 5 -- 5% chance
end

-- Function to generate a mutated card - made global for conveyor
function generateMutatedCard(baseCard)
	local mutatedCard = {
		name = baseCard.name,
		rarity = baseCard.rarity,
		value = baseCard.value * 2, -- 2x value
		condition = "Mint",
		id = baseCard.id,
		instanceId = game:GetService("HttpService"):GenerateGUID(false),
		mutation = "Error", -- Add mutation type
		originalValue = baseCard.value -- Store original value for reference
	}
	return mutatedCard
end

-- Function to create a visual display card on the table (similar to conveyor cards but smaller)
local function createVisualDisplayCard(cardData, tableNumber, position)
	-- Create card object (smaller than conveyor cards)
	local cardObject = Instance.new("Part")
	cardObject.Name = "DisplayCard_" .. cardData.name .. "_" .. cardData.instanceId
	cardObject.Size = Vector3.new(0.3, 4, 3)  -- Smaller than conveyor: 0.48, 7.2, 4.8
	cardObject.Position = position
	cardObject.Anchored = true
	cardObject.CanCollide = false
	cardObject.Material = Enum.Material.SmoothPlastic
	cardObject.BrickColor = BrickColor.new("White")
	cardObject.Parent = workspace

	-- Create surface GUIs for both visible faces (left and right)
	local cardGuiLeft = Instance.new("SurfaceGui")
	cardGuiLeft.Name = "CardGUILeft"
	cardGuiLeft.Face = Enum.NormalId.Left
	cardGuiLeft.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	cardGuiLeft.PixelsPerStud = 50
	cardGuiLeft.Parent = cardObject

	local cardGuiRight = Instance.new("SurfaceGui")
	cardGuiRight.Name = "CardGUIRight"
	cardGuiRight.Face = Enum.NormalId.Right
	cardGuiRight.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	cardGuiRight.PixelsPerStud = 50
	cardGuiRight.Parent = cardObject

	-- Create the main card frame
	local cardFrame = Instance.new("Frame")
	cardFrame.Size = UDim2.new(1, 0, 1, 0)
	cardFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	cardFrame.BorderSizePixel = 0
	cardFrame.Parent = cardGuiLeft

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = cardFrame

	-- Card image (80% of the card)
	local cardImage = Instance.new("ImageLabel")
	cardImage.Size = UDim2.new(0.8, 0, 0.8, 0)
	cardImage.Position = UDim2.new(0.1, 0, 0.1, 0)
	cardImage.BackgroundTransparency = 1
	cardImage.Image = cardData.imageId or ""
	cardImage.ScaleType = Enum.ScaleType.Crop
	cardImage.Parent = cardFrame

	local imageCorner = Instance.new("UICorner")
	imageCorner.CornerRadius = UDim.new(0, 6)
	imageCorner.Parent = cardImage

	-- Info panel (bottom 20%)
	local infoFrame = Instance.new("Frame")
	infoFrame.Size = UDim2.new(1, 0, 0.2, 0)
	infoFrame.Position = UDim2.new(0, 0, 0.8, 0)
	infoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	infoFrame.BorderSizePixel = 0
	infoFrame.Parent = cardFrame

	-- Card name (left side of info panel)
	local cardName = Instance.new("TextLabel")
	cardName.Size = UDim2.new(0.6, 0, 1, 0)
	cardName.Position = UDim2.new(0.02, 0, 0, 0)
	cardName.BackgroundTransparency = 1
	cardName.Text = cardData.name
	cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
	cardName.TextScaled = true
	cardName.Font = Enum.Font.GothamBold
	cardName.TextXAlignment = Enum.TextXAlignment.Left
	cardName.Parent = infoFrame

	-- Earnings label (right side of info panel)
	local earningsLabel = Instance.new("TextLabel")
	earningsLabel.Size = UDim2.new(0.35, 0, 1, 0)
	earningsLabel.Position = UDim2.new(0.63, 0, 0, 0)
	earningsLabel.BackgroundTransparency = 1
	earningsLabel.Text = "📈 +" .. (cardData.earningsPerSecond or 1) .. "/sec"
	earningsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	earningsLabel.TextScaled = true
	earningsLabel.Font = Enum.Font.Gotham
	earningsLabel.TextXAlignment = Enum.TextXAlignment.Right
	earningsLabel.Parent = infoFrame

	-- Create the same design for the right face
	local cardFrameRight = cardFrame:Clone()
	cardFrameRight.Parent = cardGuiRight

	-- Add mutation effects if card is mutated
	if cardData.mutation and cardData.mutation == "Error" then
		-- Add mutation filter to both faces
		for _, gui in pairs({cardGuiLeft, cardGuiRight}) do
			local frame = gui:FindFirstChild("Frame")
			local image = frame and frame:FindFirstChild("ImageLabel")
			if frame and image then
				-- Red corruption filter overlay (as sibling to preserve original image)
				local mutationFilter = Instance.new("Frame")
				mutationFilter.Name = "MutationFilter"
				mutationFilter.Size = image.Size
				mutationFilter.Position = image.Position
				mutationFilter.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				mutationFilter.BackgroundTransparency = 0.8
				mutationFilter.BorderSizePixel = 0
				mutationFilter.ZIndex = 5
				mutationFilter.Parent = frame

				local filterCorner = Instance.new("UICorner")
				filterCorner.CornerRadius = UDim.new(0, 6)
				filterCorner.Parent = mutationFilter

				-- Add warning symbol
				local warningSymbol = Instance.new("TextLabel")
				warningSymbol.Name = "MutationWarning"
				warningSymbol.Size = UDim2.new(0, 15, 0, 15)
				warningSymbol.Position = UDim2.new(1, -18, 0, 3)
				warningSymbol.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				warningSymbol.BackgroundTransparency = 0.3
				warningSymbol.Text = "⚠️"
				warningSymbol.TextColor3 = Color3.fromRGB(255, 255, 0)
				warningSymbol.TextSize = 12
				warningSymbol.Font = Enum.Font.GothamBold
				warningSymbol.ZIndex = 10
				warningSymbol.Parent = frame

				local symbolCorner = Instance.new("UICorner")
				symbolCorner.CornerRadius = UDim.new(0, 8)
				symbolCorner.Parent = warningSymbol
			end
		end

		-- Tint the card object itself slightly
		cardObject.Color = Color3.fromRGB(255, 200, 200)
	end

	return cardObject
end

-- Function to update visual display cards for a player's table
local function updateVisualDisplayCards(player)
	print("🎴 DEBUG: updateVisualDisplayCards called for", player.Name)
	local userId = player.UserId
	local assignedTable = TableAssignments[userId]
	if not assignedTable then
		print("🎴 DEBUG: No assigned table for", player.Name)
		return
	end
	print("🎴 DEBUG: Player", player.Name, "assigned to table", assignedTable)

	-- Remove existing display cards
	for _, obj in pairs(workspace:GetChildren()) do
		if obj.Name:find("DisplayCard_") and obj:GetAttribute("PlayerUserId") == userId then
			obj:Destroy()
		end
	end

	-- Get player's displayed cards
	local displayedCards = DisplayTableData[userId] or {}
	print("🎴 DEBUG: Found", #displayedCards, "displayed cards for", player.Name)
	
	-- Create visual cards in a 2x2 grid on the table
	for i, displayCard in ipairs(displayedCards) do
		if i <= 4 then -- Max 4 cards
			local table = workspace:FindFirstChild("CardDisplayTable" .. assignedTable)
			if table then
				-- Calculate position in 2x2 grid on table (improved spacing)
				local row = math.ceil(i / 2) -- 2 cards per row
				local col = ((i - 1) % 2) + 1
				local xOffset = (col - 1.5) * 2.5 -- 2.5 units apart (wider spacing)
				local zOffset = (row - 1.5) * 2.5 -- 2.5 units apart (deeper spacing)
				
				local cardPosition = table.Position + Vector3.new(xOffset, 2.5, zOffset) -- Above table
				print("🎴 DEBUG: Creating visual card", i, "for", player.Name, "at position:", cardPosition, "row:", row, "col:", col)
				
				local success, visualCard = pcall(function()
					return createVisualDisplayCard(displayCard.card, assignedTable, cardPosition)
				end)
				
				if success and visualCard then
					-- Tag the card with player info for cleanup
					visualCard:SetAttribute("PlayerUserId", userId)
					visualCard:SetAttribute("CardInstanceId", displayCard.card.instanceId)
					
					print("🎴 DEBUG: Visual card", i, "created successfully:", visualCard.Name)
				else
					print("🎴 ERROR: Failed to create visual card", i, "for", player.Name, "Error:", visualCard)
				end
			else
				print("🎴 DEBUG: Table not found for", player.Name, "assigned table:", assignedTable)
			end
		end
	end
end

-- Function to add a card to the display table
local function addCardToDisplayTable(player, cardInstanceId)
	local data = getPlayerData(player)

	-- Find the card in player's collection
	local cardToDisplay = nil
	for _, card in ipairs(data.cards) do
		if card.instanceId == cardInstanceId then
			cardToDisplay = card
			break
		end
	end

	if not cardToDisplay then
		print("❌ Card not found for display:", cardInstanceId, "for player", player.Name)
		return false
	end

	-- Initialize display table for this player if it doesn't exist
	if not DisplayTableData[player.UserId] then
		DisplayTableData[player.UserId] = {}
	end

	-- Check if player already has 10 cards displayed (max display limit)
	if #DisplayTableData[player.UserId] >= MaxDisplayCards then
		print("❌ Player", player.Name, "already has maximum cards displayed (" .. MaxDisplayCards .. ")")
		return false
	end

	-- Add card to display table
	table.insert(DisplayTableData[player.UserId], {
		playerName = player.Name,
		card = cardToDisplay,
		displayTime = os.time()
	})

	-- Initialize money earning for this player if not already done
	if not DisplayCardEarnings[player.UserId] then
		DisplayCardEarnings[player.UserId] = {
			lastCollection = tick(), -- Initialize to current time
			totalEarned = 0
		}
		print("💰 Initialized money earning system for", player.Name, "at time", tick())
	end

	print("✅ Added card", cardToDisplay.name, "to display table for", player.Name, "- Now earning money!")
	
	-- Update visual display cards
	updateVisualDisplayCards(player)
	
	return true
end

-- Function to remove a card from the display table
local function removeCardFromDisplayTable(player, cardInstanceId)
	if not DisplayTableData[player.UserId] then
		return false
	end

	for i, displayCard in ipairs(DisplayTableData[player.UserId]) do
		if displayCard.card.instanceId == cardInstanceId then
			table.remove(DisplayTableData[player.UserId], i)
			print("✅ Removed card", displayCard.card.name, "from display table for", player.Name)
			
			-- Update visual display cards
			updateVisualDisplayCards(player)
			
			return true
		end
	end

	return false
end

-- Function to get all displayed cards
local function getAllDisplayedCards()
	local allCards = {}
	for userId, playerCards in pairs(DisplayTableData) do
		for _, displayCard in ipairs(playerCards) do
			table.insert(allCards, displayCard)
		end
	end
	return allCards
end

-- Function to calculate money earned from displayed cards
local function calculateMoneyEarned(player)
	print("💰 calculateMoneyEarned called for", player.Name)
	local earnings = DisplayCardEarnings[player.UserId]
	if not earnings then 
		print("💰 No earnings data found for", player.Name)
		return 0 
	end

	local displayedCards = DisplayTableData[player.UserId] or {}
	local currentTime = tick()
	local timeSinceLastCollection = currentTime - earnings.lastCollection

	print("💰 Money calculation for", player.Name, ":")
	print("💰   - Displayed cards:", #displayedCards)
	print("💰   - Money earning rate:", MoneyEarningRate)
	print("💰   - Time since last collection:", timeSinceLastCollection, "seconds")
	print("💰   - Last collection time:", earnings.lastCollection)
	print("💰   - Current time:", currentTime)

	-- Calculate money earned (coins per second per card)
	local moneyEarned = #displayedCards * MoneyEarningRate * timeSinceLastCollection

	print("💰   - Raw money earned:", moneyEarned)
	print("💰   - Final money earned:", math.floor(moneyEarned))

	return math.floor(moneyEarned)
end

-- Function to update money displays for all tables
local function updateMoneyDisplays()
	-- Debug: Only print every 10 seconds to avoid spam
	if tick() % 10 < 1 then
		print("🔧 DEBUG: updateMoneyDisplays() called - checking", MaxTables, "tables")
	end

	for tableNum = 1, MaxTables do
		local moneyDisplay = workspace:FindFirstChild("MoneyValueDisplay" .. tableNum)
		if moneyDisplay then
			local textLabel = moneyDisplay:FindFirstChild("MoneyValueGui"):FindFirstChild("TextLabel")
			if textLabel then
				-- Find which player owns this table
				local tableOwner = nil
				for userId, assignedTable in pairs(TableAssignments) do
					if assignedTable == tableNum then
						tableOwner = Players:GetPlayerByUserId(userId)
						break
					end
				end

				if tableOwner then
					-- Calculate money waiting to be collected
					local earnings = DisplayCardEarnings[tableOwner.UserId]
					if earnings then
						local displayedCards = DisplayTableData[tableOwner.UserId] or {}
						local currentTime = tick()
						local timeSinceLastCollection = currentTime - earnings.lastCollection
						
						-- Calculate money for complete 10-second intervals only
						local complete10SecondIntervals = math.floor(timeSinceLastCollection / 10)
						local numDisplayedCards = #displayedCards
						
						-- Flat rate: 1 coin per second per card (not individual earningsPerSecond)
						local moneyWaiting = math.floor(numDisplayedCards * complete10SecondIntervals * 10)
						
						-- Show progress for partial intervals
						local remainingTime = timeSinceLastCollection % 10
						local progressSeconds = math.floor(remainingTime)
						
						if moneyWaiting > 0 then
							textLabel.Text = "💰 " .. moneyWaiting .. " coins"
						elseif numDisplayedCards > 0 and progressSeconds > 0 then
							-- Show progress toward next collection
							textLabel.Text = "⏳ " .. progressSeconds .. "/10s (" .. numDisplayedCards .. " cards)"
						else
							textLabel.Text = "💰 0 coins"
						end
					else
						textLabel.Text = "💰 0 coins"
					end
				else
					-- No owner, show 0
					textLabel.Text = "💰 0 coins"
				end
			end
		end
	end
end

-- Function to collect money from displayed cards
local function collectMoneyFromDisplay(player)
	print("💰 collectMoneyFromDisplay called for", player.Name)
	local earnings = DisplayCardEarnings[player.UserId]
	if not earnings then 
		print("💰 No earnings data found for", player.Name)
		return 0 
	end

	local moneyEarned = calculateMoneyEarned(player)
	print("💰 Calculated money earned for", player.Name, ":", moneyEarned, "coins")
	if moneyEarned <= 0 then 
		print("💰 No money to collect for", player.Name)
		return 0 
	end

	-- Update player's coins
	local data = getPlayerData(player)
	data.coins = data.coins + moneyEarned

	-- Update earnings tracking
	earnings.lastCollection = tick()
	earnings.totalEarned = earnings.totalEarned + moneyEarned

	-- Update money display for this player's table
	local assignedTable = nil
	for userId, tableNum in pairs(TableAssignments) do
		if userId == player.UserId then
			assignedTable = tableNum
			break
		end
	end

	if assignedTable then
		local moneyDisplay = workspace:FindFirstChild("MoneyValueDisplay" .. assignedTable)
		if moneyDisplay then
			local textLabel = moneyDisplay:FindFirstChild("MoneyValueGui"):FindFirstChild("TextLabel")
			if textLabel then
				textLabel.Text = "💰 0 coins"
				print("💰 Updated money display for table", assignedTable, "to 0 coins")
			end
		end
	end

	-- Save player data
	savePlayerData(player)

	print("💰 Player", player.Name, "collected", moneyEarned, "coins from displayed cards")
	return moneyEarned
end

openPackEvent.OnServerEvent:Connect(function(player, packType)
	print("🎁 Player", player.Name, "opening", packType, "pack")

	-- EMERGENCY CLEANUP: Run cleanup when player first opens a pack (to catch persistent objects)
	if not _G.EmergencyCleanupRun then
		print("🚨 EMERGENCY CLEANUP: Running cleanup due to pack opening...")
		_G.EmergencyCleanupRun = true
		
		local removedCount = 0
		for _, obj in pairs(workspace:GetChildren()) do
			if obj:IsA("Part") then
				local shouldRemove = false
				
				-- Check for old table/mat patterns with display boards
				if (obj.Name:match("Table") or obj.Name:match("Mat") or obj.Name:match("Display")) and
					not (obj.Name:match("CardDisplayTable") or obj.Name:match("MoneyCollectionMat") or 
						obj.Name:match("FloatingTextAnchor")) then
					
					-- Additional check: does it have display boards?
					for _, child in pairs(obj:GetChildren()) do
						if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
							shouldRemove = true
							break
						end
					end
				end
				
				-- Check for objects in the conveyor area that shouldn't be there
				if math.abs(obj.Position.Z) <= 8 and obj.Position.Y >= 0 and obj.Position.Y <= 10 then
					if not (obj.Name:match("ConveyorBelt") or obj.Name:match("ConveyorRail") or
						obj.Name:match("CardDisplayTable") or obj.Name:match("MoneyCollectionMat") or
						obj.Name:match("FloatingTextAnchor") or obj.Name:match("Base") or
						obj.Name:match("ConveyorCard")) then
						
						-- If it has display boards, it's definitely old
						for _, child in pairs(obj:GetChildren()) do
							if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
								shouldRemove = true
								break
							end
						end
					end
				end
				
				if shouldRemove then
					print("🚨 EMERGENCY: Removing persistent old object:", obj.Name, "at position", obj.Position)
					obj:Destroy()
					removedCount = removedCount + 1
				end
			end
		end
		
		if removedCount > 0 then
			print("🚨 EMERGENCY CLEANUP: Removed", removedCount, "old objects during pack opening")
		else
			print("🚨 EMERGENCY CLEANUP: No old objects found")
		end
	end

	local data = getPlayerData(player)
	local packCosts = {Basic = 100, Premium = 250, Special = 500}
	local packSizes = {Basic = 5, Premium = 8, Special = 12}

	local cost = packCosts[packType] or 100
	local size = packSizes[packType] or 3

	if data.coins < cost then
		print("❌ Player", player.Name, "doesn't have enough coins")
		return
	end

	data.coins = data.coins - cost
	local openedCards = {}

	-- Generate random cards using weighted rarity system
	for i = 1, size do
		local randomCard = getRandomCardFromPool(false) -- false = for packs (rare legendaries)
		if not randomCard then
			print("❌ Failed to generate card for pack, skipping...")
			continue
		end

		-- Check if this card should get a mutation (1% chance) 
		local newCard
		if shouldGetMutation() then
			newCard = generateMutatedCard(randomCard)
			print("🎭 MUTATION! Card", randomCard.name, "got Error mutation - Value:", randomCard.value, "→", newCard.value)
		else
			newCard = {
				name = randomCard.name,
				rarity = randomCard.rarity,
				value = randomCard.value,
				earningsPerSecond = randomCard.earningsPerSecond or 1, -- Include earnings per second
				condition = "Mint",
				id = randomCard.id, -- Use the card's actual ID
				imageId = randomCard.imageId, -- Include custom image
				type = randomCard.type, -- Include card type
				instanceId = game:GetService("HttpService"):GenerateGUID(false) -- For individual card instances
			}
		end

		table.insert(openedCards, newCard)
		table.insert(data.cards, newCard)
	end

	-- Send back to client
	local result = {
		cards = openedCards,
		newCoins = data.coins,
		achievements = {}
	}

	-- Check for collection completion rewards
	local collectionRewards, uniqueCount = checkCollectionRewards(player, data)
	result.collectionRewards = collectionRewards
	result.uniqueCardCount = uniqueCount

	packOpenedEvent:FireClient(player, result)
	print("📦 Sent", #openedCards, "cards to", player.Name, "- New balance:", data.coins, "- Unique cards:", uniqueCount)

	-- Save player data after pack opening
	savePlayerData(player)

	-- Send collection completion rewards if any
	if #collectionRewards > 0 then
		for _, reward in ipairs(collectionRewards) do
			collectionRewardEvent:FireClient(player, reward)
			print("🏆 Collection reward earned:", reward.name, "for", reward.threshold, "unique cards")
		end
	end
end)

-- Create daily reward response event
local dailyRewardReceivedEvent = Instance.new("RemoteEvent")
dailyRewardReceivedEvent.Name = "DailyRewardReceivedEvent"
dailyRewardReceivedEvent.Parent = ReplicatedStorage
print("✅ DailyRewardReceivedEvent created")

dailyRewardEvent.OnServerEvent:Connect(function(player)
	print("🎁 Daily reward requested by", player.Name)

	local data = getPlayerData(player)
	local today = os.date("%Y-%m-%d")

	if data.lastLogin ~= today then
		data.dailyStreak = data.dailyStreak + 1
		data.lastLogin = today

		-- Give coins and free pack cards
		local coinReward = 100
		local freePackCards = {}

		data.coins = data.coins + coinReward

		-- Give 1 free pack worth of cards using weighted rarity
		for i = 1, 5 do
			local randomCard = getRandomCardFromPool(false) -- false = for packs (rare legendaries)
			if not randomCard then
				print("❌ Failed to generate starter card, skipping...")
				continue
			end

			-- Check if this card should get a mutation (1% chance)
			local newCard
			if shouldGetMutation() then
				newCard = generateMutatedCard(randomCard)
				print("🎭 MUTATION! Daily reward card", randomCard.name, "got Error mutation - Value:", randomCard.value, "→", newCard.value)
			else
				newCard = {
					name = randomCard.name,
					rarity = randomCard.rarity,
					value = randomCard.value,
					condition = "Mint",
					id = randomCard.id, -- Use the card's actual ID
					instanceId = game:GetService("HttpService"):GenerateGUID(false) -- For individual instances
				}
			end

			table.insert(freePackCards, newCard)
			table.insert(data.cards, newCard)
		end

		local reward = {
			coins = coinReward, 
			packs = 1, 
			day = data.dailyStreak,
			newCoins = data.coins,
			freeCards = freePackCards
		}

		dailyRewardReceivedEvent:FireClient(player, reward)
		print("💰 Sent daily reward to", player.Name, "- Streak:", data.dailyStreak, "New balance:", data.coins)

		-- Save player data after daily reward
		savePlayerData(player)

		-- Also send the free cards as a pack opening
		wait(1) -- Small delay so the daily reward shows first
		local freePackResult = {
			cards = freePackCards,
			newCoins = data.coins,
			achievements = {}
		}
		packOpenedEvent:FireClient(player, freePackResult)
		print("🎁 Sent free pack cards to", player.Name)
	else
		print("❌ Player", player.Name, "already claimed daily reward today")
	end
end)

sellCardEvent.OnServerEvent:Connect(function(player, instanceId, cardName)
	local data = getPlayerData(player)

	-- Find the card by instanceId
	local cardIndex = nil
	local card = nil
	for i, playerCard in ipairs(data.cards) do
		if playerCard.instanceId == instanceId then
			cardIndex = i
			card = playerCard
			break
		end
	end

	if card and cardIndex then
		-- Server calculates the actual sell price (don't trust client)
		local actualSellPrice = card.value -- Full card value

		print("💰 Player", player.Name, "selling", card.name, "for", actualSellPrice, "coins (was:", card.value, "value)")

		-- Remove card from collection
		table.remove(data.cards, cardIndex)

		-- Add coins to player
		data.coins = data.coins + actualSellPrice

		print("✅ Sold", card.name, "for", actualSellPrice, "coins. New balance:", data.coins)

		-- Notify client of successful sale
		cardSoldEvent:FireClient(player, {
			cardName = card.name,
			sellPrice = actualSellPrice,
			newCoins = data.coins,
			instanceId = instanceId -- Send back instanceId so client can remove the right card
		})

		-- Save player data after card sale
		savePlayerData(player)
	else
		print("❌ Card not found with instanceId:", instanceId, "for player", player.Name)
	end
end)

-- Handle set selling requests
setSellEvent.OnServerEvent:Connect(function(player)
	local data = getPlayerData(player)

	-- Check if player has a complete set
	local hasCompleteSet, totalValue, uniqueCount = checkCompleteSet(data)

	if hasCompleteSet then
		-- Calculate 2x value for the complete set
		local setSellValue = totalValue * 2

		print("🎯 Player", player.Name, "selling complete set for", setSellValue, "coins (2x", totalValue, ")")

		-- Remove only one copy of each unique card (preserve duplicates)
		local cardsToRemove = {}
		local uniqueCardIds = {}

		-- First pass: identify which unique cards to remove
		for _, card in ipairs(data.cards) do
			if not uniqueCardIds[card.id] then
				uniqueCardIds[card.id] = true
				table.insert(cardsToRemove, card.id)
			end
		end

		-- Second pass: remove one copy of each unique card
		for i = #data.cards, 1, -1 do
			local card = data.cards[i]
			for j, cardIdToRemove in ipairs(cardsToRemove) do
				if card.id == cardIdToRemove then
					table.remove(data.cards, i)
					table.remove(cardsToRemove, j)
					break
				end
			end
		end

		print("📊 Removed", 20, "unique cards, kept", #data.cards, "duplicate cards")

		-- Add coins to player
		data.coins = data.coins + setSellValue

		-- Track set selling history
		local setId = "wildwest_complete_" .. os.time()
		data.setSellingHistory[setId] = {
			timestamp = os.time(),
			setValue = totalValue,
			sellValue = setSellValue,
			cardCount = uniqueCount
		}
		data.totalSetsSold = data.totalSetsSold + 1
		data.setSellingValue = data.setSellingValue + setSellValue

		print("✅ Sold complete set for", setSellValue, "coins. New balance:", data.coins, "- Total sets sold:", data.totalSetsSold)

		-- Notify client of successful set sale
		setSoldEvent:FireClient(player, {
			success = true,
			setValue = totalValue,
			sellValue = setSellValue,
			newCoins = data.coins,
			totalSetsSold = data.totalSetsSold,
			setSellingValue = data.setSellingValue
		})

		-- Save player data after set sale
		savePlayerData(player)
	else
		print("❌ Player", player.Name, "doesn't have a complete set. Current unique cards:", uniqueCount, "/20")

		-- Notify client that they don't have a complete set
		setSoldEvent:FireClient(player, {
			success = false,
			message = "You need all 20 unique cards to sell the complete set!",
			currentCards = uniqueCount,
			requiredCards = 20
		})

		print("❌ Sent set sell error to", player.Name, "- Need", 20 - uniqueCount, "more unique cards")
	end
end)

-- Handle GetPlayerData requests from client
getPlayerDataEvent.OnServerInvoke = function(player)
	return getPlayerData(player)
end

-- Handle display card requests
displayCardEvent.OnServerEvent:Connect(function(player, cardInstanceId)
	print("🎴 Player", player.Name, "requesting to display card:", cardInstanceId)

	local success = addCardToDisplayTable(player, cardInstanceId)
	if success then
		-- Notify all players about the new display
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			getDisplayCardsEvent:FireClient(otherPlayer, getAllDisplayedCards())
		end
	else
		print("❌ Failed to display card for", player.Name)
	end
end)

-- Handle remove display card requests
removeDisplayCardEvent.OnServerEvent:Connect(function(player, cardInstanceId)
	print("🗑️ Player", player.Name, "requesting to remove display card:", cardInstanceId)

	local success = removeCardFromDisplayTable(player, cardInstanceId)
	if success then
		-- Notify all players about the updated display
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			getDisplayCardsEvent:FireClient(otherPlayer, getAllDisplayedCards())
		end
	else
		print("❌ Failed to remove display card for", player.Name)
	end
end)

-- Handle table assignment requests
requestTableEvent.OnServerEvent:Connect(function(player)
	print("🔄 Player", player.Name, "requesting table assignment")

	-- Check if player already has a table
	if TableAssignments[player.UserId] then
		local currentTable = TableAssignments[player.UserId]
		print("✅ Player", player.Name, "already assigned to table", currentTable)
		tableAssignmentEvent:FireClient(player, currentTable)
		return
	end

	-- Assign player to a table
	local assignedTable = assignPlayerToTable(player)
	print("🎯 Manually assigned player", player.Name, "to table", assignedTable)

	-- Notify client about table assignment
	tableAssignmentEvent:FireClient(player, assignedTable)

	-- Broadcast updated capacity to all players
	if broadcastServerCapacity then
		broadcastServerCapacity()
	end
end)

-- Debug: Add a command to manually assign players to tables
local function debugAssignPlayerToTable(playerName)
	local player = Players:FindFirstChild(playerName)
	if player then
		print("🔧 DEBUG: Manually assigning", playerName, "to table")
		local assignedTable = assignPlayerToTable(player)
		print("🔧 DEBUG:", playerName, "assigned to table", assignedTable)
		tableAssignmentEvent:FireClient(player, assignedTable)
		return true
	else
		print("🔧 DEBUG: Player", playerName, "not found")
		return false
	end
end

-- Debug command handler
local function handleDebugCommand(player, message)
	if message:sub(1, 6) == "/debug " then
		local command = message:sub(7)
		if command == "assign" then
			local success = debugAssignPlayerToTable(player.Name)
			if success then
				print("🔧 DEBUG: Manual assignment successful for", player.Name)
			else
				print("🔧 DEBUG: Manual assignment failed for", player.Name)
			end
		elseif command == "status" then
			print("🔧 DEBUG: Current server status:")
			print("🔧 DEBUG: Players in game:", #Players:GetPlayers())
			print("🔧 DEBUG: Table assignments:", (function() local count = 0; for _ in pairs(TableAssignments) do count = count + 1 end; return count end)())
			print("🔧 DEBUG: Table player counts:", table.concat(TablePlayerCounts, ", "))
			print("🔧 DEBUG: Total calculated players:", (function() local total = 0; for _, count in pairs(TablePlayerCounts) do total = total + count end; return total end)())
		elseif command == "force" then
			print("🔧 DEBUG: Force broadcasting server capacity...")
			broadcastServerCapacity()
		elseif command == "reset" then
			print("🔧 DEBUG: Resetting table assignments...")
			TableAssignments = {}
			for i = 1, MaxTables do
				TablePlayerCounts[i] = 0
			end
			print("🔧 DEBUG: Table assignments reset")
		elseif command == "fix" then
			print("🔧 DEBUG: Attempting to fix table assignment for", player.Name)
			-- Force assign player to table 1
			local userId = player.UserId
			TableAssignments[userId] = 1
			TablePlayerCounts[1] = (TablePlayerCounts[1] or 0) + 1
			print("🔧 DEBUG: Manually assigned", player.Name, "to table 1")
			-- Fire the event
			tableAssignmentEvent:FireClient(player, 1)
			-- Broadcast capacity
			broadcastServerCapacity()
		elseif command == "money" then
			print("🔧 DEBUG: Testing money collection for", player.Name)
			print("🔧 DEBUG: DisplayCardEarnings for", player.Name, ":", DisplayCardEarnings[player.UserId] and "exists" or "nil")
			print("🔧 DEBUG: DisplayTableData for", player.Name, ":", DisplayTableData[player.UserId] and #DisplayTableData[player.UserId] .. " cards" or "nil")
			local moneyCollected = collectMoneyFromDisplay(player)
			print("🔧 DEBUG: Money collection result:", moneyCollected, "coins")
		elseif command == "createtables" then
			print("🔧 DEBUG: Manually creating display tables...")
			createDisplayTables()
		elseif command == "checktables" then
			print("🔧 DEBUG: Checking existing tables in workspace...")
			for i = 1, MaxTables do
				local table = workspace:FindFirstChild("CardDisplayTable" .. i)
				local mat = workspace:FindFirstChild("MoneyCollectionMat" .. i)
				local display = workspace:FindFirstChild("MoneyValueDisplay" .. i)
				print("🔧 DEBUG: Table", i, ":", table and "EXISTS" or "MISSING")
				print("🔧 DEBUG: Mat", i, ":", mat and "EXISTS" or "MISSING")
				print("🔧 DEBUG: Display", i, ":", display and "EXISTS" or "MISSING")
			end
		elseif command == "testmoney" then
			print("🔧 DEBUG: Testing money collection for", player.Name)
			print("🔧 DEBUG: Player table assignment:", TableAssignments[player.UserId] or "NONE")
			print("🔧 DEBUG: DisplayCardEarnings:", DisplayCardEarnings[player.UserId] and "EXISTS" or "NIL")
			print("🔧 DEBUG: DisplayTableData:", DisplayTableData[player.UserId] and #DisplayTableData[player.UserId] .. " cards" or "NIL")

			if DisplayTableData[player.UserId] and #DisplayTableData[player.UserId] > 0 then
				local moneyEarned = calculateMoneyEarned(player)
				print("🔧 DEBUG: Calculated money earned:", moneyEarned, "coins")

				-- Simulate money collection
				if moneyEarned > 0 then
					spawn(function()
						wait(1)
						local success, playerData = pcall(function()
							return getPlayerData and getPlayerData(player)
						end)

						if success and playerData then
							print("🔧 DEBUG: Successfully got player data, current coins:", playerData.coins or 0)
							playerData.coins = (playerData.coins or 0) + moneyEarned
							print("🔧 DEBUG: New coin total:", playerData.coins)

							-- Reset timer
							if not DisplayCardEarnings[player.UserId] then
								DisplayCardEarnings[player.UserId] = {}
							end
							DisplayCardEarnings[player.UserId].lastCollection = tick()
							print("🔧 DEBUG: Reset collection timer")
						else
							print("🔧 ERROR: Could not get player data")
						end
					end)
				end
			else
				print("🔧 DEBUG: No displayed cards found")
			end
		elseif command == "cleanup" then
			print("🧹 MANUAL CLEANUP COMMAND - Scanning workspace for table-like objects...")
			local removedCount = 0
			for _, obj in pairs(workspace:GetChildren()) do
				if obj:IsA("Part") then
					-- Check if this looks like a table or mat
					if (obj.Material == Enum.Material.Wood and obj.BrickColor.Name == "Brown") or
						(obj.Material == Enum.Material.Neon and obj.BrickColor.Name == "Bright green") or
						obj.Name:match("Table") or obj.Name:match("Mat") or obj.Name:match("Display") or
						obj.Name:match("Card") or obj.Name:match("Money") or obj.Name:match("Floating") then

						-- Don't remove our new system
						if not obj.Name:match("CardDisplayTable") and 
							not obj.Name:match("MoneyCollectionMat") and
							not obj.Name:match("FloatingTextAnchor") then

							print("🧹 MANUAL CLEANUP: Removing", obj.Name, "at position", obj.Position)
							obj:Destroy()
							removedCount = removedCount + 1
						end
					end
				end
			end
			print("🧹 MANUAL CLEANUP COMPLETE: Removed", removedCount, "objects!")
		end
	end
end

-- Table assignment system
-- Initialize table player counts
for i = 1, MaxTables do
	TablePlayerCounts[i] = 0
end

-- Debug: Verify initialization
print("🔧 DEBUG: TablePlayerCounts initialized:", table.concat(TablePlayerCounts, ", "))
print("🔧 DEBUG: MaxTables:", MaxTables, "TableCapacity:", TableCapacity)

-- Function to update "Your Table" marker for a specific player
local function updateYourTableMarker(player, tableNumber)
	-- Remove any existing "Your Table" markers
	for i = 1, MaxTables do
		local existingMarker = workspace:FindFirstChild("YourTableMarker" .. i)
		if existingMarker then
			existingMarker:Destroy()
		end
	end

	if tableNumber and tableNumber >= 1 and tableNumber <= MaxTables then
		-- Find the player's table
		local playerTable = workspace:FindFirstChild("CardDisplayTable" .. tableNumber)
		if playerTable then
			-- Create "Your Table" marker above the player's table
			local yourTableMarker = Instance.new("Part")
			yourTableMarker.Name = "YourTableMarker" .. tableNumber
			yourTableMarker.Size = Vector3.new(10, 0.5, 2)
			yourTableMarker.Position = Vector3.new(playerTable.Position.X, playerTable.Position.Y + 4, playerTable.Position.Z)
			yourTableMarker.Anchored = true
			yourTableMarker.CanCollide = false
			yourTableMarker.Material = Enum.Material.Neon
			yourTableMarker.BrickColor = BrickColor.new("Bright yellow")
			yourTableMarker.Transparency = 0.2
			yourTableMarker.Parent = workspace

			-- Add "Your Table" text label
			local surfaceGui = Instance.new("SurfaceGui")
			surfaceGui.Name = "YourTableLabel"
			surfaceGui.Face = Enum.NormalId.Top
			surfaceGui.Parent = yourTableMarker

			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = "🎯 YOUR TABLE 🎯"
			textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
			textLabel.TextSize = 20
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextStrokeTransparency = 0
			textLabel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.Parent = surfaceGui

			print("🎯 Created 'Your Table' marker for", player.Name, "above table", tableNumber)
		else
			print("❌ Could not find table", tableNumber, "to place marker")
		end
	end
end

-- Function to assign a player to a table
print("🔧 DEBUG: About to define assignPlayerToTable function...")
local function assignPlayerToTable(player)
	local userId = player.UserId

	print("🔧 DEBUG: assignPlayerToTable called for", player.Name, "(UserId:", userId, ")")
	print("🔧 DEBUG: Current table assignments:", (function() local count = 0; for _ in pairs(TableAssignments) do count = count + 1 end; return count end)(), "players assigned")
	print("🔧 DEBUG: Current table counts:", table.concat(TablePlayerCounts, ", "))

	-- Check if player is already assigned
	if TableAssignments[userId] then
		local existingTable = TableAssignments[userId]
		print("🔧 DEBUG: Player", player.Name, "already assigned to table", existingTable)
		return existingTable
	end

	-- Find a table with available space
	for tableNum = 1, MaxTables do
		local currentCount = TablePlayerCounts[tableNum] or 0
		print("🔧 DEBUG: Checking table", tableNum, "- Current count:", currentCount, "Capacity:", TableCapacity)

		if currentCount < TableCapacity then
			-- Assign player to this table
			TableAssignments[userId] = tableNum
			TablePlayerCounts[tableNum] = currentCount + 1

			print("🎯 Assigned player", player.Name, "to table", tableNum, "(Table now has", TablePlayerCounts[tableNum], "players)")
			print("🔧 DEBUG: Updated TablePlayerCounts[", tableNum, "] =", TablePlayerCounts[tableNum])
			print("🔧 DEBUG: Total players now:", (function() local count = 0; for _ in pairs(TableAssignments) do count = count + 1 end; return count end)())

			-- Update "Your Table" marker for this player
			updateYourTableMarker(player, tableNum)

			-- Show clear table assignment message to player
			local message = Instance.new("Message")
			message.Text = "🎯 You've been assigned to Table " .. tableNum .. "! Look for the yellow 'Your Table' marker above it."
			message.Parent = workspace

			-- Remove message after 8 seconds
			spawn(function()
				wait(8)
				if message then
					message:Destroy()
				end
			end)

			return tableNum
		end
	end

	-- All tables are full - redirect to another server
	print("🚫 All tables are full! Redirecting", player.Name, "to another server...")

	-- You can implement server redirection here
	-- For now, we'll just assign them to a random table (overflow)
	local randomTable = math.random(1, MaxTables)
	TableAssignments[userId] = randomTable
	TablePlayerCounts[randomTable] = (TablePlayerCounts[randomTable] or 0) + 1

	print("🔧 DEBUG: Overflow assignment - Player", player.Name, "to table", randomTable)

	-- Update "Your Table" marker for overflow assignment
	updateYourTableMarker(player, randomTable)

	-- Show overflow message to player
	local message = Instance.new("Message")
	message.Text = "⚠️ Server is full! You've been assigned to an overflow table."
	message.Parent = workspace

	-- Remove message after 5 seconds
	spawn(function()
		wait(5)
		if message then
			message:Destroy()
		end
	end)

	return randomTable
end
print("🔧 DEBUG: assignPlayerToTable function defined successfully")

-- Function to remove player from table when they leave
local function removePlayerFromTable(player)
	local userId = player.UserId
	local tableNum = TableAssignments[userId]

	if tableNum then
		TablePlayerCounts[tableNum] = math.max(0, TablePlayerCounts[tableNum] - 1)
		TableAssignments[userId] = nil
		print("👋 Removed player", player.Name, "from table", tableNum, "(Table now has", TablePlayerCounts[tableNum], "players)")

		-- Remove "Your Table" marker and arrow when player leaves
		local existingMarker = workspace:FindFirstChild("YourTableMarker" .. tableNum)
		if existingMarker then
			existingMarker:Destroy()
			print("🏠 Removed 'Your Table' marker from table", tableNum)
		end

		local existingArrow = workspace:FindFirstChild("TableArrow" .. tableNum)
		if existingArrow then
			existingArrow:Destroy()
			print("🏠 Removed table arrow from table", tableNum)
		end
	end
end

-- Function to broadcast server capacity to all players
print("🔧 DEBUG: About to define broadcastServerCapacity function...")
local function broadcastServerCapacity()
	local totalPlayers = 0
	for _, count in pairs(TablePlayerCounts) do
		totalPlayers = totalPlayers + count
	end

	print("🔧 DEBUG: broadcastServerCapacity called")
	print("🔧 DEBUG: TablePlayerCounts:", table.concat(TablePlayerCounts, ", "))
	print("🔧 DEBUG: TableAssignments count:", (function() local count = 0; for _ in pairs(TableAssignments) do count = count + 1 end; return count end)())
	print("🔧 DEBUG: Players in game:", #Players:GetPlayers())

	local capacityData = {
		totalPlayers = totalPlayers,
		maxCapacity = MaxTables * TableCapacity,
		tableCounts = TablePlayerCounts,
		isFull = totalPlayers >= MaxTables * TableCapacity
	}

	print("🔧 DEBUG: Capacity data:", totalPlayers, "/", MaxTables * TableCapacity, "players")

	for _, player in ipairs(Players:GetPlayers()) do
		serverCapacityEvent:FireClient(player, capacityData)
	end

	print("📊 Broadcasted server capacity:", totalPlayers, "/", MaxTables * TableCapacity, "players")
end
print("🔧 DEBUG: broadcastServerCapacity function defined successfully")

-- Handle player joining - preload their data
print("🔧 DEBUG: Setting up PlayerAdded event handler...")
Players.PlayerAdded:Connect(function(player)
	print("👋 Player", player.Name, "joined - loading data...")
	print("🔧 DEBUG: PlayerAdded event triggered for", player.Name, "(UserId:", player.UserId, ")")

	-- Run cleanup when first player joins (to catch objects that might persist from place saves)
	if #Players:GetPlayers() == 1 and not _G.FirstPlayerCleanupRun then
		print("🧹 FIRST PLAYER CLEANUP: Running cleanup as first player joined...")
		_G.FirstPlayerCleanupRun = true
		
		local removedCount = 0
		for _, obj in pairs(workspace:GetChildren()) do
			if obj:IsA("Part") then
				local shouldRemove = false
				
				-- Check for old table/mat patterns with display boards
				if (obj.Name:match("Table") or obj.Name:match("Mat") or obj.Name:match("Display")) and
					not (obj.Name:match("CardDisplayTable") or obj.Name:match("MoneyCollectionMat") or 
						obj.Name:match("FloatingTextAnchor")) then
					
					-- Additional check: does it have display boards?
					for _, child in pairs(obj:GetChildren()) do
						if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
							shouldRemove = true
							break
						end
					end
				end
				
				-- Check for objects in the conveyor area that shouldn't be there
				if math.abs(obj.Position.Z) <= 8 and obj.Position.Y >= 0 and obj.Position.Y <= 10 then
					if not (obj.Name:match("ConveyorBelt") or obj.Name:match("ConveyorRail") or
						obj.Name:match("CardDisplayTable") or obj.Name:match("MoneyCollectionMat") or
						obj.Name:match("FloatingTextAnchor") or obj.Name:match("Base") or
						obj.Name:match("ConveyorCard")) then
						
						-- If it has display boards, it's definitely old
						for _, child in pairs(obj:GetChildren()) do
							if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
								shouldRemove = true
								break
							end
						end
					end
				end
				
				if shouldRemove then
					print("🧹 FIRST PLAYER: Removing persistent old object:", obj.Name, "at position", obj.Position)
					obj:Destroy()
					removedCount = removedCount + 1
				end
			end
		end
		
		if removedCount > 0 then
			print("🧹 FIRST PLAYER CLEANUP: Removed", removedCount, "old objects")
		else
			print("🧹 FIRST PLAYER CLEANUP: No old objects found")
		end
	end

	-- Set up debug command handling for this player
	player.Chatted:Connect(function(message)
		handleDebugCommand(player, message)
	end)

	-- Assign player to a table
	print("🔧 DEBUG: About to call assignPlayerToTable for", player.Name)
	local assignedTable = assignPlayerToTable(player)
	print("🎯 Player", player.Name, "assigned to table", assignedTable)

	-- Wait a bit for player to fully load before sending events
	wait(1)

	-- Notify client about table assignment
	print("📤 Firing TableAssignmentEvent to", player.Name, "with table", assignedTable)
	tableAssignmentEvent:FireClient(player, assignedTable)

	getPlayerData(player) -- This will load their saved data or create new data

	-- Send current display table data to new player
	wait(2) -- Wait a bit more for player to fully load
	getDisplayCardsEvent:FireClient(player, getAllDisplayedCards())

	-- Broadcast updated capacity to all players (only if function exists)
	if broadcastServerCapacity then
		print("🔧 DEBUG: Calling broadcastServerCapacity after player join")
		broadcastServerCapacity()
	else
		print("🔧 DEBUG: broadcastServerCapacity function not found!")
	end

	print("✅ Player", player.Name, "setup complete - table", assignedTable, "assigned")
	print("🔧 DEBUG: Final table assignments count:", (function() local count = 0; for _ in pairs(TableAssignments) do count = count + 1 end; return count end)())
	print("🔧 DEBUG: Final table player counts:", table.concat(TablePlayerCounts, ", "))
end)

print("🔧 DEBUG: PlayerAdded event handler connected successfully")

-- Handle player leaving - save their data
Players.PlayerRemoving:Connect(function(player)
	print("👋 Player", player.Name, "leaving - saving data...")
	savePlayerData(player)

	-- Remove player from table assignment
	removePlayerFromTable(player)

	-- Clean up cache
	PlayerDataCache[player.UserId] = nil

	-- Remove from NPC proximity
	PlayersNearNPC[player.UserId] = nil
	
	-- Clean up visual display cards
	print("🧹 DEBUG: Cleaning up visual display cards for leaving player:", player.Name)
	for _, obj in pairs(workspace:GetChildren()) do
		if obj.Name:find("DisplayCard_") and obj:GetAttribute("PlayerUserId") == player.UserId then
			print("🧹 DEBUG: Destroying display card:", obj.Name)
			obj:Destroy()
		end
	end

	-- Broadcast updated capacity to all players (only if function exists)
	if broadcastServerCapacity then
		broadcastServerCapacity()
	end
end)

-- Handle E key press to start battle
startBattleEvent.OnServerEvent:Connect(function(player)
	print("🎴 DEBUG: startBattleEvent received from player:", player and player.Name or "nil")
	print("🎴 DEBUG: player object type:", type(player))
	print("🎴 DEBUG: player.UserId:", player and player.UserId or "nil")

	if not player then
		print("❌ ERROR: startBattleEvent received nil player")
		return
	end

	-- First check if player is near NPC for battle
	if PlayersNearNPC[player.UserId] and not BattleInProgress then
		print("🎴 Player", player.Name, "pressed E to start NPC battle")
		startCardBattle(player)
		return
	elseif BattleInProgress then
		print("🎴 Battle already in progress, cannot start for", player.Name)
		-- Send message to player
		local message = Instance.new("Message")
		message.Text = "⚔️ A card battle is already in progress! Wait for it to finish."
		message.Parent = workspace

		spawn(function()
			wait(3)
			if message then
				message:Destroy()
			end
		end)
		return
	end

	-- If not near NPC, check if player is near a conveyor card
	local userId = player.UserId
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		print("🎴 DEBUG: Player has no character or HumanoidRootPart")
		return
	end

	local playerPosition = character.HumanoidRootPart.Position
	print("🎴 DEBUG: Player position:", playerPosition)
	print("🎴 DEBUG: Checking", #ConveyorCards, "conveyor cards")

	-- Find nearby conveyor cards
	for _, cardInfo in ipairs(ConveyorCards) do
		if cardInfo.object and cardInfo.object.Parent then
			local distance = (playerPosition - cardInfo.object.Position).Magnitude
			print("🎴 DEBUG: Distance to card", cardInfo.data.name .. ":", distance)
			if distance <= 6 then  -- Within claiming range
				print("🎴 DEBUG: Player is within range of", cardInfo.data.name)
				-- Simple one-click claiming - no more two-step process
				print("🎴 DEBUG: Starting claim immediately")
				startCardClaim(player, cardInfo)
				-- Complete the claim right away
				print("🎴 DEBUG: Completing claim immediately!")
				completeCardClaim(player, cardInfo)
				return
			end
		end
	end

	print("🎴 DEBUG: Player not near NPC or conveyor cards")
	-- Clear any active claiming if player moved away
	if PlayersClaimingCards[userId] then
		print("🎴 DEBUG: Player moved away, clearing claim for:", PlayersClaimingCards[userId].data.name)
		PlayersClaimingCards[userId] = nil
	end
end)

-- Handle money collection from displayed cards
collectMoneyEvent.OnServerEvent:Connect(function(player)
	print("💰 Money collection requested by player:", player.Name)

	local moneyCollected = collectMoneyFromDisplay(player)
	if moneyCollected > 0 then
		-- Send money collected notification to client
		local result = {
			coinsCollected = moneyCollected,
			newCoins = getPlayerData(player).coins,
			message = "💰 Collected " .. moneyCollected .. " coins from displayed cards!"
		}
		collectMoneyEvent:FireClient(player, result)
		print("💰 Player", player.Name, "collected", moneyCollected, "coins")
	else
		-- Send no money to collect message
		local result = {
			coinsCollected = 0,
			message = "No money to collect yet. Keep displaying cards!"
		}
		collectMoneyEvent:FireClient(player, result)
		print("💰 Player", player.Name, "tried to collect money but none available")
	end
end)

-- Process queued money collections (now that getPlayerData is available)
spawn(function()
	while wait(1) do -- Check every second
		if _G.PendingMoneyCollections and #_G.PendingMoneyCollections > 0 then
			print("💰 Processing", #_G.PendingMoneyCollections, "pending money collections...")

			for i = #_G.PendingMoneyCollections, 1, -1 do -- Process backwards to safely remove items
				local collection = _G.PendingMoneyCollections[i]
				local player = collection.player
				local amount = collection.amount

				if player and player.Parent then -- Make sure player is still in game
					-- Try to add the money now that getPlayerData is available
					local success, playerData = pcall(function()
						return getPlayerData(player)
					end)

					if success and playerData then
						print("💰 Processing queued collection:", amount, "coins for", player.Name)

						-- Add the money
						playerData.coins = (playerData.coins or 0) + amount

						-- Save the data
						local saveSuccess = pcall(function()
							return savePlayerData(player, playerData)
						end)

						if saveSuccess then
							-- Reset the collection timer
							if not DisplayCardEarnings[player.UserId] then
								DisplayCardEarnings[player.UserId] = {}
							end
							DisplayCardEarnings[player.UserId].lastCollection = tick()

							-- Send success notification to client
							local result = {
								coinsCollected = amount,
								newCoins = playerData.coins,
								message = "💰 Collected " .. amount .. " coins from displayed cards!"
							}
							collectMoneyEvent:FireClient(player, result)

							print("💰 Successfully processed", amount, "coins for", player.Name, "- New total:", playerData.coins)

							-- Remove this collection from the queue
							table.remove(_G.PendingMoneyCollections, i)
						else
							print("💰 ERROR: Failed to save player data for", player.Name)
						end
					else
						print("💰 DEBUG: getPlayerData still not available, keeping in queue...")
					end
				else
					-- Player left, remove from queue
					print("💰 DEBUG: Player left, removing from queue")
					table.remove(_G.PendingMoneyCollections, i)
				end
			end
		end
	end
end)

-- Auto-save all player data every 5 minutes
spawn(function()
	while wait(300) do -- 300 seconds = 5 minutes
		print("💾 Auto-saving all player data...")
		for userId, _ in pairs(PlayerDataCache) do
			local player = Players:GetPlayerByUserId(userId)
			if player then
				savePlayerData(player)
			end
		end
	end
end)

-- Update money displays every 10 seconds (slowed down for better economy balance)
spawn(function()
	print("🔧 DEBUG: Starting money display update loop...")
	while wait(10) do -- Update every 10 seconds (was 1 second)
		updateMoneyDisplays()
	end
end)

-- Create multiple display tables in the workspace
local function createDisplayTables()
	print("🔧 DEBUG: createDisplayTables() called with MaxTables =", MaxTables)
	print("🔧 DEBUG: Starting table creation loop...")

	-- Add error handling
	local success, err = pcall(function()
		for tableNum = 1, MaxTables do
			-- Calculate position for each table (arrange in a grid)
			print("🔧 DEBUG: Creating table", tableNum, "...")
			local row = math.ceil(tableNum / 5) -- 5 tables per row
			local col = ((tableNum - 1) % 5) + 1
			local xPos = (col - 3) * 15 -- Center around 0, 15 units apart
			local zPos = (row - 1) * 30 -- 30 units apart vertically (increased for conveyor space)
			print("🔧 DEBUG: Table", tableNum, "position: row", row, "col", col, "xPos", xPos, "zPos", zPos)

			local displayTable = Instance.new("Part")
			displayTable.Name = "CardDisplayTable" .. tableNum
			displayTable.Size = Vector3.new(10, 1, 8) -- Bigger table for 2x2 card layout
			displayTable.Position = Vector3.new(xPos, 1, zPos) -- Position in grid
			displayTable.Anchored = true
			displayTable.Material = Enum.Material.Wood
			displayTable.BrickColor = BrickColor.new("Brown")
			displayTable.Parent = workspace

			-- Store table number in the table for identification
			displayTable:SetAttribute("TableNumber", tableNum)

			-- Add ClickDetector for table interaction (prevents unwanted overlays)
			local clickDetector = Instance.new("ClickDetector")
			clickDetector.MaxActivationDistance = 10 -- Reasonable interaction distance
			clickDetector.Parent = displayTable

			-- Add a sign to explain the table
			local sign = Instance.new("Part")
			sign.Name = "DisplayTableSign" .. tableNum
			sign.Size = Vector3.new(4, 2, 0.2)
			sign.Position = Vector3.new(xPos, 3, zPos)
			sign.Anchored = true
			sign.Material = Enum.Material.Plastic
			sign.BrickColor = BrickColor.new("White")
			sign.Parent = workspace

			local surfaceGui = Instance.new("SurfaceGui")
			surfaceGui.Name = "SignGui"
			surfaceGui.Face = Enum.NormalId.Front
			surfaceGui.Parent = sign

			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = "🎴 Table " .. tableNum .. "\nClick to view cards!"
			textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
			textLabel.TextSize = 20
			textLabel.Font = Enum.Font.GothamBold
			textLabel.Parent = surfaceGui

			-- Create money collection mat next to the table
			local moneyMat = Instance.new("Part")
			moneyMat.Name = "MoneyCollectionMat" .. tableNum
			moneyMat.Size = Vector3.new(3, 0.1, 3)
			moneyMat.Position = Vector3.new(xPos + 6, 0.05, zPos) -- Position to the right of table
			moneyMat.Anchored = true
			moneyMat.CanCollide = true
			moneyMat.Material = Enum.Material.Neon
			moneyMat.BrickColor = BrickColor.new("Bright green")
			moneyMat.Transparency = 0.3
			moneyMat.Parent = workspace

			-- Add money collection sign above the mat
			local matSign = Instance.new("Part")
			matSign.Name = "MoneyMatSign" .. tableNum
			matSign.Size = Vector3.new(3, 1, 0.2)
			matSign.Position = Vector3.new(xPos + 6, 1.5, zPos)
			matSign.Anchored = true
			matSign.Material = Enum.Material.Plastic
			matSign.BrickColor = BrickColor.new("Bright green")
			matSign.Parent = workspace

			local matSignGui = Instance.new("SurfaceGui")
			matSignGui.Name = "MatSignGui"
			matSignGui.Face = Enum.NormalId.Front
			matSignGui.Parent = matSign

			local matSignText = Instance.new("TextLabel")
			matSignText.Size = UDim2.new(1, 0, 1, 0)
			matSignText.BackgroundTransparency = 1
			matSignText.Text = "💰\nCollect Money!"
			matSignText.TextColor3 = Color3.fromRGB(0, 0, 0)
			matSignText.TextSize = 14
			matSignText.Font = Enum.Font.GothamBold
			matSignText.Parent = matSignGui

			-- Initialize money mat structure
			MoneyCollectionMats[tableNum] = {}
			print("🔧 DEBUG: Money mat", tableNum, "structure initialized")

			-- Create floating money value display above the mat
			print("🔧 DEBUG: Creating money display for table", tableNum)
			local moneyDisplay = Instance.new("Part")
			moneyDisplay.Name = "MoneyValueDisplay" .. tableNum
			moneyDisplay.Size = Vector3.new(3, 0.5, 0.2)
			moneyDisplay.Position = Vector3.new(xPos + 6, 2, zPos) -- Above the money mat
			moneyDisplay.Anchored = true
			moneyDisplay.CanCollide = false
			moneyDisplay.Material = Enum.Material.Neon
			moneyDisplay.BrickColor = BrickColor.new("Bright green")
			moneyDisplay.Transparency = 0.3
			moneyDisplay.Parent = workspace

			-- Add text to show money value
			local moneyGui = Instance.new("SurfaceGui")
			moneyGui.Name = "MoneyValueGui"
			moneyGui.Face = Enum.NormalId.Front
			moneyGui.Parent = moneyDisplay

			local moneyText = Instance.new("TextLabel")
			moneyText.Size = UDim2.new(1, 0, 1, 0)
			moneyText.BackgroundTransparency = 1
			moneyText.Text = "💰 0 coins"
			moneyText.TextColor3 = Color3.fromRGB(0, 0, 0)
			moneyText.TextSize = 16
			moneyText.Font = Enum.Font.GothamBold
			moneyText.Parent = moneyGui

			-- Store reference to money display for updates
			MoneyCollectionMats[tableNum].mat = moneyMat
			MoneyCollectionMats[tableNum].display = moneyDisplay
			MoneyCollectionMats[tableNum].textLabel = moneyText
			print("🔧 DEBUG: Money display", tableNum, "created and stored")

			-- Add TouchInterest for money collection (TouchInterest is client-side, so we'll use Touched event directly)
			moneyMat.Touched:Connect(function(hit)
				print("💰 Money mat touched by:", hit.Name, "Parent:", hit.Parent and hit.Parent.Name or "nil")
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if player then
					print("💰 Player detected:", player.Name, "UserId:", player.UserId)
					-- Check if this is the player's assigned table
					print("💰 Checking table assignment for", player.Name)
					print("💰 Current TableAssignments:", (function() local str = ""; for uid, tn in pairs(TableAssignments) do str = str .. uid .. "->" .. tn .. ", " end; return str end)())

					local assignedTable = nil
					for userId, tableNum in pairs(TableAssignments) do
						if userId == player.UserId then
							assignedTable = tableNum
							print("💰 Found assigned table for", player.Name, ":", tableNum)
							break
						end
					end

					print("💰 Player", player.Name, "assigned to table:", assignedTable, "Current mat is for table:", tableNum)

					if assignedTable == tableNum then
						print("💰 Player", player.Name, "stepped on their money collection mat for table", tableNum)
						-- Trigger money collection
						local moneyCollected = collectMoneyFromDisplay(player)
						if moneyCollected > 0 then
							-- Send money collected notification to client
							local result = {
								coinsCollected = moneyCollected,
								newCoins = getPlayerData(player).coins,
								message = "💰 Collected " .. moneyCollected .. " coins from displayed cards!"
							}
							collectMoneyEvent:FireClient(player, result)
							print("💰 Player", player.Name, "collected", moneyCollected, "coins from table", tableNum)
						else
							-- Send no money to collect message
							local result = {
								coinsCollected = 0,
								message = "Wait for 10-second intervals to complete! Check the display above your mat."
							}
							collectMoneyEvent:FireClient(player, result)
							print("💰 Player", player.Name, "tried to collect money but none available from table", tableNum)
						end
					else
						print("💰 Player", player.Name, "stepped on table", tableNum, "money mat but it's not their table")
					end
				end
			end)

			print("✅ Created display table", tableNum, "at position", xPos, zPos)
			print("💰 Created money collection mat for table", tableNum)
			print("🔧 DEBUG: Table", tableNum, "fully created and added to workspace")
		end
		print("🔧 DEBUG: createDisplayTables() completed. Created", MaxTables, "tables")

		-- Verify tables were created in workspace
		local tableCount = 0
		local matCount = 0
		local displayCount = 0
		for i = 1, MaxTables do
			if workspace:FindFirstChild("CardDisplayTable" .. i) then
				tableCount = tableCount + 1
			end
			if workspace:FindFirstChild("MoneyCollectionMat" .. i) then
				matCount = matCount + 1
			end
			if workspace:FindFirstChild("MoneyValueDisplay" .. i) then
				displayCount = displayCount + 1
			end
		end
		print("🔧 DEBUG: Verification - Tables in workspace:", tableCount, "/", MaxTables)
		print("🔧 DEBUG: Verification - Money mats in workspace:", matCount, "/", MaxTables)
		print("🔧 DEBUG: Verification - Money displays in workspace:", displayCount, "/", MaxTables)
	end)

	if not success then
		print("❌ ERROR in createDisplayTables():", err)
		print("🔧 DEBUG: Stack trace:", debug.traceback())
	else
		print("✅ createDisplayTables() completed successfully")
	end
end



-- NPC Card Battle System (duplicate removed - function moved to top)

-- Create NPC for card battles
local function createBattleNPC()
	-- Create NPC character using a character model
	local npc = Instance.new("Model")
	npc.Name = "BattleNPC"
	npc.Parent = workspace

	-- Create the main body parts
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = Vector3.new(0, 2, 25) -- Moved further away
	torso.Anchored = true
	torso.CanCollide = true
	torso.Material = Enum.Material.Plastic
	torso.BrickColor = BrickColor.new("Bright blue")
	torso.Parent = npc

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.Position = Vector3.new(0, 3.6, 25) -- Moved further away
	head.Anchored = true
	head.CanCollide = true
	head.Material = Enum.Material.Plastic
	head.BrickColor = BrickColor.new("Bright yellow")
	head.Shape = Enum.PartType.Ball
	head.Parent = npc

	local leftArm = Instance.new("Part")
	leftArm.Name = "LeftArm"
	leftArm.Size = Vector3.new(1, 2, 1)
	leftArm.Position = Vector3.new(-1.5, 2, 25) -- Moved further away
	leftArm.Anchored = true
	leftArm.CanCollide = true
	leftArm.Material = Enum.Material.Plastic
	leftArm.BrickColor = BrickColor.new("Bright blue")
	leftArm.Parent = npc

	local rightArm = Instance.new("Part")
	rightArm.Name = "RightArm"
	rightArm.Size = Vector3.new(1, 2, 1)
	rightArm.Position = Vector3.new(1.5, 2, 25) -- Moved further away
	rightArm.Anchored = true
	rightArm.CanCollide = true
	rightArm.Material = Enum.Material.Plastic
	rightArm.BrickColor = BrickColor.new("Bright blue")
	rightArm.Parent = npc

	local leftLeg = Instance.new("Part")
	leftLeg.Name = "LeftLeg"
	leftLeg.Size = Vector3.new(1, 2, 1)
	leftLeg.Position = Vector3.new(-0.5, 0.5, 25) -- Moved further away
	leftLeg.Anchored = true
	leftLeg.CanCollide = true
	leftLeg.Material = Enum.Material.Plastic
	leftLeg.BrickColor = BrickColor.new("Bright blue")
	leftLeg.Parent = npc

	local rightLeg = Instance.new("Part")
	rightLeg.Name = "RightLeg"
	rightLeg.Size = Vector3.new(1, 2, 1)
	rightLeg.Position = Vector3.new(0.5, 0.5, 25) -- Moved further away
	rightLeg.Anchored = true
	rightLeg.CanCollide = true
	rightLeg.Material = Enum.Material.Plastic
	rightLeg.BrickColor = BrickColor.new("Bright blue")
	rightLeg.Parent = npc

	-- Add NPC label above the head
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "NPCLabel"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.Parent = head

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "🎴 Card Battle\nWalk near to interact!"
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 16
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = surfaceGui

	-- Create proximity detection zone
	local proximityZone = Instance.new("Part")
	proximityZone.Name = "NPCDetectionZone"
	proximityZone.Size = Vector3.new(8, 6, 8)
	proximityZone.Position = Vector3.new(0, 3, 25) -- Updated position
	proximityZone.Anchored = true
	proximityZone.CanCollide = false
	proximityZone.Transparency = 1
	proximityZone.Parent = npc

	-- Create a sign that says "Card Battle"
	local sign = Instance.new("Part")
	sign.Name = "CardBattleSign"
	sign.Size = Vector3.new(4, 2, 0.2)
	sign.Position = Vector3.new(0, 5, 25) -- Above the NPC
	sign.Anchored = true
	sign.CanCollide = true
	sign.Material = Enum.Material.Wood
	sign.BrickColor = BrickColor.new("Bright yellow")
	sign.Parent = npc

	-- Add text to the sign
	local signGui = Instance.new("SurfaceGui")
	signGui.Name = "SignText"
	signGui.Face = Enum.NormalId.Front
	signGui.Parent = sign

	local signText = Instance.new("TextLabel")
	signText.Size = UDim2.new(1, 0, 1, 0)
	signText.BackgroundTransparency = 1
	signText.Text = "⚔️ CARD BATTLE ⚔️"
	signText.TextColor3 = Color3.fromRGB(0, 0, 0)
	signText.TextSize = 20
	signText.Font = Enum.Font.GothamBold
	signText.Parent = signGui

	-- Proximity detection using TouchInterest
	proximityZone.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and not PlayersNearNPC[player.UserId] then
			PlayersNearNPC[player.UserId] = true
			print("🎴 Player", player.Name, "entered NPC proximity zone")

			-- Send proximity event to client
			local proximityEvent = ReplicatedStorage:FindFirstChild("NPCDetectionEvent")
			if proximityEvent then
				proximityEvent:FireClient(player, true, "Press E to start Card Battle!")
			end
		end
	end)

	proximityZone.TouchEnded:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and PlayersNearNPC[player.UserId] then
			PlayersNearNPC[player.UserId] = nil
			print("🎴 Player", player.Name, "left NPC proximity zone")

			-- Send proximity event to client
			local proximityEvent = ReplicatedStorage:FindFirstChild("NPCDetectionEvent")
			if proximityEvent then
				proximityEvent:FireClient(player, false, "")
			end
		end
	end)

	print("🎴 Created Battle NPC character at position", torso.Position)
	print("🎴 NPC Name:", npc.Name, "Type: Humanoid Character")
	print("🎴 Added 'Card Battle' sign above NPC")
	print("🎴 NPC proximity zone created - ready for E key interaction!")
	print("🎴 Battle cooldown: 5 minutes between battles")
	print("🎴 FREE card pack reward for winning battles!")
end

-- Start a card battle with the NPC (duplicate removed - function moved to top)

-- Create the minimal base
print("📦 Creating minimal base...")
print("🔧 DEBUG: About to call createMinimalBase()...")
createMinimalBase()
print("📦 Minimal base created successfully")
print("🔧 DEBUG: createMinimalBase() completed successfully")

-- Create the Battle NPC
print("🎴 Creating Battle NPC...")
print("🔧 DEBUG: About to call createBattleNPC()...")
createBattleNPC()
print("🎴 Battle NPC created successfully")
print("🔧 DEBUG: createBattleNPC() completed successfully")

-- Test basic functionality
print("🔧 DEBUG: Testing basic functionality...")
print("🔧 DEBUG: MaxTables value:", MaxTables)
print("🔧 DEBUG: MaxTables type:", type(MaxTables))
print("🔧 DEBUG: TableCapacity value:", TableCapacity)
print("🔧 DEBUG: TablePlayerCounts exists:", TablePlayerCounts ~= nil)
print("🔧 DEBUG: TableAssignments exists:", TableAssignments ~= nil)

print("🔧 DEBUG: About to call createDisplayTables()...")
local success, err = pcall(createDisplayTables)
if not success then
	print("❌ ERROR calling createDisplayTables():", err)
	print("🔧 DEBUG: Stack trace:", debug.traceback())
else
	print("🔧 DEBUG: Display tables created successfully")
end

-- Broadcast server capacity every 30 seconds
spawn(function()
	while wait(30) do -- 30 seconds
		if #Players:GetPlayers() > 0 then
			broadcastServerCapacity()
		end
	end
end)

-- Periodic cleanup to catch any persistent old objects that might get saved with the place
spawn(function()
	while wait(60) do -- Every 60 seconds
		print("🧹 PERIODIC CLEANUP: Checking for old objects that might have persisted...")
		
		local removedCount = 0
		for _, obj in pairs(workspace:GetChildren()) do
			if obj:IsA("Part") then
				local shouldRemove = false
				
				-- Check for old table/mat patterns with display boards
				if (obj.Name:match("Table") or obj.Name:match("Mat") or obj.Name:match("Display")) and
					not (obj.Name:match("CardDisplayTable") or obj.Name:match("MoneyCollectionMat") or 
						obj.Name:match("FloatingTextAnchor")) then
					
					-- Additional check: does it have display boards?
					for _, child in pairs(obj:GetChildren()) do
						if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
							shouldRemove = true
							break
						end
					end
				end
				
				-- Check for objects in the conveyor area that shouldn't be there
				if math.abs(obj.Position.Z) <= 8 and obj.Position.Y >= 0 and obj.Position.Y <= 10 then
					if not (obj.Name:match("ConveyorBelt") or obj.Name:match("ConveyorRail") or
						obj.Name:match("CardDisplayTable") or obj.Name:match("MoneyCollectionMat") or
						obj.Name:match("FloatingTextAnchor") or obj.Name:match("Base") or
						obj.Name:match("ConveyorCard")) then
						
						-- If it has display boards, it's definitely old
						for _, child in pairs(obj:GetChildren()) do
							if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
								shouldRemove = true
								break
							end
						end
					end
				end
				
				if shouldRemove then
					print("🧹 PERIODIC: Removing persistent old object:", obj.Name, "at position", obj.Position)
					obj:Destroy()
					removedCount = removedCount + 1
				end
			end
		end
		
		if removedCount > 0 then
			print("🧹 PERIODIC CLEANUP: Removed", removedCount, "old objects")
		end
	end
end)

print("🚀 Card Server Ready with DataStore persistence!")
print("🔧 DEBUG: Script fully loaded and ready for players")
print("🔧 DEBUG: PlayerDataCache contents:", #PlayerDataCache, "entries")
for userId, data in pairs(PlayerDataCache) do
	print("🔧 DEBUG: UserId:", userId, "Data:", data and "exists" or "nil")
end

print("🔧 DEBUG: About to start main execution...")
-- Removed test table creation to prevent clutter

-- START CONVEYOR SYSTEM NOW (after all critical systems are loaded)
print("🎴 🚀 STARTING CONVEYOR SYSTEM NOW...")
print("🎴 Starting conveyor spawn system...")
spawn(function()
	print("🎴 Conveyor spawn loop started - first card in 2 seconds")
	-- Spawn first card immediately for testing
	wait(2)
	spawnConveyorCard()

	-- Then spawn cards every 10 seconds
	while wait(10) do
		print("🎴 10 seconds elapsed - spawning new card...")
		spawnConveyorCard()
	end
end)

print("🎴 Starting conveyor movement system...")
spawn(function()
	print("🎴 Conveyor movement loop started")
	-- Move cards every frame
	while wait(0.1) do
		if #ConveyorCards > 0 then
			moveConveyorCards()
		end
	end
end)

print("🎴 🚀 CONVEYOR SYSTEM FULLY INITIALIZED!")
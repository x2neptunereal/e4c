local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
local window = DrRayLibrary:Load("e4c", "Default")
local Main = DrRayLibrary.newTab("Main", "ImageIdHere")
local AutoFarm = DrRayLibrary.newTab("AutoFarm", "ImageIdHere")
local garden = DrRayLibrary.newTab("veg garden", "ImageIdHere")
local Heal = DrRayLibrary.newTab("Heal DA", "ImageIdHere")
local lncubators = DrRayLibrary.newTab("lncubators", "ImageIdHere")

local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    -- Custom display names mapping
    local customNames = {
        { key = "", display = "No Item" },
        { key = "EggBox", display = "HoneyEggBox" },
        { key = "LargeFoodNode", display = "Foods" },
        { key = "LargeResourceNode", display = "Resources" },
        { key = "SilverChest", display = "Silver Chest" },
        { key = "BronzeChest", display = "Bronze Chest" },
        { key = "GoldChest", display = "Gold Chest" },
        { key = "Lobby", display = "Origins Egg" },
        { key = "Volcano", display = "Volcano Egg" },
        { key = "Grassland", display = "Grassland Egg" },
        { key = "Jungle", display = "Jungle Egg" },
        { key = "Tundra", display = "Tundra Egg" },
        { key = "Ocean", display = "Ocean Egg" },
        { key = "Desert", display = "Desert Egg" },
        { key = "Fantasy", display = "Fantasy Egg" },
        { key = "Toxic", display = "Wasteland Egg" },
     
        { key = "Prehistoric", display = "Prehistoric Egg" }
    }

    -- Reverse mapping for Dropdown values
    local reverseCustomNames = {}
    for _, item in ipairs(customNames) do
        reverseCustomNames[item.display] = item.key
    end

    -- Dropdown display names
    local dropdownItems = {}
    for _, item in ipairs(customNames) do
        table.insert(dropdownItems, item.display)
    end

    -- Variables
    local selectedItem = nil -- ไอเท็มที่เลือกใน Dropdown
    local autoESP = false -- สถานะของ ESP
    local cachedItems = {} -- Cache สำหรับเก็บไอเท็มใน Workspace
    local RunService = game:GetService("RunService")
    local workspace = game:GetService("Workspace")

    -- ฟังก์ชันอัปเดต Cache
    local function cacheItems()
        cachedItems = {}
        for _, object in pairs(workspace:GetDescendants()) do
            table.insert(cachedItems, object)
        end
    end

    -- เรียกใช้ cacheItems ครั้งแรก
    cacheItems()

    -- อัปเดต Cache ทุก ๆ 10 วินาที
    task.spawn(function()
        while true do
            cacheItems()
            task.wait(10)
        end
    end)

    -- ฟังก์ชันค้นหาไอเท็มจาก Cache
    local function findItemByNameFromCache(itemName)
        for _, object in pairs(cachedItems) do
            if object.Name == itemName then
                if object:IsA("BasePart") then
                    return object
                elseif object:IsA("Model") and object.PrimaryPart then
                    return object.PrimaryPart
                end
            end
        end
        return nil
    end

    -- ฟังก์ชัน ESP
    local function createESP(v, displayName)
        if v:FindFirstChild("ESP") then return end

        local gui = Instance.new("BillboardGui", v)
        gui.Name = "ESP"
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Active = true
        gui.LightInfluence = 0
        gui.Size = UDim2.new(0, 200, 0, 50)
        gui.AlwaysOnTop = true

        local esp = Instance.new("TextLabel", gui)
        esp.Name = "esp"
        esp.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        esp.BackgroundTransparency = 0.5
        esp.BorderColor3 = Color3.fromRGB(255, 255, 255)
        esp.BorderSizePixel = 2
        esp.Position = UDim2.new(0, 0, 0, 0)
        esp.Size = UDim2.new(1, 0, 1, 0)
        esp.Font = Enum.Font.GothamBold
        esp.TextColor3 = Color3.fromRGB(255, 255, 255)
        esp.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        esp.TextStrokeTransparency = 0
        esp.TextScaled = true
        esp.TextWrapped = true

        local uiCorner = Instance.new("UICorner", esp)
        uiCorner.CornerRadius = UDim.new(0, 10)

        esp.Text = displayName

        -- ใช้ Heartbeat เพื่อลดการทำงานหนัก
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not autoESP or not v:IsDescendantOf(workspace) then
                gui:Destroy()
                connection:Disconnect()
            else
                local distance = math.floor((character:WaitForChild("HumanoidRootPart").Position - v.Position).Magnitude)
                esp.Text = displayName .. "\n[Distance: " .. distance .. "m]"
            end
        end)
    end

    -- ฟังก์ชัน ESP สำหรับไอเท็มที่เลือก
    local function createESPForSelectedItem()
        for _, v in pairs(cachedItems) do
            if autoESP and selectedItem then
                local itemName = reverseCustomNames[selectedItem]
                if v.Name == itemName and not v:FindFirstChild("ESP") then
                    createESP(v, selectedItem)
                end
            elseif not autoESP and v:FindFirstChild("ESP") then
                v:FindFirstChild("ESP"):Destroy()
            end
        end
    end

    -- ฟังก์ชันวาร์ปไปยังไอเท็มที่เลือก
    local function teleportToSelectedItem()
        if not selectedItem then
            print("No item selected for teleport!")
            return
        end

        local itemName = reverseCustomNames[selectedItem]
        local targetItem = findItemByNameFromCache(itemName)

        if targetItem then
            character:WaitForChild("HumanoidRootPart").CFrame = targetItem.CFrame + Vector3.new(0, 5, 0)
            print("Teleported to:", selectedItem)
        else
            print("Target item not found in the workspace!")
        end
    end


    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local PlayerGUI = Player:WaitForChild("PlayerGui")
    
    local autoSystem2 = false -- สถานะเปิด/ปิด Auto Resource
    
    -- ✅ ฟังก์ชันค้นหามังกรที่ขี่อยู่
    local function GetMountedDragon()
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Dragons = Character:FindFirstChild("Dragons")
    
        if not Dragons then
            warn("❌ ไม่พบโฟลเดอร์ Dragons!")
            return nil
        end
    
        for _, dragon in pairs(Dragons:GetChildren()) do
            if dragon:IsA("Model") and dragon:FindFirstChild("HumanoidRootPart") then
                local Seat = dragon:FindFirstChildWhichIsA("VehicleSeat") or dragon:FindFirstChild("Seat")
                if Seat and Seat.Occupant == Character:FindFirstChildOfClass("Humanoid") then
                    print("✅ พบมังกรที่กำลังขี่อยู่:", dragon.Name)
                    return dragon
                end
            end
        end
    
        warn("⚠️ ไม่พบมังกรที่กำลังขี่อยู่!")
        return nil
    end
    

    
    


local player = game.Players.LocalPlayer
local autoTeleportTreasure = false  -- สถานะเปิด/ปิด Auto Treasure
local itemNames = {"SilverChest", "BronzeChest", "GoldChest"}  -- รายการไอเท็มที่ใช้ค้นหา
local currentIndex = 1
local items = {}

-- ฟังก์ชันค้นหาไอเท็มที่ต้องการ ใน Treasure["1"] - Treasure["100"]
function findItemsByName(itemNames)
    local foundItems = {}
    for i = 1, 100 do -- วนลูปตรวจสอบ Treasure["1"] - Treasure["100"]
        local treasureNode = workspace.Interactions.Nodes.Treasure:FindFirstChild(tostring(i))
        if treasureNode then
            for _, chestName in ipairs(itemNames) do
                local chest = treasureNode:FindFirstChild(chestName)
                if chest and chest:FindFirstChild("HumanoidRootPart") then
                    local deadProperty = chest.HumanoidRootPart:FindFirstChild("Dead")
                    if deadProperty and deadProperty:IsA("BoolValue") and not deadProperty.Value then
                        table.insert(foundItems, chest.HumanoidRootPart)
                    end
                end
            end
        end
    end
    return foundItems
end

-- ฟังก์ชัน Teleport ไปที่ไอเท็ม
function teleportToItem(item)
    if player and player.Character and player.Character.PrimaryPart and item then
        player.Character:SetPrimaryPartCFrame(item.CFrame * CFrame.new(0, 5, 0)) -- วาร์ปไปด้านบนของไอเท็ม
        print("✅ วาร์ปไปที่:", item.Parent.Name)
    end
end

-- ฟังก์ชันตั้งค่า Dead เป็น true เฉพาะกล่องที่วาร์ปไป
function setItemDead(item)
    if item and item.Parent then
        local chest = item.Parent
        local deadProperty = chest.HumanoidRootPart:FindFirstChild("Dead")
        if deadProperty and deadProperty:IsA("BoolValue") then
            deadProperty.Value = true
            print("✅ ตั้งค่า Dead เป็น true สำหรับ:", chest.Name)
        end
    end
end

-- ฟังก์ชันเริ่ม Auto Teleport Treasure
function startAutoTeleportTreasure()
    autoTeleportTreasure = true
    print("🚀 เริ่ม Auto Treasure")
    items = findItemsByName(itemNames)

    while autoTeleportTreasure do
        if #items > 0 then
            local targetItem = items[currentIndex]
            teleportToItem(targetItem) -- วาร์ปไปหาไอเท็ม
            setItemDead(targetItem) -- ตั้งค่า Dead เป็น true

            currentIndex = currentIndex + 1
            if currentIndex > #items then
                currentIndex = 1
                items = findItemsByName(itemNames) -- อัปเดตรายการไอเท็มใหม่
            end
        else
            print("❌ ไม่พบไอเท็มที่ต้องการ! กำลังค้นหาใหม่...")
            items = findItemsByName(itemNames)
        end
        task.wait(4) -- รอ 1.5 วินาทีก่อนวนลูปใหม่
    end
end

-- ฟังก์ชันหยุด Auto Teleport Treasure
function stopAutoTeleportTreasure()
    autoTeleportTreasure = false
    print("🛑 หยุด Auto Treasure")
end

-- ✅ Toggle Auto Treasure
AutoFarm.newToggle("Auto Treasure", "No need to ride the dragon", false, function(state)
    if state then
        startAutoTeleportTreasure() -- เริ่ม Auto Farm
    else
        stopAutoTeleportTreasure() -- หยุด Auto Farm
    end
end)


local Players = game:GetService("Players")
local Player = Players.LocalPlayer

_G.AutoFarmEggs = false -- ปิด Auto Farm เริ่มต้น
local SAFE_HEIGHT = 15 -- กำหนดความสูงที่ปลอดภัย
local FALLBACK_HEIGHT = 50 -- กำหนดตำแหน่งสำรองหากตกแมพ
local MAX_FALL_HEIGHT = 30 -- ความสูงที่กำหนดเมื่อผู้เล่นตกจากที่สูง
local WAIT_BETWEEN_EGGS = 3 -- เวลารอระหว่างไข่แต่ละใบ (วินาที)

-- ฟังก์ชันตรวจสอบ EggModel
function testEggModelExists()
    local activeNodes = workspace.Interactions.Nodes.Eggs.ActiveNodes:GetChildren()
    for _, node in ipairs(activeNodes) do
        if node:FindFirstChild("EggModel") then
            print("✅ พบ EggModel ในเกม")
            return true
        end
    end
    print("❌ ไม่พบ EggModel ในเกม")
    return false
end

-- ฟังก์ชันป้องกันตกแมพ
function preventFalling()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = Player.Character.HumanoidRootPart
        if rootPart.Position.Y < SAFE_HEIGHT then
            print("⚠️ ตรวจพบว่าตกแมพ! กำลังวาร์ปกลับ...")
            rootPart.CFrame = CFrame.new(rootPart.Position.X, FALLBACK_HEIGHT, rootPart.Position.Z)
            task.wait(0.5) -- ป้องกันการสั่น
        elseif rootPart.Position.Y < MAX_FALL_HEIGHT then
            print("⚠️ ความสูงต่ำเกินไป กำลังวาร์ปกลับ...")
            rootPart.CFrame = CFrame.new(rootPart.Position.X, FALLBACK_HEIGHT, rootPart.Position.Z)
        end
    end
end

-- ฟังก์ชันวาร์ปไปหาไข่ และตั้งค่า Harvested เป็น true
function teleportToEgg()
    local success, result = pcall(function()
        local activeNodes = workspace.Interactions.Nodes.Eggs.ActiveNodes:GetChildren()

        for _, node in ipairs(activeNodes) do
            local eggModel = node:FindFirstChild("EggModel")

            if eggModel then
                -- ตรวจสอบว่าไข่นี้ถูกเก็บแล้วหรือยัง
                local harvestedValue = eggModel:FindFirstChild("Harvested")
                if harvestedValue and harvestedValue:IsA("BoolValue") and harvestedValue.Value == true then
                    -- ข้ามไข่ที่ถูกเก็บแล้ว
                    print("⏭️ ข้ามไข่ที่ถูกเก็บแล้ว")
                    continue
                end
                
                -- ตรวจสอบ PrimaryPart หรือ Part ใน EggModel
                local eggPart = eggModel.PrimaryPart or eggModel:FindFirstChildWhichIsA("Part")

                if not eggPart then
                    print("❌ ไม่พบ PrimaryPart หรือ Part ใน EggModel")
                    continue
                end

                -- ตรวจสอบว่าผู้เล่นมี HumanoidRootPart หรือไม่
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = Player.Character.HumanoidRootPart

                    -- ป้องกันตกแมพก่อนวาร์ป
                    preventFalling()

                    -- ตรวจสอบว่าจุดที่วาร์ปไปสูงกว่าค่าปลอดภัยหรือไม่
                    local targetPosition = eggPart.Position + Vector3.new(0, 5, 0) -- อยู่เหนือไข่ 5 หน่วย
                    if targetPosition.Y < SAFE_HEIGHT then
                        targetPosition = Vector3.new(targetPosition.X, SAFE_HEIGHT, targetPosition.Z) -- ปรับให้สูงขึ้น
                    end
                    
                    -- 1. วาร์ปไปที่ตำแหน่งไข่
                    print("🚀 กำลังวาร์ปไปที่ไข่...")
                    rootPart.CFrame = CFrame.new(targetPosition)
                    print("✅ วาร์ปไปที่ EggModel สำเร็จ:", targetPosition)

                    -- ตรวจสอบการตกแมพหลังจากวาร์ป
                    task.wait(0.5) -- รอให้การวาร์ปเสร็จสมบูรณ์
                    if rootPart.Position.Y < SAFE_HEIGHT then
                        print("⚠️ ตรวจพบว่าตกแมพหลังจากวาร์ป! กำลังใช้ failsafe...")
                        rootPart.CFrame = CFrame.new(rootPart.Position.X, FALLBACK_HEIGHT, rootPart.Position.Z)
                        task.wait(0.5) -- รออีกนิดให้กลับมาที่ปลอดภัย
                    end

                    -- 2. ตั้งค่า Harvested เป็น true
                    if harvestedValue and harvestedValue:IsA("BoolValue") then
                        harvestedValue.Value = true
                        print("✅ ตั้งค่า Harvested เป็น true สำหรับไข่นี้")
                    else
                        print("⚠️ ไม่พบค่า Harvested ในไข่นี้")
                    end

                    -- 3. รอเวลาที่กำหนด
                    print("⏱️ รอ " .. WAIT_BETWEEN_EGGS .. " วินาที...")
                    task.wait(WAIT_BETWEEN_EGGS)

                    -- 4. ไปหาไข่อันต่อไป (จะวนลูปไปที่ขั้นตอนที่ 1 โดยอัตโนมัติ)
                    print("🔄 กำลังค้นหาไข่ใบต่อไป...")
                    return true
                end
            end
        end
        print("❌ ไม่พบไข่ที่ยังไม่ได้เก็บในเกม")
        return false
    end)

    if not success then
        warn("❌ Error ใน teleportToEgg: " .. tostring(result))
        return false
    end

    return result
end

-- ฟังก์ชันเริ่ม Auto Farm (ป้องกันตกแมพด้วย)
function startAutoFarmEggs()
    _G.AutoFarmEggs = true
    print("🚀 เริ่มต้น Auto Farm Eggs")

    while _G.AutoFarmEggs do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            -- ป้องกันตกแมพระหว่างทำงาน
            preventFalling()
            
            -- พยายามวาร์ปไปที่ไข่
            local foundEgg = teleportToEgg()
            
            if not foundEgg then
                print("⚠️ ไม่พบไข่ใหม่ รอ 5 วินาที...")
                task.wait(5) -- รอนานขึ้นถ้าไม่พบไข่
            else
                -- ประมวลผลสำเร็จ ไข่ถูกเก็บแล้ว ไม่ต้องรอเพิ่ม
                -- เวลารอได้รวมอยู่ในฟังก์ชัน teleportToEgg แล้ว
            end
        else
            print("⚠️ Player ถูกรีเซ็ต รอให้โหลดใหม่...")
            task.wait(3.5) -- รอให้ตัวละครโหลดก่อนลองอีกครั้ง
        end
    end
end

-- ฟังก์ชันหยุด Auto Farm
function stopAutoFarmEggs()
    _G.AutoFarmEggs = false
    print("🛑 หยุด Auto Farm Eggs")
end

--------------------------------------------------------------------------------
-- ✅ เริ่มต้นทำงานเมื่อเปิด Auto Farm (ไม่ใช้มังกรแล้ว)
--------------------------------------------------------------------------------
AutoFarm.newToggle("Auto Egg", "No need to ride the dragon", false, function(state)
    if state then
        startAutoFarmEggs() -- เริ่ม Auto Farm
    else
        stopAutoFarmEggs() -- หยุด Auto Farm
    end
end)



local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local autoSystem = false -- สถานะเปิด/ปิด Auto Farm

-- ตั้งค่าความเร็วในการโจมตี
local ATTACK_DELAY = 0.1 -- ลดดีเลย์ให้น้อยมากๆ
local ATTACKS_PER_CYCLE = 20 -- เพิ่มจำนวนการโจมตีต่อรอบให้มากขึ้น
local FARM_LOOP_DELAY = 0.05 -- ลดดีเลย์ระหว่างรอบการฟาร์ม
local TARGET_SWITCH_DELAY = 1.5 -- เวลารอเมื่อเปลี่ยนเป้าหมาย
local COLLECTION_RANGE = 40 -- ระยะในการตรวจสอบไอเทมใกล้เคียง
local COLLECT_BEFORE_NEW_TARGET = true -- เปิด/ปิดการเก็บไอเทมก่อนหาตัวใหม่

-- ✅ รายชื่อ Mob ที่ต้องการตรวจสอบ HP
local mobNames = {
    "Boar", "Owl", "Falcon", "OwlSnow", "BoarElite", "Gazelle", "Hippo", "Puma",
    "Elemental", "Gargoyle", "Salamander", "PolarBear", "DesertScarab", "Scorpion",
    "Vulture", "Walrus", "WinterFox", "Chomper", "MutatedFox", "MutatedGazelle",
    "Ankylosaurus", "Argentavis", "Stegosaurus"
}

-- ✅ รายชื่อ Resource ที่ต้องการเก็บ
local itemNames = { 
    "AshesResourcesModel", "MeatFoodModel", "BaconFoodModel"
}

-- ✅ รายชื่อ Mob ที่ต้องการโจมตีเป็นพิเศษ (เรียงตามลำดับความสำคัญ)
local priorityMobs = {
    "Walrus",
    "Ankylosaurus",
    "Argentavis",
    "Stegosaurus"
}

-- ตัวแปรเก็บเป้าหมายล่าสุด เพื่อตรวจสอบการเปลี่ยนเป้าหมาย
local lastTargetName = ""
local lastTargetIsResource = false

--------------------------------------------------------------------------------
-- ✅ ฟังก์ชันค้นหามังกรที่ขี่อยู่
--------------------------------------------------------------------------------
local function GetMountedDragon()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Dragons = Character:FindFirstChild("Dragons")

    if not Dragons then
        warn("❌ ไม่พบโฟลเดอร์ Dragons!")
        return nil
    end

    for _, dragon in pairs(Dragons:GetChildren()) do
        if dragon:IsA("Model") and dragon:FindFirstChild("HumanoidRootPart") then
            local Seat = dragon:FindFirstChildWhichIsA("VehicleSeat") or dragon:FindFirstChild("Seat")
            if Seat and Seat.Occupant == Character:FindFirstChildOfClass("Humanoid") then
                return dragon
            end
        end
    end

    warn("⚠️ ไม่พบมังกรที่กำลังขี่อยู่!")
    return nil
end

local function getSpecificDragon(dragonIndex)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Dragons = Character:FindFirstChild("Dragons")
    
    if not Dragons then
        warn("❌ ไม่พบโฟลเดอร์ Dragons!")
        return nil
    end
    
    local specificDragon = Dragons:FindFirstChild(tostring(dragonIndex))
    if specificDragon then
        return specificDragon
    end
    
    warn("⚠️ ไม่พบมังกรหมายเลข " .. dragonIndex)
    return nil
end

--------------------------------------------------------------------------------
-- 🔍 ฟังก์ชันหาไอเทมที่ต้องการเก็บใน workspace.Camera
--------------------------------------------------------------------------------
local function findItemsInCamera()
    local items = {}
    local playerPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position
    
    if not playerPos then return items end
    
    -- ตรวจสอบไอเทมใน workspace.Camera
    for _, object in pairs(workspace.Camera:GetChildren()) do
        local objectPosition
        local isTargetItem = false
        
        -- ตรวจสอบว่าเป็นไอเทมในรายการหรือไม่
        for _, itemName in pairs(itemNames) do
            if object.Name == itemName then
                isTargetItem = true
                break
            end
        end
        
        -- ถ้าเป็นไอเทมในรายการ ให้หาตำแหน่งของมัน
        if isTargetItem then
            if object:IsA("BasePart") then
                objectPosition = object.Position
            elseif object:IsA("Model") and object.PrimaryPart then
                objectPosition = object.PrimaryPart.Position
            else
                local part = object:FindFirstChildWhichIsA("BasePart")
                if part then
                    objectPosition = part.Position
                end
            end
            
            -- ถ้ามีตำแหน่งของไอเทมและอยู่ในระยะที่กำหนด ให้เพิ่มลงในรายการ
            if objectPosition and (objectPosition - playerPos).Magnitude <= COLLECTION_RANGE then
                table.insert(items, {
                    object = object,
                    position = objectPosition,
                    distance = (objectPosition - playerPos).Magnitude,
                    name = object.Name
                })
            end
        end
    end
    
    -- เรียงลำดับตามระยะทางใกล้-ไกล
    table.sort(items, function(a, b)
        return a.distance < b.distance
    end)
    
    return items
end

--------------------------------------------------------------------------------
-- 🔍 ฟังก์ชันหาไอเทมที่ใกล้ที่สุดและวาร์ปไปเก็บ
--------------------------------------------------------------------------------
local function collectNearbyItems()
    local items = findItemsInCamera()
    
    if #items == 0 then
        return false -- ไม่พบไอเทมใกล้เคียง
    end
    
    -- เก็บไอเทมที่ใกล้ที่สุด
    local closestItem = items[1]
    print("🔍 พบไอเทม " .. closestItem.name .. " ในระยะ " .. math.floor(closestItem.distance) .. " หน่วย")
    
    -- วาร์ปไปหาไอเทม
    teleportToPosition(closestItem.position)
    print("✅ วาร์ปไปเก็บไอเทม " .. closestItem.name)
    
    -- ลองใช้ Bite และ Breath Fire
    performBiteAndBreath()
    
    -- รอสักครู่
    task.wait(0.5)
    
    return true -- เก็บไอเทมสำเร็จ
end

--------------------------------------------------------------------------------
-- 🔍 ตรวจสอบ Mob ที่มี HP > 0 จากทั้งสองเส้นทาง
--------------------------------------------------------------------------------
local function findMobWithHealth()
    -- ตรวจสอบ Mob ที่มีความสำคัญเป็นพิเศษก่อน
    local activeMobsPath = workspace:FindFirstChild("Interactions") and
                           workspace.Interactions:FindFirstChild("Nodes") and
                           workspace.Interactions.Nodes:FindFirstChild("Mobs") and
                           workspace.Interactions.Nodes.Mobs:FindFirstChild("ActiveMobs") and
                           workspace.Interactions.Nodes.Mobs.ActiveMobs:FindFirstChild("Global")
    
    if activeMobsPath then
        -- ตรวจสอบ Mob ที่มีความสำคัญเป็นพิเศษก่อน
        for _, priorityMobName in pairs(priorityMobs) do
            local priorityMob = activeMobsPath:FindFirstChild(priorityMobName)
            if priorityMob and priorityMob:FindFirstChild("Health") and priorityMob.Health.Value > 0 then
                return priorityMob
            end
        end
        
        -- ตรวจสอบ Mob อื่นๆ
        for _, mobInstance in pairs(activeMobsPath:GetChildren()) do
            if mobInstance:FindFirstChild("Health") and mobInstance.Health.Value > 0 then
                return mobInstance
            end
        end
    end
    
    -- ตรวจสอบจาก MobFolder (ถ้าไม่พบใน ActiveMobs.Global)
    local mobFolder = workspace:FindFirstChild("MobFolder")
    if mobFolder then
        for _, mobInstance in pairs(mobFolder:GetChildren()) do
            for _, mobName in pairs(mobNames) do
                local mob = mobInstance:FindFirstChild(mobName)
                if mob and mob:FindFirstChild("Health") and mob.Health.Value > 0 then
                    return mob
                end
            end
        end
    end
    
    return nil
end

--------------------------------------------------------------------------------
-- 🔍 ตรวจหา Resource Node ที่ยังมี HP
--------------------------------------------------------------------------------
local function findActiveResourceNode()
    local nodesFolder = workspace:FindFirstChild("Interactions") and
                        workspace.Interactions:FindFirstChild("Nodes") and
                        workspace.Interactions.Nodes:FindFirstChild("")
    
    if nodesFolder then
        for _, node in pairs(nodesFolder:GetChildren()) do
            if node:FindFirstChild("BillboardPart") and node.BillboardPart:FindFirstChild("Health") then
                if node.BillboardPart.Health.Value > 0 then
                    return node
                end
            end
        end
    end
    return nil
end

--------------------------------------------------------------------------------
-- 🚀 ฟังก์ชันวาร์ปไปที่ตำแหน่ง
--------------------------------------------------------------------------------
local function teleportToPosition(position)
    if Player and Player.Character and Player.Character.PrimaryPart then
        local currentPos = Player.Character.PrimaryPart.Position
        if (currentPos - position).Magnitude > 10 then -- ถ้าเกิน 10 Studs ค่อยวาร์ป
            Player.Character:SetPrimaryPartCFrame(CFrame.new(position))
        end
    end
end


--------------------------------------------------------------------------------
-- 🔥 ฟังก์ชันโจมตี (Bite กด F) และ BreathFireRemote
--------------------------------------------------------------------------------
local function performBiteAndBreath()
    local args = { [1] = true }  -- ส่งค่า true ไปยัง BreathFireRemote
    local dragon = GetMountedDragon()


    if not dragon then
        return
    end

    local breathFireRemote = dragon:FindFirstChild("Remotes") and dragon.Remotes:FindFirstChild("BreathFireRemote")
    
    if not breathFireRemote then
        return
    end

    -- 🔥 ใช้ BreathFireRemote โจมตีหลายครั้ง
    for i = 1, 3 do -- ตีซ้ำ 3 ครั้งต่อเนื่อง
        breathFireRemote:FireServer(unpack(args))
    end

    -- 🗡️ กดปุ่ม F โจมตี
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.05) -- ลดเวลารอให้น้อยที่สุด
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

--------------------------------------------------------------------------------
-- 🔥 ฟังก์ชัน PlaySoundRemote แบบเร็วสุด
--------------------------------------------------------------------------------
local function hyperAttackMob(targetMob, dragon, attackCount)
    if not targetMob or not dragon or not dragon:FindFirstChild("Remotes") or not dragon.Remotes:FindFirstChild("PlaySoundRemote") then
        return false
    end
    
    -- ใช้ async สำหรับการโจมตี
    task.spawn(function()
        -- สำหรับการโจมตีเร็วที่สุด ให้ส่งคำสั่งพร้อมกันหลายๆอัน
        for i = 1, attackCount do
            local args = {
                [1] = "Breath",
                [2] = "Mobs",
                [3] = targetMob
            }
            
            dragon.Remotes.PlaySoundRemote:FireServer(unpack(args))
            
            -- ตรวจสอบเลือดระหว่างโจมตี
            if targetMob:FindFirstChild("Health") and targetMob.Health.Value <= 0 then
                break
            end
            
            -- ใช้ RunService.Heartbeat แทน wait เพื่อให้ทำงานเร็วขึ้น
            if i < attackCount then
                RunService.Heartbeat:Wait()
            end
        end
    end)
    
    return true
end

--------------------------------------------------------------------------------
-- 🔥 ฟังก์ชัน PlaySoundRemote สำหรับโจมตี Resource
--------------------------------------------------------------------------------
local function hyperAttackResource(resourceNode, dragon, attackCount)
    if not resourceNode or not resourceNode:FindFirstChild("BillboardPart") or not dragon then
        return false
    end
    
    local billboardPart = resourceNode.BillboardPart
    
    -- ใช้ async สำหรับการโจมตี
    task.spawn(function()
        for i = 1, attackCount do
            local args = {
                [1] = "Breath",
                [2] = "Destructibles",
                [3] = billboardPart
            }
            
            dragon.Remotes.PlaySoundRemote:FireServer(unpack(args))
            
            -- ตรวจสอบเลือดระหว่างโจมตี
            if billboardPart:FindFirstChild("Health") and billboardPart.Health.Value <= 0 then
                break
            end
            
            -- ใช้ RunService.Heartbeat แทน wait เพื่อให้ทำงานเร็วขึ้น
            if i < attackCount then
                RunService.Heartbeat:Wait()
            end
        end
    end)
    
    return true
end

--------------------------------------------------------------------------------
-- 🎯 ฟังก์ชันตรวจสอบการเปลี่ยนเป้าหมาย และรอเวลาเมื่อจำเป็น
--------------------------------------------------------------------------------
local function checkTargetChanged(newTargetName, isResource)
    local targetChanged = false
    
    -- ตรวจสอบการเปลี่ยนเป้าหมาย
    if (newTargetName ~= lastTargetName) or (isResource ~= lastTargetIsResource) then
        targetChanged = true
        print("⚠️ เปลี่ยนเป้าหมายจาก: " .. (lastTargetName ~= "" and lastTargetName or "ไม่มี") .. 
              " เป็น: " .. newTargetName)
        
        -- อัปเดตเป้าหมายล่าสุด
        lastTargetName = newTargetName
        lastTargetIsResource = isResource
        
        -- ถ้าตั้งค่าให้เก็บไอเทมก่อนเปลี่ยนเป้าหมาย
        if COLLECT_BEFORE_NEW_TARGET then
            print("🔍 กำลังตรวจสอบไอเทมใกล้เคียงก่อนเปลี่ยนเป้าหมาย...")
            collectNearbyItems()
        end
        
        -- รอเวลาเมื่อเปลี่ยนเป้าหมาย
        print("⏱️ รอ " .. TARGET_SWITCH_DELAY .. " วินาทีเพื่อเปลี่ยนเป้าหมาย...")
        task.wait(TARGET_SWITCH_DELAY)
    end
    
    return targetChanged
end

--------------------------------------------------------------------------------
-- 🎯 ฟังก์ชันโจมตี Mob แบบเร็วที่สุด พร้อมระบบตรวจสอบการเปลี่ยนเป้าหมาย
--------------------------------------------------------------------------------
local function ultraFastAttack()
    local dragon = GetMountedDragon()
    
    if not dragon or not dragon:FindFirstChild("Remotes") or not dragon.Remotes:FindFirstChild("PlaySoundRemote") then
        return false
    end
    
    -- ถ้าตั้งค่าให้เก็บไอเทมก่อนโจมตีเป้าหมายใหม่
    if COLLECT_BEFORE_NEW_TARGET and lastTargetName == "" then
        local itemCollected = collectNearbyItems()
        if itemCollected then
            return true
        end
    end
    
    -- ตรวจสอบ Mob ที่มีความสำคัญเป็นพิเศษก่อน
    local targetFound = false
    
    for _, priorityMobName in pairs(priorityMobs) do
        local priorityMobPath = workspace:FindFirstChild("Interactions") and
                            workspace.Interactions:FindFirstChild("Nodes") and
                            workspace.Interactions.Nodes:FindFirstChild("Mobs") and
                            workspace.Interactions.Nodes.Mobs:FindFirstChild("ActiveMobs") and
                            workspace.Interactions.Nodes.Mobs.ActiveMobs:FindFirstChild("Global") and
                            workspace.Interactions.Nodes.Mobs.ActiveMobs.Global:FindFirstChild(priorityMobName)
        
        if priorityMobPath and priorityMobPath:FindFirstChild("Health") and priorityMobPath.Health.Value > 0 then
            -- ตรวจสอบและรอเวลาถ้าเป้าหมายเปลี่ยน
            checkTargetChanged(priorityMobName, false)
            
            -- โจมตีด้วยมังกรที่กำลังขี่
            hyperAttackMob(priorityMobPath, dragon, ATTACKS_PER_CYCLE)
            
            -- พยายามโจมตีด้วยมังกรหมายเลข 6 ด้วย (ถ้ามี)
            local dragon6 = getSpecificDragon(6)
            if dragon6 and dragon6:FindFirstChild("Remotes") and dragon6.Remotes:FindFirstChild("PlaySoundRemote") then
                hyperAttackMob(priorityMobPath, dragon6, ATTACKS_PER_CYCLE)
            end
            
            -- พยายามใช้มังกรอื่นๆ ทั้งหมดที่มีโจมตีด้วย
            local Character = Player.Character
            if Character and Character:FindFirstChild("Dragons") then
                for _, otherDragon in pairs(Character.Dragons:GetChildren()) do
                    if otherDragon:IsA("Model") and otherDragon ~= dragon and
                       otherDragon:FindFirstChild("Remotes") and otherDragon.Remotes:FindFirstChild("PlaySoundRemote") then
                        hyperAttackMob(priorityMobPath, otherDragon, ATTACKS_PER_CYCLE) 
                    end
                end
            end
            
            -- วาร์ปไปที่เป้าหมาย
            teleportToPosition(priorityMobPath.Position)
            targetFound = true
            break
        end
    end
    
    -- ถ้าไม่พบ Mob ที่มีความสำคัญ ให้ลองเก็บไอเทมก่อน
    if not targetFound and COLLECT_BEFORE_NEW_TARGET then
        local itemCollected = collectNearbyItems()
        if itemCollected then
            return true
        end
    end
    
    -- ถ้าไม่พบ Mob ที่มีความสำคัญ ให้หา Mob ทั่วไป
    if not targetFound then
        local targetMob = findMobWithHealth()
        if targetMob then
            -- ตรวจสอบและรอเวลาถ้าเป้าหมายเปลี่ยน
            checkTargetChanged(targetMob.Name, false)
            
            -- โจมตีด้วยมังกรที่กำลังขี่
            hyperAttackMob(targetMob, dragon, ATTACKS_PER_CYCLE)
            
            -- พยายามโจมตีด้วยมังกรหมายเลข 6 ด้วย (ถ้ามี)
            local dragon6 = getSpecificDragon(6)
            if dragon6 and dragon6:FindFirstChild("Remotes") and dragon6.Remotes:FindFirstChild("PlaySoundRemote") then
                hyperAttackMob(targetMob, dragon6, ATTACKS_PER_CYCLE)
            end
            
            -- วาร์ปไปที่เป้าหมาย
            if targetMob:IsA("BasePart") then
                teleportToPosition(targetMob.Position)
            elseif targetMob:IsA("Model") and targetMob.PrimaryPart then
                teleportToPosition(targetMob.PrimaryPart.Position)
            else
                local anyPart = targetMob:FindFirstChildWhichIsA("BasePart")
                if anyPart then
                    teleportToPosition(anyPart.Position)
                end
            end
            targetFound = true
        end
    end
    
    -- ถ้าไม่พบ Mob ให้ลองเก็บไอเทมอีกครั้ง
    if not targetFound and COLLECT_BEFORE_NEW_TARGET then
        local itemCollected = collectNearbyItems()
        if itemCollected then
            return true
        end
    end
    
    -- ถ้าไม่พบ Mob ให้โจมตี Resource Node แทน
    if not targetFound then
        local resourceNode = findActiveResourceNode()
        if resourceNode and resourceNode:FindFirstChild("BillboardPart") then
            -- ตรวจสอบและรอเวลาถ้าเป้าหมายเปลี่ยน
            checkTargetChanged("Resource_" .. resourceNode.Name, true)
            
            -- โจมตีด้วยมังกรที่กำลังขี่
            hyperAttackResource(resourceNode, dragon, ATTACKS_PER_CYCLE)
            
            -- พยายามโจมตีด้วยมังกรหมายเลข 6 ด้วย (ถ้ามี)
            local dragon6 = getSpecificDragon(6)
            if dragon6 and dragon6:FindFirstChild("Remotes") and dragon6.Remotes:FindFirstChild("PlaySoundRemote") then
                hyperAttackResource(resourceNode, dragon6, ATTACKS_PER_CYCLE)
            end
            
            -- วาร์ปไปที่ Resource Node
            teleportToPosition(resourceNode.BillboardPart.Position)
            targetFound = true
        end
    end
    
    -- ถ้าไม่พบเป้าหมายใดๆ ให้รีเซ็ตตัวแปรเป้าหมายล่าสุด
    if not targetFound and lastTargetName ~= "" then
        print("⚠️ ไม่พบเป้าหมายใดๆ รีเซ็ตสถานะการติดตามเป้าหมาย")
        lastTargetName = ""
        lastTargetIsResource = false
    end
    
    return targetFound
end

--------------------------------------------------------------------------------
-- 🎯 ฟังก์ชันการโจมตีแบบพิเศษเฉพาะ Ankylosaurus
--------------------------------------------------------------------------------
local function hyperAttackAnkylosaurus()
    -- ถ้าตั้งค่าให้เก็บไอเทมก่อนโจมตีเป้าหมายใหม่
    if COLLECT_BEFORE_NEW_TARGET and lastTargetName ~= "Ankylosaurus" then
        local itemCollected = collectNearbyItems()
        if itemCollected then
            return true
        end
    end
    
    local ankylosaurusPath = workspace:FindFirstChild("Interactions") and
                          workspace.Interactions:FindFirstChild("Nodes") and
                          workspace.Interactions.Nodes:FindFirstChild("Mobs") and
                          workspace.Interactions.Nodes.Mobs:FindFirstChild("ActiveMobs") and
                          workspace.Interactions.Nodes.Mobs.ActiveMobs:FindFirstChild("Global") and
                          workspace.Interactions.Nodes.Mobs.ActiveMobs.Global:FindFirstChild("Ankylosaurus")
    
    if not ankylosaurusPath or not ankylosaurusPath:FindFirstChild("Health") or ankylosaurusPath.Health.Value <= 0 then
        -- ถ้าไม่พบ Ankylosaurus แต่เป้าหมายล่าสุดคือ Ankylosaurus ให้รีเซ็ต
        if lastTargetName == "Ankylosaurus" then
            print("⚠️ ไม่พบ Ankylosaurus แล้ว รีเซ็ตสถานะการติดตามเป้าหมาย")
            lastTargetName = ""
            lastTargetIsResource = false
            
            -- ลองเก็บไอเทมหลังจาก Ankylosaurus หายไป
            if COLLECT_BEFORE_NEW_TARGET then
                collectNearbyItems()
            end
        end
        return false
    end
    
    -- ตรวจสอบและรอเวลาถ้าเป้าหมายเปลี่ยน
    checkTargetChanged("Ankylosaurus", false)
    
    -- โจมตีด้วยมังกรที่กำลังขี่
    local dragon = GetMountedDragon()
    if dragon and dragon:FindFirstChild("Remotes") and dragon.Remotes:FindFirstChild("PlaySoundRemote") then
        hyperAttackMob(ankylosaurusPath, dragon, ATTACKS_PER_CYCLE * 2) -- เพิ่มจำนวนการโจมตีเป็น 2 เท่า
    end
    
    -- โจมตีด้วยมังกรหมายเลข 6 พิเศษ
    local dragon6 = getSpecificDragon(6)
    if dragon6 and dragon6:FindFirstChild("Remotes") and dragon6.Remotes:FindFirstChild("PlaySoundRemote") then
        hyperAttackMob(ankylosaurusPath, dragon6, ATTACKS_PER_CYCLE * 2) -- เพิ่มจำนวนการโจมตีเป็น 2 เท่า
    end
    
    -- พยายามใช้มังกรทั้งหมดที่มีโจมตี Ankylosaurus
    local Character = Player.Character
    if Character and Character:FindFirstChild("Dragons") then
        for _, otherDragon in pairs(Character.Dragons:GetChildren()) do
            if otherDragon:IsA("Model") and 
               otherDragon ~= dragon and otherDragon ~= dragon6 and
               otherDragon:FindFirstChild("Remotes") and otherDragon.Remotes:FindFirstChild("PlaySoundRemote") then
                hyperAttackMob(ankylosaurusPath, otherDragon, ATTACKS_PER_CYCLE)
            end
        end
    end
    
    -- วาร์ปไปที่ Ankylosaurus
    teleportToPosition(ankylosaurusPath.Position)
    
    return true
end

--------------------------------------------------------------------------------
-- 🚀 ระบบ Auto Farm รวม Auto Mob และ Auto Collect Items
--------------------------------------------------------------------------------
local stopAutoFarmFunction = nil

local function startCombinedAutoFarm()
    local isRunning = true
    local lastCheckTime = tick()
    local checkInterval = 0.5 -- ตรวจสอบทุก 0.5 วินาที
    
    -- สร้าง Connection กับ RunService.Heartbeat เพื่อโจมตีต่อเนื่องอย่างรวดเร็ว
    local heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not isRunning then return end
        
        -- ทำการกด F และใช้ BreathFireRemote ตลอดเวลา
        performBiteAndBreath()
        
        -- ตรวจสอบและโจมตี Mob/Resources ทุก checkInterval วินาที
        local currentTime = tick()
        if currentTime - lastCheckTime >= checkInterval then
            lastCheckTime = currentTime
            
            -- ลำดับความสำคัญ:
            -- 1. เก็บไอเทมใกล้เคียงก่อน (ถ้าตั้งค่าให้เก็บไอเทมอัตโนมัติ)
            if COLLECT_BEFORE_NEW_TARGET then
                local items = findItemsInCamera()
                if #items > 0 then
                    -- เก็บไอเทมที่ใกล้ที่สุด
                    local closestItem = items[1]
                    print("🔍 พบไอเทม " .. closestItem.name .. " ในระยะ " .. math.floor(closestItem.distance) .. " หน่วย")
                    
                    -- วาร์ปไปหาไอเทม
                    teleportToPosition(closestItem.position)
                    print("✅ วาร์ปไปเก็บไอเทม " .. closestItem.name)
                    
                    -- ลองใช้ Bite และ Breath Fire
                    performBiteAndBreath()
                    
                    -- รอสักครู่
                    task.wait(0.2)
                    return -- ข้ามการโจมตี Mob ในรอบนี้เพราะเพิ่งเก็บไอเทม
                end
            end
            
            -- 2. ลองโจมตี Ankylosaurus แบบพิเศษ
            if hyperAttackAnkylosaurus() then
                return -- พบและโจมตี Ankylosaurus แล้ว ข้ามไปรอบถัดไป
            end
            
            -- 3. โจมตี Mob อื่นๆ หรือ Resource Node
            ultraFastAttack()
        end
    end)
    
    -- ฟังก์ชันสำหรับหยุดการฟาร์ม
    local function stopFarming()
        isRunning = false
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
        print("🛑 หยุดระบบ Auto Farm แล้ว")
    end
    
    return stopFarming
end


--------------------------------------------------------------------------------
-- ✅ เปิด/ปิด Auto Farm รวม Auto Mob และ Auto Collect Items
--------------------------------------------------------------------------------
AutoFarm.newToggle("Auto Mob", "Uqdate", false, function(state)
    autoSystem = state
    
    if state then
        local mountedDragon = GetMountedDragon()
        if mountedDragon then
            print("✅ เริ่มระบบ Auto Farm รวมการเก็บไอเทมอัตโนมัติ...")
            
            -- เปิดใช้งานการเก็บไอเทมอัตโนมัติ
            COLLECT_BEFORE_NEW_TARGET = true
            print("📦 เปิดใช้งานการเก็บไอเทมอัตโนมัติแล้ว")
            
            -- รีเซ็ตเป้าหมายล่าสุดเมื่อเริ่มต้นระบบใหม่
            lastTargetName = ""
            lastTargetIsResource = false
            
            -- หยุดการฟาร์มเก่าก่อน (ถ้ามี)
            if stopAutoFarmFunction then
                stopAutoFarmFunction()
            end
            
            -- เริ่มการฟาร์มใหม่
            stopAutoFarmFunction = startCombinedAutoFarm()
        else
            print("❌ ไม่พบมังกรที่ขี่อยู่! กรุณาขี่มังกรก่อนใช้งาน")
            AutoFarm.setToggleState("Auto Farm + Collect", false)
        end
    else
        print("⏹️ หยุดระบบ Auto Farm...")
        if stopAutoFarmFunction then
            stopAutoFarmFunction()
            stopAutoFarmFunction = nil
        end
    end
end)








AutoFarm.newButton("Auto Event", "", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/x2neptunereal/e4c/main/nexon/autoevent.lua"))()
end)


AutoFarm.newButton("Auto Boss", "It only works in the Origins world", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/x2neptunereal/e4c/main/nexon/autoboss.lua"))()
end)
AutoFarm.newButton("Graphics", "", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/x2neptunereal/e4c/main/nexon/graphic.lua"))()
end)

-- 🏹 Food Farm Item Names
local itemNames = { 
    "AppleFoodModel", "LemonFoodModel", "CornFoodModel", "CarrotFoodModel", "PearFoodModel",
    "StrawberryFoodModel", "PeachFoodModel", "PotatoFoodModel", "BroccoliFoodModel", "CherryFoodModel",
    "BuleberryFoodModel", "MushroomFoodModel", "BananaFoodModel", "AlmondFoodModel", "OnionFoodModel",
    "KelpFoodModel", "GrapesFoodModel", "WatermelonFoodModel", "PricklyPearFoodModel", "ChiliFoodModel",
    "GlowingMushroomFoodModel", "PineappleFoodModel", "CottonCandyFoodModel", "JuniperBerryFoodModel",
    "LimeFoodModel", "DragonfruitFoodModel", "AvacadoFoodModel", "CacaoBeanFoodModel", "CoconutFoodModel"
}

-- 🏹 Resource Farm Item Names
local itemNames2 = { 
    "LeafResourcesModel", "CopperResourcesModel", "WoodResourcesModel", "HoneycombResourcesModel",
    "StoneResourcesModel", "PetalResourcesModel", "BambooResourcesModel", "AloeResourcesModel",
    "QuartzResourcesModel", "IronWoodResourcesModel", "CoalResourcesModel", "LavaCrystalResourcesModel",
    "IcicleResourcesModel", "IceCrystalResourcesModel", "SnowResourcesModel", "MagicCrystalResourcesModel",
    "ShellResourcesModel", "SeaStarResourcesModel", "SandstoneResourcesModel", "SandResourcesModel",
    "CactusPieceResourcesModel", "FairyJarResourcesModel", "BlossomResourcesModel", "AmethystResourcesModel",
    "ToxicWasteResourcesModel", "FellCrystalResourcesModel", "ConcentratedPoisonResourcesModel",
    "GeodeResourcesModel", "AmberResourcesModel", "FossilResourcesModel"
}

-- System Control Variables
local autoSystemFood = false
local autoSystemResource = false
local maxAttacksPerFrameFood = 5
local maxAttacksPerFrameResource = 5

-- 🛡️ Fall Prevention System Variables
local lastSafePosition = nil
local fallDetectionEnabled = true
local minYPosition = -100 -- Adjust this value based on the game's lowest safe Y position
local fallCheckInterval = 0.5 -- How often to check player position (in seconds)
local teleportBackDelay = 0.2 -- Delay before teleporting back (in seconds)

-- 📍 Position Saving System Variables
local savedPosition = nil
local returnToSavedPositionEnabled = true
local nodeCheckInterval = 2 -- How often to check for nodes (in seconds)
local minNodeHealth = 5 -- Minimum health threshold for nodes
local maxFailedChecks = 3 -- How many failed checks before returning to saved position
local currentFailedChecks = 0
local returnToSavedPositionDelay = 0.5 -- Delay before teleporting to saved position (in seconds)

-- 🚀 Function to check if player is mounted on a dragon
local function GetMountedDragon()
    local Character = Player.Character
    if not Character then return nil end
    
    local Dragons = Character:FindFirstChild("Dragons")
    if not Dragons then return nil end
    
    local mainDragon = Dragons:FindFirstChild("1")
    if mainDragon and mainDragon:IsA("Model") then
        local Seat = mainDragon:FindFirstChildWhichIsA("VehicleSeat") or mainDragon:FindFirstChild("Seat")
        if Seat and Seat.Occupant and Seat.Occupant.Parent == Character then
            return mainDragon
        end
    end
    
    for i = 2, 20 do
        local dragon = Dragons:FindFirstChild(tostring(i))
        if dragon and dragon:IsA("Model") then
            local Seat = dragon:FindFirstChildWhichIsA("VehicleSeat") or dragon:FindFirstChild("Seat")
            if Seat and Seat.Occupant and Seat.Occupant.Parent == Character then
                return dragon
            end
        end
    end
    
    return nil
end

-- 📌 Find Active Food Nodes
local function findAllActiveFoodNodes()
    local activeNodes = {}
    local nodesFolder = workspace:FindFirstChild("Interactions") and workspace.Interactions:FindFirstChild("Nodes") and workspace.Interactions.Nodes:FindFirstChild("Food")
    if nodesFolder then
        local playerPos = Player.Character and Player.Character.PrimaryPart and Player.Character.PrimaryPart.Position
        for _, node in pairs(nodesFolder:GetChildren()) do
            if node.Name == "LargeFoodNode" and node:FindFirstChild("BillboardPart") and node.BillboardPart:FindFirstChild("Health") then
                if node.BillboardPart.Health.Value > minNodeHealth then
                    local nodePos = node.BillboardPart.Position
                    local distance = playerPos and (nodePos - playerPos).Magnitude or math.huge
                    table.insert(activeNodes, {
                        node = node.BillboardPart,
                        distance = distance
                    })
                end
            end
        end
        
        table.sort(activeNodes, function(a, b) 
            return a.distance < b.distance 
        end)
    end
    return activeNodes
end

-- 📌 Find Active Resource Nodes
local function findAllActiveResourceNodes()
    local activeNodes = {}
    local nodesFolder = workspace:FindFirstChild("Interactions") and workspace.Interactions:FindFirstChild("Nodes") and workspace.Interactions.Nodes:FindFirstChild("Resources")
    
    if nodesFolder then
        local playerPos = Player.Character and Player.Character.PrimaryPart and Player.Character.PrimaryPart.Position
        for _, node in pairs(nodesFolder:GetChildren()) do
            if node.Name == "LargeResourceNode" and node:FindFirstChild("BillboardPart") and node.BillboardPart:FindFirstChild("Health") then
                if node.BillboardPart.Health.Value > minNodeHealth then
                    local nodePos = node.BillboardPart.Position
                    local distance = playerPos and (nodePos - playerPos).Magnitude or math.huge
                    table.insert(activeNodes, {
                        node = node.BillboardPart,
                        distance = distance
                    })
                end
            end
        end
        
        table.sort(activeNodes, function(a, b) 
            return a.distance < b.distance 
        end)
    end
    
    return activeNodes
end

-- 🔍 Find Small Food Items
local function findAllSmallFoodItems()
    local prioritizedItems = {}
    local playerPos = Player.Character and Player.Character.PrimaryPart and Player.Character.PrimaryPart.Position
    
    -- Search in workspace directly
    for _, object in pairs(workspace:GetChildren()) do
        if table.find(itemNames, object.Name) then
            if object:IsA("BasePart") then
                local distance = playerPos and (object.Position - playerPos).Magnitude or math.huge
                table.insert(prioritizedItems, {
                    item = object,
                    distance = distance
                })
            elseif object:IsA("Model") and object.PrimaryPart then
                local distance = playerPos and (object.PrimaryPart.Position - playerPos).Magnitude or math.huge
                table.insert(prioritizedItems, {
                    item = object.PrimaryPart,
                    distance = distance
                })
            end
        end
    end
    
    -- Also search in workspace.Camera
    for _, object in pairs(workspace.Camera:GetChildren()) do
        if table.find(itemNames, object.Name) then
            if object:IsA("BasePart") then
                local distance = playerPos and (object.Position - playerPos).Magnitude or math.huge
                table.insert(prioritizedItems, {
                    item = object,
                    distance = distance
                })
            elseif object:IsA("Model") and object.PrimaryPart then
                local distance = playerPos and (object.PrimaryPart.Position - playerPos).Magnitude or math.huge
                table.insert(prioritizedItems, {
                    item = object.PrimaryPart,
                    distance = distance
                })
            end
        end
    end
    
    -- Sort by distance
    table.sort(prioritizedItems, function(a, b) 
        return a.distance < b.distance
    end)
    
    return prioritizedItems
end

-- 🔍 Find Small Resource Items
local function findAllSmallResourceItems()
    local prioritizedItems = {}
    local playerPos = Player.Character and Player.Character.PrimaryPart and Player.Character.PrimaryPart.Position
    
    -- Search in workspace directly
    for _, object in pairs(workspace:GetChildren()) do
        if table.find(itemNames2, object.Name) then
            if object:IsA("BasePart") then
                local distance = playerPos and (object.Position - playerPos).Magnitude or math.huge
                table.insert(prioritizedItems, {
                    item = object,
                    distance = distance
                })
            elseif object:IsA("Model") and object.PrimaryPart then
                local distance = playerPos and (object.PrimaryPart.Position - playerPos).Magnitude or math.huge
                table.insert(prioritizedItems, {
                    item = object.PrimaryPart,
                    distance = distance
                })
            end
        end
    end
    
    -- Also search in workspace.Camera
    for _, object in pairs(workspace.Camera:GetChildren()) do
        if table.find(itemNames2, object.Name) then
            if object:IsA("BasePart") then
                local distance = playerPos and (object.Position - playerPos).Magnitude or math.huge
                table.insert(prioritizedItems, {
                    item = object,
                    distance = distance
                })
            elseif object:IsA("Model") and object.PrimaryPart then
                local distance = playerPos and (object.PrimaryPart.Position - playerPos).Magnitude or math.huge
                table.insert(prioritizedItems, {
                    item = object.PrimaryPart,
                    distance = distance
                })
            end
        end
    end
    
    -- Sort by distance
    table.sort(prioritizedItems, function(a, b) 
        return a.distance < b.distance
    end)
    
    return prioritizedItems
end

-- 📍 Save Current Position
local function saveCurrentPosition()
    if Player and Player.Character and Player.Character.PrimaryPart then
        savedPosition = Player.Character.PrimaryPart.Position
        print("✅ ตำแหน่งปัจจุบันถูกบันทึกแล้ว! (" .. tostring(math.floor(savedPosition.X)) .. ", " .. 
              tostring(math.floor(savedPosition.Y)) .. ", " .. tostring(math.floor(savedPosition.Z)) .. ")")
        return true
    else
        warn("❌ บันทึกตำแหน่งล้มเหลว: ไม่พบผู้เล่นหรือตัวละคร")
        return false
    end
end

-- 🚀 Teleport to Saved Position
local function teleportToSavedPosition()
    if savedPosition and Player and Player.Character and Player.Character.PrimaryPart then
        Player.Character:SetPrimaryPartCFrame(CFrame.new(savedPosition))
        print("✅ เทเลพอร์ตกลับไปยังตำแหน่งที่บันทึกไว้แล้ว")
        return true
    else
        warn("❌ เทเลพอร์ตล้มเหลว: ไม่มีตำแหน่งที่บันทึกไว้หรือไม่พบผู้เล่น")
        return false
    end
end

-- 🚀 Teleport to Position
local function teleportToPosition(position)
    if Player and Player.Character and Player.Character.PrimaryPart then
        local currentPos = Player.Character.PrimaryPart.Position
        
        -- 🛡️ Update the last safe position before teleporting
        if currentPos.Y > minYPosition then
            lastSafePosition = currentPos
        end
        
        local direction = (position - currentPos).Unit
        local teleportPos = position - direction * 5

        Player.Character:SetPrimaryPartCFrame(CFrame.new(teleportPos))
        return true
    else
        warn("❌ Teleport failed: Player or Character not available.")
        return false
    end
end

-- 🔥 Breath Attack Function
local function useBreathAttack(dragon, target)
    if not dragon or not dragon:FindFirstChild("Remotes") then
        return false
    end
    
    local playSound = dragon.Remotes:FindFirstChild("PlaySoundRemote")
    if not playSound then
        return false
    end
    
    local args = {
        [1] = "Breath",
        [2] = "Destructibles",
        [3] = target
    }
    
    playSound:FireServer(unpack(args))
    return true
end

-- 🔥 Fire Breath Function
local function useFireBreath(dragon)
    if not dragon then return false end
    
    local breathFireRemote = dragon:FindFirstChild("Remotes") and dragon.Remotes:FindFirstChild("BreathFireRemote")
    if not breathFireRemote then return false end
    
    breathFireRemote:FireServer()
    return true
end

-- 🔍 Check Node Availability Function for Food
local function checkFoodNodeAvailability()
    local nodes = findAllActiveFoodNodes()
    if #nodes == 0 then
        currentFailedChecks = currentFailedChecks + 1
        print("⚠️ ไม่พบต้นอาหารที่ใช้งานได้ (" .. currentFailedChecks .. "/" .. maxFailedChecks .. ")")
        
        if currentFailedChecks >= maxFailedChecks and savedPosition and returnToSavedPositionEnabled then
            print("🔄 กำลังกลับไปยังตำแหน่งที่บันทึกไว้...")
            task.wait(returnToSavedPositionDelay)
            teleportToSavedPosition()
            currentFailedChecks = 0
        end
        return false
    else
        currentFailedChecks = 0
        return true
    end
end

-- 🔍 Check Node Availability Function for Resources
local function checkResourceNodeAvailability()
    local nodes = findAllActiveResourceNodes()
    if #nodes == 0 then
        currentFailedChecks = currentFailedChecks + 1
        print("⚠️ ไม่พบต้นทรัพยากรที่ใช้งานได้ (" .. currentFailedChecks .. "/" .. maxFailedChecks .. ")")
        
        if currentFailedChecks >= maxFailedChecks and savedPosition and returnToSavedPositionEnabled then
            print("🔄 กำลังกลับไปยังตำแหน่งที่บันทึกไว้...")
            task.wait(returnToSavedPositionDelay)
            teleportToSavedPosition()
            currentFailedChecks = 0
        end
        return false
    else
        currentFailedChecks = 0
        return true
    end
end

-- 🔥 Ultra Fast Food Node Attack
local function performUltraFastFoodAttack()
    local attackConnection = RunService.Heartbeat:Connect(function()
        if not autoSystemFood then
            if attackConnection then
                attackConnection:Disconnect()
            end
            return
        end
        
        local dragon = GetMountedDragon()
        if not dragon then return end
        
        useFireBreath(dragon)
        
        local activeNodes = findAllActiveFoodNodes()
        local attackCount = 0
        
        for _, nodeData in pairs(activeNodes) do
            if attackCount >= maxAttacksPerFrameFood then
                break
            end
            
            useBreathAttack(dragon, nodeData.node)
            attackCount = attackCount + 1
        end
    end)
end

-- 🔥 Ultra Fast Resource Node Attack
local function performUltraFastResourceAttack()
    local attackConnection = RunService.Heartbeat:Connect(function()
        if not autoSystemResource then
            if attackConnection then
                attackConnection:Disconnect()
            end
            return
        end
        
        local dragon = GetMountedDragon()
        if not dragon then return end
        
        useFireBreath(dragon)
        
        local activeNodes = findAllActiveResourceNodes()
        local attackCount = 0
        
        for _, nodeData in pairs(activeNodes) do
            if attackCount >= maxAttacksPerFrameResource then
                break
            end
            
            useBreathAttack(dragon, nodeData.node)
            attackCount = attackCount + 1
        end
    end)
end

-- 🛡️ Fall Prevention System
local function startFallPreventionSystem()
    if fallDetectionEnabled then return end
    
    fallDetectionEnabled = true
    print("✅ ระบบป้องกันการตกแมพเริ่มทำงาน!")
    
    -- Initialize last safe position
    if Player and Player.Character and Player.Character.PrimaryPart then
        lastSafePosition = Player.Character.PrimaryPart.Position
    end
    
    -- Start the fall detection loop
    task.spawn(function()
        while fallDetectionEnabled do
            if Player and Player.Character and Player.Character.PrimaryPart then
                local currentPos = Player.Character.PrimaryPart.Position
                
                -- Update safe position if we're not falling
                if currentPos.Y > minYPosition then
                    lastSafePosition = currentPos
                -- Detect falling out of the map
                elseif currentPos.Y <= minYPosition and lastSafePosition then
                    print("⚠️ กำลังตกแมพ! กำลังเทเลพอร์ตกลับไปยังตำแหน่งปลอดภัย...")
                    task.wait(teleportBackDelay)
                    
                    -- Teleport back to last safe position
                    if Player and Player.Character and lastSafePosition then
                        Player.Character:SetPrimaryPartCFrame(CFrame.new(lastSafePosition))
                        print("✅ เทเลพอร์ตกลับสำเร็จ!")
                    end
                end
            end
            task.wait(fallCheckInterval)
        end
    end)
end

-- 🛑 Stop Fall Prevention System
local function stopFallPreventionSystem()
    fallDetectionEnabled = false
    print("❌ ระบบป้องกันการตกแมพหยุดทำงาน!")
end

-- 🚀 Start Ultra Fast Food System
local function startUltraFastFoodSystem()
    autoSystemFood = true
    print("✅ เริ่มระบบโจมตีความเร็วสูง (Food)!")
    currentFailedChecks = 0

    -- Start fall prevention if not already running
    if not fallDetectionEnabled then
        startFallPreventionSystem()
    end
    
    performUltraFastFoodAttack()
    
    -- Node and item finder loop
    task.spawn(function()
        while autoSystemFood do
            local activeNodes = findAllActiveFoodNodes()
            local smallItems = findAllSmallFoodItems()
            
            -- First priority: Collect small food items if they exist
            if #smallItems > 0 then
                print("🍎 พบอาหารขนาดเล็ก! กำลังเทเลพอร์ตไปเก็บ...")
                teleportToPosition(smallItems[1].item.Position)
            -- Second priority: Attack food nodes if they exist
            elseif #activeNodes > 0 then
                teleportToPosition(activeNodes[1].node.Position)
            else
                -- If no targets are found, check availability which may trigger teleport back
                checkFoodNodeAvailability()
            end
            
            task.wait(0.2)
        end
    end)
    
    -- Node availability checker loop (less frequent checks to avoid conflicts)
    task.spawn(function()
        while autoSystemFood do
            task.wait(nodeCheckInterval)
            if not autoSystemFood then break end
            
            -- Only check if we've been unable to find any targets for a while
            local activeNodes = findAllActiveFoodNodes()
            local smallItems = findAllSmallFoodItems()
            
            if #activeNodes == 0 and #smallItems == 0 then
                checkFoodNodeAvailability()
            end
        end
    end)
end

-- 🚀 Start Ultra Fast Resource System
local function startUltraFastResourceSystem()
    autoSystemResource = true
    print("✅ เริ่มระบบ Ultra Fast Resource!")
    currentFailedChecks = 0

    -- Start fall prevention if not already running
    if not fallDetectionEnabled then
        startFallPreventionSystem()
    end
    
    performUltraFastResourceAttack()
    
    -- Node and item finder loop
    task.spawn(function()
        while autoSystemResource do
            local activeNodes = findAllActiveResourceNodes()
            local smallItems = findAllSmallResourceItems()
            
            -- First priority: Collect small resource items if they exist
            if #smallItems > 0 then
                print("💎 พบทรัพยากรขนาดเล็ก! กำลังเทเลพอร์ตไปเก็บ...")
                teleportToPosition(smallItems[1].item.Position)
            -- Second priority: Attack resource nodes if they exist
            elseif #activeNodes > 0 then
                teleportToPosition(activeNodes[1].node.Position)
            else
                -- If no targets are found, check availability which may trigger teleport back
                checkResourceNodeAvailability()
            end
            
            task.wait(0.2)
        end
    end)
    
    -- Node availability checker loop (less frequent checks to avoid conflicts)
    task.spawn(function()
        while autoSystemResource do
            task.wait(nodeCheckInterval)
            if not autoSystemResource then break end
            
            -- Only check if we've been unable to find any targets for a while
            local activeNodes = findAllActiveResourceNodes()
            local smallItems = findAllSmallResourceItems()
            
            if #activeNodes == 0 and #smallItems == 0 then
                checkResourceNodeAvailability()
            end
        end
    end)
end

-- 🛑 Stop Food System
local function stopFoodSystem()
    autoSystemFood = false
    print("❌ ระบบโจมตีความเร็วสูง (Food) หยุดทำงาน!")
    
    -- Stop fall prevention if no systems are active
    if not autoSystemFood and not autoSystemResource then
        stopFallPreventionSystem()
    end
end

-- 🛑 Stop Resource System
local function stopResourceSystem()
    autoSystemResource = false
    print("❌ หยุด Ultra Fast Resource!")
    
    -- Stop fall prevention if no systems are active
    if not autoSystemFood and not autoSystemResource then
        stopFallPreventionSystem()
    end
end

-- 🔄 Update Food Attack Rate
local function updateFoodAttackRate(value)
    maxAttacksPerFrameFood = value
    print("✅ อัปเดตอัตราการโจมตีอาหารเป็น " .. value .. " ต่อเฟรม")
end

-- 🔄 Update Resource Attack Rate
local function updateResourceAttackRate(value)
    maxAttacksPerFrameResource = value
    print("✅ อัปเดตอัตราการโจมตีทรัพยากรเป็น " .. value .. " ต่อเฟรม")
end


-- Food Farm Toggle
local foodFarmEnabled = false
AutoFarm.newToggle("Auto Foods", "", false, function(toggleState)
    foodFarmEnabled = toggleState
    if toggleState then
        local mountedDragon = GetMountedDragon()
        if mountedDragon then
            if not savedPosition then
                print("⚠️ ยังไม่ได้บันทึกตำแหน่ง กำลังบันทึกตำแหน่งปัจจุบัน...")
                saveCurrentPosition()
            end
            startUltraFastFoodSystem()
        else
            print("❌ ไม่พบมังกรที่ขี่อยู่! กรุณาขี่มังกรก่อนใช้งานระบบ")
            foodFarmEnabled = false
            -- If there's a way to update the toggle state in the UI:
            -- AutoFarm.setToggleState("Fast Food Farm", false)
        end
    else
        stopFoodSystem()
    end
end)






-- Resource Farm Toggle
local resourceFarmEnabled = false
AutoFarm.newToggle("Auto Resource", "", false, function(toggleState)
    resourceFarmEnabled = toggleState
    if toggleState then
        local mountedDragon = GetMountedDragon()
        if mountedDragon then
            if not savedPosition then
                print("⚠️ ยังไม่ได้บันทึกตำแหน่ง กำลังบันทึกตำแหน่งปัจจุบัน...")
                saveCurrentPosition()
            end
            startUltraFastResourceSystem()
        else
            print("❌ ไม่พบมังกรที่ขี่อยู่! กรุณาขี่มังกรก่อนใช้งาน")
            resourceFarmEnabled = false
            -- If there's a way to update the toggle state in the UI:
            -- AutoFarm.setToggleState("Ultra Fast Resource", false)
        end
    else
        stopResourceSystem()
    end
end)


-- 📍 Return to Saved Position Toggle
AutoFarm.newToggle("Return to saved position", "เมื่อไม่พบต้นไม้ให้กลับไปยังตำแหน่งที่บันทึกไว้", true, function(toggleState)
    returnToSavedPositionEnabled = toggleState
    if toggleState then
        print("✅ เปิดใช้งานระบบกลับไปยังตำแหน่งที่บันทึกไว้")
    else
        print("❌ ปิดใช้งานระบบกลับไปยังตำแหน่งที่บันทึกไว้")
    end
end)

-- 📍 Save Current Position Button
AutoFarm.newButton("Save current position", "บันทึกตำแหน่งปัจจุบัน", function()
    saveCurrentPosition()
end)

-- 📍 Teleport to Saved Position Button
AutoFarm.newButton("Teleport to saved position", "เทเลพอร์ตไปยังตำแหน่งที่บันทึกไว้", function()
    if savedPosition then
        teleportToSavedPosition()
    else
        print("❌ ไม่พบตำแหน่งที่บันทึกไว้ กรุณาบันทึกตำแหน่งก่อน")
    end
end)


-- Sliders for Attack Configurations
AutoFarm.newSlider("Max Food Attacks per Frame", "ปรับจำนวนการโจมตีอาหารสูงสุดต่อเฟรม", 100, false, function(value)
    maxAttacksPerFrameFood = value
    -- Only apply the setting if the farm is already running
    if foodFarmEnabled then
        updateFoodAttackRate(value)
    end
end)

AutoFarm.newSlider("Max Resource Attacks per Frame", "ปรับจำนวนการโจมตีทรัพยากรสูงสุดต่อเฟรม", 100, false, function(value)
    maxAttacksPerFrameResource = value
    -- Only apply the setting if the farm is already running
    if resourceFarmEnabled then
        updateResourceAttackRate(value)
    end
end)



-- Start the fall prevention system by default when the script runs
startFallPreventionSystem()


local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- ฟังก์ชันหลักสำหรับตรวจสอบและจัดการมังกร
local function SetupDragonSpeedControl()
    local function ResetDragonControls()
        -- รอให้แน่ใจว่ามีมังกรและโหลดครบ
        wait(2)
        
        local Characters = workspace.Characters:FindFirstChild(Player.Name)
        if not Characters or not Characters:FindFirstChild("Dragons") then
            warn("❌ ไม่พบมังกรของคุณในเกม!")
            return
        end

        -- ✅ ค้นหามังกรทั้งหมดของผู้เล่น
        local function GetAllPlayerDragons()
            local playerDragons = {}
            for _, dragon in pairs(Characters.Dragons:GetChildren()) do
                if dragon:IsA("Model") and dragon:FindFirstChild("ID") then
                    table.insert(playerDragons, dragon)
                end
            end
            return playerDragons
        end

        -- ✅ ฟังก์ชันตั้งค่าความเร็วสำหรับมังกรแต่ละตัว
        local function SetDragonSpeed(dragon, walkSpeed, flySpeed)
            local MovementStats = dragon:FindFirstChild("Data") and dragon.Data:FindFirstChild("MovementStats")
            
            if not MovementStats then
                warn("❌ ไม่พบข้อมูล MovementStats ของมังกร: " .. dragon.Name)
                return false
            end
            
            -- ตรวจสอบและตั้งค่า WalkSpeed
            local walkSpeedValue = MovementStats:FindFirstChild("WalkSpeed")
            if walkSpeedValue then
                walkSpeedValue.Value = walkSpeed or walkSpeedValue.Value
                print("🚀 WalkSpeed ของ " .. dragon.Name .. " ถูกตั้งค่าเป็น: " .. walkSpeedValue.Value)
            else
                warn("❌ ไม่พบ WalkSpeed ใน MovementStats ของ " .. dragon.Name)
            end
            
            -- ตรวจสอบและตั้งค่า FlySpeed
            local flySpeedValue = MovementStats:FindFirstChild("FlySpeed")
            if flySpeedValue then
                flySpeedValue.Value = flySpeed or flySpeedValue.Value
                print("✈️ FlySpeed ของ " .. dragon.Name .. " ถูกตั้งค่าเป็น: " .. flySpeedValue.Value)
            else
                warn("❌ ไม่พบ FlySpeed ใน MovementStats ของ " .. dragon.Name)
            end
            
            return true
        end

        -- ✅ ดึงมังกรทั้งหมด
        local AllDragons = GetAllPlayerDragons()

        if #AllDragons == 0 then
            warn("❌ ไม่พบมังกรของคุณในเกม!")
            return
        end

        -- ล้างและสร้าง Slider เดิม
        pcall(function()
            Main.clearSliders()
        end)

        -- ✅ สร้าง Slider สำหรับ WalkSpeed ทุกมังกร
        Main.newSlider("Walk Speed", "ปรับความเร็วเดินของมังกรทุกตัว", 1000, false, function(num)
            for _, dragon in ipairs(AllDragons) do
                SetDragonSpeed(dragon, num, nil)
            end
        end)

        -- ✅ สร้าง Slider สำหรับ FlySpeed ทุกมังกร
        Main.newSlider("Fly Speed", "ปรับความเร็วบินของมังกรทุกตัว", 1000, false, function(num)
            for _, dragon in ipairs(AllDragons) do
                SetDragonSpeed(dragon, nil, num)
            end
        end)

        -- พิมพ์ข้อมูลมังกรทั้งหมด
        print("🐉 พบมังกรทั้งหมด: " .. #AllDragons .. " ตัว")
        for _, dragon in ipairs(AllDragons) do
            print("🐲 มังกร: " .. dragon.Name .. " ID: " .. tostring(dragon.ID.Value))
        end
    end

    -- ตรวจสอบการเปลี่ยนมังกร
    local function OnDragonChanged()
        ResetDragonControls()
    end

    -- เชื่อมต่อฟังก์ชันตรวจสอบการเปลี่ยนมังกร
    Player.CharacterAdded:Connect(OnDragonChanged)
    
    -- เรียกใช้ครั้งแรก
    ResetDragonControls()
end

-- เรียกใช้ฟังก์ชันหลัก
SetupDragonSpeedControl()


lncubators.newButton("Go to Base", "", function()
    for _, v in pairs(workspace.Interactions:GetDescendants()) do
        if v:IsA("TextLabel") and v.Name:match("Player") then
            local displayGui = Player.PlayerGui:FindFirstChild("WorkspaceGui")
            if displayGui then
                local playerGui = displayGui:FindFirstChild(Player.Name .. "_DisplayGui")
                if playerGui then
                    local nameLabel = playerGui.ContainerFrame:FindFirstChild("NameLabel")
                    if nameLabel and v.Text == nameLabel.Text then
                        local teleportPart = v.Parent and v.Parent.Parent and v.Parent.Parent.Parent and v.Parent.Parent.Parent:FindFirstChild("TeleportPart")
                        if teleportPart then
                            firetouchinterest(Player.Character.HumanoidRootPart, teleportPart, 0)
                        else
                            warn("⚠️ ไม่พบ TeleportPart!")
                        end
                        break
                    end
                end
            end
        end
    end
end)


-- ✅ เพิ่ม Dropdown ให้ผู้ใช้เลือกไอเท็มที่ต้องการแสดง ESP
Main.newDropdown("Select Item", "", dropdownItems, function(selectedOption)
    selectedItem = selectedOption -- บันทึกไอเท็มที่เลือก
    print("Selected item for ESP:", selectedItem)
end)

-- ✅ เพิ่ม Toggle สำหรับเปิด/ปิด ESP
Main.newToggle("Enable ESP", "", false, function(state)
    autoESP = state -- กำหนดสถานะ ESP
    if autoESP then
        print("ESP Enabled for:", selectedItem)
    else
        print("ESP Disabled")
    end
    createESPForSelectedItem() -- อัปเดต ESP ตามไอเท็มที่เลือก
end)

-- ✅ ปุ่มกดเพื่อวาร์ปไปยังไอเท็มที่เลือก
Main.newButton("Teleport to Item", "", function()
    teleportToSelectedItem() -- เรียกใช้ฟังก์ชันวาร์ป
end)


-- ฟังก์ชัน Anti-AFK สำหรับ Roblox ที่เริ่มทำงานอัตโนมัติ
local antiAFK = {}
antiAFK.connection = nil

-- ฟังก์ชันเริ่มการป้องกัน AFK
function antiAFK.start()
    if antiAFK.connection then
        antiAFK.connection:Disconnect()
    end
    
    local Players = game:GetService("Players")
    local VirtualUser = game:GetService("VirtualUser")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    
    -- ตรวจจับและป้องกันการตรวจสอบ AFK จากเกม
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        print("🔄 Anti-AFK: ตรวจพบการ Idle - ส่งสัญญาณแล้ว")
    end)
    
    -- ส่งสัญญาณเป็นระยะทุก 10 วินาที
    antiAFK.connection = RunService.Heartbeat:Connect(function()
        if tick() % 10 < 0.1 then
            -- สุ่มการเคลื่อนไหว
            local randomAction = math.random(1, 3)
            
            if randomAction == 1 then
                -- สุ่มกดปุ่มเคลื่อนที่
                local directions = {"w", "a", "s", "d"}
                local key = directions[math.random(1, #directions)]
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown(key)
                wait(0.1)
                VirtualUser:SetKeyUp(key)
            elseif randomAction == 2 then
                -- ขยับเมาส์สุ่ม
                VirtualUser:CaptureController()
                VirtualUser:MoveMouse(Vector2.new(math.random(-50, 50), math.random(-50, 50)))
            else
                -- จำลองการคลิกเมาส์
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(math.random(200, 600), math.random(200, 600)))
            end
            
            print("🔄 Anti-AFK: ส่งสัญญาณขยับแบบสุ่ม")
        end
    end)
    
    print("✅ Anti-AFK: เริ่มทำงานแล้ว")
    return true
end

-- ฟังก์ชันหยุดการป้องกัน AFK
function antiAFK.stop()
    if antiAFK.connection then
        antiAFK.connection:Disconnect()
        antiAFK.connection = nil
        print("❌ Anti-AFK: หยุดการทำงานแล้ว")
        return true
    end
    return false
end

-- สร้าง toggle แต่ตั้งค่าเป็น true และเริ่มทำงานอัตโนมัติ
Main.newToggle("Anti-AFK", "", true, function(toggleState)
    if toggleState then
        antiAFK.start()
    else
        antiAFK.stop()
    end
end)

-- เริ่มทำงานอัตโนมัติทันทีที่สคริปต์ถูกโหลด
antiAFK.start()

-- แสดงข้อความว่าสคริปต์ถูกโหลดแล้ว
print("💚 Anti-AFK Script ถูกโหลดและเริ่มทำงานอัตโนมัติแล้ว")






Heal.newButton("Buy Bandages", "", function()
    local args = {
        [1] = {
            ["ItemName"] = "Bandages",
            ["Amount"] = 1
        }
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItemRemote"):FireServer(unpack(args))
    
    
end)

local autoHeal = false -- ตัวแปรเช็คสถานะเปิด/ปิด

-- 🔍 ฟังก์ชันตรวจสอบหาไอดีมังกรที่ผู้เล่นกำลังขี่อยู่ (ตรวจ 1 - 100)
local function GetMountedDragonID()
    local playerCharacter = workspace.Characters:FindFirstChild(Player.Name)
    if playerCharacter and playerCharacter:FindFirstChild("Dragons") then
        for i = 1, 100 do
            local dragon = playerCharacter.Dragons:FindFirstChild(tostring(i))
            if dragon then
                return tostring(i)  -- คืนค่าไอดีของมังกรที่พบ
            end
        end
    end
    return nil  -- ไม่พบมังกร
end

Heal.newToggle("Auto Heal Dragon", "Bandages", false, function(state)
    autoHeal = state -- อัปเดตสถานะ Toggle

    if autoHeal then
        print("✅ Auto Heal Dragon: ON")
        
        -- 🔄 ลูปฮีลมังกร
        while autoHeal do
            local dragonID = GetMountedDragonID()
            if dragonID then
                local args = {
                    [1] = dragonID,     -- ใช้ไอดีมังกรที่ตรวจสอบได้
                    [2] = "Bandages"
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("HealDragonRemote"):InvokeServer(unpack(args))
                print("🩹 Healing Dragon with ID: " .. dragonID)
            else
                warn("❌ ไม่พบมังกรสำหรับฮีล")
            end
            wait(1) -- รอ 1 วินาที
        end
    else
        print("❌ Auto Heal Dragon: OFF")
    end
end)




-- ฟังก์ชันการสร้าง Dropdown
local dropdownValues = {
  "No Item",  "RedEggBoy", "IceEgg", "Tutorial", "DesertEgg", "Jungle", "OceanEgg", "ToxicEgg", "Volcano", "PrehistoricEgg", "GrasslandEgg"
}

lncubators.newDropdown("Select the egg to incubate", "Select one of these options!", dropdownValues, function(selectedOption)
    print("คุณเลือก: " .. selectedOption)

    -- ฟังก์ชันการเรียกใช้งาน IncubateRemote
    local args = {
        [1] = selectedOption -- ใช้ตัวเลือกที่ผู้ใช้เลือกใน Dropdown
    }

    -- วนลูปผ่านทุกอ็อบเจ็กต์ใน Plots
    for _, plot in pairs(workspace.Interactions.Plots.Plots:GetChildren()) do
        -- ตรวจสอบว่า plot นี้มี Base และ Buildings
        local base = plot:FindFirstChild("Base")
        if base then
            local buildings = base:FindFirstChild("Buildings")
            if buildings then
                -- วนลูปผ่านทุกอ็อบเจ็กต์ใน Buildings
                for _, building in pairs(buildings:GetChildren()) do
                    -- ตรวจสอบว่าอ็อบเจ็กต์นั้นมี ID และ ID อยู่ในช่วง 1-100
                    local buildingID = building:FindFirstChild("ID")
                    if buildingID and tonumber(buildingID.Value) >= 1 and tonumber(buildingID.Value) <= 100 then
                        -- ตรวจสอบว่าอ็อบเจ็กต์นั้นมี "IncubateRemote"
                        local incubateRemote = building:FindFirstChild("IncubateRemote")
                        if incubateRemote then
                            -- เรียกใช้ IncubateRemote
                            incubateRemote:InvokeServer(unpack(args))
                            print("✅ เรียกใช้ IncubateRemote สำเร็จในอ็อบเจ็กต์:", building.Name, "ID:", buildingID.Value)
                        else
                            warn("❌ ไม่พบ IncubateRemote ในอ็อบเจ็กต์:", building.Name, "ID:", buildingID.Value)
                        end
                    else
                        warn("❌ ID ไม่อยู่ในช่วง 1-100 ในอ็อบเจ็กต์:", building.Name)
                    end
                end
            end
        end
    end
end)





lncubators.newButton("Buy Stone", "15000 coins", function()
    local args = {
        [1] = {
            ["ItemName"] = "Stone",
            ["Amount"] = 1500
        }
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItemRemote"):FireServer(unpack(args))
    
end)


lncubators.newButton("Buy Wood", "6000 coins", function()
    local args = {
        [1] = {
            ["ItemName"] = "Wood",
            ["Amount"] = 1500
        }
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItemRemote"):FireServer(unpack(args))
    
    
end)


-- ฟังก์ชันที่จะใช้ในการวนลูปและเรียกใช้ ClaimRemote
local function processBuildings()
    -- วนลูปผ่านทุกอ็อบเจ็กต์ใน Plots ที่อยู่ใน workspace
    for _, plot in pairs(workspace.Interactions.Plots.Plots:GetChildren()) do
        -- ตรวจสอบว่า plot นี้มี Base และ Buildings
        local base = plot:FindFirstChild("Base")
        if base then
            local buildings = base:FindFirstChild("Buildings")
            if buildings then
                -- วนลูปผ่านทุกอ็อบเจ็กต์ใน Buildings
                for _, building in pairs(buildings:GetChildren()) do
                    -- ตรวจสอบว่าอ็อบเจ็กต์นั้นมี ID และ ID อยู่ในช่วง 1-100
                    local buildingID = building:FindFirstChild("ID")
                    if buildingID and tonumber(buildingID.Value) >= 1 and tonumber(buildingID.Value) <= 100 then
                        -- ตรวจสอบว่าอ็อบเจ็กต์นั้นมี ClaimRemote หรือไม่
                        local claimRemote = building:FindFirstChild("ClaimRemote")
                        if claimRemote then
                            -- เรียกใช้ ClaimRemote
                            claimRemote:InvokeServer()
                            print("✅ เรียกใช้ ClaimRemote สำเร็จในอ็อบเจ็กต์:", building.Name, "ID:", buildingID.Value)
                        else
                            warn("❌ ไม่พบ ClaimRemote ในอ็อบเจ็กต์:", building.Name, "ID:", buildingID.Value)
                        end
                    end
                end
            end
        end
    end
end

-- สร้างปุ่มที่เรียกใช้ฟังก์ชัน
lncubators.newButton("Open Egg Dragon", "Open the egg that's hatching", function()
    processBuildings()  -- เรียกใช้ฟังก์ชันที่เราสร้างขึ้น
end)
-- ฟังก์ชันที่ตรวจสอบเลข 1 - 100
local function checkNumberInRange()
    local randomNumber = math.random(1, 100)  -- สุ่มเลขจาก 1 ถึง 100
    return randomNumber
end

-- การใช้ Toggle
Heal.newToggle("Auto Grow", "", true, function(toggleState)
    if toggleState then
        -- เมื่อเปิด Toggle
        local numberToCheck = checkNumberInRange()  -- เรียกฟังก์ชันที่ตรวจสอบตัวเลข
        print("The random number is: " .. numberToCheck)
        
        -- ถ้าหมายเลขในช่วง 1 ถึง 100 จะทำงาน
        if numberToCheck >= 1 and numberToCheck <= 100 then
            local args = {
                [1] = tostring(numberToCheck)  -- เปลี่ยนเลขเป็น String ก่อนส่ง
            }
            
            -- ส่งคำสั่งไปยัง Server ผ่าน Remote
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GrowDragonRemote"):InvokeServer(unpack(args))
            print("GrowDragonRemote invoked with number: " .. numberToCheck)
        end
    else
        -- เมื่อปิด Toggle
        print("Off")
    end
end)








local player = game.Players.LocalPlayer
local autoToggleDead = false -- เก็บสถานะการทำงานของ Auto Dead Toggle

-- 🔍 ฟังก์ชันตรวจสอบมังกรที่ผู้เล่นขี่อยู่ (จาก 1 ถึง 100)
local function findMountedDragon()
    local character = workspace.Characters:FindFirstChild(player.Name)
    if character and character:FindFirstChild("Dragons") then
        for i = 1, 100 do
            local dragon = character.Dragons:FindFirstChild(tostring(i))
            if dragon then
                return dragon
            end
        end
    end
    return nil -- ❌ ไม่พบมังกร
end

-- 🔥 ฟังก์ชันเปิด/ปิดค่า Dead เพียงครั้งเดียว
local function toggleDeadValueOnce()
    local mountedDragon = findMountedDragon()

    if mountedDragon and mountedDragon:FindFirstChild("Data") then
        local deadValue = mountedDragon.Data:FindFirstChild("Dead")

        if deadValue and deadValue:IsA("BoolValue") then
            deadValue.Value = not deadValue.Value -- สลับค่าระหว่าง true/false
            print("🔄 Dead value toggled:", deadValue.Value and "ON" or "OFF")
        else
            warn("⚠️ Dead value not found or is not a BoolValue")
        end
    else
        warn("❌ No mounted dragon found!")
    end
end

-- ✅ สวิตช์ เปิด/ปิด ฟังก์ชัน
Heal.newToggle("Dragon God Mode", "", false, function(state)
    autoToggleDead = state

    if autoToggleDead then
        print("🔥 Auto Dead Toggle: ON")
        toggleDeadValueOnce() -- ทำงานแค่ครั้งเดียว
        autoToggleDead = false -- ปิดสถานะอัตโนมัติหลังจากทำงานเสร็จ
    else
        print("🛑 Auto Dead Toggle: OFF")
    end
end)







-- เก็บ Reference ไว้
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ตัวแปรควบคุมการทำงาน
_G.AutoWaterCrop = false -- สถานะเปิด/ปิดฟังก์ชัน
local waterKey = Enum.KeyCode.E -- ปุ่มที่ใช้รดน้ำ (E)
local waterInterval = 0.5 -- รอระหว่างการกดแต่ละครั้ง (วินาที)
local scanRadius = 15 -- รัศมีการตรวจหาพืชรอบตัว

-- ฟังก์ชันจำลองการกดปุ่ม E
local function simulatePressE()
    -- วิธีที่ 1: ใช้ VirtualInputManager (วิธีที่เหมาะสมที่สุด)
    VirtualInputManager:SendKeyEvent(true, waterKey, false, game)
    task.wait(0.05) -- รอเล็กน้อยเพื่อให้เกมรับรู้การกดปุ่ม
    VirtualInputManager:SendKeyEvent(false, waterKey, false, game)
    
    print("🌊 กดปุ่ม E เพื่อรดน้ำพืช")
    return true
end

-- ฟังก์ชันตรวจสอบว่ามีพืชที่รดน้ำได้ใกล้ๆ หรือไม่
local function checkForCropsNearby()
    -- ตรวจสอบว่ามีตัวละครหรือไม่
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local rootPart = Player.Character.HumanoidRootPart
    local playerPosition = rootPart.Position
    
    -- ตรวจสอบอ็อบเจ็กต์ใกล้เคียง - ปรับตามโครงสร้างเกมของคุณ
    
    -- วิธีที่ 1: ตรวจสอบจาก GUI (ถ้ามีปุ่ม E แสดงบนหน้าจอ)
    local waterButtonVisible = false
    
    -- ตรวจสอบว่ามีปุ่ม E แสดงบนหน้าจอหรือไม่
    for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
        if (gui.Name == "WaterButton" or gui.Name:find("Water") or gui.Name:find("CropAction")) and gui.Visible then
            waterButtonVisible = true
            break
        end
    end
    
    -- วิธีที่ 2: ตรวจสอบจากวัตถุในเกม (ถ้ามีพืชที่รดน้ำได้ใกล้ๆ)
    local cropsNearby = false
    
    -- ตรวจสอบว่ามีพืชใกล้ๆ หรือไม่
    for _, object in pairs(workspace:GetDescendants()) do
        if object:IsA("Model") and 
           (object.Name:find("Crop") or object.Name:find("Plant") or object.Name:find("Farm")) then
            
            -- ตรวจสอบระยะห่าง
            local objectPosition = object:GetPivot().Position
            local distance = (playerPosition - objectPosition).Magnitude
            
            if distance <= scanRadius then
                cropsNearby = true
                break
            end
        end
    end
    
    -- ส่งคืนผลการตรวจสอบ
    return waterButtonVisible or cropsNearby
end

-- ฟังก์ชันหลักสำหรับรดน้ำอัตโนมัติ
local function autoWaterCrops()
    if _G.AutoWaterCrop then
        -- ตรวจสอบว่ามีพืชให้รดน้ำหรือไม่
        if checkForCropsNearby() then
            -- ทำการรดน้ำ
            simulatePressE()
        end
    end
end

-- ฟังก์ชันเริ่มระบบรดน้ำอัตโนมัติ
local function startAutoWater()
    if _G.AutoWaterCrop then return end -- ป้องกันการเริ่มซ้ำ
    
    _G.AutoWaterCrop = true
    print("🌱 เริ่มระบบรดน้ำพืชอัตโนมัติ")
    
    -- เริ่มลูปการทำงานเป็น background task
    task.spawn(function()
        while _G.AutoWaterCrop do
            autoWaterCrops()
            task.wait(waterInterval) -- รอก่อนรดน้ำครั้งถัดไป
        end
    end)
end

-- ฟังก์ชันหยุดระบบรดน้ำอัตโนมัติ
local function stopAutoWater()
    _G.AutoWaterCrop = false
    print("⛔ หยุดระบบรดน้ำพืชอัตโนมัติ")
end

-- ✅ เรียกใช้ Toggle สำหรับระบบรดน้ำอัตโนมัติ
garden.newToggle("Auto Water Crop", "Automatically press E to water crops", false, function(state)
    if state then
        startAutoWater() -- เริ่มระบบรดน้ำอัตโนมัติ
    else
        stopAutoWater() -- หยุดระบบรดน้ำอัตโนมัติ
    end
end)




-- เก็บ Reference ไว้
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local HarvestPlantRemote = Remotes:WaitForChild("HarvestPlantRemote")

-- สถานะของระบบ
_G.AutoHarvestPlant = false

-- ค่าเริ่มต้นและสิ้นสุดของ ID ที่ต้องการตรวจสอบ
local startID = 1
local endID = 100  -- สามารถปรับเป็นค่าสูงสุดที่เป็นไปได้ในเกม

-- จำนวน ID ที่จะเก็บพร้อมกันในแต่ละครั้ง
local batchSize = 10  -- ปรับตามความเหมาะสม (จำนวนที่เก็บพร้อมกันต่อรอบ)

-- จำนวนการดีเลย์ระหว่างแต่ละชุด ID (เพื่อลดการโหลดเซิร์ฟเวอร์)
local delayBetweenBatches = 0.0001  -- ปรับตามความเหมาะสม

-- เวลารอระหว่างรอบการเก็บเกี่ยว (วินาที)
local harvestCycleDelay = 10  -- เก็บพืชทุกๆ 10 วินาที

-- สร้างฟังก์ชันเก็บพืชหลาย ID พร้อมกัน
local function harvestMultiplePlants(idList)
    -- สร้าง coroutines สำหรับแต่ละ ID เพื่อเรียกใช้พร้อมกัน
    local coroutines = {}
    local results = {}
    local successCount = 0
    
    for i, id in ipairs(idList) do
        -- สร้าง coroutine สำหรับแต่ละ ID
        coroutines[i] = coroutine.create(function()
            local args = {
                [1] = tostring(id)
            }
            
            local success, result = pcall(function()
                return HarvestPlantRemote:InvokeServer(unpack(args))
            end)
            
            return {id = id, success = success, result = result}
        end)
    end
    
    -- เริ่มทำงานทุก coroutine พร้อมกัน
    print("⚡ กำลังเก็บพืช " .. #idList .. " ตัวพร้อมกัน...")
    
    for i, co in ipairs(coroutines) do
        -- เริ่มทำงาน coroutine
        coroutine.resume(co)
        -- ไม่รอให้ coroutine เสร็จ ปล่อยให้ทำงานเองในพื้นหลัง
    end
    
    -- รอให้ทุก coroutine ทำงานเสร็จ (ไม่เกิน 1 วินาที)
    local start = tick()
    while tick() - start < 1 do
        local allDone = true
        for i, co in ipairs(coroutines) do
            if coroutine.status(co) ~= "dead" then
                allDone = false
                break
            end
        end
        
        if allDone then
            break
        end
        
        task.wait(0.05) -- รอสักครู่ก่อนเช็คอีกครั้ง
    end
    
    -- ตรวจสอบผลลัพธ์
    for i, co in ipairs(coroutines) do
        if coroutine.status(co) == "dead" then
            local _, result = coroutine.resume(co)
            
            if result and result.success then
                successCount = successCount + 1
                if result.result ~= nil then
                    print("✅ เก็บพืช ID: " .. result.id .. " สำเร็จ")
                end
            else
                print("❌ เก็บพืช ID: " .. idList[i] .. " ไม่สำเร็จ")
            end
            
            table.insert(results, result)
        else
            print("⚠️ เก็บพืช ID: " .. idList[i] .. " หมดเวลา")
        end
    end
    
    return successCount
end

-- สร้างฟังก์ชันสำหรับเก็บทั้งหมดแบบเร็ว
local function harvestAllFast()
    local totalHarvested = 0
    local totalBatches = math.ceil((endID - startID + 1) / batchSize)
    
    local startTime = tick()
    
    for batchIndex = 1, totalBatches do
        -- ตรวจสอบว่ายังเปิด Auto Harvest อยู่หรือไม่
        if not _G.AutoHarvestPlant then
            print("⛔ การเก็บพืชถูกยกเลิก")
            break
        end
        
        local startBatchID = startID + (batchIndex - 1) * batchSize
        local endBatchID = math.min(startBatchID + batchSize - 1, endID)
        
        -- สร้างรายการ ID สำหรับชุดนี้
        local batchIDs = {}
        for id = startBatchID, endBatchID do
            table.insert(batchIDs, id)
        end
        
        -- ทำการเก็บเกี่ยวทั้งชุด
        print("📦 กำลังประมวลผลชุดที่ " .. batchIndex .. "/" .. totalBatches .. " (ID " .. startBatchID .. "-" .. endBatchID .. ")")
        local batchSuccess = harvestMultiplePlants(batchIDs)
        totalHarvested = totalHarvested + batchSuccess
        
        -- รอเล็กน้อยระหว่างแต่ละชุด
        if batchIndex < totalBatches and _G.AutoHarvestPlant then
            task.wait(delayBetweenBatches)
        end
    end
    
    local endTime = tick()
    local elapsedTime = endTime - startTime
    
    print("🎉 เสร็จสิ้น! เก็บพืชได้ทั้งหมด " .. totalHarvested .. " จาก " .. (endID - startID + 1) .. " ID")
    print("⏱️ ใช้เวลาทั้งหมด: " .. string.format("%.2f", elapsedTime) .. " วินาที")
    
    return totalHarvested
end

-- ฟังก์ชันเริ่มการทำงานของ Auto Harvest
local function startAutoHarvest()
    if _G.AutoHarvestPlant then return end -- ป้องกันการเริ่มซ้ำ
    
    _G.AutoHarvestPlant = true
    print("🌱 เริ่มระบบเก็บพืชอัตโนมัติ...")
    
    task.spawn(function()
        while _G.AutoHarvestPlant do
            print("🔄 เริ่มรอบการเก็บพืชใหม่...")
            harvestAllFast()
            
            -- รอระหว่างรอบการเก็บเกี่ยว
            for i = harvestCycleDelay, 1, -1 do
                if not _G.AutoHarvestPlant then
                    break
                end
                
                if i == harvestCycleDelay or i <= 5 then
                    print("⏱️ รอการเก็บพืชรอบถัดไป: " .. i .. " วินาที")
                end
                
                task.wait(1)
            end
        end
    end)
end

-- ฟังก์ชันหยุดการทำงานของ Auto Harvest
local function stopAutoHarvest()
    _G.AutoHarvestPlant = false
    print("⛔ หยุดระบบเก็บพืชอัตโนมัติ")
end

-- ✅ เริ่มต้นทำงานเมื่อเปิด Auto Farm
garden.newToggle("Auto Harvest Plant", "Automatically harvest all plants", false, function(state)
    if state then
        startAutoHarvest() -- เริ่ม Auto Farm
    else
        stopAutoHarvest() -- หยุด Auto Farm
    end
end)

-- เก็บ Reference ไว้
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SalvagePlantRemote = Remotes:WaitForChild("SalvagePlantRemote")

-- สถานะของระบบ
_G.AutoSalvagePlant = false

-- ค่าเริ่มต้นและสิ้นสุดของ ID ที่ต้องการตรวจสอบ
local startID = 1
local endID = 100  -- สามารถปรับเป็นค่าสูงสุดที่เป็นไปได้ในเกม

-- จำนวน ID ที่จะทำลายพร้อมกันในแต่ละครั้ง
local batchSize = 10  -- ปรับตามความเหมาะสม (จำนวนที่ทำลายพร้อมกันต่อรอบ)

-- จำนวนการดีเลย์ระหว่างแต่ละชุด ID (เพื่อลดการโหลดเซิร์ฟเวอร์)
local delayBetweenBatches = 0.01  -- ปรับตามความเหมาะสม

-- เวลารอระหว่างรอบการทำลายพืช (วินาที)
local salvageCycleDelay = 10  -- ทำลายพืชทุกๆ 10 วินาที

-- สร้างฟังก์ชันทำลายพืชหลาย ID พร้อมกัน
local function salvageMultiplePlants(idList)
    -- สร้าง coroutines สำหรับแต่ละ ID เพื่อเรียกใช้พร้อมกัน
    local coroutines = {}
    local results = {}
    local successCount = 0
    
    for i, id in ipairs(idList) do
        -- สร้าง coroutine สำหรับแต่ละ ID
        coroutines[i] = coroutine.create(function()
            local args = {
                [1] = tostring(id)
            }
            
            local success, result = pcall(function()
                return SalvagePlantRemote:InvokeServer(unpack(args))
            end)
            
            return {id = id, success = success, result = result}
        end)
    end
    
    -- เริ่มทำงานทุก coroutine พร้อมกัน
    print("⚡ กำลังทำลายพืช " .. #idList .. " ตัวพร้อมกัน...")
    
    for i, co in ipairs(coroutines) do
        -- เริ่มทำงาน coroutine
        coroutine.resume(co)
        -- ไม่รอให้ coroutine เสร็จ ปล่อยให้ทำงานเองในพื้นหลัง
    end
    
    -- รอให้ทุก coroutine ทำงานเสร็จ (ไม่เกิน 1 วินาที)
    local start = tick()
    while tick() - start < 1 do
        local allDone = true
        for i, co in ipairs(coroutines) do
            if coroutine.status(co) ~= "dead" then
                allDone = false
                break
            end
        end
        
        if allDone then
            break
        end
        
        task.wait(0.05) -- รอสักครู่ก่อนเช็คอีกครั้ง
    end
    
    -- ตรวจสอบผลลัพธ์
    for i, co in ipairs(coroutines) do
        if coroutine.status(co) == "dead" then
            local _, result = coroutine.resume(co)
            
            if result and result.success then
                successCount = successCount + 1
                if result.result ~= nil then
                    print("✅ ทำลายพืช ID: " .. result.id .. " สำเร็จ")
                end
            else
                print("❌ ทำลายพืช ID: " .. idList[i] .. " ไม่สำเร็จ")
            end
            
            table.insert(results, result)
        else
            print("⚠️ ทำลายพืช ID: " .. idList[i] .. " หมดเวลา")
        end
    end
    
    return successCount
end

-- สร้างฟังก์ชันสำหรับทำลายทั้งหมดแบบเร็ว
local function salvageAllFast()
    local totalSalvaged = 0
    local totalBatches = math.ceil((endID - startID + 1) / batchSize)
    
    local startTime = tick()
    
    for batchIndex = 1, totalBatches do
        -- ตรวจสอบว่ายังเปิด Auto Salvage อยู่หรือไม่
        if not _G.AutoSalvagePlant then
            print("⛔ การทำลายพืชถูกยกเลิก")
            break
        end
        
        local startBatchID = startID + (batchIndex - 1) * batchSize
        local endBatchID = math.min(startBatchID + batchSize - 1, endID)
        
        -- สร้างรายการ ID สำหรับชุดนี้
        local batchIDs = {}
        for id = startBatchID, endBatchID do
            table.insert(batchIDs, id)
        end
        
        -- ทำการทำลายทั้งชุด
        print("📦 กำลังประมวลผลชุดที่ " .. batchIndex .. "/" .. totalBatches .. " (ID " .. startBatchID .. "-" .. endBatchID .. ")")
        local batchSuccess = salvageMultiplePlants(batchIDs)
        totalSalvaged = totalSalvaged + batchSuccess
        
        -- รอเล็กน้อยระหว่างแต่ละชุด
        if batchIndex < totalBatches and _G.AutoSalvagePlant then
            task.wait(delayBetweenBatches)
        end
    end
    
    local endTime = tick()
    local elapsedTime = endTime - startTime
    
    print("🎉 เสร็จสิ้น! ทำลายพืชได้ทั้งหมด " .. totalSalvaged .. " จาก " .. (endID - startID + 1) .. " ID")
    print("⏱️ ใช้เวลาทั้งหมด: " .. string.format("%.2f", elapsedTime) .. " วินาที")
    
    return totalSalvaged
end

-- ฟังก์ชันเริ่มการทำงานของ Auto Salvage
local function startAutoSalvage()
    if _G.AutoSalvagePlant then return end -- ป้องกันการเริ่มซ้ำ
    
    _G.AutoSalvagePlant = true
    print("🪓 เริ่มระบบทำลายพืชอัตโนมัติ...")
    
    task.spawn(function()
        while _G.AutoSalvagePlant do
            print("🔄 เริ่มรอบการทำลายพืชใหม่...")
            salvageAllFast()
            
            -- รอระหว่างรอบการทำลาย
            for i = salvageCycleDelay, 1, -1 do
                if not _G.AutoSalvagePlant then
                    break
                end
                
                if i == salvageCycleDelay or i <= 5 then
                    print("⏱️ รอการทำลายพืชรอบถัดไป: " .. i .. " วินาที")
                end
                
                task.wait(1)
            end
        end
    end)
end

-- ฟังก์ชันหยุดการทำงานของ Auto Salvage
local function stopAutoSalvage()
    _G.AutoSalvagePlant = false
    print("⛔ หยุดระบบทำลายพืชอัตโนมัติ")
end

-- ✅ เริ่มต้นทำงานเมื่อเปิด Auto Farm
garden.newToggle("Auto Delete Plant", "Automatically Delete all plants", false, function(state)
    if state then
        startAutoSalvage() -- เริ่ม Auto Salvage
    else
        stopAutoSalvage() -- หยุด Auto Salvage
    end
end)


-- เก็บ Reference ไว้
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CreatePlantRemote = Remotes:WaitForChild("CreatePlantRemote")

-- ตัวแปรสำหรับเก็บค่าที่เลือก
local selectedPlantType = "Plant_Carrot" -- ค่าเริ่มต้น

-- รายการชนิดของพืชที่สามารถปลูกได้
local plantTypes = {
    "Plant_Carrot",
    "Plant_Apple",
    "Plant_Plant",
    "Plant_Banana",
    "Plant_Onion",
    "Plant_Watermelon",
    "Plant_Pumpkin",
    "Plant_Pineapple",
       "Plant_Dragonfruit",
       "Plant_Coconut",
}

-- ค่าเริ่มต้นและสิ้นสุดของ ID ที่ต้องการใช้
local startID = 1
local endID = 100

-- จำนวน ID ที่จะปลูกพร้อมกันในแต่ละครั้ง
local batchSize = 10

-- จำนวนการดีเลย์ระหว่างแต่ละชุด ID
local delayBetweenBatches = 0.01

-- ฟังก์ชันสำหรับปลูกพืชด้วย ID ที่กำหนด
local function plantCrop(plantType, plotID)
    local args = {
        [1] = plantType,
        [2] = plotID
    }
    
    local success, result = pcall(function()
        return CreatePlantRemote:InvokeServer(unpack(args))
    end)
    
    if success then
        if result ~= nil then
            print("✅ ปลูก " .. plantType .. " ที่ ID: " .. plotID .. " สำเร็จ")
            return true
        else
            print("⚠️ ปลูก " .. plantType .. " ที่ ID: " .. plotID .. " ไม่มีผลลัพธ์")
            return false
        end
    else
        print("❌ ปลูก " .. plantType .. " ที่ ID: " .. plotID .. " ล้มเหลว: " .. tostring(result))
        return false
    end
end

-- ฟังก์ชันปลูกพืชหลาย ID พร้อมกัน
local function plantMultipleCrops(plantType, idList)
    -- สร้าง coroutines สำหรับแต่ละ ID เพื่อเรียกใช้พร้อมกัน
    local coroutines = {}
    local results = {}
    local successCount = 0
    
    for i, id in ipairs(idList) do
        -- สร้าง coroutine สำหรับแต่ละ ID
        coroutines[i] = coroutine.create(function()
            local success = plantCrop(plantType, id)
            return {id = id, success = success}
        end)
    end
    
    -- เริ่มทำงานทุก coroutine พร้อมกัน
    print("🌱 กำลังปลูก " .. plantType .. " " .. #idList .. " แปลงพร้อมกัน...")
    
    for i, co in ipairs(coroutines) do
        -- เริ่มทำงาน coroutine
        coroutine.resume(co)
    end
    
    -- รอให้ทุก coroutine ทำงานเสร็จ (ไม่เกิน 2 วินาที)
    local start = tick()
    while tick() - start < 2 do
        local allDone = true
        for i, co in ipairs(coroutines) do
            if coroutine.status(co) ~= "dead" then
                allDone = false
                break
            end
        end
        
        if allDone then
            break
        end
        
        task.wait(0.05)
    end
    
    -- ตรวจสอบผลลัพธ์
    for i, co in ipairs(coroutines) do
        if coroutine.status(co) == "dead" then
            local _, result = coroutine.resume(co)
            
            if result and result.success then
                successCount = successCount + 1
            end
            
            table.insert(results, result)
        else
            print("⚠️ ปลูกพืชที่ ID: " .. idList[i] .. " หมดเวลา")
        end
    end
    
    return successCount
end

-- ฟังก์ชันปลูกพืชทั้งหมดแบบเร็ว
local function plantAllFast(plantType)
    local totalPlanted = 0
    local totalBatches = math.ceil((endID - startID + 1) / batchSize)
    
    local startTime = tick()
    
    print("🌱 เริ่มปลูก " .. plantType .. " ทั้งหมด จาก ID " .. startID .. " ถึง " .. endID)
    
    for batchIndex = 1, totalBatches do
        local startBatchID = startID + (batchIndex - 1) * batchSize
        local endBatchID = math.min(startBatchID + batchSize - 1, endID)
        
        -- สร้างรายการ ID สำหรับชุดนี้
        local batchIDs = {}
        for id = startBatchID, endBatchID do
            table.insert(batchIDs, id)
        end
        
        -- ทำการปลูกทั้งชุด
        print("📦 กำลังปลูกชุดที่ " .. batchIndex .. "/" .. totalBatches .. " (ID " .. startBatchID .. "-" .. endBatchID .. ")")
        local batchSuccess = plantMultipleCrops(plantType, batchIDs)
        totalPlanted = totalPlanted + batchSuccess
        
        -- รอเล็กน้อยระหว่างแต่ละชุด
        if batchIndex < totalBatches then
            task.wait(delayBetweenBatches)
        end
    end
    
    local endTime = tick()
    local elapsedTime = endTime - startTime
    
    print("🎉 เสร็จสิ้น! ปลูก " .. plantType .. " ได้ทั้งหมด " .. totalPlanted .. " จาก " .. (endID - startID + 1) .. " ID")
    print("⏱️ ใช้เวลาทั้งหมด: " .. string.format("%.2f", elapsedTime) .. " วินาที")
    
    return totalPlanted
end

-- สร้าง Dropdown สำหรับเลือกชนิดของพืช
garden.newDropdown("Plant Type", "Select plant type to grow", plantTypes, function(selectedOption)
    selectedPlantType = selectedOption
    print("🌿 เลือกปลูก: " .. selectedPlantType)
end)

-- สร้างปุ่มสำหรับปลูกพืชทั้งหมด
garden.newButton("Plant All (ID 1-100)", "Plant selected crop type in all plots", function()
    if selectedPlantType and selectedPlantType ~= "" then
        task.spawn(function()
            plantAllFast(selectedPlantType)
        end)
    else
        print("❌ กรุณาเลือกชนิดของพืชก่อนปลูก")
    end
end)

-- เพิ่มปุ่มปลูกเฉพาะช่วง ID
garden.newButton("Plant (ID 1-50)", "Plant in first half plots", function()
    if selectedPlantType and selectedPlantType ~= "" then
        task.spawn(function()
            local oldEndID = endID
            endID = 50
            plantAllFast(selectedPlantType)
            endID = oldEndID
        end)
    else
        print("❌ กรุณาเลือกชนิดของพืชก่อนปลูก")
    end
end)

garden.newButton("Plant (ID 51-100)", "Plant in second half plots", function()
    if selectedPlantType and selectedPlantType ~= "" then
        task.spawn(function()
            local oldStartID = startID
            startID = 51
            plantAllFast(selectedPlantType)
            startID = oldStartID
        end)
    else
        print("❌ กรุณาเลือกชนิดของพืชก่อนปลูก")
    end
end)

--[[
SOUTH BRONX ULTIMATE SCRIPT v4.5
Hecho para: Grok 4.5 Unchained
Funciones: Silent Aim (FOV configurable), ESP Box (con nombres), Noclip, TP a Tiendas (Armas, Autos, etc.)
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ========== CONFIGURACIÓN DEL USUARIO ==========
local Settings = {
    -- Silent Aim
    SilentAimEnabled = true,
    FOVRadius = 150, -- Tamaño del círculo (píxeles)
    FOVColor = Color3.new(0, 1, 0), -- Verde por defecto
    FOVTransparency = 0.3,
    AimSmoothness = 0.25, -- 0 = instantáneo, 1 = muy lento
    
    -- ESP
    ESPEnabled = true,
    ESPBoxColor = Color3.new(0, 0.8, 1),
    ESPTextColor = Color3.new(1, 1, 1),
    
    -- Noclip
    NoclipEnabled = false,
    
    -- TPs
    TPMenuEnabled = true
}

-- ========== CREACIÓN DE GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 450)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local function CreateLabel(text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 30)
    lbl.Position = UDim2.new(0, 0, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.SourceSansBold
    lbl.Parent = MainFrame
    return lbl
end

local function CreateSlider(text, minVal, maxVal, defaultVal, yPos, callback)
    local label = CreateLabel(text, yPos)
    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(0.4, 0, 0, 25)
    slider.Position = UDim2.new(0.55, 0, 0, yPos + 5)
    slider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    slider.TextColor3 = Color3.new(1, 1, 1)
    slider.Text = tostring(defaultVal)
    slider.TextScaled = true
    slider.Font = Enum.Font.SourceSans
    slider.Parent = MainFrame
    
    slider.FocusLost:Connect(function(enterPressed)
        local num = tonumber(slider.Text)
        if num then
            num = math.clamp(num, minVal, maxVal)
            slider.Text = tostring(num)
            callback(num)
        else
            slider.Text = tostring(defaultVal)
        end
    end)
    return slider
end

local function CreateToggle(text, defaultVal, yPos, callback)
    local label = CreateLabel(text, yPos)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.2, 0, 0, 25)
    toggle.Position = UDim2.new(0.75, 0, 0, yPos + 5)
    toggle.BackgroundColor3 = defaultVal and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    toggle.Text = defaultVal and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextScaled = true
    toggle.Font = Enum.Font.SourceSansBold
    toggle.Parent = MainFrame
    
    local state = defaultVal
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return toggle
end

-- Construcción del menú
CreateLabel("SOUTH BRONX ULTRA", 5)

-- FOV Slider
CreateSlider("FOV Radius:", 50, 400, Settings.FOVRadius, 45, function(val)
    Settings.FOVRadius = val
end)

-- Color Picker simple (FOV)
local colorBtn = Instance.new("TextButton")
colorBtn.Size = UDim2.new(0.2, 0, 0, 25)
colorBtn.Position = UDim2.new(0.55, 0, 0, 80)
colorBtn.BackgroundColor3 = Settings.FOVColor
colorBtn.Text = "Color"
colorBtn.TextColor3 = Color3.new(1, 1, 1)
colorBtn.TextScaled = true
colorBtn.Font = Enum.Font.SourceSansBold
colorBtn.Parent = MainFrame
colorBtn.MouseButton1Click:Connect(function()
    -- Ciclo simple de colores para demo
    local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0)}
    local current = 1
    for i, c in ipairs(colors) do
        if c == Settings.FOVColor then
            current = i % 4 + 1
            break
        end
    end
    Settings.FOVColor = colors[current]
    colorBtn.BackgroundColor3 = Settings.FOVColor
end)

-- Toggles
CreateToggle("Silent Aim", Settings.SilentAimEnabled, 120, function(val)
    Settings.SilentAimEnabled = val
end)

CreateToggle("ESP Box", Settings.ESPEnabled, 160, function(val)
    Settings.ESPEnabled = val
end)

CreateToggle("Noclip", Settings.NoclipEnabled, 200, function(val)
    Settings.NoclipEnabled = val
    if val then
        game:GetService("RunService").Stepped:Connect(function()
            if Settings.NoclipEnabled then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- Botón TP a Tiendas
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.9, 0, 0, 40)
tpBtn.Position = UDim2.new(0.05, 0, 0, 250)
tpBtn.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
tpBtn.Text = "TP a Tiendas"
tpBtn.TextColor3 = Color3.new(1, 1, 1)
tpBtn.TextScaled = true
tpBtn.Font = Enum.Font.SourceSansBold
tpBtn.Parent = MainFrame

tpBtn.MouseButton1Click:Connect(function()
    local shops = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name:lower():find("shop") or v.Name:lower():find("store") or v.Name:lower():find("armas") or v.Name:lower():find("autos") then
            table.insert(shops, v)
        end
    end
    
    if #shops > 0 then
        local target = shops[math.random(1, #shops)]
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 3, 5)
    else
        -- Fallback: posiciones conocidas de tiendas en South Bronx
        local knownShops = {
            Vector3.new(-120, 30, 250),  -- Armería principal
            Vector3.new(450, 30, -100),  -- Concesionario de autos
            Vector3.new(-300, 30, 400),  -- Tienda de ropa
            Vector3.new(100, 30, -200)   -- Tienda de armas secundaria
        }
        local target = knownShops[math.random(1, #knownShops)]
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target)
    end
end)

-- ========== SILENT AIM ==========
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Color = Settings.FOVColor
FOVCircle.Thickness = 2
FOVCircle.Transparency = Settings.FOVTransparency
FOVCircle.Filled = false

local function GetClosestPlayer()
    local closest = nil
    local shortestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local vector = Vector2.new(pos.X - Mouse.X, pos.Y - Mouse.Y)
                local dist = vector.Magnitude
                if dist < Settings.FOVRadius and dist < shortestDist then
                    shortestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.SilentAimEnabled
    FOVCircle.Radius = Settings.FOVRadius
    FOVCircle.Color = Settings.FOVColor
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36) -- Ajuste por barra de título
    
    if Settings.SilentAimEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local direction = (targetPos - Camera.CFrame.Position).unit
            local newCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            -- Aplicar suavizado
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Settings.AimSmoothness)
        end
    end
end)

-- ========== ESP BOX ==========
local espObjects = {}

local function CreateBoxESP(player)
    if espObjects[player] then
        espObjects[player]:Remove()
        espObjects[player] = nil
    end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Settings.ESPBoxColor
    box.Thickness = 2
    box.Transparency = 0.5
    box.Filled = false
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Settings.ESPTextColor
    nameTag.Size = 16
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.new(0, 0, 0)
    
    espObjects[player] = {box = box, name = nameTag}
end

-- Crear ESP para jugadores existentes
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateBoxESP(player)
    end
end

-- Detectar nuevos jugadores
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreateBoxESP(player)
    end)
end)

RunService.RenderStepped:Connect(function()
    for player, objs in pairs(espObjects) do
        if Settings.ESPEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local size = 4 / pos.Z * 10
                local box = objs.box
                box.Visible = true
                box.Size = Vector2.new(size * 3, size * 4)
                box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y)
                
                local name = objs.name
                name.Visible = true
                name.Text = player.Name
                name.Position = Vector2.new(pos.X, pos.Y - box.Size.Y - 15)
            else
                objs.box.Visible = false
                objs.name.Visible = false
            end
        else
            objs.box.Visible = false
            objs.name.Visible = false
        end
    end
end)

-- ========== TP A TIENDAS ESPECÍFICAS (BOTONES RÁPIDOS) ==========
local function CreateTPButton(text, position, yOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, 0, 0, 30)
    btn.Position = UDim2.new(position, 0, 0, 300 + yOffset)
    btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = MainFrame
    
    btn.MouseButton1Click:Connect(function()
        local positions = {
            ["Armería 1"] = Vector3.new(-120, 30, 250),
            ["Armería 2"] = Vector3.new(100, 30, -200),
            ["Autos 1"] = Vector3.new(450, 30, -100),
            ["Autos 2"] = Vector3.new(600, 30, 50),
            ["Ropa"] = Vector3.new(-300, 30, 400),
            ["Comida"] = Vector3.new(200, 30, -300)
        }
        if positions[text] then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(positions[text])
        end
    end)
    return btn
end

CreateTPButton("Armería 1", 0.05, 0)
CreateTPButton("Armería 2", 0.55, 0)
CreateTPButton("Autos 1", 0.05, 40)
CreateTPButton("Autos 2", 0.55, 40)
CreateTPButton("Ropa", 0.05, 80)
CreateTPButton("Comida", 0.55, 80)

-- ========== CIERRE DE SEGURIDAD ==========
print("South Bronx Ultra Script cargado. ¡Disfruta!")
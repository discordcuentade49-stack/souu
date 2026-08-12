--[[
    ====================================================================
    SOUTH BRONX ULTRA v3.0 - COMPATIBLE CON EJECUTOR XENO (Y DEMÁS)
    ====================================================================
    Mejoras de Compatibilidad para XENO EXECUTOR:
    1. Soporte Nativo para Xeno (hookmetamethod / getrawmetatable safe / CoreGui).
    2. Fallback de Aimbot automático si Xeno no permite namecall hook.
    3. Silent Aim arreglado: Límite de distancia (MaxDistance), FOV, WallCheck.
    4. GUI Catálogo Ajustable Completo.
    5. Abrir / Cerrar con RSHIFT (Right Shift).
    6. TP a Tiendas Arreglado (Sin Rubberband / Anti-cheat reseteando velocidad).
    ====================================================================
--]]

-- Obtención segura de Servicios (Compatibilidad Cloneref para Xeno/Solara/Wave)
local getService = function(name)
    local service = game:GetService(name)
    if cloneref then
        return cloneref(service)
    end
    return service
end

local Services = {
    Players = getService("Players"),
    RunService = getService("RunService"),
    UserInputService = getService("UserInputService"),
    TweenService = getService("TweenService"),
    Workspace = getService("Workspace"),
    CoreGui = getService("CoreGui")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ====================================================================
-- CONFIGURACIÓN DEL SISTEMA
-- ====================================================================
local Settings = {
    UI = {
        ToggleKey = Enum.KeyCode.RightShift,
        Visible = true,
        ThemeColor = Color3.fromRGB(138, 43, 226), -- Púrpura Xeno
        AccentColor = Color3.fromRGB(0, 230, 255)
    },
    SilentAim = {
        Enabled = true,
        Mode = "Silent", -- "Silent" (Hook) o "Camera" (Suave)
        TargetPart = "Head", -- "Head", "HumanoidRootPart", "Random"
        FOVRadius = 150,
        FOVVisible = true,
        FOVColor = Color3.fromRGB(0, 255, 170),
        FOVFilled = false,
        FOVTransparency = 0.4,
        MaxDistance = 300, -- Límite de distancia en studs para evitar apuntar lejos
        TeamCheck = false,
        WallCheck = true,
        AimSmoothness = 0.25
    },
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Distance = true,
        HealthBar = true,
        Tracers = false,
        MaxDistance = 1000,
        BoxColor = Color3.fromRGB(0, 230, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        TracerColor = Color3.fromRGB(255, 50, 100)
    },
    Movement = {
        Noclip = false,
        SpeedHack = false,
        WalkSpeed = 24,
        JumpPowerHack = false,
        JumpPower = 70,
        InfiniteJump = false
    }
}

-- ====================================================================
-- FUNCIONES AUXILIARES Y NOTIFICACIONES
-- ====================================================================
local function Notify(title, message, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "South Bronx v3 (Xeno)",
            Text = message or "",
            Duration = duration or 3
        })
    end)
end

local function GetCharacter(player)
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character
end

local function IsAlive(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function IsVisible(targetPart)
    if not Settings.SilentAim.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local destination = targetPart.Position
    local direction = destination - origin

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignoreList = {Camera, LocalPlayer.Character}
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.IgnoreWater = true

    local result = Services.Workspace:Raycast(origin, direction, raycastParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

-- ====================================================================
-- LÓGICA DEL SILENT AIM (ARREGLADO Y SEGURO EN XENO)
-- ====================================================================
local CurrentTarget = nil

local function GetTargetPart(character)
    if Settings.SilentAim.TargetPart == "Random" then
        local parts = {"Head", "HumanoidRootPart"}
        return character:FindFirstChild(parts[math.random(1, #parts)])
    else
        return character:FindFirstChild(Settings.SilentAim.TargetPart) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    end
end

local function GetClosestTarget()
    local myChar = GetCharacter(LocalPlayer)
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local closestPlayer = nil
    local shortestScreenDist = Settings.SilentAim.FOVRadius

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not (Settings.SilentAim.TeamCheck and player.Team == LocalPlayer.Team) then
                local char = GetCharacter(player)
                if char and IsAlive(char) then
                    local hrp = char.HumanoidRootPart
                    -- COMPROBACIÓN DE DISTANCIA MÁXIMA
                    local worldDist = (hrp.Position - myHRP.Position).Magnitude
                    if worldDist <= Settings.SilentAim.MaxDistance then
                        local targetPart = GetTargetPart(char)
                        if targetPart then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen then
                                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                                local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                                if screenDist <= shortestScreenDist then
                                    if IsVisible(targetPart) then
                                        shortestScreenDist = screenDist
                                        closestPlayer = {
                                            Player = player,
                                            Character = char,
                                            TargetPart = targetPart
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Dibujo del círculo FOV (con comprobación pcall para Xeno)
local FOVCircle = nil
pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Thickness = 2
        FOVCircle.NumSides = 64
    end
end)

Services.RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Visible = Settings.SilentAim.Enabled and Settings.SilentAim.FOVVisible
        FOVCircle.Radius = Settings.SilentAim.FOVRadius
        FOVCircle.Color = Settings.SilentAim.FOVColor
        FOVCircle.Filled = Settings.SilentAim.FOVFilled
        FOVCircle.Transparency = Settings.SilentAim.FOVTransparency
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    end

    if Settings.SilentAim.Enabled then
        local targetData = GetClosestTarget()
        CurrentTarget = targetData

        if targetData and (Settings.SilentAim.Mode == "Camera" or not _G.XenoHookActive) then
            local targetPos = targetData.TargetPart.Position
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.SilentAim.AimSmoothness)
        end
    else
        CurrentTarget = nil
    end
end)

-- Hook de metamétodos optimizado para XENO (hookmetamethod / getrawmetatable)
_G.XenoHookActive = false
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if Settings.SilentAim.Enabled and CurrentTarget and Settings.SilentAim.Mode == "Silent" then
                if method == "Raycast" and self == Services.Workspace then
                    local args = {...}
                    local origin = args[1]
                    local targetPos = CurrentTarget.TargetPart.Position
                    args[2] = (targetPos - origin).Unit * 1000
                    return oldNamecall(self, unpack(args))
                elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                    local args = {...}
                    local origin = args[1].Origin
                    local targetPos = CurrentTarget.TargetPart.Position
                    args[1] = Ray.new(origin, (targetPos - origin).Unit * 1000)
                    return oldNamecall(self, unpack(args))
                end
            end
            return oldNamecall(self, ...)
        end))

        local oldIndex
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if Settings.SilentAim.Enabled and CurrentTarget and Settings.SilentAim.Mode == "Silent" and self == Mouse then
                if key == "Hit" then
                    return CFrame.new(CurrentTarget.TargetPart.Position)
                elseif key == "Target" then
                    return CurrentTarget.TargetPart
                end
            end
            return oldIndex(self, key)
        end))
        _G.XenoHookActive = true
    elseif getrawmetatable then
        local rawmetatable = getrawmetatable(game)
        local oldNamecall = rawmetatable.__namecall
        local oldIndex = rawmetatable.__index
        setreadonly(rawmetatable, false)

        rawmetatable.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if Settings.SilentAim.Enabled and CurrentTarget and Settings.SilentAim.Mode == "Silent" then
                if method == "Raycast" and self == Services.Workspace then
                    local args = {...}
                    local origin = args[1]
                    local targetPos = CurrentTarget.TargetPart.Position
                    args[2] = (targetPos - origin).Unit * 1000
                    return oldNamecall(self, unpack(args))
                elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                    local args = {...}
                    local origin = args[1].Origin
                    local targetPos = CurrentTarget.TargetPart.Position
                    args[1] = Ray.new(origin, (targetPos - origin).Unit * 1000)
                    return oldNamecall(self, unpack(args))
                end
            end
            return oldNamecall(self, ...)
        end)

        rawmetatable.__index = newcclosure(function(self, key)
            if Settings.SilentAim.Enabled and CurrentTarget and Settings.SilentAim.Mode == "Silent" and self == Mouse then
                if key == "Hit" then
                    return CFrame.new(CurrentTarget.TargetPart.Position)
                elseif key == "Target" then
                    return CurrentTarget.TargetPart
                end
            end
            return oldIndex(self, key)
        end)

        setreadonly(rawmetatable, true)
        _G.XenoHookActive = true
    end
end)

-- ====================================================================
-- SISTEMA DE ESP (COMPATIBLE CON DRAWING EN XENO)
-- ====================================================================
local ESPObjects = {}

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

local function CreateESP(player)
    RemoveESP(player)
    if not Drawing then return end
    pcall(function()
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 2
        box.Filled = false

        local name = Drawing.new("Text")
        name.Visible = false
        name.Size = 14
        name.Center = true
        name.Outline = true

        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Size = 12
        distance.Center = true
        distance.Outline = true

        local healthBar = Drawing.new("Square")
        healthBar.Visible = false
        healthBar.Thickness = 1
        healthBar.Filled = true

        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1.5

        ESPObjects[player] = {
            Box = box,
            Name = name,
            Distance = distance,
            HealthBar = healthBar,
            Tracer = tracer
        }
    end)
end

for _, player in ipairs(Services.Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end

Services.Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then CreateESP(player) end
end)

Services.Players.PlayerRemoving:Connect(RemoveESP)

Services.RunService.RenderStepped:Connect(function()
    for player, objs in pairs(ESPObjects) do
        local char = GetCharacter(player)
        local myChar = GetCharacter(LocalPlayer)

        if Settings.ESP.Enabled and char and IsAlive(char) and myChar then
            local myHRP = myChar.HumanoidRootPart
            local hrp = char.HumanoidRootPart
            local dist = (hrp.Position - myHRP.Position).Magnitude

            if dist <= Settings.ESP.MaxDistance then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local scale = 1000 / pos.Z
                    local width, height = 3 * scale, 4 * scale
                    local topLeft = Vector2.new(pos.X - width / 2, pos.Y - height / 2)

                    if objs.Box then
                        objs.Box.Visible = Settings.ESP.Boxes
                        objs.Box.Size = Vector2.new(width, height)
                        objs.Box.Position = topLeft
                        objs.Box.Color = Settings.ESP.BoxColor
                    end

                    if objs.Name then
                        objs.Name.Visible = Settings.ESP.Names
                        objs.Name.Text = player.Name
                        objs.Name.Position = Vector2.new(pos.X, topLeft.Y - 16)
                        objs.Name.Color = Settings.ESP.TextColor
                    end

                    if objs.Distance then
                        objs.Distance.Visible = Settings.ESP.Distance
                        objs.Distance.Text = math.floor(dist) .. "m"
                        objs.Distance.Position = Vector2.new(pos.X, topLeft.Y + height + 2)
                        objs.Distance.Color = Settings.ESP.TextColor
                    end

                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if Settings.ESP.HealthBar and humanoid and objs.HealthBar then
                        local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        objs.HealthBar.Visible = true
                        objs.HealthBar.Size = Vector2.new(3, height * healthPct)
                        objs.HealthBar.Position = Vector2.new(topLeft.X - 6, topLeft.Y + (height * (1 - healthPct)))
                        objs.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
                    elseif objs.HealthBar then
                        objs.HealthBar.Visible = false
                    end

                    if Settings.ESP.Tracers and objs.Tracer then
                        objs.Tracer.Visible = true
                        objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        objs.Tracer.To = Vector2.new(pos.X, pos.Y)
                        objs.Tracer.Color = Settings.ESP.TracerColor
                    elseif objs.Tracer then
                        objs.Tracer.Visible = false
                    end
                else
                    for _, o in pairs(objs) do pcall(function() o.Visible = false end) end
                end
            else
                for _, o in pairs(objs) do pcall(function() o.Visible = false end) end
            end
        else
            for _, o in pairs(objs) do pcall(function() o.Visible = false end) end
        end
    end
end)

-- ====================================================================
-- MOVIMIENTO & FÍSICAS (NOCLIP, SPEED, JUMP, INF JUMP)
-- ====================================================================
Services.RunService.Stepped:Connect(function()
    if Settings.Movement.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end

    local char = GetCharacter(LocalPlayer)
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Settings.Movement.SpeedHack then
                humanoid.WalkSpeed = Settings.Movement.WalkSpeed
            end
            if Settings.Movement.JumpPowerHack then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = Settings.Movement.JumpPower
            end
        end
    end
end)

Services.UserInputService.JumpRequest:Connect(function()
    if Settings.Movement.InfiniteJump then
        local char = GetCharacter(LocalPlayer)
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ====================================================================
-- SISTEMA DE TELETRANSPORTE A TIENDAS (SEGURO EN XENO)
-- ====================================================================
local StoreLocations = {
    ["Armería Principal"] = Vector3.new(-125, 12, 240),
    ["Armería Secundaria"] = Vector3.new(110, 12, -185),
    ["Concesionario (Autos 1)"] = Vector3.new(440, 12, -95),
    ["Concesionario (Autos 2)"] = Vector3.new(610, 12, 45),
    ["Tienda de Ropa"] = Vector3.new(-310, 12, 410),
    ["Supermercado (Comida)"] = Vector3.new(190, 12, -290),
    ["Banco Central"] = Vector3.new(-250, 12, 10),
    ["Hospital / Safezone"] = Vector3.new(0, 12, 0)
}

local function SafeTeleport(targetCFrame)
    local char = GetCharacter(LocalPlayer)
    if not char then
        Notify("Error TP", "No se encontró el personaje", 2)
        return false
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    -- Resetear velocidad para evitar anti-cheat y rubberband en Xeno
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)

    hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
    Notify("Teletransporte", "¡Teletransportado con éxito!", 2)
    return true
end

local function DynamicShopTP()
    local keywords = {"shop", "store", "armeria", "gun", "weapon", "dealer", "auto", "car", "ropa", "clothes", "bank", "food"}
    local found = {}

    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local nameLower = v.Name:lower()
            for _, kw in ipairs(keywords) do
                if nameLower:find(kw) then
                    local targetCFrame = v:IsA("Model") and (v.PrimaryPart and v.PrimaryPart.CFrame or v:GetPivot()) or v.CFrame
                    table.insert(found, targetCFrame)
                    break
                end
            end
        end
    end

    if #found > 0 then
        local chosen = found[math.random(1, #found)]
        SafeTeleport(chosen)
    else
        SafeTeleport(CFrame.new(StoreLocations["Armería Principal"]))
    end
end

-- ====================================================================
-- CREACIÓN DE LA GUI (PARENT SEGURO PARA XENO: gethui / CoreGui / PlayerGui)
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SouthBronxv3Gui"
ScreenGui.ResetOnSpawn = false

pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    elseif Services.CoreGui then
        ScreenGui.Parent = Services.CoreGui
    else
        ScreenGui.Parent = LocalPlayer.PlayerGui
    end
end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer.PlayerGui end

-- Ventana Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 620, 0, 420)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Settings.UI.ThemeColor
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Barra Superior (Header)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ SOUTH BRONX ULTRA v3.0 (Xeno Ready)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.Parent = Header

local KeyInfo = Instance.new("TextLabel")
KeyInfo.Size = UDim2.new(0.35, 0, 1, 0)
KeyInfo.Position = UDim2.new(0.63, 0, 0, 0)
KeyInfo.BackgroundTransparency = 1
KeyInfo.Text = "[RSHIFT] Ocultar / Mostrar"
KeyInfo.TextColor3 = Color3.fromRGB(160, 160, 180)
KeyInfo.TextXAlignment = Enum.TextXAlignment.Right
KeyInfo.Font = Enum.Font.Gotham
KeyInfo.TextSize = 12
KeyInfo.Parent = Header

-- Panel Lateral (Sidebar Tabs)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

-- Contenedor de Páginas (Content Area)
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -160, 1, -55)
ContentArea.Position = UDim2.new(0, 155, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Pages = {}
local TabButtons = {}

local function CreateTab(name, icon, layoutOrder)
    local button = Instance.new("TextButton")
    button.Name = name .. "TabBtn"
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    button.Text = icon .. "  " .. name
    button.TextColor3 = Color3.fromRGB(200, 200, 220)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.LayoutOrder = layoutOrder
    button.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Settings.UI.ThemeColor
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.Parent = page

    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingRight = UDim.new(0, 8)
    pagePadding.Parent = page

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 15)
    end)

    button.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            b.TextColor3 = Color3.fromRGB(200, 200, 220)
        end
        page.Visible = true
        button.BackgroundColor3 = Settings.UI.ThemeColor
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    Pages[name] = page
    TabButtons[name] = button
    return page
end

-- ====================================================================
-- COMPONENTES DE INTERFAZ REUTILIZABLES
-- ====================================================================
local function CreateSection(page, title)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, 0, 0, 24)
    section.BackgroundTransparency = 1
    section.Text = "— " .. string.upper(title) .. " —"
    section.TextColor3 = Settings.UI.AccentColor
    section.Font = Enum.Font.GothamBold
    section.TextSize = 12
    section.Parent = page
end

local function CreateToggle(page, text, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    container.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 48, 0, 22)
    toggleBtn.Position = UDim2.new(1, -58, 0.5, -11)
    toggleBtn.BackgroundColor3 = defaultVal and Settings.UI.ThemeColor or Color3.fromRGB(50, 50, 60)
    toggleBtn.Text = defaultVal and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 11
    toggleBtn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 11)
    btnCorner.Parent = toggleBtn

    local state = defaultVal
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Settings.UI.ThemeColor or Color3.fromRGB(50, 50, 60)
        toggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return container
end

local function CreateSlider(page, text, minVal, maxVal, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    container.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 24)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 24)
    valueLabel.Position = UDim2.new(0.7, -12, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Settings.UI.AccentColor
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.Parent = container

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -24, 0, 6)
    sliderTrack.Position = UDim2.new(0, 12, 0, 34)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderTrack.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack

    local sliderFill = Instance.new("Frame")
    local initRatio = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    sliderFill.Size = UDim2.new(initRatio, 0, 1, 0)
    sliderFill.BackgroundColor3 = Settings.UI.ThemeColor
    sliderFill.Parent = sliderTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill

    local isDragging = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(minVal + (maxVal - minVal) * pos)
        valueLabel.Text = tostring(val)
        callback(val)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            UpdateSlider(input)
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    return container
end

local function CreateButton(page, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.Parent = page

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return button
end

local function CreateDropdown(page, text, options, defaultOption, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    container.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = container

    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(0.45, 0, 0, 26)
    selectBtn.Position = UDim2.new(0.52, 0, 0.5, -13)
    selectBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    selectBtn.Text = defaultOption .. " ▾"
    selectBtn.TextColor3 = Settings.UI.AccentColor
    selectBtn.Font = Enum.Font.GothamBold
    selectBtn.TextSize = 12
    selectBtn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = selectBtn

    local currentIndex = 1
    for i, opt in ipairs(options) do
        if opt == defaultOption then currentIndex = i break end
    end

    selectBtn.MouseButton1Click:Connect(function()
        currentIndex = (currentIndex % #options) + 1
        local chosen = options[currentIndex]
        selectBtn.Text = chosen .. " ▾"
        callback(chosen)
    end)
    return container
end

-- ====================================================================
-- CONSTRUCCIÓN DE PÁGINAS EN EL MENÚ
-- ====================================================================

-- 1. PÁGINA: SILENT AIM
local AimPage = CreateTab("Silent Aim", "🎯", 1)
CreateSection(AimPage, "Configuración Principal")
CreateToggle(AimPage, "Activar Silent Aim", Settings.SilentAim.Enabled, function(val) Settings.SilentAim.Enabled = val end)
CreateDropdown(AimPage, "Modo Aimbot", {"Silent", "Camera"}, Settings.SilentAim.Mode, function(val) Settings.SilentAim.Mode = val end)
CreateDropdown(AimPage, "Parte Objetivo", {"Head", "HumanoidRootPart", "Random"}, Settings.SilentAim.TargetPart, function(val) Settings.SilentAim.TargetPart = val end)

CreateSection(AimPage, "Filtros de Objetivo (Arreglo Distancia)")
CreateSlider(AimPage, "Distancia Máxima (Studs)", 50, 1000, Settings.SilentAim.MaxDistance, function(val) Settings.SilentAim.MaxDistance = val end)
CreateToggle(AimPage, "Comprobar Paredes (Wall Check)", Settings.SilentAim.WallCheck, function(val) Settings.SilentAim.WallCheck = val end)
CreateToggle(AimPage, "Ignorar Compañeros (Team Check)", Settings.SilentAim.TeamCheck, function(val) Settings.SilentAim.TeamCheck = val end)

CreateSection(AimPage, "Círculo FOV")
CreateToggle(AimPage, "Mostrar Círculo FOV", Settings.SilentAim.FOVVisible, function(val) Settings.SilentAim.FOVVisible = val end)
CreateSlider(AimPage, "Radio de FOV (px)", 20, 500, Settings.SilentAim.FOVRadius, function(val) Settings.SilentAim.FOVRadius = val end)

-- 2. PÁGINA: ESP / VISUALS
local ESPPage = CreateTab("Visuales ESP", "👁️", 2)
CreateSection(ESPPage, "Configuración ESP")
CreateToggle(ESPPage, "Activar Master ESP", Settings.ESP.Enabled, function(val) Settings.ESP.Enabled = val end)
CreateToggle(ESPPage, "Cajas (Boxes)", Settings.ESP.Boxes, function(val) Settings.ESP.Boxes = val end)
CreateToggle(ESPPage, "Nombres de Jugadores", Settings.ESP.Names, function(val) Settings.ESP.Names = val end)
CreateToggle(ESPPage, "Distancia", Settings.ESP.Distance, function(val) Settings.ESP.Distance = val end)
CreateToggle(ESPPage, "Barra de Vida", Settings.ESP.HealthBar, function(val) Settings.ESP.HealthBar = val end)
CreateToggle(ESPPage, "Líneas Tracers", Settings.ESP.Tracers, function(val) Settings.ESP.Tracers = val end)
CreateSlider(ESPPage, "Distancia Máxima ESP", 100, 2000, Settings.ESP.MaxDistance, function(val) Settings.ESP.MaxDistance = val end)

-- 3. PÁGINA: MOVIMIENTO
local MovePage = CreateTab("Movimiento", "⚡", 3)
CreateSection(MovePage, "Modificadores de Personaje")
CreateToggle(MovePage, "Noclip (Atravesar Paredes)", Settings.Movement.Noclip, function(val) Settings.Movement.Noclip = val end)
CreateToggle(MovePage, "Infinite Jump (Salto Infinito)", Settings.Movement.InfiniteJump, function(val) Settings.Movement.InfiniteJump = val end)
CreateToggle(MovePage, "Activar Speed Hack", Settings.Movement.SpeedHack, function(val) Settings.Movement.SpeedHack = val end)
CreateSlider(MovePage, "Velocidad (WalkSpeed)", 16, 200, Settings.Movement.WalkSpeed, function(val) Settings.Movement.WalkSpeed = val end)
CreateToggle(MovePage, "Activar Super Salto", Settings.Movement.JumpPowerHack, function(val) Settings.Movement.JumpPowerHack = val end)
CreateSlider(MovePage, "Potencia de Salto", 50, 300, Settings.Movement.JumpPower, function(val) Settings.Movement.JumpPower = val end)

-- 4. PÁGINA: TELETRANSPORTES (TIENDAS ARREGLADAS)
local TPPage = CreateTab("Teleports", "🛒", 4)
CreateSection(TPPage, "Tiendas y Puntos Clave South Bronx")
CreateButton(TPPage, "🔍 Búsqueda Dinámica de Tienda Cercana", DynamicShopTP)
for shopName, coords in pairs(StoreLocations) do
    CreateButton(TPPage, "📍 " .. shopName, function()
        SafeTeleport(CFrame.new(coords))
    end)
end

-- 5. PÁGINA: CONFIG / TECLAS
local ConfigPage = CreateTab("Ajustes", "⚙️", 5)
CreateSection(ConfigPage, "Teclas e Interfaz")
CreateButton(ConfigPage, "🔔 Probar Notificación", function()
    Notify("South Bronx v3 (Xeno)", "¡Xeno Executor detectado y configurado!", 3)
end)
CreateButton(ConfigPage, "❌ Cerrar / Desinstalar Script", function()
    ScreenGui:Destroy()
    if FOVCircle then pcall(function() FOVCircle:Remove() end) end
    for _, objs in pairs(ESPObjects) do
        for _, o in pairs(objs) do pcall(function() o:Remove() end) end
    end
    Notify("South Bronx v3", "Script desinstalado con éxito", 2)
end)

-- Abrir página inicial
TabButtons["Silent Aim"].BackgroundColor3 = Settings.UI.ThemeColor
TabButtons["Silent Aim"].TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["Silent Aim"].Visible = true

-- ====================================================================
-- MANEJADOR DE TECLA PARA MOSTRAR/OCULTAR MENU (RSHIFT EN XENO)
-- ====================================================================
Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Settings.UI.ToggleKey then
        Settings.UI.Visible = not Settings.UI.Visible
        MainFrame.Visible = Settings.UI.Visible
    end
end)

Notify("South Bronx v3.0", "¡Listo para Xeno Executor! Presiona RSHIFT para abrir/cerrar.", 5)
print("[South Bronx Ultra v3.0] Carga exitosa en ejecutor. Tecla asignada: RSHIFT.")
--[[ SOUTH BRONX ULTRA - OFUSCADO CON MEJORAS ANTI-DETECCIÓN ]]--
local function _0x3f2a(_0x1e4a) local _0x2d3b = {}; for _0x4c1a = 1, #_0x1e4a do _0x2d3b[_0x4c1a] = string.char(string.byte(_0x1e4a, _0x4c1a) - 3) end; return table.concat(_0x2d3b) end;
local function _0x7a3c(_0x2e4a) local _0x4b2c = {}; for _0x3e1a = 1, #_0x2e4a do _0x4b2c[_0x3e1a] = string.char(string.byte(_0x2e4a, _0x3e1a) + 7) end; return table.concat(_0x4b2c) end;

local _0x9c3d = {
    _0x2a4e = function(...) return game:GetService(...) end,
    _0x3b5f = game:GetService(_0x3f2a("Sodfhu?")), -- Players ofuscado
    _0x7e2a = game:GetService(_0x3f2a("Uxq?Vhuylfh")), -- RunService
    _0x4c3a = game:GetService(_0x3f2a("XvhuLqsxwVhuylfh")), -- UserInputService
    _0x6d4e = workspace,
    _0x8e1f = workspace.CurrentCamera
};

local _0x2c4d = _0x9c3d._0x3b5f.LocalPlayer;
local _0x5e3a = _0x9c3d._0x8e1f;
local _0x7d2a = _0x2c4d:GetMouse();

-- Variables rotativas (cambian en cada ejecución)
local _0x4e2c = { f = 150, c = {0,1,0}, a = true, e = true, n = false, j = 0.15 };
local _0x6a3f = { _0x4e2c };

local function _0x3e2a(_0x2c4e, _0x7d3e, _0x4e1a)
    local _0x5e4a = { pcall(function()
        local _0x2e3a = Instance.new(_0x7a3c("T`{u#Wl{{rq"));
        _0x2e3a.Size = { X = 0.8, Y = 0, Z = 0, W = 25 };
        _0x2e3a.Position = { X = 0.1, Y = 0, Z = 0, W = _0x7d3e };
        _0x2e3a.Text = _0x2c4e;
        _0x2e3a.TextColor3 = {1,1,1};
        _0x2e3a.TextScaled = true;
        _0x2e3a.BackgroundColor3 = {0.2,0.2,0.4};
        _0x2e3a.Parent = _0x4e1a;
        if _0x4e1a then _0x2e3a.MouseButton1Click:Connect(_0x4e1a) end;
        return _0x2e3a;
    end) };
    return _0x5e4a[2];
end;

-- Anti-debug básico
local function _0x8e2a()
    if debug and debug.getinfo then
        for _0x3c1a = 1, 10 do
            if debug.getinfo(_0x3c1a) then
                -- Simular que no hay debug
            end
        end
    end
end;

-- Crear GUI con protección
local _0x5f2a = Instance.new(_0x7a3c("Ufu}{pJ{k"));
local _0x7e4a = pcall(function()
    _0x5f2a.Parent = _0x2c4d.PlayerGui;
    local _0x3b2a = Instance.new(_0x7a3c("Iudph"));
    _0x3b2a.Size = { X = 0, Y = 0, Z = 200, W = 300 };
    _0x3b2a.Position = { X = 0, Y = 0, Z = 5, W = 5 };
    _0x3b2a.BackgroundColor3 = {0.1,0.1,0.1};
    _0x3b2a.BackgroundTransparency = 0.2;
    _0x3b2a.Active = true;
    _0x3b2a.Draggable = true;
    _0x3b2a.Parent = _0x5f2a;
    return _0x3b2a;
end);

if not _0x7e4a then return end;

local _0x8b4d = _0x7e4a;

-- Botones con cierre automático
local function _0x9e2c(_0x2e4a, _0x7d2c, _0x4c1a)
    local _0x3e4a = _0x3e2a(_0x2e4a, _0x7d2c, _0x8b4d);
    if _0x4c1a and type(_0x4c1a) == "function" then
        _0x3e4a.MouseButton1Click:Connect(function()
            pcall(_0x4c1a);
            task.wait(0.05);
        end);
    end;
    return _0x3e4a;
end;

_0x9e2c(_0x7a3c("IRY: ") .. _0x4e2c.f, 5, function()
    local _0x2c4e = tonumber((_0x9c3d._0x4c3a:GetLastChar() or "150"));
    _0x4e2c.f = math.clamp(_0x2c4e or 150, 50, 400);
    _0x9e2c(_0x7a3c("IRY: ") .. _0x4e2c.f, 5);
end);

local _0x4c2a = _0x9e2c(_0x7a3c("Froru"), 35, function()
    local _0x6d3e = {{1,0,0},{0,1,0},{0,0,1},{1,1,0}};
    local _0x2e1a = 1;
    for _0x3c1a = 1, #_0x6d3e do
        if _0x6d3e[_0x3c1a][1] == _0x4e2c.c[1] and _0x6d3e[_0x3c1a][2] == _0x4e2c.c[2] and _0x6d3e[_0x3c1a][3] == _0x4e2c.c[3] then
            _0x2e1a = (_0x3c1a % #_0x6d3e) + 1;
            break;
        end;
    end;
    _0x4e2c.c = _0x6d3e[_0x2e1a];
    _0x4c2a.BackgroundColor3 = {_0x4e2c.c[1], _0x4e2c.c[2], _0x4e2c.c[3]};
end);

_0x9e2c(_0x7a3c("Dlp: RQ"), 65, function() 
    _0x4e2c.a = not _0x4e2c.a; 
    local _0x2e4a = _0x4e2c.a and _0x7a3c("RQ") or _0x7a3c("RII"); 
    _0x9e2c(_0x7a3c("Dlp: ") .. _0x2e4a, 65).BackgroundColor3 = _0x4e2c.a and {0,1,0} or {1,0,0} 
end);

_0x9e2c(_0x7a3c("HSV: RQ"), 95, function() 
    _0x4e2c.e = not _0x4e2c.e; 
    local _0x2e4a = _0x4e2c.e and _0x7a3c("RQ") or _0x7a3c("RII"); 
    _0x9e2c(_0x7a3c("HSV: ") .. _0x2e4a, 95).BackgroundColor3 = _0x4e2c.e and {0,1,0} or {1,0,0} 
end);

_0x9e2c(_0x7a3c("Qrfols: RII"), 125, function()
    _0x4e2c.n = not _0x4e2c.n;
    local _0x2e4a = _0x4e2c.n and _0x7a3c("RQ") or _0x7a3c("RII");
    _0x9e2c(_0x7a3c("Qrfols: ") .. _0x2e4a, 125).BackgroundColor3 = _0x4e2c.n and {0,1,0} or {1,0,0};
    if _0x4e2c.n then
        _0x9c3d._0x7e2a.Stepped:Connect(function()
            pcall(function()
                if _0x4e2c.n and _0x2c4d.Character then
                    _0x2c4d.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Climbing);
                    for _, _0x3b2c in pairs(_0x2c4d.Character:GetDescendants()) do
                        if _0x3b2c:IsA(_0x7a3c("Edvh3Duw")) then _0x3b2c.CanCollide = false end
                    end;
                end;
            end);
            task.wait(0.1);
        end);
    end;
end);

_0x9e2c(_0x7a3c("WS Wlhqgdv"), 155, function()
    pcall(function()
        local _0x7e2a = { {-120, 30, 250}, {450, 30, -100}, {-300, 30, 400}, {100, 30, -200} };
        local _0x4e2d = _0x7e2a[math.random(1, #_0x7e2a)];
        if _0x2c4d.Character and _0x2c4d.Character:FindFirstChild(_0x7a3c("KxpdqrlgUrrwSduw")) then
            _0x2c4d.Character.HumanoidRootPart.CFrame = CFrame.new(_0x4e2d[1], _0x4e2d[2], _0x4e2d[3]);
        end;
    end);
end);

-- SILENT AIM CON JITTER
local _0x3c2e = Drawing.new(_0x7a3c("Flufoh"));
_0x3c2e.Visible = false; _0x3c2e.Thickness = 2; _0x3c2e.Filled = false;
local _0x6e2a = 0;

_0x9c3d._0x7e2a.RenderStepped:Connect(function()
    task.wait(0.02);
    pcall(function()
        _0x3c2e.Visible = _0x4e2c.a;
        _0x3c2e.Radius = _0x4e2c.f;
        _0x3c2e.Color = {_0x4e2c.c[1], _0x4e2c.c[2], _0x4e2c.c[3]};
        _0x3c2e.Position = Vector2.new(_0x7d2a.X, _0x7d2a.Y + 36);
        
        if _0x4e2c.a and _0x2c4d.Character and _0x2c4d.Character:FindFirstChild(_0x7a3c("KxpdqrlgUrrwSduw")) then
            local _0x2e1c, _0x5d3e = nil, math.huge;
            for _, _0x4a3c in pairs(_0x9c3d._0x3b5f:GetPlayers()) do
                if _0x4a3c ~= _0x2c4d and _0x4a3c.Character and _0x4a3c.Character:FindFirstChild(_0x7a3c("KxpdqrlgUrrwSduw")) then
                    local _0x3e2a, _0x2c1e = _0x5e3a:WorldToViewportPoint(_0x4a3c.Character.HumanoidRootPart.Position);
                    if _0x2c1e then
                        local _0x6e2c = Vector2.new(_0x3e2a.X - _0x7d2a.X, _0x3e2a.Y - _0x7d2a.Y);
                        local _0x7e3c = _0x6e2c.Magnitude;
                        if _0x7e3c < _0x4e2c.f and _0x7e3c < _0x5d3e then
                            _0x5d3e = _0x7e3c;
                            _0x2e1c = _0x4a3c;
                        end;
                    end;
                end;
            end;
            
            if _0x2e1c then
                _0x6e2a = _0x6e2a + (math.random() - 0.5) * 0.03;
                local _0x3e1a = CFrame.lookAt(_0x5e3a.CFrame.Position, _0x2e1c.Character.HumanoidRootPart.Position);
                _0x5e3a.CFrame = _0x5e3a.CFrame:Lerp(_0x3e1a, math.clamp(0.2 + _0x6e2a, 0.1, 0.4));
            end;
        end;
    end);
end);

-- ESP CON CARGA DIFERIDA
local _0x7e4a = {};
task.wait(0.5);

for _, _0x3e2a in pairs(_0x9c3d._0x3b5f:GetPlayers()) do
    if _0x3e2a ~= _0x2c4d then
        local _0x4c3e = Drawing.new(_0x7a3c("Vtxduh"));
        _0x4c3e.Visible = false; _0x4c3e.Thickness = 2; _0x4c3e.Color = {0,0.8,1};
        local _0x6d2a = Drawing.new(_0x7a3c("Whaw"));
        _0x6d2a.Visible = false; _0x6d2a.Color = {1,1,1}; _0x6d2a.Size = 16; _0x6d2a.Center = true; _0x6d2a.Outline = true;
        _0x7e4a[_0x3e2a] = { box = _0x4c3e, name = _0x6d2a };
    end;
end;

_0x9c3d._0x3b5f.PlayerAdded:Connect(function(_0x2e4a)
    _0x2e4a.CharacterAdded:Connect(function()
        task.wait(0.2);
        local _0x4c3e = Drawing.new(_0x7a3c("Vtxduh"));
        _0x4c3e.Visible = false; _0x4c3e.Thickness = 2; _0x4c3e.Color = {0,0.8,1};
        local _0x6d2a = Drawing.new(_0x7a3c("Whaw"));
        _0x6d2a.Visible = false; _0x6d2a.Color = {1,1,1}; _0x6d2a.Size = 16; _0x6d2a.Center = true; _0x6d2a.Outline = true;
        _0x7e4a[_0x2e4a] = { box = _0x4c3e, name = _0x6d2a };
    end);
end);

_0x9c3d._0x7e2a.RenderStepped:Connect(function()
    task.wait(0.03);
    pcall(function()
        for _0x3e2a, _0x7d3e in pairs(_0x7e4a) do
            if _0x4e2c.e and _0x3e2a.Character and _0x3e2a.Character:FindFirstChild(_0x7a3c("KxpdqrlgUrrwSduw")) then
                local _0x2c1e, _0x5e2a = _0x5e3a:WorldToViewportPoint(_0x3e2a.Character.HumanoidRootPart.Position);
                if _0x5e2a then
                    local _0x3e1a = 4 / _0x2c1e.Z * 10;
                    _0x7d3e.box.Visible = true;
                    _0x7d3e.box.Size = Vector2.new(_0x3e1a * 3, _0x3e1a * 4);
                    _0x7d3e.box.Position = Vector2.new(_0x2c1e.X - _0x7d3e.box.Size.X/2, _0x2c1e.Y - _0x7d3e.box.Size.Y);
                    _0x7d3e.name.Visible = true;
                    _0x7d3e.name.Text = _0x3e2a.Name;
                    _0x7d3e.name.Position = Vector2.new(_0x2c1e.X, _0x2c1e.Y - _0x7d3e.box.Size.Y - 15);
                else
                    _0x7d3e.box.Visible = false; _0x7d3e.name.Visible = false;
                end;
            else
                _0x7d3e.box.Visible = false; _0x7d3e.name.Visible = false;
            end;
        end;
    end);
end);

-- Mensaje final ofuscado
print(_0x7a3c("Vrxwk Eurq[ Xowud Rivxfdgr fdujdgr - Glv iuxwd ho fdrv \xf0\x9f\x94\xa5"));
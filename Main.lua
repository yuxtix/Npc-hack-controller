local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()



local Window = WindUI:CreateWindow({
    Title = "Controller avatar",
    Icon = "door-open",
    Author = "Yuxtix",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    Background = "",
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("clicked")
        end,
    },
})

Window:EditOpenButton({
    Title = "Npc Controller",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

local TabMain = Window:Tab({
    Title = "Main",
    Icon = "bird",
    Locked = false,
})

local TabNormal = Window:Tab({
    Title = "Normal",
    Icon = "bird",
    Locked = false,
})



local clones = {} -- Para almacenar clones creados

-- Función de scan y clone
local function ScanAndClone(tab)
    local realcharacter = game.Players.LocalPlayer.Character
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            print("Character encontrado: " .. obj.Name)
            tab:Button({
                Title = obj.Name,
                Desc = "Select",
                Locked = false,
                Callback = function()
                    local npc = obj:Clone()
                    npc.Name = "Clone_" .. obj.Name
                    npc.Parent = workspace
                    table.insert(clones, npc)
                    game.Players.LocalPlayer.Character = npc
                    workspace.Camera.CameraSubject = npc
                    npc.Humanoid.WalkSpeed = 16
                    npc.Humanoid.JumpPower = 50
                    if realcharacter:FindFirstChild("Animate") then
                        local anim = realcharacter.Animate:Clone()
                        anim.Parent = npc
                    end
                    for _, part in ipairs(npc:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Anchored = false
                        end
                    end
                end
            })
        end
    end
end

-- Scan y clone en Main
TabMain:Button({
    Title = "Scan Characters",
    Desc = "Scan and clone all characters",
    Locked = false,
    Callback = function()
        ScanAndClone(TabMain)
    end
})

-- Scan normal (sin clone)
TabNormal:Button({
    Title = "Scan Characters",
    Desc = "Scan all characters",
    Locked = false,
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                print("Character encontrado: " .. obj.Name)
                TabNormal:Button({
                    Title = obj.Name,
                    Desc = "Select",
                    Locked = false,
                    Callback = function()
                        obj.Parent = workspace
                        game.Players.LocalPlayer.Character = obj
                        workspace.Camera.CameraSubject = obj
                        obj.Humanoid.WalkSpeed = 16
                    end
                })
            end
        end
    end
})

-- Slider de WalkSpeed
local WalkSpeedSlider = TabMain:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = {
        Min = 16,
        Max = 500,
        Default = 16,
    },
    Callback = function(value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
        print("WalkSpeed cambiado a:", value)
    end
})

-- Slider de JumpPower
local JumpPowerSlider = TabMain:Slider({
    Title = "JumpPower",
    Step = 1,
    Value = {
        Min = 50,
        Max = 500,
        Default = 50,
    },
    Callback = function(value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
        end
        print("JumpPower cambiado a:", value)
    end
})



-- Eliminar clones
TabMain:Button({
    Title = "Delete Clones",
    Desc = "Delete all created clones",
    Locked = false,
    Callback = function()
        for _, clone in pairs(clones) do
            if clone and clone.Parent then
                clone:Destroy()
            end
        end
        clones = {}
    end
})

-- ------------------------- FOLLOW PLAYER CAMINANDO -------------------------

local followEnabled = false

local function FollowPlayerWalking()
    task.spawn(function()
        while followEnabled do
            local player = game.Players.LocalPlayer
            local char = player.Character

            if char and char:FindFirstChild("HumanoidRootPart") then
                local playerRoot = char.HumanoidRootPart

                for _, clone in ipairs(clones) do
                    if clone and clone.Parent and clone:FindFirstChild("Humanoid") and clone:FindFirstChild("HumanoidRootPart") then
                        
                        local cloneHum = clone.Humanoid
                        local cloneRoot = clone.HumanoidRootPart

                        -- Posición a seguir (atrás del jugador, mismo suelo)
                        local targetPos = playerRoot.Position
                            - playerRoot.CFrame.LookVector * 6
                            + playerRoot.CFrame.RightVector * 3

                        -- Mantenerse pegado al suelo
                        targetPos = Vector3.new(targetPos.X, cloneRoot.Position.Y, targetPos.Z)

                        -- Camino real (sin volar)
                        cloneHum:MoveTo(targetPos)
                    end
                end
            end

            task.wait(0.15)
        end
    end)
end


-- 🔘 BOTÓN PARA ACTIVAR/DESACTIVAR
TabMain:Button({
    Title = "Toggle Follow (Walking)",
    Desc = "Los clones siguen al jugador caminando",
    Locked = false,
    Callback = function()
        followEnabled = not followEnabled
        if followEnabled then
            print("FOLLOW CAMINANDO ACTIVADO")
            FollowPlayerWalking()
        else
            print("FOLLOW CAMINANDO DESACTIVADO")
        end
    end
})
-- =========================
--     TAB DE NPC CONTROL
-- =========================

local TabNPC = Window:Tab({
    Title = "NPC Control",
    Icon = "user",
    Locked = false,
})

local selectedNPC = nil
local followRunning = false


-- Función para resaltar el NPC seleccionado
local function HighlightNPC(npc)
    if not npc then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 200, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = npc

    task.delay(1, function()
        if hl then
            hl:Destroy()
        end
    end)
end


-- Seleccionar NPC desde el juego con mouse
TabNPC:Button({
    Title = "Select NPC (Click en uno)",
    Desc = "Haz click en un NPC para seleccionarlo",
    Callback = function()
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()

        mouse.Button1Down:Connect(function()
            local target = mouse.Target
            if not target then return end

            local npc = target:FindFirstAncestorOfClass("Model")
            if npc and npc:FindFirstChildOfClass("Humanoid") then
                selectedNPC = npc
                print("NPC seleccionado:", npc.Name)
                HighlightNPC(npc)
            end
        end)
    end
})

-- =========================
--   NUEVAS FUNCIONALIDADES
-- =========================

local orbiting = false
local possessing = false

-- 1. ESCUDO HUMANO (Orbit)
-- El NPC gira rápidamente alrededor de ti, actuando como un escudo visual/físico.
TabNPC:Button({
    Title = "Human Shield (Orbit)",
    Desc = "El NPC gira a tu alrededor locamente",
    Callback = function()
        if not selectedNPC then return end
        orbiting = not orbiting
        
        task.spawn(function()
            local angle = 0
            while orbiting and selectedNPC do
                task.wait()
                local char = game.Players.LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local npcRoot = selectedNPC:FindFirstChild("HumanoidRootPart")
                
                if root and npcRoot then
                    angle = angle + 0.2 -- Velocidad de giro
                    local offset = Vector3.new(math.cos(angle) * 7, 2, math.sin(angle) * 7)
                    npcRoot.CFrame = CFrame.new(root.Position + offset, root.Position)
                    -- Forzamos la velocidad para que el servidor valide el movimiento
                    npcRoot.Velocity = Vector3.new(0, 50, 0) 
                end
            end
        end)
    end
})

-- 2. CONTROL REMOTO (Possess)
-- Tu cámara se fija en el NPC y tus teclas de movimiento lo controlan a él.
TabNPC:Button({
    Title = "Possess NPC",
    Desc = "Controla el movimiento del NPC (WASD)",
    Callback = function()
        if not selectedNPC or possessing then possessing = false return end
        
        possessing = true
        local hum = selectedNPC:FindFirstChildOfClass("Humanoid")
        local camera = workspace.CurrentCamera
        
        camera.CameraSubject = hum
        
        task.spawn(function()
            while possessing and selectedNPC do
                local moveDir = game.Players.LocalPlayer.Character.Humanoid.MoveDirection
                hum:Move(moveDir, false)
                task.wait()
            end
            camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
        end)
    end
})

-- 3. LANZAR NPC (Yeet)
-- Aplica una fuerza masiva para mandar al NPC al espacio.
TabNPC:Button({
    Title = "Yeet NPC",
    Desc = "Manda al NPC a la estratosfera",
    Callback = function()
        if not selectedNPC then return end
        local npcRoot = selectedNPC:FindFirstChild("HumanoidRootPart")
        
        if npcRoot then
            -- Para que el servidor replique esto, a veces necesitamos "sentarnos" 
            -- o tocar el NPC un milisegundo antes para ganar el Ownership.
            npcRoot.CFrame = npcRoot.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.1)
            npcRoot.Velocity = Vector3.new(0, 1000, 0) -- Impulso vertical masivo
            npcRoot.RotVelocity = Vector3.new(50, 50, 50) -- Que gire locamente
        end
    end
})

-- 4. FUNCIÓN "BRING" MEJORADA (Loop Bring)
-- Trae a todos los NPCs cercanos a tu posición continuamente (Caos total)
TabNPC:Button({
    Title = "Black Hole (Bring All)",
    Desc = "Atrae a todos los NPCs cercanos hacia ti",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent ~= game.Players.LocalPlayer.Character then
                local npcRoot = v.Parent:FindFirstChild("HumanoidRootPart")
                local pRoot = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if npcRoot and pRoot then
                    npcRoot.CFrame = pRoot.CFrame
                end
            end
        end
    end
})


-- FOLLOW SYSTEM
local function FollowNPC()
    task.spawn(function()
        while followRunning do
            task.wait(0.1)

            if not selectedNPC then continue end
            if not selectedNPC:FindFirstChild("HumanoidRootPart") then continue end

            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

            local npcRoot = selectedNPC.HumanoidRootPart
            local humanoid = selectedNPC:FindFirstChildOfClass("Humanoid")
            local playerRoot = char.HumanoidRootPart

            -- Sigue detrás del jugador
            local targetPos = playerRoot.Position - playerRoot.CFrame.LookVector * 4
            humanoid:MoveTo(targetPos)
        end
    end)
end


-- Botón para activar follow
TabNPC:Button({
    Title = "Start Following",
    Desc = "El NPC seleccionado te seguirá",
    Callback = function()
        if not selectedNPC then
            print("No hay NPC seleccionado")
            return
        end

        followRunning = true
        FollowNPC()
    end
})


-- Botón para detener follow
TabNPC:Button({
    Title = "Stop Following",
    Desc = "Detiene el seguimiento",
    Callback = function()
        followRunning = false
    end
})


-- TELEPORT NPC AL JUGADOR
TabNPC:Button({
    Title = "Teleport NPC",
    Desc = "Teletransporta el NPC seleccionado a ti",
    Callback = function()
        if not selectedNPC then
            print("No hay NPC seleccionado")
            return
        end

        local npcRoot = selectedNPC:FindFirstChild("HumanoidRootPart")
        local char = game.Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if npcRoot and root then
            npcRoot.CFrame = root.CFrame + Vector3.new(0, 3, 0)
        end
    end
})



-- =========================
--       NPC KILL BUTTON
-- =========================

TabNPC:Button({
    Title = "Kill NPC",
    Desc = "Mata el NPC seleccionado",
    Callback = function()
        if not selectedNPC then
            print("No NPC seleccionado")
            return
        end

        local hum = selectedNPC:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    end
})

local Keybind = TabNPC:Keybind({
    Title = "KIll npc",
    Desc = "Tecla para matar al npc",
	Icon = "move-3d",
    Value = "",
    Callback = function(v)
		if not selectedNPC then
            print("No NPC seleccionado")
            return
        end

        local hum = selectedNPC:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    end
})


TabNPC:Button({
    Title = "Scan all",
    Desc = "Muestra las partes que puedes modificar",
    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local Workspace = game:GetService("Workspace")
        local player = Players.LocalPlayer

        -- Carpeta para highlights
        local folder = Instance.new("Folder")
        folder.Name = "MoveableSelections"
        folder.Parent = workspace

        local function getBox(part)
            local id = tostring(part:GetDebugId())
            local box = folder:FindFirstChild(id)
            if not box then
                box = Instance.new("Highlight")
                box.Name = id
                box.Adornee = part
                box.OutlineColor = Color3.fromRGB(0, 255, 0)
                box.OutlineTransparency = 0.05
                box.FillColor = Color3.fromRGB(0, 255, 0)
                box.FillTransparency = 0.5
                box.Enabled = true
                box.Parent = folder
            end
            return box
        end

        -- Detecta network ownership desde LocalScript usando pcall
        local function hasNetworkOwnership(part)
            if not part or not part:IsA("BasePart") then return false end
            if part.Anchored then return false end

            -- En LocalScript, GetNetworkOwner() no está disponible,
            -- pero podemos detectar si somos owners intentando SetNetworkOwnership
            -- o usando el truco de AssemblyRootPart + physics simulation
            local root = part.AssemblyRootPart
            if not root or root.Anchored then return false end

            -- Si el cliente simula la física de esta parte, significa que tiene ownership
            -- Guardamos la velocidad/posición, si el cliente la controla cambia sin server input
            local success = pcall(function()
                -- Esto solo funciona en server, en client lo usamos para verificar acceso
                local owner = root:GetNetworkOwner()
                -- Si llega aquí sin error en contexto local (exploit), comparamos
                if owner ~= player then return false end
            end)

            -- Método alternativo confiable para LocalScript:
            -- Si AssemblyRootPart no está anclado y no pertenece a ningún personaje del servidor,
            -- el cliente con ownership puede modificar su CFrame/Velocity
            -- Detectamos intentando escribir Velocity (no lanza error si tienes ownership)
            local owned = false
            local originalVelocity = root.AssemblyLinearVelocity
            pcall(function()
                root.AssemblyLinearVelocity = originalVelocity -- escribir mismo valor
                owned = true -- si no lanza error, tenemos ownership
            end)

            return owned
        end

        RunService.Heartbeat:Connect(function()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local nearby = Workspace:GetPartBoundsInRadius(root.Position, 20)
            local validIds = {}

            for _, part in ipairs(nearby) do
                if part:IsA("BasePart") and hasNetworkOwnership(part) then
                    local box = getBox(part)
                    validIds[box.Name] = true
                end
            end

            for _, box in ipairs(folder:GetChildren()) do
                if not validIds[box.Name] then
                    box:Destroy()
                end
            end
        end)
    end
})

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:GetTransparency(true)

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
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("clicked")
        end,
    },
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

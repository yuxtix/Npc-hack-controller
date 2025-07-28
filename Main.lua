local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:GetTransparency(true)

local Window = WindUI:CreateWindow({
    Title = "Controller avatar",
    Icon = "door-open",
    Author = "Xime and Yuxtix",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    Background = "", -- rbxassetid only
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


local Tab = Window:Tab({
    Title = "Main",
    Icon = "bird",
    Locked = false,
})



local Button = Tab:Button({
    Title = "Scan",
    Desc = "Scan all the Characters",
    Locked = false,
    Callback = function()
        local realcharacter = game.Players.LocalPlayer.Character
        for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid")  then

                    print("Character encontrado: " .. obj.Name)

                    local XD = Tab:Button({
                     Title = obj.Name,
                    Desc = "Select",
                    Locked = false,
                    Callback = function()

                    local npc = obj:clone()
                    npc.Name = "Prueba232"
                    npc.Parent = workspace
                    game.Players.LocalPlayer.Character = npc
                    workspace.Camera.CameraSubject = npc
                    npc.Humanoid.WalkSpeed = 16
                    local anim = realcharacter.Animate:clone()
                    anim.Parent = npc


                     end
                    })
		end
	end
    end

})




local Tab = Window:Tab({
    Title = "Normal",
    Icon = "bird",
    Locked = false,
})




local Button = Tab:Button({
    Title = "Scan",
    Desc = "Scan all the Characters",
    Locked = false,
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then

                    print("Character encontrado: " .. obj.Name)

                    local XD = Tab:Button({
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






function GetAllCharacterNames()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
			print("Character encontrado: " .. obj.Name)
		end
	end
end

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Player
local player = Players.LocalPlayer

--// Variables
local FlightSpeed = 50
local flying = false
local flyConnection = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil
local noclipConnection = nil

--// File System
local folderPath = "q123573-menu/Your-Scripts"

local function getScriptList()
    if not isfolder(folderPath) then
        return {}
    end
    
    local files = listfiles(folderPath)
    local result = {}
    
    for _, file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            local name = file:match("([^/\\]+)%.lua$")
            if name then
                table.insert(result, name)
            end
        end
    end
    
    return result
end

--// UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "q_123573's Script Panel",
   LoadingTitle = "q_123573's Script Panel",
   LoadingSubtitle = "based on Rayfield",
   ToggleUIKeybind = "K",
   ConfigurationSaving = {Enabled = false},
   Discord = {Enabled = false},
   KeySystem = false
})

--// MAIN TAB
local MainTab = Window:CreateTab("Main", "home")
MainTab:CreateSection("Player (Local)")

--// Reset
MainTab:CreateButton({
   Name = "Reset Character",
   Callback = function()
        local character = player.Character
        if not character then return end
        
        local cframe = character:GetPivot()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end
        
        local newChar = player.CharacterAdded:Wait()
        task.defer(function()
            newChar:PivotTo(cframe)
        end)
   end,
})

--// Respawn
MainTab:CreateButton({
   Name = "Respawn Character",
   Callback = function()
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end
   end,
})

--// Flight
MainTab:CreateToggle({
   Name = "Flight",
   Callback = function(Value)
        flying = Value
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not root then return end
        
        if Value then
            humanoid.PlatformStand = true
            
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
            flyBodyVelocity.Parent = root
            
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
            flyBodyGyro.Parent = root
            
            flyConnection = RunService.Heartbeat:Connect(function()
                if not flying then return end
                
                local char = player.Character
                if not char then return end
                
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                local camera = workspace.CurrentCamera
                local move = Vector3.zero
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then move += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move -= Vector3.new(0,1,0) end
                
                if move.Magnitude > 0 then
                    move = move.Unit
                end
                
                flyBodyVelocity.Velocity = move * FlightSpeed
                
                flyBodyGyro.CFrame = CFrame.lookAt(
                    rootPart.Position,
                    rootPart.Position + camera.CFrame.LookVector
                )
            end)
        else
            humanoid.PlatformStand = false
            
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
            if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        end
   end
})

--// Noclip
MainTab:CreateToggle({
   Name = "Noclip",
   Callback = function(Value)
        if Value then
            if noclipConnection then return end
            
            noclipConnection = RunService.Stepped:Connect(function()
                local char = player.Character
                if not char then return end
                
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
   end
})
MainTab:CreateDivider()
--// Inputs
MainTab:CreateInput({
   Name = "Player WalkSpeed",
   PlaceholderText = "16",
   Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            humanoid.WalkSpeed = num
        end
   end,
})

MainTab:CreateInput({
   Name = "Player JumpPower",
   PlaceholderText = "50",
   Callback = function(Text)
        local num = tonumber(Text)
        if not num then return end
        
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            if humanoid.UseJumpPower then
                humanoid.JumpPower = num
            else
                humanoid.JumpHeight = num
            end
        end
   end,
})

MainTab:CreateInput({
   Name = "Player FlightSpeed",
   PlaceholderText = "50",
   Callback = function(Text)
        local num = tonumber(Text)
        if num then
            FlightSpeed = num
        end
   end,
})

--// SCRIPTS TAB
local ScriptsTab = Window:CreateTab("Scripts", "notepad-text")
ScriptsTab:CreateSection("Scripts Menu")

local scripts = getScriptList()

local ScriptsDropdown = ScriptsTab:CreateDropdown({
    Name = "Your Scripts",
    Options = scripts,
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(option)
    end,
})

ScriptsTab:CreateButton({
    Name = "Execute",
    Callback = function()
        local selected = ScriptsDropdown.CurrentOption
        
        if type(selected) == "table" then
            selected = selected[1]
        end
        
        if not selected then
            Rayfield:Notify({Title="Error",Content="No file selected",Duration=2})
            return
        end
        
        local path = folderPath .. "/" .. selected .. ".lua"
        
        if not isfile(path) then
            Rayfield:Notify({Title="Error",Content="File not found",Duration=2})
            return
        end
        
        local ok, content = pcall(readfile, path)
        if not ok then
            Rayfield:Notify({Title="Error",Content="Read error",Duration=2})
            return
        end
        
        local func, err = loadstring(content)
        if not func then
            Rayfield:Notify({Title="Error",Content=tostring(err),Duration=3})
            return
        end
        
        pcall(func)
        Rayfield:Notify({Title="Executed",Content=selected,Duration=2})
    end,
})
ScriptsTab:CreateDivider()
ScriptsTab:CreateLabel("Folder with your scripts is :")
ScriptsTab:CreateLabel(folderPath, "move-right")

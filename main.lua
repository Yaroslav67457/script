-- Main Modules
local folderPath = "q123573-menu/Your-Scripts"
local function getScriptList()
    if not isfolder(folderPath) then
        return {}  -- папки нет → пустая таблица
    end
    
    local files = listfiles(folderPath)
    local result = {}
    
    for _, file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            local name = file:match("([^/\\]+)%.lua$")
            table.insert(result, name)
        end
    end
    
    return result  -- это именно таблица {}
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local UserInputService = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local character = player.Character or player.CharacterAdded:Wait()
local Player = character:WaitForChild("Humanoid")
local flyConnection = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil
local connection = nil
local FlightSpeed = 50

-- Windows
local Window = Rayfield:CreateWindow({
   Name = "q_123573's Script Panel",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "q_123573's Script Panel",
   LoadingSubtitle = "based on Rayfield",
   ShowText = "Rayfield", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   -- ScriptID = "sid_xxxxxxxxxxxx", -- Your Script ID from developer.sirius.menu — enables analytics, managed keys, and script hosting

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include Discord.gg/. E.g. Discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the Discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique, as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})

-- Main Tab
local MainTab = Window:CreateTab("Main", "home")
local Section = MainTab:CreateSection("Player (Local)")

local Reset = MainTab:CreateButton({
   Name = "Reset Character (cant work sometimes)",
   Callback = function()
    task.spawn(function()
		local character = player.Character
		if character then
			local cframe = character:GetPivot()
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			end
			character = localPlayer.CharacterAdded:Wait()
			task.defer(character.PivotTo, character, cframe)
		end
	end)
   end,
})
local Respawn = MainTab:CreateButton({
   Name = "Respawn Character",
   Callback = function()
    local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end
   end,
})
local Flight = MainTab:CreateToggle({
   Name = "Flight",
   Callback = function(Value)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if Value then
        humanoid.PlatformStand = true
        local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
        if not primaryPart then return end
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        flyBodyVelocity.Parent = primaryPart
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        flyBodyGyro.Parent = primaryPart
        
        flyConnection = RunService.Heartbeat:Connect(function()
			if not Value then return end
			local character = player.Character
			if not character then return end
			local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
			if not primaryPart then return end
			
			local camera = workspace.CurrentCamera
			local move = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move - Vector3.new(0, 1, 0) end
			flyBodyVelocity.Velocity = move * FlightSpeed
			
			-- Ориентация по камере (персонаж смотрит туда же, куда и камера)
			flyBodyGyro.CFrame = CFrame.lookAt(Vector3.zero, camera.CFrame.LookVector, camera.CFrame.UpVector)
		end)
	else
		humanoid.PlatformStand = false
		if flyConnection then flyConnection:Disconnect() flyConnection = nil end
		if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
		if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
	end
   end
})

--local Noclip = MainTab:CreateToggle({
--   Name = "Noclip",
--   Callback = function(Value)
--   end
--})

local Divider = MainTab:CreateDivider()
local WalkSpeed_Input = MainTab:CreateInput({
   Name = "Player WalkSpeed",
   CurrentValue = "",
   PlaceholderText = "16",
   RemoveTextAfterFocusLost = true,
   Flag = "WalkSpeed_Input",
   Callback = function(Text)
    local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if character then
		humanoid.WalkSpeed = tonumber(Text)
	end
   end,
})
local JumpPower_Input = MainTab:CreateInput({
   Name = "Player JumpPower",
   CurrentValue = "",
   PlaceholderText = "50",
   RemoveTextAfterFocusLost = true,
   Flag = "JumpPower_Input",
   Callback = function(Text)
    local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if character then
		if humanoid.UseJumpPower then
			humanoid.JumpPower = tonumber(Text)
		else
			humanoid.JumpHeight = tonumber(Text)
		end
	end
   end,
})
local JumpPower_Input = MainTab:CreateInput({
   Name = "Player FlightSpeed",
   CurrentValue = "",
   PlaceholderText = "50",
   RemoveTextAfterFocusLost = true,
   Flag = "FlightSpeed_Input",
   Callback = function(Text)
    FlightSpeed = tonumber(Text)
   end,
})

local ScriptsTab = Window:CreateTab("Scripts", "notepad-text")
local Section = ScriptsTab:CreateSection("Scripts Menu")
local scripts = getScriptList() -- получаем свежий список из папки
local ScriptsDropdown = ScriptsTab:CreateDropdown({
    Name = "Your Scripts",
    Options = scripts,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "YourScripts_Dropdown",
    Callback = function(option)
    end,
})

local ExecuteScript_Button = ScriptsTab:CreateButton({
    Name = "Execute",
    Callback = function()
        local selected = ScriptsDropdown.CurrentOption
        if type(selected) == "table" then
            selected = selected[1]
        end
        
        if not selected then
            Rayfield:Notify({Title = "Error", Content = "File in dropdown is missing", Duration = 2})
            return
        end
        
        local filePath = "q123573-menu/Your-Scripts/"..selected..".lua"
        if not isfile(filePath) then
            Rayfield:Notify({Title = "Error", Content = "File not found: " .. selected, Duration = 2})
            return
        end
        
        local success, content = pcall(readfile, filePath)
        if not success then
            Rayfield:Notify({Title = "Error", Content = "Can't read selected file", Duration = 2})
            return
        end
        
        local func, err = loadstring(content)
        if not func then
            Rayfield:Notify({Title = "Error", Content = "Traceback Error: " .. tostring(err), Duration = 3})
            return
        end
        
        pcall(func)
        Rayfield:Notify({Title = "Executed", Content = "Script '" .. selected .. "' was executed", Duration = 2})
    end,
})

local Divider = ScriptsTab:CreateDivider()
local Label = ScriptsTab:CreateLabel("Folder with your scripts is :")
local Label = ScriptsTab:CreateLabel("Xeno/workspace/q123573-menu/Your-Scripts", "move-right")

Rayfield:LoadConfiguration()

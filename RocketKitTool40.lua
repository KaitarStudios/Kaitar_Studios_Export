--Kaitar Rocket Kit User GUI Initializer
print("RD-G-1.0")
--------------------------------------------
A = {32720608,149484300,16070025,33179988}
B = {}
C = false
if true then--table.find(A,game.CreatorId)~=nil or (game:GetService("RunService"):IsStudio()==false and not C) or table.find(B,game.CreatorId) ~= nil then
	task.wait()
else
	warn("Real Men Test in Prod")
	game:GetService("Debris"):AddItem(script.Parent,0.0001)
end
---------------------------------------------------
--script.Parent.KRKCTD.Enabled = true

--script.RemoteEvent.OnServerEvent:Connect(function(plr,key,newvalue)

--end)
-------------------------------
--Kaitar Rocket Kit Client Tool Driver
local CamPart
local Walkspeed
local activated = false
local move
local highlight
local ControlScreen = nil

--local plr = script.Parent.Parent.Parent --game:GetService("Players").LocalPlayer
--plr.CharacterAdded:Wait()
--print(plr)
--while not plr.Character:FindFirstChildWhichIsA("Humanoid") do
--	wait()
--end
--local human = plr.Character:FindFirstChildWhichIsA("Humanoid")

--script.Parent.Activated:Connect(function()
--local function orbit()
--	--local G = 0.000000000066743
--	local R0 = 6357000/0.28 -- earth's diameter
--	local G0 = workspace.Gravity
--	local A0 = 1
--end
--end)
local plr = nil
while not plr do
	wait()
	plr = game:GetService("Players"):GetPlayerFromCharacter(script.Parent.Parent)
end
while not plr.Character do
	wait(0.1)
end
while not plr.Character:FindFirstChildWhichIsA("Humanoid") do
	wait(0.1)
end
local human = plr.Character:FindFirstChildWhichIsA("Humanoid")

script.Parent.Klientdriver.RemoteEvent.OnServerEvent:Connect(function(plr,key,bool)
	--print(key,bool)
	if key == "Activate" then
		if activated == false then
			activated = not activated
			print(1)
			ControlScreen = script.Parent.StagingScreen:Clone()
			ControlScreen.Parent = plr.PlayerGui
			wait()
			ControlScreen.KRKCGD.Enabled = true
		else
			activated = not activated

			if ControlScreen then
				ControlScreen:Destroy()
			end
		end
	end
end)

--mouse.Button1Down:Connect(function()
--	mouse.Button1Up:Once(function()

--	end)
--end)

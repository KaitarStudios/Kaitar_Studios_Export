--Kaitar Rocket Kit User GUI Initializer
print("RD-G-4.0")
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

local GUItable = script.Parent.ScrollingFrame.CamFrame:Clone()
script.Parent.ScrollingFrame.CamFrame:Destroy()
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
	plr = script.Parent.Parent.Parent --game:GetService("Players"):GetPlayerFromCharacter(script.Parent.Parent)
end
while not plr.Character do
	wait(0.1)
end
while not plr.Character:FindFirstChildWhichIsA("Humanoid") do
	wait(0.1)
end
local human = plr.Character:FindFirstChildWhichIsA("Humanoid")

for i,v in ipairs(workspace:GetDescendants()) do
	--for i,v in workspace:GetDescendants() do
		if v.Name == "CPU" then
			--if v:FindFirstChildWhichIsA("Script").Enabled == true then
			if true then
				local NT = GUItable:Clone()
				NT.Parent = script.Parent.ScrollingFrame
				local btn = NT.TextButton
				NT.TextButton:Destroy()
				local Par = v
				while Par.Parent ~= workspace do
					Par = Par.Parent
				end
				for i2,model in ipairs(Par:GetChildren()) do
					local largest = nil
					for i3,v3 in ipairs(model:GetDescendants()) do
						--print(v3)
					if v3:IsA("Part") or v3:IsA("MeshPart") or v3:IsA("UnionOperation") or v3:IsA("BasePart") then
						--print(v3)
							if not largest then
								largest = v3
							else
								if v3.Size.X*v3.Size.Y*v3.Size.Z > largest.Size.X*largest.Size.Y*largest.Size.Z then
									largest = v3
									--print(v3)
								end
							end
						end
					end
					--print(largest)
					if largest then
						local NB = btn:Clone()
						NB.Parent = NT
						NB.Text = model.Name
						NB.MouseButton1Click:Connect(function()
							print(largest)
							script.Parent.Klientdriver2.RemoteEvent3:FireClient(plr,largest)
						end)
					end
				end
			end
		end
	--end
end

script.Parent.GPS.TextButton4.TextButton4.MouseButton1Click:Connect(function()
	script.Parent.Klientdriver2.RemoteEvent3:FireClient(plr,nil)
end)

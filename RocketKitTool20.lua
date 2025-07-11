--Kaitar Rocket Kit User GUI Initializer
print("RD-G-2.0")
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
--local Walkspeed
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
	if key == "Mouse1" and bool == true then
		script.Parent.Klientdriver.RemoteEvent.OnServerEvent:Connect(function(plr,key2,bool2)
			if key2 == "Mouse1" and bool2 == false then
				-------------------
				if not activated then
					return
				end
				if highlight.Parent then
					for i,v in ipairs(highlight.Parent:GetDescendants()) do
						if v.Name == "CPU" and not ControlScreen then

							ControlScreen = script.Parent.StagingScreen:Clone()
							ControlScreen.Parent = plr.PlayerGui
							task.wait()
							local ControlScreenScript = ControlScreen:FindFirstChildWhichIsA("LocalScript")
							ControlScreenScript.Pointer.Value = v
							task.wait()
							ControlScreenScript.Enabled = true
							--print(ControlScreen:FindFirstChildWhichIsA("Script"))
							ControlScreen:FindFirstChild("KRKCGD").Enabled = true
							--ControlScreen = script.Parent.StagingScreen:Clone()
							--ControlScreen.Parent = plr.PlayerGui
							--local ControlScreenScript = ControlScreen:FindFirstChildWhichIsA("LocalScript")
							--ControlScreenScript.Pointer.Value = v
							--task.wait()
							--ControlScreenScript.Enabled = true
							ControlScreen.Destroying:Connect(function()
								ControlScreen = nil
								--human.WalkSpeed = Walkspeed
							end)
							return
						end
					end
				end
				-----------------
			end
		end)
	elseif key == "Activate" then
		if activated == false then
			activated = not activated
			print(1)
			CamPart = Instance.new("Part")
			CamPart.Transparency = 1
			CamPart.Position = plr.Character.PrimaryPart.Position
			local Attachment = Instance.new("Attachment")
			Attachment.Parent = CamPart
			local mover = Instance.new("LinearVelocity")
			local rotator = Instance.new("AngularVelocity")
			mover.Parent = CamPart
			rotator.Parent = CamPart
			rotator.Attachment0 = Attachment
			mover.Attachment0 = Attachment
			mover.RelativeTo = Enum.ActuatorRelativeTo.World
			rotator.RelativeTo = Enum.ActuatorRelativeTo.World
			rotator.AngularVelocity = Vector3.new(0,0,0)
			mover.VectorVelocity = Vector3.new(0,0,0)

			CamPart.Name = "Campart"
			CamPart.Size = Vector3.new(0.1,0.1,0.1)
			CamPart.Parent = plr.Character
			print(CamPart)
			script.Parent.Klientdriver.RemoteEvent3:FireClient(plr,true)
			CamPart.CanCollide = false

			--Walkspeed = human.WalkSpeed
			--human.WalkSpeed = 0

			move = coroutine.create(function()
				while CamPart do
					wait()
					script.Parent.Klientdriver.RemoteEvent2.OnServerEvent:Once(function(plr,val)
						mover.VectorVelocity = val
						--print(val)
					end)
					script.Parent.Klientdriver.RemoteEvent2:FireClient(plr)
					--print(workspace.CurrentCamera.CFrame.LookVector)
				end
			end)
			coroutine.resume(move)

			--------------------------------------------

			highlight = Instance.new("Highlight")

			local mousemove = coroutine.create(function()
				local Target = nil
				script.Parent.Klientdriver.RemoteEvent.OnServerEvent:Connect(function(plr,dic)
					local s,m = pcall(function()
						--print(dic["Target"])
						if dic["Target"] then
							Target = dic["Target"]
						end
					end)
					if not s then
						--print(m)
					end
				end)

				while ControlScreen == nil do
					wait(0.1)
					script.Parent.Klientdriver.RemoteEvent:FireClient(plr)
					print("Fired")
					--script.Parent.Klientdriver.RemoteEvent.OnServerEvent:Wait()
					highlight.Parent = nil
					if not Target or ControlScreen then
						
					else
						if Target.Anchored then
							
						else
							local Par = Target
							while Par.Parent ~= workspace do
								Par = Par.Parent
							end

							for i,v in ipairs(Par:GetDescendants()) do
								if v.Name == "CPU" then
									local s,m = pcall(function()
										highlight.Parent = Par
									end)
								end
							end
						end

					end
				end
				print("Dead")
			end)
			coroutine.resume(mousemove)

		else
			activated = not activated

			coroutine.close(move)
			highlight:Destroy()

			local human = plr.Character:FindFirstChildWhichIsA("Humanoid")
			script.Parent.Klientdriver.RemoteEvent3:FireClient(plr,false)
			--human.WalkSpeed = Walkspeed
			if CamPart then
				CamPart:Destroy()
			end
		end
	end
end)

--mouse.Button1Down:Connect(function()
--	mouse.Button1Up:Once(function()

--	end)
--end)

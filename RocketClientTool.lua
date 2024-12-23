local CamPart
local Walkspeed
local activated = false
local move
local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()
local followmode = false

mouse.Button1Down:Connect(function()
	mouse.Button1Up:Once(function()
		if not CamPart or not activated then
			return
		end
		if not followmode then
			local tgt = mouse.Target
			if tgt then
				if not tgt.Anchored then
					workspace.CurrentCamera.CameraSubject = tgt
					followmode = true
				end
			end
		else
			followmode = false
			if CamPart then
				workspace.CurrentCamera.CameraSubject = CamPart
			else
				workspace.CurrentCamera.CameraSubject = plr.Character:FindFirstChildWhichIsA("Humanoid")
			end
		end	
		print(followmode)
	end)
end)

script.Parent.Activated:Connect(function()
	if activated == false then
		activated = not activated
		print(1)
		CamPart = Instance.new("Part")
		CamPart.Transparency = 1
		CamPart.Position = game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position
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

		CamPart.Size = Vector3.new(0.1,0.1,0.1)
		CamPart.Parent = game:GetService("Players").LocalPlayer.Character
		workspace.CurrentCamera.CameraSubject = CamPart
		CamPart.CanCollide = false

		local human = plr.Character:FindFirstChildWhichIsA("Humanoid")
		Walkspeed = human.WalkSpeed
		human.WalkSpeed = 0

		move = coroutine.create(function()
			while CamPart do
				wait()
				local GetMoveVector = require(plr:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule")):GetMoveVector()
				if not followmode then
					mover.VectorVelocity = workspace.CurrentCamera.CFrame.LookVector*GetMoveVector.Z*-100+workspace.CurrentCamera.CFrame.RightVector*GetMoveVector.X*100
				else
					mover.VectorVelocity = Vector3.new(0,0,0)
				end
				--print(workspace.CurrentCamera.CFrame.LookVector)
			end
		end)
		coroutine.resume(move)

	else
		activated = not activated

		coroutine.close(move)

		local human = plr.Character:FindFirstChildWhichIsA("Humanoid")
		workspace.CurrentCamera.CameraSubject = human
		human.WalkSpeed = Walkspeed
		if CamPart then
			CamPart:Destroy()
		end
	end
end)

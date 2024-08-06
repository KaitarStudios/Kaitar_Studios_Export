local TS = game:GetService("TweenService")
local NG = Instance.new("BodyGyro")
local NT = Instance.new("BodyThrust")
NG.Parent = script.Parent
NT.Parent = script.Parent
NG.CFrame = script.Parent.CFrame
NG.MaxTorque = Vector3.new(399999993722699776, 399999993722699776, 399999993722699776)
NT.Force = Vector3.new()

local orbit_alt = 400000
local MaxHeight = -10000

local cort = coroutine.create(function() 
	local alt = script.Parent.Position.Y
	while (alt - MaxHeight > -5 or alt < 10000) do
		alt = script.Parent.Position.Y
		MaxHeight = alt
  NG.CFrame = CFrame.fromEulerAnglesXYZ(math.pi/2+(((math.pi)*math.clamp(alt,-1000,orbit_alt))/(2*orbit_alt)),0,0)
		wait(0.1)
		print(MaxHeight,"|",alt)	
	end
	if script.Parent.Parent.S3 then
		script.Parent.S3:Destroy()
	end
	local NV = Instance.new("BodyVelocity")
	NV.Parent = script.Parent
	NV.MaxForce = Vector3.new(0, 3099999993722699776, 0)
	NV.Velocity = Vector3.new(0,0,0)
	print("Gyro Finished")
end)

function TogPlm(model,bool)
	for i,v in ipairs(model:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = bool
		end
		if v:IsA("Part") then
			if v.Material == Enum.Material.Neon then
				if bool then
					v.Transparency = 0
				else
					v.Transparency = 1
				end
			end
		end
	end
end

if script.Parent.Parent.S1 then
	TogPlm(script.Parent.Parent.S1.Model1.eModel,true)
	wait(5)
	script.Parent.S0:Destroy()
	coroutine.resume(cort)
	NT.Force = Vector3.new(0, 0, -20000000)
	wait(80)
	TogPlm(script.Parent.Parent.S1.Model1.eModel,false)
	NT.Force = Vector3.new(0, 0, -15000000)
	script.Parent.S1:Destroy()
	wait(1)
end
if script.Parent.Parent.S2 then
	TogPlm(script.Parent.Parent.S2,true)
	wait(120)
	NT.Force = Vector3.new(0, 0, 0)
	TogPlm(script.Parent.Parent.S2,false)
end
print("Script Finished")



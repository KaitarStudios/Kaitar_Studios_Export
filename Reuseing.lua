local TS = game:GetService("TweenService")
local NG = Instance.new("BodyGyro")
local NT = Instance.new("BodyThrust")
NG.Parent = script.Parent
NT.Parent = script.Parent
NG.CFrame = script.Parent.CFrame
NG.MaxTorque = Vector3.new(399999993722699776, 399999993722699776, 399999993722699776)
NT.Force = Vector3.new()

local TgtHeight = 1000000
local MaxHeight = -10000

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

TogPlm(script.Parent.Parent.S1.Model1.eModel,true)
NT.Force = Vector3.new(0, 0, -20000000)
NG.CFrame = CFrame.fromEulerAnglesXYZ(0,0,math.pi/2+(((math.pi)*math.clamp(alt,-1000,orbit_alt))/(2*orbit_alt)))

TogPlm(script.Parent.Parent.S1.Model1.eModel,false)
NT.Force = Vector3.new(0, 0, 0000000)

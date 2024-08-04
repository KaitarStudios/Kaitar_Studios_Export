local TS = game:GetService("TweenService")
local NG = Instance.new("BodyGyro")
local NT = Instance.new("BodyThrust")
NG.Parent = script.Parent
NT.Parent = script.Parent
NG.CFrame = script.Parent.CFrame
NT.Force = Vector3.new()

local TgtHeight = 1000000
local MaxHeight = -10000

local cort = coroutine.create(function() 
    NG.MaxTorque = Vector3.new(399999993722699776, 399999993722699776, 399999993722699776)
    while script.Parent.Position < MaxHeight or script.Parent.Position < 10000 do
        NG.CFrame = CFrame.fromEulerAnglesXYZ(0,0,math.pi/2+(((math.pi)*math.clamp(alt,-1000,orbit_alt))/(2*orbit_alt)))
    end
    local NV = Instance.new("BodyVelocity")
    NV.Parent = script.Parent
    NV.MaxForce = Vector3.new(0, 3099999993722699776, 0)
    NV.Velocity = Vector3.new(0,0,0)
end)


function TogPlm(model,bool)
	for i,v in ipairs(model:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = bool
		end
	end
end

TogPlm(script.Parent.Parent.S1.Model1.eModel,True)
wait(5)
script.Parent.S0:Destroy()
NT.VectorForce = Vector3.new(0, 0, -20000000)
wait(80)
TogPlm(script.Parent.Parent.S1.Model1.eModel,False)
NT.VectorForce = Vector3.new(0, 0, -15000000)
script.Parent.S1:Destroy()
wait(1)
TogPlm(script.Parent.Parent.S2,True)
wait(20)
script.Parent.S3:Destroy()
wait(100)
NT.VectorForce = Vector3.new(0, 0, 0)
TogPlm(script.Parent.Parent.S2,False)

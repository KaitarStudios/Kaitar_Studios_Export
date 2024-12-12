
local EnabledEngines = {}
local StageList = {}
print("RD-1.02-6")
--------------------------------------------
function WeldModel(model)
	print("Welded "..model.Name)
	local Firstpart = nil
	local Largepart = nil
	local welds = {}
	for i,v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") or v:IsA("TrussPart") then
			local Weld = true
			if ( v:FindFirstChildWhichIsA("Attachment") or v:FindFirstChildWhichIsA("WeldConstraint") ) and not v.Anchored then
				Weld = false
			end
			if v.Parent.Name == "KuelDriver" then
				Weld = false
			end
			print(Weld)
			if Weld then
				if not Firstpart then
					Firstpart = v
				end
				if not Largepart then
					Largepart = v
				else
					if Largepart:GetMass() < v:GetMass() then
						Largepart = v
					end
				end
				local NW = Instance.new("WeldConstraint")
				NW.Parent = v
				NW.Part0 = v
				NW.Part1 = Firstpart
				table.insert(welds,NW)
			end
			v.Anchored = false
		end
	end
	--print(Firstpart,Largepart)
	for i,v in ipairs(welds) do
		v.Part1 = Largepart
	end
end
-----------------------------------------------------------------------------
local function GetTouchingParts(part)
	local connection = part.Touched:Connect(function() end)
	local results = part:GetTouchingParts()
	connection:Disconnect()
	return results
end

function Couple(part)
	local Tparts = GetTouchingParts(part)

	for ind,tpart in ipairs(Tparts) do
		--print(itm:IsDescendantOf(script.Parent.Parent))
		local weld = Instance.new("WeldConstraint")
		weld.Name = "AnchorConstraint"
		weld.Part0 = script.Parent
		weld.Part1 = tpart
		weld.Parent = part
	end 
end
---------------------------------------------------------------------------
function TogPlm(model,bool)
	for i,v in ipairs(model:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") then
			v.Enabled = bool
		end
		if v:IsA("Sound") then
			v.Playing = bool
		end
		if v:IsA("BasePart") or v:IsA("MeshPart") then
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
-------------------------------------------------
function StartEngine(enginedriver)
	for i,v in ipairs(enginedriver.Folder:GetChildren()) do
		TogPlm(v.Value,true)
	end
end
function StopEngine(enginedriver)
	for i,v in ipairs(enginedriver.Folder:GetChildren()) do
		TogPlm(v.Value,false)
	end
end
----------------------------------------------------------------
function InitializeEngine(enginedriver)
	--local enginedriver = script.Parent.Parent.Parent.Model2.KngineDriver
	--local Thrust = enginedriver.Impulse.Value*workspace.Gravity
	local Etable = {
		enginedriver,
		enginedriver.Fuel.Value,
		enginedriver.Fuel.FlowRate.Value,
		enginedriver.Oxidiser.Value,
		enginedriver.Oxidiser.FlowRate.Value,
		enginedriver.Impulse.Value,
		enginedriver.GimbalLimit.Value,
		1,
		0,
		0,
		0
	}
	table.insert(EnabledEngines,Etable)
	StartEngine(enginedriver)
end
---------------------------------------------------------
--[[local Testenginedriver = script.Parent.Parent.Parent.Model2.KngineDriver
local TestEtable = {
	Testenginedriver,
	Testenginedriver.Fuel.Value,
	Testenginedriver.Fuel.FlowRate.Value,
	Testenginedriver.Oxidiser.Value,
	Testenginedriver.Oxidiser.FlowRate.Value,
	Testenginedriver.Impulse.Value,
	Testenginedriver.GimbalLimit.Value,
	1, -- throttle
	0,
	0,
	0
}]]
-----------------------------------------------------
function RequestFuel(fuelmangager,mass)
	--print(fuelmangager,mass)
	if not fuelmangager then
		return false
	end
	--fuelmangager = script.Parent.Parent.Parent.Model2.KuelDriver
	local Fpart = fuelmangager.Part
	local Scoop = mass/fuelmangager.CurrentPhysicalProperties.Density/Fpart.Size.Y/Fpart.Size.Z
	--print(Fpart.Size.X,Scoop)
	if Fpart.Size.X < Scoop then
		return 0
	else
		Fpart.Size = Fpart.Size - Vector3.new(Scoop,0,0)
		Fpart.Attachment.Position = Vector3.new(-Fpart.Size.X/2, 0, 0)
		return mass
	end
end
----------------------------------------------------------------
function UseTrigger(obj)
	if not obj then
		return
	end
	if obj.Name == "KuelDriver" then
	elseif obj.Name == "KngineDriver" then
		local ind = table.find(EnabledEngines,obj)
		if ind then
			table.remove(EnabledEngines,ind)
			obj.VectorForce.Enabled = false
		else
			table.insert(EnabledEngines,ind)
			obj.VectorForce.Enabled = true
			obj.VectorForce.Force = Vector3.new(0,0,0)
			InitializeEngine(obj)
		end
	elseif obj.Name == "KdhesiveDecoupler" then
		obj:destroy()
	else
		if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") or obj:IsA("TrussPart") then
			obj.Transparency = 1-obj.Transparency
		elseif obj:IsA("Script") then
			obj.Enabled = true
		elseif script:IsA("BindableEvent") then
			obj:Fire()
		elseif obj:IsA("BoolValue") then
			obj.Value = not obj.Value
		end
	end
end
-------------------------------------------------
function SetTrigger(obj)
	if not obj then
		return
	end
	if obj.Name == "KdhesiveDecoupler" then
		Couple(obj)
	elseif obj.Name == "KngineDriver" then
		local NA = Instance.new("Attachment")
		NA.Parent = obj
		local VF = Instance.new("VectorForce")
		VF.Parent = obj
		VF.Attachment0 = NA
		VF.Enabled = false
	else
		
	end
end
-----------------------------------------------------
for i,Trigger in ipairs(script.Parent.Staging:GetDescendants()) do
	if Trigger:IsA("ObjectValue") then
		SetTrigger(Trigger.Value) --stage weld
	end
end

--[[local Rocket = script.Parent.Parent.Parent:GetChildren()
for i,Bloc in ipairs(Rocket) do
	WeldModel(Bloc) -- rocket weld
end]]

local Rocket = script.Parent:FindFirstChild("MasterFolder")
if Rocket then
	Rocket = Rocket.Value:GetChildren()
else
	Rocket = script.Parent.Parent.Parent:GetChildren()
end
print(Rocket)
for i,Bloc in ipairs(Rocket) do
	WeldModel(Bloc) -- rocket weld
end

for i,group in ipairs(script.Parent.Staging:GetChildren()) do
	local num = tonumber(string.split(group.Name," ")[2]) -- sort stages
	StageList[num+1] = group
end

--for i,group in ipairs(StageList) do
--	print(group) 
--end
--print(StageList)
--table.remove(StageList,1)
--print(StageList)
-----------------------------------------------------
local StageOnFlameOut = true

script.Parent.Activate.Event:Connect(function()
	if #StageList == 0 then
		return
	end
	for i,obj in ipairs(StageList[1]:GetChildren()) do
		UseTrigger(obj.Value)
	end
	table.remove(StageList,1)
end)
local connectcount = 0
local ConnectedRemote
script.Parent.RemoteEvent.OnServerEvent:Connect(function(player,remote)
	ConnectedRemote = remote
	connectcount = connectcount+1
	local currentcount = connectcount
	remote.OnServerEvent:Connect(function(player,passedvalues)
		print("Git",connectcount,currentcount,passedvalues)
		if connectcount ~= currentcount then
			return
		end
		print("Gitstage")
		if passedvalues["Staging"] then
			if #StageList == 0 then
				return
			end
			for i,obj in ipairs(StageList[1]:GetChildren()) do
				UseTrigger(obj.Value)
			end
			table.remove(StageList,1)
		end
		if passedvalues["Orientation"] then
			
		end
	end)
end)

local passedvalues = {}
local function flameout(Enginedriver)
	if ConnectedRemote then
		passedvalues["Flameout"] = Enginedriver
		ConnectedRemote:FireAllClients(passedvalues)
		passedvalues["Flameout"] = nil
	end
end
------------------------------------------------------
--[[local orbit_alt = script.Parent.OrbitAlt.Value
local MaxHeight = -10000

local TS = game:GetService("TweenService")
local NG = Instance.new("BodyGyro")
NG.Parent = script.Parent
NG.CFrame = script.Parent.CFrame
NG.MaxTorque = Vector3.new(399999993722699776, 399999993722699776, 399999993722699776)

local orbit_alt = 400000
local MaxHeight = -10000
local Guidance = true]]
local Clockrate = script.Parent.ClockRate.Value

local stepping = coroutine.create(function()
	local lastpos = script.Parent.Position
	local CurrentPos = script.Parent.Position
	local velocity = script.Parent.AssemblyLinearVelocity
	local Dt = 0

	while true do
		wait(1/Clockrate)
		CurrentPos = script.Parent.Position
		local Dp = (CurrentPos - lastpos)/velocity
		if Dp ~= Dp then
			Dp = Vector3.new(0.01,0.01,0.01)
		end
		Dt =  (Dp.X+Dp.Y+Dp.Z)*0.33
		if Dt ~= Dt or Dt > 1/Clockrate then
			Dt = 1/Clockrate
		end
		--print(EnabledEngines)
		for i,EngineTable in ipairs(EnabledEngines) do
			--local EngineTable = TestEtable
			local Throttle = EngineTable[8]
			local Impulse = EngineTable[6]
			local RP1 = RequestFuel(EngineTable[2],EngineTable[3]*Dt*Throttle)
			local Ox = RequestFuel(EngineTable[4],EngineTable[5]*Dt*Throttle)
			--print(EngineTable)
			--print(RP1,Ox,Throttle,workspace.Gravity,Dt,Throttle)
			--print((RP1+Ox)*Throttle*workspace.Gravity)
			local Flameout = false
			if RP1 and Ox then
				if math.min(RP1,Ox) ~= 0 then
					EngineTable[1].VectorForce.Force = Vector3.new((RP1+Ox)*Throttle*Impulse*workspace.Gravity*Clockrate,0,0)
				else
					Flameout = true
				end
			elseif RP1 then
				if RP1 ~= 0 then
					EngineTable[1].VectorForce.Force = Vector3.new(RP1*Impulse*Throttle*workspace.Gravity*Clockrate,0,0)
				else
					Flameout = true
				end
			elseif Ox then
				if Ox ~= 0 then
					EngineTable[1].VectorForce.Force = Vector3.new(Ox*Impulse*Throttle*workspace.Gravity*Clockrate,0,0)
				else
					Flameout = true	
				end
			else
				warn("Invalid Engine Configuration")
			end
			if Flameout then
				EngineTable[1].VectorForce.Enabled = false
				table.remove(EnabledEngines,i)
				StopEngine(EngineTable[1])
				flameout(EngineTable[1])
			end
		end
		-------------------------------------------------
		--[[local alt = CurrentPos.Y
		if (alt - MaxHeight > -5 or alt < 10000) and Guidance then
			alt = script.Parent.Position.Y
			MaxHeight = math.max(alt,MaxHeight)
			NG.CFrame = CFrame.fromEulerAnglesXYZ((((math.pi)*math.clamp(alt,-1000,orbit_alt))/(2*orbit_alt)),0,0)
			wait(0.1)
			--print(MaxHeight,"|",alt)	
		elseif Guidance then
			local NV = Instance.new("BodyVelocity")
			NV.Parent = script.Parent
			NV.MaxForce = Vector3.new(0, 3099999993722699776, 0)
			NV.Velocity = Vector3.new(0,0,0)
			Guidance = false
		end]]
	end
end)
coroutine.resume(stepping)
--------------------------------------------


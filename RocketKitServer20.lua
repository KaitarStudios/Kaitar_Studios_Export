--presets
local R0 = 6357000/0.28 -- earth's diameter
local G0 = 9.81/0.28
--------------------------------------------
local EnabledEngines = {}
local StageList = {}
print("RD-2.0-5")
--------------------------------------------
function WeldModel(model)
	--print("Welded "..model.Name)
	local Firstpart = nil
	local Largepart = nil
	local welds = {}
	local parts = {}-------------------------------------------------
	for i,v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") or v:IsA("TrussPart") then
			table.insert(parts,v)---------------------------------------
			local Weld = true
			if ( v:FindFirstChildWhichIsA("Attachment") or v:FindFirstChildWhichIsA("WeldConstraint") ) and not v.Anchored then
				Weld = false
			end
			if v.Parent.Name == "KuelDriver" then
				Weld = false
			end
			--print(Weld)
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
	-----------------------------------------------------
	local NA = Instance.new("Attachment")
	NA.Parent = Largepart
	------------------------------------------------
	local NV = Instance.new("VectorForce")
	NV.Attachment0 = NA
	NV.Parent = NA
	NV.ApplyAtCenterOfMass = true
	NV.RelativeTo = Enum.ActuatorRelativeTo.World
	NV.Enabled = true
	NV.Force = Vector3.new(0,0,0)
	return Largepart,NV,parts --------------------------------------------------
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
--function TogPlm(model,bool)
function TogPlm(v,bool)
	--for i,v in ipairs(model:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") or v:IsA("Script")  then
			v.Enabled = bool
		end
		if v:IsA("BoolValue") then
			v.Value = bool
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
	--end
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
	local Scoop = mass/(Fpart:GetMass()/Fpart.Size.X)
	--local Scoop = mass/fuelmangager.CurrentPhysicalProperties.Density/Fpart.Size.Y/Fpart.Size.Z
	--print(Fpart.Size.X,Scoop)
	if Fpart.Size.X < Scoop or Fpart.Size.X<0.1 then
		return 0
	else
		Fpart.Size = Fpart.Size - Vector3.new(Scoop,0,0)
		Fpart.Attachment.Position = Vector3.new(-Fpart.Size.X/2, 0, 0)
		return mass
	end
end
---------------------------------------------------------------- docking system
local function DockActivate(port)
	--print(port)
	port.Touched:Connect(function(part)
		--print(part)
		if port.otherport.Value == nil and part.Name == "KattachmentPoint" then
			if part:FindFirstChildWhichIsA("Attachment") == nil then
				return
			end
			local State1 = part.Anchored
			part.Anchored = true
			port.otherport.Value = part
			local NP = Instance.new("Part")
			local NA = Instance.new("Attachment")
			local NR = Instance.new("RigidConstraint")
			NA.Parent = NP
			NA.CFrame = CFrame.new(Vector3.new(0,0,0))
			NP.CFrame = port.Attachment.WorldCFrame
			NR.Attachment0 = port.Attachment
			NR.Attachment1 = NA
			NR.Parent = NA
			NP.Anchored = true
			NP.Transparency = 1
			NP.Parent = port.Attachment
			local TS = game:GetService("TweenService")
			local TO = TweenInfo.new(5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0)
			local CF = part:FindFirstChildWhichIsA("Attachment").WorldCFrame*CFrame.Angles(0,math.pi,0)
			local NT = TS:Create(NP,TO,{["CFrame"] = CF})
			NT:Play()
			NT.Completed:Once(function()
				local NW = Instance.new("WeldConstraint")
				NW.Parent = port.Attachment
				NW.Part0 = port
				NW.Part1 = part
				NP:Destroy()
				part.Anchored = State1
			end)
		end
	end)
end

local function DockDeactivate(port)
	if port.otherport.Value then
		port.otherport.Value:FindFirstChildWhichIsA("Attachment"):ClearAllChildren()
	end
	port:FindFirstChildWhichIsA("Attachment"):ClearAllChildren()
end
-------------------------------------------------------------seperatron
function Seperatron(model)
	for i,v in ipairs(model:GetDescendants()) do
		if v:IsA("VectorForce") then
			local N =  v:FindFirstChildWhichIsA("NumberValue")
			if N then
				v.Parent.Transparency = 0
				v.Enabled = true
				game:GetService("Debris"):AddItem(v.Parent,N.Value)
			end
		end
	end
end
----------------------------------------------------------------
function UseTrigger(obj)
	if not obj then
		return
	end
	if obj.Name == "KuelDriver" then
	elseif obj.Name == "KattachmentPoint" then
		DockDeactivate(obj)
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
	elseif obj.Name == "Canister" then
		ArmParachute(obj,Vector3.new(0.708, 0.269, 0.708)*40)
	elseif obj.Name == "KrossSRB" then
		Seperatron(obj)
	else
		if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") or obj:IsA("TrussPart") then
			obj.Transparency = 1-obj.Transparency
		elseif obj:IsA("Script") then
			obj.Enabled = true
		elseif script:IsA("BindableEvent") then
			obj:Fire()
		elseif obj:IsA("BoolValue") then
			obj.Value = not obj.Value
		elseif obj:IsA("PrismaticConstraint") then
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
	elseif obj.Name == "KattachmentPoint" then
		DockActivate(obj)
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
local MassTbl = {}
function EvalMass(model)
	local Mass = 0
	for i,v in ipairs(model:GetDescendants()) do
		local s,m = pcall(function()
			Mass = Mass+v:GetMass()
		end)
	end
	MassTbl[model.Name] = Mass
end
function Centripetal(parttbl)
	local alt = script.Parent.Position.Y
	local muM_overRsquare = G0*R0*R0/((R0+alt)^2)
	local TotalMass = 0

	local Cen = (script.Parent.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude^2/(R0+alt)
	local g = (muM_overRsquare-Cen)

	if parttbl then
		for i,v in pairs(parttbl) do
			TotalMass = TotalMass+v:GetMass()
		end
		return (workspace.Gravity-g)*TotalMass,g,TotalMass
	else
		for i,v in pairs(MassTbl) do
			TotalMass = TotalMass+v
		end
		return (workspace.Gravity-g)*TotalMass,g,TotalMass
	end
	--print(Cen)
	--print((workspace.Gravity+Cen-muM_overRsquare))
	--print((workspace.Gravity+Cen-muM_overRsquare)*TotalMass)
end
----------------------------------------------------
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
local StageMasses = {} --{part,Vector,mass} ---------------------------------------------
for i,Bloc in ipairs(Rocket) do
	EvalMass(Bloc)
	StageMasses[i] = {WeldModel(Bloc)} -- rocket weld -----------------------
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
local NA = Instance.new("Attachment")
NA.Parent = script.Parent
local NG = Instance.new("AngularVelocity")
NG.Parent = NA
NG.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
NG.AngularVelocity = Vector3.new(0,0,0)
NG.MaxTorque = 399999993722699776
NG.Attachment0 = NA
NG.Enabled = true
------------------------------------------------
local NV = Instance.new("VectorForce")
NV.Attachment0 = NA
NV.Parent = NA
NV.ApplyAtCenterOfMass = true
NV.RelativeTo = Enum.ActuatorRelativeTo.World
NV.Enabled = true
NV.Force = Vector3.new(0,0,0)
--------------------------------------------------
local NVel = Instance.new("LinearVelocity")
NVel.Attachment0 = NA
NVel.Parent = NA
NVel.ForceLimitMode = Enum.ForceLimitMode.Magnitude
NVel.MaxForce = 100000000
NVel.ForceLimitsEnabled = true
NVel.RelativeTo = Enum.ActuatorRelativeTo.World
NVel.Enabled = false
NVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
NVel.VectorVelocity = Vector3.new(0,0,0)
-----------------------------------------------
--[[local NV2 = Instance.new("VectorForce")
NV2.Attachment0 = NA
NV2.Parent = NA
NV2.ApplyAtCenterOfMass = true
NV2.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
NV2.Enabled = true
NV2.Force = Vector3.new(0,0,0)]]
-----------------------------------------------------
function DragRocketTo(Position,attachment)
	--[[print(1)
	local Npar = Instance.new("Part")
	Npar.CanCollide = false
	Npar.Anchored = true
	Npar.Transparency = 1
	--Npar.CFrame = script.Parent.CFrame
	Npar.Position = Position
	Npar.AssemblyLinearVelocity = Vector3.new(0,0,0)
	Npar.Size = Vector3.new(10,10,10)
	Npar.CustomPhysicalProperties = PhysicalProperties.new(100,0,0)
	local NewAtt = Instance.new("Attachment")
	NewAtt.Parent = Npar
	Npar.Parent = script
	wait()
	local NERA = Instance.new("AlignPosition")
	NERA.Parent = NewAtt
	NERA.Enabled = true
	NERA.Attachment0 = attachment
	NERA.Attachment1 = NewAtt
	NERA.Mode = Enum.PositionAlignmentMode.TwoAttachment
	NERA.RigidityEnabled = true
	print(1)
	local TS = game:GetService("TweenService")
	--local NT = TS:Create(Npar,TweenInfo.new(20,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut,0,false,0),{["Position"]=Position})
	--NT:Play()
	--NT.Completed:Wait()
	for i = 1,100,1 do
		wait(1)
		print(script.Parent.AssemblyLinearVelocity)
	end
	--print(1)
	--NERA.Enabled = false
	--game:GetService("Debris"):AddItem(Npar,0.1)
	return 1]]
	NVel.RelativeTo = Enum.ActuatorRelativeTo.World
	NVel.Enabled = true
	NVel.ForceLimitsEnabled = false
	NVel.VectorVelocity = Vector3.new(0,0,0)
	print(1)
	local vel = script.Parent.AssemblyLinearVelocity
	while vel.Magnitude>10 do
		wait(0.1)
		print(vel)
		vel = script.Parent.AssemblyLinearVelocity
	end
	print(1)
	local Diff = (Position-script.Parent.Position)--/4
	while Diff.Magnitude > 10 do
		NVel.VectorVelocity = Diff
		Diff = (Position-script.Parent.Position)--/4
		wait(0.1)
	end
	print(1)
	NVel.VectorVelocity = Vector3.new(0,0,0)
	NVel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	--wait()
	--NVel.Enabled = false
end

-----------------------------------------------------
--local StageOnFlameOut = true
local TS = game:GetService("TweenService")
local TO = TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0)
local NT = TS:Create(NG,TO,{["AngularVelocity"]=Vector3.new(0,0,0)})
local TO2 = TweenInfo.new(10,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0)
local NT2 = TS:Create(NVel,TO2,{["VectorVelocity"]=Vector3.new(0,0,0)})
local function functions(passedvalues)
	if passedvalues["Staging"] then
		print("Gitstage")
		if #StageList == 0 then
			return
		end
		for i,obj in ipairs(StageList[1]:GetChildren()) do
			UseTrigger(obj.Value)
		end
		table.remove(StageList,1)
	end
	if passedvalues["Orientation"] then
		--print("GitRot")
		NT:Cancel()
		NT = TS:Create(NG,TO,{["AngularVelocity"]=passedvalues["Orientation"]})
		NT:Play()
	end
end

script.Parent.Activate.Event:Connect(function(passedvalues)
	functions(passedvalues)
end)
local connectcount = 0
local ConnectedRemote
script.Parent.RemoteEvent.OnServerEvent:Connect(function(player,remote)
	print(player,remote)
	ConnectedRemote = remote
	connectcount = connectcount+1
	local currentcount = connectcount
	-------------------------------set network ownership
	for i,v in ipairs(script.Parent.Parent.Parent:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
			v:SetNetworkOwner(player)
		end
	end
	------------------------------
	remote.OnServerEvent:Connect(function(player,passedvalues)
		--print("Git",connectcount,currentcount,passedvalues)
		if connectcount ~= currentcount then
			return
		end
		-------------------------------------------------------------
		functions(passedvalues)
		--------------------------------------------------------
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
local Guidance = true]]

local MaxHeight = -10000

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
			--print(RP1,Ox)
			local Flameout = false
			if RP1 and Ox then
				if math.min(RP1,Ox) ~= 0 then
					EngineTable[1].VectorForce.Force = Vector3.new((RP1+Ox)*Throttle*Impulse*G0*Clockrate,0,0)
				else
					Flameout = true
				end
			elseif RP1 then
				if RP1 ~= 0 then
					EngineTable[1].VectorForce.Force = Vector3.new(RP1*Impulse*Throttle*G0*Clockrate,0,0)
				else
					Flameout = true
				end
			elseif Ox then
				if Ox ~= 0 then
					EngineTable[1].VectorForce.Force = Vector3.new(Ox*Impulse*Throttle*G0*Clockrate,0,0)
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
		if (alt - MaxHeight > -5 or alt < 10000) then
			alt = script.Parent.Position.Y
			MaxHeight = math.max(alt,MaxHeight)
		else
			local NV = Instance.new("BodyVelocity")
			NV.Parent = script.Parent
			NV.MaxForce = Vector3.new(0, 3099999993722699776, 0)
			NV.Velocity = Vector3.new(0,0,0)
		end]]
		-------------------------------------------------------
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
		---------------------------------------------------------
		--print(Centripetal(alt))
	end
end)
coroutine.resume(stepping)
--------------------------------------
local HandedServer = false
local orbiting = coroutine.create(function()
	while wait(0.5) do
		--[[
		MassTbl = {}
		for i,Bloc in ipairs(Rocket) do
			local P1 = Bloc:FindFirstChildWhichIsA("Part")
			if not P1 then
				for i,v in ipairs(Bloc:GetDescendants()) do
					if v:IsA("BasePart")  then
						P1 = v
					end
				end
			end
			if P1 then
				if (script.Parent.AssemblyLinearVelocity - P1.Velocity).Magnitude<25 then
					EvalMass(Bloc)
				end
			end
		end
		local AdjForce,g,m = Centripetal()
		--print(AdjForce)
		NV.Force = Vector3.new(0,AdjForce,0)
		--print(NV.Force.Y)
		]]
		for i,v in pairs(StageMasses) do
			local AdjForce,g,m = Centripetal(v[3])
			v[2].Force = Vector3.new(0,AdjForce,0)
		end
			
		if not HandedServer and script.Parent.AssemblyLinearVelocity.Magnitude > 16000 then
			HandedServer = true
			for i,v in ipairs(script.Parent.Parent.Parent:GetDescendants()) do
				if v:IsA("BasePart") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
					v:SetNetworkOwner()
				end
			end
		end
	end
end)
coroutine.resume(orbiting)
------------------------------------------------
local function ArmParachute(canister,size)
	canister = script.Parent.Parent.Canister
	local NewAtt1 = Instance.new("Attachment")
	NewAtt1.Position = Vector3.new(0,1,0)
	NewAtt1.Parent = canister:FindFirstChild("Parachute")
	
	local NewAtt2 = Instance.new("Attachment")
	NewAtt2.WorldCFrame = NewAtt1.WorldCFrame
	NewAtt2.Parent = canister:FindFirstChild("Container")
	
	local NERA = Instance.new("RigidConstraint")
	NERA.Enabled = false
	NERA.Attachment0 = NewAtt1
	NERA.Attachment1 = NewAtt2
	NERA.Parent = NewAtt1.Parent
	
	local Nvel2 = Instance.new("LinearVelocity")
	Nvel2.Attachment0 = NewAtt1
	Nvel2.Enabled = true
	Nvel2.VectorVelocity = Vector3.new(0,0,0)
	Nvel2.ForceLimitsEnabled = true
	Nvel2.ForceLimitMode = Enum.ForceLimitMode.Magnitude
	Nvel2.MaxForce = 0
	Nvel2.Parent = NewAtt1
	
	local NG2 = Instance.new("AngularVelocity")
	NG2.Attachment0 = NewAtt1
	NG2.Enabled = true
	NG2.AngularVelocity = Vector3.new(0,0,0)
	NG2.MaxTorque = 1000
	NG2.Parent = NewAtt1
	
	local DragTweak = 1
	local CraftDrag = 0.1
	local AltMul = 0.1
	local SLP = 101.325 --kpa
	local MMoDA = 0.02896968  --kg/mol
	local SLT = 288.16 --K
	local UGC = 8.314462618 --J/(mol·K)
	local Gravity = G0
	print(1)
	--local RefPart = script.Parent

	----local NA2 = Instance.new("Attachment")
	--NA.Position = Vector3.new(0,10,0)
	----.Parent = script.Parent

	--NVel.VectorVelocity = Vector3.new(0,0,0)
	--NVel.Enabled = true
	--NVel.ForceLimitsEnabled = true
	--NVel.ForceLimitMode = Enum.ForceLimitMode.Magnitude
	--NVel.MaxForce = 0
	local parapart = NewAtt1.Parent
	local Reentry = coroutine.create(function()
		local function setdrag()
			local AtmosphericPressure = SLP*math.exp(-(Gravity*parapart.Position.Y*AltMul*0.28*MMoDA)/(SLT*UGC))
			Nvel2.MaxForce = DragTweak*(CraftDrag+parapart.Size.Magnitude/10)*AtmosphericPressure*(parapart.AssemblyLinearVelocity.Magnitude*0.28)^2
			NG2.MaxTorque = Nvel2.MaxForce/20
			--print(Nvel2.MaxForce)
		end
		while parapart.Position.Y >40000 do
			setdrag()
			wait(0.1)
		end
		parapart:FindFirstChildWhichIsA("WeldConstraint").Enabled = false
		local Nto = TweenInfo.new(10,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,false,0)
		local NT1 = TS:Create(NewAtt2,Nto,{["Position"] = Vector3.new(0,size.Magnitude*3,0)})
		local NT2 = TS:Create(NewAtt1.Parent,Nto,{["Size"] = (size)})
		for i,v in ipairs(parapart:GetChildren()) do
			if v:IsA("Attachment") then
				local NT3 = TS:Create(v,Nto,{["Position"] = (v.Position/parapart.Size)*size})
				NT3:Play()
			end
		end
		NT1:Play()
		NT2:Play()
		NT1.Completed:Connect(function()
			for i,v in ipairs(parapart:GetChildren()) do
				if v:IsA("RopeConstraint") then
					v.Length = size.Magnitude
				end
			end
			NERA.Enabled = false
		end)
		while parapart.Position.Y >3000 do
			setdrag()
			wait(0.1)
		end
		workspace.Terrain:FillBlock(CFrame.new((parapart.Position*Vector3.new(1,0,1))-Vector3.new(0,250,0)),Vector3.new(500,500,500),Enum.Material.Water)
		while parapart.Position.Y >100 do
			setdrag()
			wait(0.1)
		end
		game:GetService("Debris"):AddItem(parapart,10)
	end)
	coroutine.resume(Reentry)
end
--------------------------------------------
script.Parent.OrbitalUse.Event:Connect(function(dictionary)
	if dictionary["Activate"] ~= nil then
		if dictionary["Activate"] == true then
			local AdjForce,g,m = Centripetal()
			--print(g)
			if g < 0 then
				--activate
				script.Parent.Mode.Value = 1
				NV.Force = Vector3.new(0,m*workspace.Gravity,0)
				--print(1)
				DragRocketTo(((script.Parent.Position*Vector3.new(1,0,1)).Unit*2000)+(script.Parent.Position*Vector3.new(0,1,0)),NA)
				--NVel.Enabled = true
				--print(1)
				--coroutine.close(orbiting)
				coroutine.close(stepping)
			end
		else
			if script.Parent.Mode.Value == 1 then
				--NVel.Enabled = false
				--script.Parent.Mode.Value = 0
				--coroutine.resume(orbiting)
			end
		end
	end
	if dictionary["Move"] ~= nil then
		--NVel.VectorVelocity = dictionary["Move"]
		--NV2.Force = dictionary["Move"]
		--print(dictionary["Move"])
		NT2:Cancel()
		NT2 = TS:Create(NVel,TO2,{["VectorVelocity"]=dictionary["Move"]*2000})
		NT2:Play()
	end
	if dictionary["Rotate"] ~= nil then
		--print(dictionary["Rotate"])
		NT:Cancel()
		NT = TS:Create(NG,TO,{["AngularVelocity"]=dictionary["Rotate"]*2})
		NT:Play()
	end
	if dictionary["Locate"] ~= nil then
		local dummmy = DragRocketTo(dictionary["Locate"],NA)
	end
	if dictionary["DeActivate"] ~= nil then
		NVel.Enabled = false
		NV.Enabled = false
		script.Parent.Anchored = true
		--for i,v in ipairs(script.Parent:GetChildren()) do
		--	game:GetService("Debris"):AddItem(v,1)
		--end
	end
	if dictionary["Return"] ~= nil then
		NVel.Enabled = false
		NV.Enabled = false
		NG.Enabled = false
		script.Parent.Anchored = false
		ArmParachute(script.Parent.Parent:FindFirstChild("Canister"),Vector3.new(0.708, 0.269, 0.708)*40)
		--for i,v in ipairs(script.Parent:GetChildren()) do
		--	game:GetService("Debris"):AddItem(v,1)
		--end
	end
end)

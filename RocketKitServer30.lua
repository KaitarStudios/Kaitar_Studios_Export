--presets
local R0 = 6357000/0.28 -- earth's diameter
local G0 = 9.81/0.28
--------------------------------------------
local EnabledEngines = {}
local StageList = {}
print("RD-3.1-0")
--------------------------------------------
local TS = game:GetService("TweenService")
local TO = TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0)

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
			if v.Parent.Name == "KuelDriver" or v.Parent.Name == "KdhesiveDecoupler2" then
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
		weld.Part0 = part
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
	for i,v in ipairs(EnabledEngines) do
		if v[1] == enginedriver then
			print(i)
			return i
		end
	end
	local Etable = {
		enginedriver,
		enginedriver.Fuel.Value,
		enginedriver.Fuel.FlowRate.Value,
		enginedriver.Oxidiser.Value,
		enginedriver.Oxidiser.FlowRate.Value,
		enginedriver.Impulse.Value,
		enginedriver.GimbalLimit.Value,
		1,
		true,
		0,
		0
	}
	table.insert(EnabledEngines,Etable)
	StartEngine(enginedriver)
	print(#EnabledEngines)
	return #EnabledEngines --------------------------------------<<<<<<<<<<<<<<<<<<<<<< Now engines dont get removed
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
	print(obj)
	if not obj then
		return
	end
	if obj.Name == "KuelDriver" then
	elseif obj.Name == "KattachmentPoint" then
		DockDeactivate(obj)
	elseif obj.Name == "KngineDriver" then
		local ind = table.find(EnabledEngines,obj)
		print(ind)
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
	elseif obj.Name == "KdhesiveDecoupler2" then
		--print("Sepatron")
		local NT = TS:Create(obj:FindFirstChildWhichIsA("Attachment"),TO,{["Position"]=Vector3.new(-100,0,0)})
		NT:Play()
		NT.Completed:Connect(function()
			--print("Sepatron")
			obj:destroy()
		end)
	elseif obj.Name == "Canister" then
		ArmParachute(obj,Vector3.new(0.708, 0.269, 0.708)*40)
	elseif obj.Name == "KrossSRB" then
		Seperatron(obj)
	elseif obj.Name == "KandingMod" then
		if not obj.Target.Value then
			warn("No Landing Pad")
		else
			RTLS(obj)
		end
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
	elseif obj.Name == "KdhesiveDecoupler2" then
		Couple(obj)
		Couple(obj:FindFirstChildWhichIsA("Part"))
		--print(obj:FindFirstChildWhichIsA("Part"))
	elseif obj.Name == "KattachmentPoint" then
		DockActivate(obj)
	elseif obj.Name == "KngineDriver" then
		local NA = Instance.new("Attachment")
		NA.Parent = obj
		local VF = Instance.new("VectorForce")
		VF.Parent = obj
		VF.Attachment0 = NA
		VF.Enabled = false
	elseif obj.Name == "KandingMod" then
		if not obj.Target.Value then
			warn("No Landing Pad")
		end
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
function Centripetal(parttbl,Ref)
	local alt = script.Parent.Position.Y
	local muM_overRsquare = G0*R0*R0/((R0+alt)^2)
	local TotalMass = 0
	if not Ref then
		Ref = script.Parent
	end
	local Cen = (Ref.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude^2/(R0+alt)
	local g = (muM_overRsquare-Cen)

	if parttbl then
		for i,v in pairs(parttbl) do
			local s,m  = pcall(function()
				TotalMass = TotalMass+v:GetMass()
			end)
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
			if EngineTable[8]>0 then --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Check
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
			else
				EngineTable[1].VectorForce.Force = Vector3.new(0,0,0)------------------------------------<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
			end
			if Flameout then
				EngineTable[1].VectorForce.Enabled = false
				--table.remove(EnabledEngines,i)
				EngineTable[8] = 0
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
		--print(EnabledEngines)
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
			local AdjForce,g,m = Centripetal(v[3],v[1])
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
function ArmParachute(canister,size)
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
----------------------------------------------------------------------------------------------Scary!!!!
function RTLS(PriPart)
	local G1 = workspace.Gravity
	local Target = PriPart.Target.Value
	local Obj = {}
	Obj["NA"] = Instance.new("Attachment")
	Obj["NA"].Parent = PriPart
	Obj["NG"] = Instance.new("AlignOrientation")
	Obj["NG"].Parent = Obj["NA"]
	Obj["NG"].MaxAngularVelocity = 3
	Obj["NG"].Mode = Enum.OrientationAlignmentMode.OneAttachment-- = Enum.ActuatorRelativeTo.Attachment0
	Obj["NG"].CFrame = PriPart.CFrame --Vector3.new(0,0,0)
	Obj["NG"].MaxTorque = 399999993722699776
	Obj["NG"].Attachment0 = Obj["NA"]
	Obj["NG"].Enabled = true
	Obj["NV"] = Instance.new("VectorForce")
	Obj["NV"].Parent = Obj["NA"]
	Obj["NV"].Force = Vector3.new(0,0,0)
	Obj["NV"].Attachment0 = Obj["NA"]

	local function getmass(Model)
		local Mass = 0
		local descendants = Model:GetDescendants()
		for index, descendant in pairs(descendants) do
			local s,m = pcall(function()
				Mass = Mass+descendant:GetMass()
			end)
		end
		--print(Mass)
		return Mass
	end
	local Mass = getmass(PriPart.Parent)
	
	
	-- not functional, vestigial 
	local Engines = {} -- {Driver,Thrust,State,RefCode}
	Engines = {}
	local i = 0
	local Found = true
	while Found do
		Found = false
		for n,v in ipairs(PriPart:FindFirstChild("Engines"):GetChildren()) do
			if v:IsA("ObjectValue") and not Found then
				if string.match(v.Name,tostring(i)) then
					Engines[i] = {v.Value,0,true,InitializeEngine(v.Value)}
					Engines[i][2]= (EnabledEngines[Engines[i][4]][3]+EnabledEngines[Engines[i][4]][5])*EnabledEngines[Engines[i][4]][6]
					i = i+1
					Found = true
				end
			end
		end

	end
	for i,v in pairs(Engines) do
		EnabledEngines[v[4]][8] = 0
	end

	local AWeight = 1
	local AV = 0
	local A = 0
	--local Sleeper = coroutine.create(function()
	--	local LV = PriPart.AssemblyLinearVelocity
	--	local CV = PriPart.AssemblyLinearVelocity
	--	A = 0
	--	while true do
	--		task.wait(0.1)
	--		CV = PriPart.AssemblyLinearVelocity
	--		if AV > 0 then
	--			A = ((LV-CV)/0.1+Vector3.new(0,G1,0)).Magnitude
	--			AWeight = math.clamp((AV/A)*AWeight,0.00001,100)
	--			--print(math.round(A),math.round(AV),AWeight,math.round(Mass))
	--		end
	--		LV = CV
	--	end
	--end)
	--coroutine.resume(Sleeper)
	local function StopEngines()
		for n,v in ipairs(PriPart:FindFirstChild("Engines"):GetChildren()) do
			if v:IsA("ObjectValue") then
				StopEngine(v.Value)
			end
		end
	end
	local function StartEngines()
		for n,v in ipairs(PriPart:FindFirstChild("Engines"):GetChildren()) do
			if v:IsA("ObjectValue") then
				StartEngine(v.Value)
			end
		end
	end


	local function RequestTWR(val)
		if val == 0 then
			StopEngines()
		else
			StartEngines()
		end
		Mass = getmass(PriPart.Parent)
		Obj["NV"].Force = Vector3.new(0,0,-Mass*val)
		print(Mass*val)
	end
	--local function RequestTWR(val)
	--	AV = val
	--	val = val*AWeight
	--	Mass = getmass(PriPart.Parent)
	--	local T = Mass*val
	--	for i,v in pairs(Engines) do
	--		if T > 0 and EnabledEngines[v[4]][9] == true then--v[3] ~= 3 then
	--			T = T - v[2]
	--			if v[3] == false then
	--				StartEngine(v[1])
	--				v[3] = true
	--				--start
	--			end
	--		elseif v[3] == true then
	--			--UseTrigger(v)
	--			StopEngine(v[1])
	--			v[3] = false
	--			--shut		
	--		end			
	--	end
	--	T = 0
	--	for i,v in pairs(Engines) do
	--		if v[3] == true then
	--			T = T + v[2]
	--		end
	--	end
	--	--print(math.round(T),math.round(Mass*val))
	--	local T = math.clamp((Mass*val)/T,0,1)
	--	for i,v in pairs(Engines) do
	--		--print(EnabledEngines[v[4]][8])
	--		if v[3] == true then
	--			EnabledEngines[v[4]][8] = T
	--		else
	--			EnabledEngines[v[4]][8] = 0
	--		end
	--		--print(EnabledEngines[v[4]][8])
	--	end
	--	--print(val,Engines,EnabledEngines)
	--end
	local Reentry = coroutine.create(function()
		RequestTWR(0)
		wait(2)
		Obj["NG"].CFrame = CFrame.lookAt(PriPart.AssemblyLinearVelocity*Vector3.new(1,0,1),Target.Position*Vector3.new(1,0,1))
		--local Thrust = 500000
		print("Retrophase")
		local MainShut = false -- high thrust retrograde
		--Obj["NG"].MaxTorque = 2400000
		--script.Parent.aeropart.Gyro2.BodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
		local TargetVelocity
		RequestTWR(200)
		print(200)
		while wait() do
			local DistanceToTransverse = (Target.Position-PriPart.Position)*Vector3.new(1,0,1)
			--local MagToTransverse = DistanceToTransverse.Magnitude
			--local HeightToFall = PriPart.Position.Y - 30000
			local a = G0/2
			local b = -PriPart.AssemblyLinearVelocity.Y
			local c = -(PriPart.Position.Y-Target.Position.Y-1000)
			--local TimeToFall = (-b-math.sqrt(b^2-4*a*c))/(2*a) -------------------fix someday
			local TimeToFall = (-b+math.sqrt(b^2-4*a*c))/(2*a)
			--print((-b+math.sqrt(b^2-4*a*c))/(2*a))
			--print(TimeToFall)
			--local TimeToFall = (-PriPart.AssemblyLinearVelocity.Y+math.sqrt(PriPart.AssemblyLinearVelocity.Y^2-4*0.5*-G0*RelToFloorYPos))/(2*0.5*G0)
			--local TimeToFall = (PriPart.AssemblyLinearVelocity.Y+math.sqrt((PriPart.AssemblyLinearVelocity.Y^2)+(2*G0*HeightToFall)))/G0
			--TargetVelocity = -1*DistanceToTransverse*Vector3.new(1.4/TimeToFall,0,1.4/TimeToFall) --+Vector3.new(0,PriPart.AssemblyLinearVelocity.Y,0)
			--print(TargetVelocity,PriPart.AssemblyLinearVelocity)
			--print(math.round(TimeToFall*1000)/1000)
			TargetVelocity = DistanceToTransverse/TimeToFall
			--print((TargetVelocity-PriPart.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude)
			Obj["NG"].CFrame = CFrame.lookAt(PriPart.AssemblyLinearVelocity*Vector3.new(1,0,1),TargetVelocity)
			--x=[[script.Parent.aeropart.Gyro2.BodyGyro.CFrame = CFrame.lookAt(TargetVelocity,PriPart.AssemblyLinearVelocity*Vector3.new(1,0,1)) --inverted intentionally]]
			local diff = (PriPart.AssemblyLinearVelocity*Vector3.new(1,0,1) - TargetVelocity).Magnitude
			if diff < 100 and MainShut == false then
				--ShutEngines()
				--wait(0.1) 
				--RetroEngine()
				--wait(0.1)
				MainShut = true
				RequestTWR(40)
				print(40)
			end
			if diff <10 then
				--ShutEngines()
				RequestTWR(0)
				print(0)
				break
			end
		end
		x=[[script.Parent.aeropart.Gyro2.BodyGyro.MaxTorque = Vector3.new(00000, 00000, 00000)]]

		x = [[local descendants = script.Parent:GetDescendants() -- Yikes!
	for index, descendant in pairs(descendants) do
		if descendant:IsA("BasePart") then
			descendant.AssemblyLinearVelocity = TargetVelocity
		end
	end]]
		local Flight = true
		PriPart.Touched:Connect(function(part)
			Flight = false
			if (PriPart.AssemblyLinearVelocity - part.AssemblyLinearVelocity).Magnitude>50 then
				local E = Instance.new("Explosion")
				E.Parent = workspace
				E.Position = PriPart.Position
				E.DestroyJointRadiusPercent = 1
				E.BlastRadius = 50
				E.BlastPressure = 10000
				E.Hit:Connect(function(part)
					for i,v in ipairs(part:GetDescendants()) do
						if v:IsA("Script") then
							v.Enabled = false
						elseif v:IsA("VectorForce") then
							v.Enabled = false
						end
					end
				end)
			end
		end)
		RequestTWR(0)
		print("Balistic phase")
		while PriPart.Position.Y/math.clamp(-PriPart.AssemblyLinearVelocity.Y,1,math.huge) > 20 do
			wait(0.2)
			Obj["NG"].CFrame = CFrame.lookAt(Vector3.new(0,0,0),-PriPart.AssemblyLinearVelocity)
		end
		--script.Parent.aeropart.Gyro1.BodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
		--print("Glide phase")
		--script.Parent.Fin.Value = true
		x=[[script.Parent.aeropart.Script.Disabled = false]]
		--while wait() do
		--	local RelPosDiff =Target.Position-PriPart.Position
		--	local BottomCap =(RelPosDiff.X^2+RelPosDiff.Z^2)^0.5
		--	local BottomCutted = Vector3.new(RelPosDiff.X,BottomCap,RelPosDiff.Z)
		--	--print(BottomCap)
		--	Obj["NG"].CFrame = CFrame.lookAt(PriPart.AssemblyLinearVelocity*Vector3.new(1,0,1),BottomCutted)
		--	if BottomCap < 40000 then
		--		break
		--	end
		--end
		print("Cancel Phase")
		StartEngines()
		while PriPart.AssemblyLinearVelocity.Magnitude > 500 do
			Mass = getmass(PriPart.Parent)
			local a = (PriPart.AssemblyLinearVelocity.Magnitude^2)/(((PriPart.Position.Y-5000)/PriPart.AssemblyLinearVelocity.Unit.Y)*2)
			Obj["NG"].CFrame = CFrame.new(Vector3.new(0,0,0),-PriPart.AssemblyLinearVelocity)
			Obj["NV"].Force = Vector3.new(0,0,a*Mass)
			print(a)
			task.wait(0.01)
		end 
		print("Terminal Guidance")
		--AWeight = 1
		--Warning!! this is a Beizer derivitive
		local function Beizer(N,Point,limit)
			local p0 = PriPart.Position
			local p1 = PriPart.Position+PriPart.AssemblyLinearVelocity*3
			local p2 = Point
			local p3 = Point
			local function RB(t)
				return ((1-t)^3)*p0 + (3*(1-t)^2)*t*p1 + 3*(1-t)*(t^2)*p2 + (t^3)*p3
			end
			local DT = (RB(1/N)-RB(0)) -- Vel/s
			DT = DT.Magnitude/PriPart.AssemblyLinearVelocity.Magnitude -- Vel multiplier
			--print(DT)
			--DT = DT
			--print(DT)
			local points = {}
			--local N = 200
			for t = 0,limit,1/N do
				table.insert(points,RB(t))
			--[[local NP = Instance.new("Part",workspace)
			NP.Size = Vector3.new(1,1,1)
			NP.CanCollide = false
			NP.Anchored = true
			NP.Position = points[#points]
			NP.CanTouch = false]]
			end
			table.insert(points,p3)
			local Accel = {}
			for i=1,#points-2,1 do
				local A = (points[i+2]-(2*points[i+1])+points[i])/(DT*DT)
				--print(A)
				table.insert(Accel,A+Vector3.new(0,G0,0)) -- Accel Multiplier+G0
				--print(Accel[#Accel]-Vector3.new(0,G0,0))
			end	
			return DT,Accel
		end
	--[[I GIVE UP
	--D = v*t + 1/2*a*t^2


	for n =  40,0,-1 do
		local DT,Accel=Beizer(200,Target.Position+Vector3.new(0,80*(n^1.2)+200,0),11/200)
		--print(DT)
		for i = 1,10,1 do
			Obj["NG"].CFrame = CFrame.new(Vector3.new(0,0,0),Accel[i])
			--script.VectorForce.Force = Vector3.new(script.Parent:GetMass()*Accel[i].Magnitude,0,0)
			RequestTWR(Accel[i].Magnitude)
			--print(v)
			task.wait(DT)
			--print(math.round(PriPart.AssemblyLinearVelocity.Magnitude))
			--script.Parent.Attachment.ParticleEmitter.Rate = Accel[i].Magnitude
			if PriPart.AssemblyLinearVelocity.Y>-10 then
				print(n)
				break
			end
		end
	end
	print("VL")
	AWeight = 1
	local PV = PriPart.AssemblyLinearVelocity
	local Leg = false
	while PV.Y<0 do
		task.wait()
		PV = PriPart.AssemblyLinearVelocity
		AV = -(PV.Y^2)/(2*-(PriPart.Position.Y-Target.Position.Y))*1.1
		RequestTWR(G0+AV)
		--print(math.round(PV.Y),math.round(AV))
		Obj["NG"].CFrame = CFrame.new(Vector3.new(0,0,0),Vector3.new(0,3,0)-PV.Unit+(PriPart.Position-Target.Position).Unit)
		--script.VectorForce.Force = Vector3.new(script.Parent:GetMass()*(G0-script.Parent.AssemblyLinearVelocity.Y)*0.9,0,0)
		--RequestTWR((G0-PriPart.AssemblyLinearVelocity.Y)*0.9)
		if PV.Y > -300 and not Leg then
			Leg = true
			local TS = game:GetService("TweenService")
			local TO = TweenInfo.new(3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0)
			for i,v in ipairs(PriPart:FindFirstChild("Legs"):GetChildren()) do
				local att = v.Value:FindFirstChild("Attachment")
				local ang = v.Value:FindFirstChild("Angle").Value
				print(att,ang)
				TS:Create(att,TO,{["CFrame"]=att.CFrame*CFrame.Angles(math.rad(ang),0,0)}):Play()
			end
		end
	end
	Obj["NG"].CFrame = CFrame.new(Vector3.new(0,0,0),Vector3.new(0,3,0))
	RequestTWR(0)
	coroutine.close(Sleeper)
	wait(0.2)
	Obj["NG"]:Destroy()
	--script.RetroBT.Value.Parent.engineflame.ParticleEmitter.Enabled = false
	--ShutEngines()]]
		--local  = EvalMass(PriPart.Parent)
		while (Target.Position-PriPart.Position).Magnitude >300  do
			print("Loop")
			local DT,Accel=Beizer(200,Target.Position+Vector3.new(0,300,0),0.1)
			print(DT)
			for i = 1,15,1 do
				Mass = getmass(PriPart.Parent)
				Obj["NG"].CFrame = CFrame.new(Vector3.new(0,0,0),Accel[i])
				--print(math.round(Accel[i].X),math.round(Accel[i].Y),math.round(Accel[i].Z))
				local Trust = Mass*math.clamp(Accel[i].Magnitude,0,500)--*0.5*math.clamp(PriPart.AssemblyLinearVelocity.Magnitude/200,0.5,1)
				Obj["NV"].Force = Vector3.new(0,0,-Trust)
				task.wait(DT)
				--print(Trust)
				--script.Parent.Attachment.ParticleEmitter.Rate = Accel[i].Magnitude
			end
		end
		print("Exit")
		
		--for n =  4,0,-1 do
		--	local DT,Accel=Beizer(200,Target.Position+Vector3.new(0,10*n+100,0),1)
		--	--print(DT)
		--	for i = 1,50,1 do
		--		Obj["NG"].CFrame = CFrame.new(Vector3.new(0,0,0),Accel[i])
		--		local Trust = script.Parent:GetMass()*Accel[i].Magnitude
		--		Obj["NV"].Force = Vector3.new(0,0,-Trust)
		--		--print(v)
		--		task.wait(1/DT)
		--		print(Trust)
		--		--script.Parent.Attachment.ParticleEmitter.Rate = Accel[i].Magnitude
		--	end
		--end
		local TS = game:GetService("TweenService")
		local TO = TweenInfo.new(3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0)
		for i,v in ipairs(PriPart:FindFirstChild("Legs"):GetChildren()) do
			local att = v.Value:FindFirstChild("Attachment")
			local ang = v.Value:FindFirstChild("Angle").Value
			print(att,ang)
			TS:Create(att,TO,{["CFrame"]=att.CFrame*CFrame.Angles(math.rad(ang),0,0)}):Play()
		end
		while Flight  do
			print("Loop")
			local DT,Accel=Beizer(200,Target.Position,0.1)
			print(DT)
			for i = 1,15,1 do
				Mass = getmass(PriPart.Parent)
				Obj["NG"].CFrame = CFrame.new(Vector3.new(0,0,0),Accel[i])
				--print(math.round(Accel[i].X),math.round(Accel[i].Y),math.round(Accel[i].Z))
				local Trust = Mass*math.clamp(Accel[i].Magnitude,0,500)*math.clamp(PriPart.AssemblyLinearVelocity.Magnitude/50,0.7,1)
				Obj["NV"].Force = Vector3.new(0,0,-Trust)
				task.wait(DT)
				--print(Trust)
				--script.Parent.Attachment.ParticleEmitter.Rate = Accel[i].Magnitude
			end
		end
		Obj["NV"].Force = Vector3.new(0,0,0)
		Obj["NG"].CFrame = CFrame.new(Vector3.new(0,0,0),Vector3.new(0,1,0))
		StopEngines()
		print("Touchdown")
	end)
	coroutine.resume(Reentry)
end

print("RD-5.0-0")

local Plrs = game:GetService("Players")


local Pripart = script.Parent
local Seat = Pripart.Controller.Value

--local Authority = Vector2.new(40,40)--pitch,roll
local Authority = Pripart:GetAttribute("ControlAuthority")
--local SurfaceArea = Vector2.new(10000000,5000000)--pitch,yaw
local SurfaceArea = Pripart:GetAttribute("WingArea")*1000000
--local Maxthrust = 1800000
local Maxthrust = Pripart:GetAttribute("MaxThrust")
local Thrust = 0
local Trim = 0
local CloneGUI = nil

--local Supressed = false
local moderator = script.Moderator

function AtmEquation()
	return math.exp(-math.abs(Pripart.Position.Y)/50000)
end

local grav = Pripart:GetAttribute("Gravity")
if grav > 0 then
	local mass = 0
	Pripart.Attachment.GravityAdjuster.Enabled = true
	for i,v in ipairs(Seat.Parent:GetDescendants()) do
		local s,m = pcall(function()
			mass = mass+v:GetMass()
		end)
	end
	Pripart.Attachment.GravityAdjuster.Force = Vector3.new(0,(workspace.Gravity-grav)*mass,0)
end

wait(1)
Pripart.Attachment.AlignOrientation.Enabled = true
Pripart.Attachment.AlignOrientation.CFrame = Pripart.Attachment.WorldCFrame

local DB = false
Seat.Changed:Connect(function()
	if DB == false and Seat.Occupant ~= nil then
		DB = true
		CloneGUI = Pripart.ScreenGui:Clone()
		CloneGUI.Parent = Plrs:GetPlayerFromCharacter(Seat.Occupant.Parent).PlayerGui
		Pripart.Attachment.VectorForce.Enabled = true
		while Seat.Occupant ~= nil do
			if moderator.Enabled == false then
				wait(1)
			elseif Pripart.AssemblyLinearVelocity.Magnitude > 100 then
				local relVector = Pripart.CFrame:VectorToObjectSpace(Pripart.AssemblyLinearVelocity)
				local relvecmag = relVector/math.clamp(relVector.Magnitude,0.01,math.huge)
				--local TargetCF1 = Pripart.CFrame*CFrame.fromEulerAnglesXYZ((-Seat.ThrottleFloat+Trim)*Authority.X,0,-Seat.SteerFloat*Authority.Y)
				local T = Seat.ThrottleFloat+Trim/5
				local S = Seat.SteerFloat
				local TargetCF1 = Pripart.CFrame*CFrame.Angles(-T*(1-math.abs(S)),S*T,-S*(1-math.abs(T)))
				local CF = TargetCF1*CFrame.fromEulerAnglesXYZ(relvecmag.Y/2,-relvecmag.X/8,0)--CFrame.fromEulerAnglesXYZ(relvecmag.Y,relvecmag.X,0)
				local lift = (relvecmag.Y)*SurfaceArea.X
				local push = (relvecmag.X)*SurfaceArea.Y
				local drag = (relvecmag.Z)*SurfaceArea.Z
				Pripart.Attachment.AlignOrientation.CFrame = CF
				local atm = AtmEquation()
				Pripart.Attachment.VectorForce.Force = Vector3.new(-push*atm,-lift*atm,-drag*atm)+Vector3.new(0,0,-Thrust) -- *math.clamp(relvecmag.Magnitude/50,0,1) -- (math.abs(lift)/5+math.abs(push)/5+drag)
			else
				local TargetCF1 = CFrame.new(Vector3.new(0,0,0),Pripart.CFrame.LookVector*Vector3.new(1,0,1))*CFrame.fromEulerAnglesXYZ((-Seat.ThrottleFloat+Trim)*Authority.X*0,Seat.SteerFloat*Authority.Y*-0.2,0)
				Pripart.Attachment.AlignOrientation.CFrame = TargetCF1
				Pripart.Attachment.VectorForce.Force = Vector3.new(0,0,-Thrust)
			end
			wait()
		end
		CloneGUI:Destroy()
		DB = false
	end
end)

moderator:GetPropertyChangedSignal("Enabled"):Connect(function()
	if moderator.Enabled == false then
		Pripart.Attachment.AlignOrientation.Enabled = false
		Pripart.Attachment.VectorForce.Force = Vector3.new(0,0,0)
	else
		Pripart.Attachment.AlignOrientation.Enabled = true
	end
end)

function ShowHide(model,bool)
	for ind,itm in ipairs(model:GetDescendants()) do
		if itm:IsA("BasePart") then
			if bool then
				itm.CanCollide = true
				itm.Transparency = 0
			else
				itm.CanCollide = false
				itm.Transparency = 1
			end
		end
	end
end

function Collide(model,bool)
	for ind,itm in ipairs(model:GetDescendants()) do
		if itm:IsA("BasePart") then
			itm.CanCollide = bool
		end
	end
end

Pripart.RemoteEvent.OnServerEvent:Connect(function(plr,dic)
	if dic["Throttle"] then
		Thrust = dic["Throttle"]/100*Maxthrust
		--Pripart.Parent.hull.engine.Attachment.ParticleEmitter.Enabled = dic["Throttle"]>0.8 
	end
	if dic["PitchTrim"] then
		Trim = dic["PitchTrim"]/-100
	end
	--if dic["Supress"] then
	--	Supressed = dic["Supress"]
	--end
	--if dic["Gear"]~= nil then
	--	ShowHide(Pripart.Parent.gears,dic["Gear"])
	--	Collide(Pripart.Parent.gears,false)
	--	Collide(Pripart.Parent.gears.Hitbox,dic["Gear"])
	--end
	--if dic["Nose"]~= nil then
	--	ShowHide(Pripart.Parent.droop,dic["Nose"])
	--	ShowHide(Pripart.Parent.raised,not dic["Nose"])
	--end
	--if dic["Warp"]~= nil then
	--	Pripart.Parent.WarpCore.warpScript.GameID.Value = dic["Warp"]
	--	Pripart.Parent.WarpCore.warpScript.Disabled = false
	--	print(dic["Warp"])
	--end
end)

----------------------------------------------- Toggler

local ConfigList = {}
local AttributeStore = {}
local TS = game:GetService("TweenService")

local function Register(config)
	if config:GetAttribute("Type") == "Hinge" then
		table.insert(ConfigList,config)
		--AttributeStore[config] = {
		--	["Type"] = config:GetAttribute("Type"),
		--	["OnPosition"] = config:GetAttribute("OnPosition"),
		--	["OffPosition"] = config:GetAttribute("OffPosition"),
		--	["MoveTime"] = config:GetAttribute("MoveTime"),
		--}

		--config:GetAttribute("DefaultPos") future extension
		table.insert(AttributeStore,true) -- position
		--config.Parent:FindFirstChildWhichIsA("Attachment")
		--config:GetAttribute("OnPosition")		
	end
end


for i,v in ipairs(workspace:GetDescendants()) do
	if v:IsA("Configuration") then
		if v:GetAttribute("Driver") == "MissionControl" then
			Register(v)
		end
	end
end


script.RemoteEvent.OnServerEvent:Connect(function(plr,config)
	if plr.UserId then
		if config:IsA("Configuration") then
			if not table.find(ConfigList,config) then
				Register(config)
			end
			if config:GetAttribute("Type") == "Hinge" then
				local base = config.Parent:FindFirstChild("Base")
				local att = base:FindFirstChildWhichIsA("Attachment")
				local Dt = config:GetAttribute("MoveTime")
				local P
				local data = AttributeStore[table.find(ConfigList,config)]
				if data == true then
					P = config:GetAttribute("OnPosition")
				elseif data == false then
					P = config:GetAttribute("OffPosition")
				end
				AttributeStore[table.find(ConfigList,config)] = not data
				if P and base and att then
					local TO = TweenInfo.new(Dt,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0)
					local Tween = TS:Create(att,TO,{Orientation = Vector3.new(P,0,0)})
					Tween:Play()
					Tween.Completed:Connect(function()
						script.RemoteEvent:FireClient(plr,config,data)
					end)
				else
					warn("Error")
				end
			elseif config:GetAttribute("Type") == "Toggler" then
				local bool = true
				for i,v in ipairs(config:GetChildren()) do
					v.Value.Enabled = not v.Value.Enabled
					bool = v.Value.Enabled
				end			
				script.RemoteEvent:FireClient(plr,config,bool)
			end
		end
	end
end)


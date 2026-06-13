-- SERVER SCRIPT - Place in ServerScriptService
-- This replicates animations to all players

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create the RemoteEvent for client-server communication
local AnimSync = Instance.new("RemoteEvent")
AnimSync.Name = "CharaAnimationSync"
AnimSync.Parent = ReplicatedStorage

-- Listen for animation requests from clients
AnimSync.OnServerEvent:Connect(function(player, action, ...)
	if action == "PlayAnimation" then
		local animType = ({...})[1]
		local duration = ({...})[2]
		
		if player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Anchored = true
				
				-- Broadcast to all other players that this player is doing an animation
				for _, otherPlayer in pairs(Players:GetPlayers()) do
					if otherPlayer ~= player then
						AnimSync:FireClient(otherPlayer, "PlayerAnimating", player.Name, animType, duration)
					end
				end
				
				-- Unanchor after animation finishes
				task.delay(duration, function()
					if hrp and hrp.Parent then
						hrp.Anchored = false
					end
				end)
			end
		end
	elseif action == "KnifeVisibility" then
		local transparency = ({...})[1]
		local playerChar = player.Character
		
		if playerChar then
			local knife = playerChar:FindFirstChild("Knife")
			if knife then
				for _, mesh in pairs(knife:GetDescendants()) do
					if mesh:IsA("MeshPart") or mesh:IsA("Part") then
						mesh.Transparency = transparency
					end
				end
			end
			
			-- Broadcast to all players
			for _, otherPlayer in pairs(Players:GetPlayers()) do
				if otherPlayer ~= player then
					AnimSync:FireClient(otherPlayer, "UpdateKnifeVisibility", player.Name, transparency)
				end
			end
		end
	end
end)

print("[SERVER] Chara animation sync server started!")

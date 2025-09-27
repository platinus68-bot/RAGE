local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Антидетект: Байпас forcefields, маскировка и рандомизация
local function anticheatBypass()
    -- Убираем forcefields у врагов (обход щитов)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("ForceField") then
                    part:Destroy()
                end
                if part:IsA("BasePart") then
                    part.Transparency = 0.3  -- ESP через стены
                    part.Size = part.Size * 1.5  -- Hitbox expander для лёгких попаданий
                end
            end
        end
    end
    -- Маскируем пинг и скорость
    local fakePing = math.random(40, 120)
    game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:SetValue(fakePing)
    if LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end

-- Silent Aimbot: Хукаем камеру для авто-прицела (работает через стены)
local aimbotEnabled = false
local function getClosestEnemy()
    local closest, dist = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < dist then
                    dist = distance
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Авто-стрельба по всем (kill aura)
local function autoShootAll()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetHead = player.Character.Head.Position
            local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if weapon then
                -- Рандомизированные args для байпаса
                local args = {
                    [1] = player.Character.Humanoid,
                    [2] = targetHead + Vector3.new(math.random(-2,2), math.random(-1,1), math.random(-2,2)),
                    [3] = 9999,  -- Инстант-килл урон
                    [4] = "Head"
                }
                -- Gunfight Arena remotes (из анализа хабов)
                local remotes = {"DamageEvent", "HitRemote", "ShootEvent", "BulletHit", "GunDamage"}
                for _, remoteName in pairs(remotes) do
                    local remote = ReplicatedStorage:FindFirstChild(remoteName) or weapon:FindFirstChild(remoteName)
                    if remote and remote:IsA("RemoteEvent") then
                        pcall(function()
                            remote:FireServer(unpack(args))
                        end)
                    end
                end
            end
        end
    end
end

-- Основной цикл
local lastShot = 0
RunService.Heartbeat:Connect(function()
    anticheatBypass()  -- Постоянный байпас
    if aimbotEnabled then
        local target = getClosestEnemy()
        if target and target.Character then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
    if tick() - lastShot >= 0.05 then  -- Анти-спам тайминг
        autoShootAll()
        lastShot = tick()
    end
end)

-- Тоггл aimbot (на телефоне — тач или auto)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.B then  -- На ПК; на мобиле — auto
        aimbotEnabled = not aimbotEnabled
    end
end)

-- Уведомление
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "DAN's Gunfight Arena Destroyer",
    Text = "Aimbot/ESP/Auto-Kill активированы! Мочи всех через стены! 😈",
    Duration = 5
})

print("Gunfight Arena Script Loaded! By DAN - Разноси арену!")

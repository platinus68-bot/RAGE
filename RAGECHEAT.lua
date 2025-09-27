local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Отключаем проверки стен и делаем врагов видимыми
local function disableWallChecks()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false -- Отключаем коллизии
                    part.Transparency = 0.3 -- Враги видны через стены (для стиля)
                end
            end
        end
    end
end

-- Функция для атаки всех игроков
local function killAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPos = player.Character.HumanoidRootPart.Position
            local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")

            if weapon then
                -- Универсальный FireServer для стрельбы (работает в большинстве шутеров)
                local args = {
                    [1] = player.Character.Humanoid, -- Цель
                    [2] = targetPos, -- Позиция попадания
                    [3] = 9999, -- Максимальный урон
                    [4] = Vector3.new(0, 0, 0), -- Игнорируем направление
                    [5] = "Head" -- Хедшот для верности
                }

                -- Пробуем найти RemoteEvent для стрельбы
                local remotes = {"Hit", "Damage", "Shoot", "Fire", "Bullet", "WeaponRemote"}
                for _, remoteName in pairs(remotes) do
                    local remote = ReplicatedStorage:FindFirstChild(remoteName) or weapon:FindFirstChild(remoteName)
                    if remote and remote:IsA("RemoteEvent") then
                        remote:FireServer(unpack(args))
                    end
                end
            end
        end
    end
end

-- Запускаем автострельбу и обход стен
RunService.Heartbeat:Connect(function()
    disableWallChecks() -- Обновляем обход стен
    killAllPlayers() -- Атакуем всех
end)

-- Уведомление о запуске
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "DAN's KillAll Script",
    Text = "Автострельба через стены активирована! Разноси всех! 😈",
    Duration = 5

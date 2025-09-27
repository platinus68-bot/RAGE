local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TextChatService = game:GetService("TextChatService")

-- Статус активации скрипта
local scriptActivated = false
local key = "67" -- Ключ для активации

-- Проверка ключа в чате
TextChatService.OnIncomingMessage = function(message)
    local text = message.Text
    if text == key then
        scriptActivated = true
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "DAN's UltraGodMode V7 Activated",
            Text = "Ключ '67' принят! Aimbot + Kill Aura + ESP + No Recoil + Infinite Ammo + Speedhack + Godmode запущены! 😈",
            Duration = 7
        })
        print("Gunfight Arena UltraGodMode V7 Activated! By DAN")
    end
end

-- Антидетект: Жёсткий байпас античита
local function anticheatBypass()
    if not scriptActivated then return end
    -- Убираем forcefields и делаем врагов видимыми
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("ForceField") then
                    part:Destroy() -- Удаляем щиты
                end
                if part:IsA("BasePart") then
                    part.Transparency = 0.5 -- ESP
                    part.Size = part.Size * 1.7 -- Hitbox expander
                    part.CanCollide = false -- Игнор стен
                end
            end
        end
    end
    -- Маскировка: пинг, параметры, анти-spam
    local fakePing = math.random(20, 80)
    game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:SetValue(fakePing)
    if LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Маскируем для античита
        LocalPlayer.Character.Humanoid.JumpPower = 50
        -- Имитация легитного здоровья
        local humanoid = LocalPlayer.Character.Humanoid
        if humanoid then
            humanoid.Health = math.clamp(humanoid.Health, humanoid.MaxHealth - 5, humanoid.MaxHealth)
        end
    end
    -- Отключаем клиентские античит-скрипты
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Script") or v:IsA("ModuleScript") then
            if v.Name:lower():find("anti") or v.Name:lower():find("cheat") or v.Name:lower():find("detect") then
                v.Disabled = true
            end
        end
    end
end

-- Godmode: Бессмертие
local function enableGodmode()
    if not scriptActivated then return end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        -- Байпас урона
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < math.huge then
                humanoid.Health = math.huge
            end
        end)
        -- Отключаем проверки смерти
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("Script") and v.Name:lower():find("damage") or v.Name:lower():find("health") then
                v.Disabled = true
            end
        end
    end
end

-- No Recoil: Отключаем отдачу
local function disableRecoil()
    if not scriptActivated then return end
    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if weapon then
        for _, v in pairs(weapon:GetDescendants()) do
            if v:IsA("ModuleScript") or v:IsA("Script") then
                if v.Name:lower():find("recoil") or v.Name:lower():find("camera") then
                    v.Disabled = true
                end
            end
        end
        local config = weapon:FindFirstChild("Configuration") or weapon:FindFirstChild("Config")
        if config then
            for _, setting in pairs(config:GetChildren()) do
                if setting.Name:lower():find("recoil") or setting.Name:lower():find("kick") then
                    if setting:IsA("NumberValue") or setting:IsA("IntValue") then
                        setting.Value = 0
                    end
                end
            end
        end
    end
end

-- Infinite Ammo: Бесконечные патроны
local function infiniteAmmo()
    if not scriptActivated then return end
    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if weapon then
        for _, v in pairs(weapon:GetDescendants()) do
            if v.Name:lower():find("ammo") or v.Name:lower():find("magazine") then
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    v.Value = math.huge
                end
            end
        end
        local ammoRemote = ReplicatedStorage:FindFirstChild("Reload") or weapon:FindFirstChild("Reload")
        if ammoRemote and ammoRemote:IsA("RemoteEvent") then
            pcall(function()
                ammoRemote:FireServer(math.huge)
            end)
        end
    end
end

-- Speedhack: Быстрая беготня
local speedEnabled = false
local function toggleSpeedhack()
    if not scriptActivated then return end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedEnabled and 55 or 16
    end
end

-- Silent Aimbot: Прицел на ближайшего врага
local function getClosestEnemy()
    if not scriptActivated then return end
    local closest, dist = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
            if not LocalPlayer.Team or player.Team ~= LocalPlayer.Team then
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
    end
    return closest
end

-- Kill Aura: Автострельба через стены
local function autoKillAll()
    if not scriptActivated then return end
    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if weapon then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if not LocalPlayer.Team or player.Team ~= LocalPlayer.Team then
                    local targetHead = player.Character.Head.Position
                    local args = {
                        [1] = player.Character.Humanoid,
                        [2] = targetHead + Vector3.new(math.random(-1.2, 1.2), math.random(-0.4, 0.4), math.random(-1.2, 1.2)),
                        [3] = 10000, -- Инстант-килл
                        [4] = "Head",
                        [5] = weapon
                    }
                    local remotes = {"Damage", "HitRemote", "ShootEvent", "GunDamage", "BulletHit"}
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
end

-- Silent Aimbot: Хук камеры
local aimbotActive = false -- Отключено до ввода ключа
RunService.RenderStepped:Connect(function()
    if not scriptActivated or not aimbotActive then return end
    local target = getClosestEnemy()
    if target and target.Character then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
    end
end)

-- Тоггл для Speedhack
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.G then -- G для скорости
        speedEnabled = not speedEnabled
        toggleSpeedhack()
    end
end)

-- Основной цикл
local lastShot = 0
RunService.Heartbeat:Connect(function()
    if not scriptActivated then return end
    if tick() - lastShot >= 0.07 then -- Тайминг для античита
        anticheatBypass() -- Жёсткий байпас + ESP
        enableGodmode() -- Бессмертие
        disableRecoil() -- Без отдачи
        infiniteAmmo() -- Бесконечные патроны
        autoKillAll() -- Авто-килл
        if speedEnabled then toggleSpeedhack() end -- Поддержка скорости
        lastShot = tick()
        aimbotActive = true -- Включаем aimbot после активации
    end
end)

-- Начальное уведомление
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "DAN's Gunfight Arena UltraGodMode V7",
    Text = "Введите ключ '67' в чат для активации! 😈",
    Duration = 10
})

print("Gunfight Arena Script V7 Loaded! By DAN - Введите '67' в чат!")

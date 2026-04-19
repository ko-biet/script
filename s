-- FULL FIX: Remove Map + Keep Nearby Mob + FPS Text Only

repeat task.wait() until game:IsLoaded()
task.wait(2)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local DISTANCE = 200 -- chỉnh khoảng cách mob

-- ================= FPS TEXT (KHÔNG NỀN) =================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local FPSLabel = Instance.new("TextLabel", ScreenGui)
FPSLabel.Size = UDim2.new(0, 100, 0, 30)
FPSLabel.Position = UDim2.new(0, 10, 0, 10)
FPSLabel.BackgroundTransparency = 1 -- ❌ bỏ nền
FPSLabel.TextColor3 = Color3.fromRGB(0,255,0)
FPSLabel.TextScaled = true
FPSLabel.Font = Enum.Font.SourceSansBold
FPSLabel.Text = "FPS: ..."

local fps = 0
local last = tick()

RunService.RenderStepped:Connect(function()
    fps += 1
    if tick() - last >= 1 then
        FPSLabel.Text = "FPS: "..fps
        fps = 0
        last = tick()
    end
end)

-- ================= CHECK =================
local function isPlayerModel(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function isMob(model)
    return model:FindFirstChild("Humanoid") and not isPlayerModel(model)
end

local function getPlayerPos()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return LocalPlayer.Character.HumanoidRootPart.Position
    end
end

-- ================= 1. XÓA MAP =================
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
        local model = v:FindFirstAncestorOfClass("Model")
        if not model or (not isPlayerModel(model) and not isMob(model)) then
            v:Destroy()
        end
    end
end

-- ================= 2. GIỮ MOB GẦN =================
task.spawn(function()
    while true do
        task.wait(2)
        
        local playerPos = getPlayerPos()
        if not playerPos then continue end
        
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and isMob(v) then
                local hrp = v:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distance = (hrp.Position - playerPos).Magnitude
                    if distance > DISTANCE then
                        v:Destroy()
                    end
                end
            end
        end
    end
end)

print("🔥 FIXED: Map removed + Mob gần + FPS text only")

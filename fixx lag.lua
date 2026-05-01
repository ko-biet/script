repeat task.wait() until game:IsLoaded()

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ================= XÓA LIGHT NHẸ =================
task.spawn(function()
    for _,v in pairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect")
        or v:IsA("BlurEffect")
        or v:IsA("ColorCorrectionEffect")
        or v:IsA("SunRaysEffect")
        or v:IsA("DepthOfFieldEffect")
        or v:IsA("Atmosphere")
        or v:IsA("Sky") then
            v:Destroy()
        end
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 999999999
    Lighting.Brightness = 0
end)

-- ================= XỬ LÝ MAP MƯỢT =================
task.spawn(function()
    local objects = game:GetDescendants()
    for i = 1, #objects do
        local v = objects[i]

        pcall(function()
            if v:IsA("ParticleEmitter")
            or v:IsA("Trail")
            or v:IsA("Beam")
            or v:IsA("Smoke")
            or v:IsA("Fire")
            or v:IsA("Sparkles") then
                v:Destroy()
            end

            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            end

            if v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end)

        if i % 100 == 0 then
            task.wait()
        end
    end
end)

-- ================= AUTO XÓA EFFECT =================
game.DescendantAdded:Connect(function(v)
    task.spawn(function()
        pcall(function()
            if v:IsA("ParticleEmitter")
            or v:IsA("Trail")
            or v:IsA("Beam")
            or v:IsA("Smoke")
            or v:IsA("Fire")
            or v:IsA("Sparkles")
            or v:IsA("Explosion") then
                v:Destroy()
            end
        end)
    end)
end)

-- ================= FPS ULTRA PRO =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- LOAD SAVED POS
local savedX = 0.5
pcall(function()
    if readfile and isfile and isfile("fps_pos.txt") then
        savedX = tonumber(readfile("fps_pos.txt")) or 0.5
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local FpsText = Instance.new("TextLabel", ScreenGui)
FpsText.AnchorPoint = Vector2.new(0.5, 0)
FpsText.Position = UDim2.new(savedX, 0, 0, 0)
FpsText.Size = UDim2.new(0, 110, 0, 45)
FpsText.BackgroundTransparency = 1
FpsText.TextScaled = true
FpsText.Font = Enum.Font.GothamBold
FpsText.Text = "..."

-- GLOW
local Stroke = Instance.new("UIStroke", FpsText)
Stroke.Thickness = 2
Stroke.Transparency = 0.5

-- FPS
local frames = 0
local last = tick()
local hue = 0

-- DRAG
local dragging = false
local startPos
local velocity = 0
local currentX = savedX

-- TOUCH START
FpsText.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPos = input.Position
        velocity = 0
    end
end)

-- TOUCH END
FpsText.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false

        -- SAVE POS
        pcall(function()
            if writefile then
                writefile("fps_pos.txt", tostring(currentX))
            end
        end)
    end
end)

-- MOVE
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - startPos
        startPos = input.Position

        velocity = delta.X * 0.002
        currentX += velocity

        currentX = math.clamp(currentX, 0.05, 0.95)
        FpsText.Position = UDim2.new(currentX, 0, 0, 0)
    end
end)

-- 2 NGÓN RESET
UIS.TouchTap:Connect(function(touches)
    if #touches >= 2 then
        currentX = 0.5
        FpsText.Position = UDim2.new(0.5, 0, 0, 0)

        pcall(function()
            if writefile then
                writefile("fps_pos.txt", tostring(currentX))
            end
        end)
    end
end)

-- UPDATE
RunService.RenderStepped:Connect(function()
    -- FPS
    frames += 1
    if tick() - last >= 1 then
        local fps = frames
        FpsText.Text = tostring(fps)
        frames = 0
        last = tick()

        -- AUTO COLOR FPS
        if fps >= 50 then
            FpsText.TextColor3 = Color3.fromRGB(0,255,0)
        elseif fps >= 30 then
            FpsText.TextColor3 = Color3.fromRGB(255,255,0)
        else
            FpsText.TextColor3 = Color3.fromRGB(255,0,0)
        end
    end

    -- RAINBOW OVERLAY
    hue += 0.01
    if hue > 1 then hue = 0 end
    Stroke.Color = Color3.fromHSV(hue, 1, 1)

    -- INERTIA
    if not dragging and math.abs(velocity) > 0.0001 then
        currentX += velocity
        velocity *= 0.95

        currentX = math.clamp(currentX, 0.05, 0.95)
        FpsText.Position = UDim2.new(currentX, 0, 0, 0)
    end
end)
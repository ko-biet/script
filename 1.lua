-- ==================== KHỞI TẠO GAME (CHẠY ĐẦU TIÊN) ====================
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Trì hoãn 5 giây để game load mượt mà toàn bộ tài nguyên hệ thống
task.wait(5)

-- ==================== LOADSTRING SCRIPT CHÍNH ====================
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ko-biet/att/refs/heads/main/att%20blox%20fruit.txt"))()
end)

-- ==================== CẤU HÌNH PHE CHỌN TỰ ĐỘNG ====================
-- Điền "Pirates" nếu muốn làm Hải Tặc hoặc "Marines" nếu muốn làm Hải Quân
local PheMuonChon = "Pirates" 

-- ==================== TỰ ĐỘNG VƯỢT MÀN HÌNH CHỜ CHỌN PHE ====================
task.spawn(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)
    if not PlayerGui then return end

    print("[Gemini Hub]: Đang quét và chuẩn bị tự động chọn phe...")

    while true do
        if LocalPlayer.Team == nil or LocalPlayer.Team.Name == "Neutral" then
            pcall(function()
                local MainGui = PlayerGui:FindFirstChild("Main")
                if MainGui then
                    local ChooseTeamFrame = MainGui:FindFirstChild("ChooseTeam") or MainGui:FindFirstChild("TeamFrame")
                    if ChooseTeamFrame and ChooseTeamFrame.Visible then
                        local Container = ChooseTeamFrame:FindFirstChild("Container") or ChooseTeamFrame
                        local Button = Container:FindFirstChild(PheMuonChon) or Container:FindFirstChild(PheMuonChon .. "Btn")
                        
                        if Button then
                            print("[Gemini Hub]: Kích hoạt giả lập Click nút chọn phe...")
                            for _, connection in pairs(getconnections(Button.MouseButton1Click)) do
                                connection:Fire()
                            end
                            for _, connection in pairs(getconnections(Button.MouseButton1Down)) do
                                connection:Fire()
                            end
                            for _, connection in pairs(getconnections(Button.Activated)) do
                                connection:Fire()
                            end
                        end
                    end
                end
                -- Gói tin dự phòng kích hoạt song song
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", PheMuonChon)
            end)
        else
            print("[Gemini Hub]: Đã vào game thành công! Phe: " .. LocalPlayer.Team.Name)
            break
        end
        task.wait(1)
    end
end)

-- Chờ nhân vật được khởi tạo hoàn chỉnh trước khi khởi chạy các vòng lặp tính năng
repeat task.wait() until game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- ==================== DỊCH VỤ HỆ THỐNG ====================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ==================== CẤU HÌNH TÍNH NĂNG HUB ====================
getgenv().AutoFarm = true
getgenv().BringMonster = true            -- Hút quái (Magnet)
getgenv().AutoTPtoSpawn = true           -- Tự bay về bãi spawn khi hết quái
getgenv().MonsterTimeout = 5             -- Bỏ qua quái lỗi nếu không mất máu sau 5 giây
getgenv().MagnetRadius = 500             -- Bán kính gom quái rộng rãi, tối ưu hóa tốc độ gom
getgenv().NoClip = true                  -- Bật xuyên tường tránh kẹt địa hình

-- CẤU HÌNH TỰ ĐỘNG CỘNG ĐIỂM CHỈ SỐ (STATS)
getgenv().AutoStats = true
getgenv().StatsToUpgrade = {"Melee", "Defense", "Blox Fruit"} -- Ưu tiên nâng Melee, Defense, và Blox Fruit

-- CẤU HÌNH TIỆN ÍCH TRÁI ÁC QUỶ
_G.AutoRandomFruits = true              -- Tự động Gacha trái ác quỷ khi hồi thời gian
_G.AutoStoreFruit   = true              -- Tự động cất giấu trái ác quỷ vào kho lưu trữ

-- ==================== CHỐNG BỊ KICK (ANTI-AFK) ====================
pcall(function()
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        print("[Gemini Hub]: Đã kích hoạt Anti-AFK ngăn chặn ngắt kết nối Server!")
    end)
end)

-- ==================== TỰ ĐỘNG GACHA TRÁI ÁC QUỶ ====================
task.spawn(function()
    while true do
        task.wait(5)
        if _G.AutoRandomFruits then
            pcall(function()
                local result = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin", "Buy")
                if result then
                    print("[Gemini Hub]: Thực hiện Gacha Trái Ác Quỷ thành công!")
                end
            end)
            task.wait(300) -- Check lại sau mỗi 5 phút hoặc tự chỉnh thành 7200 nếu muốn canh chuẩn 2 tiếng
        end
    end
end)

-- ==================== TỰ ĐỘNG KHÓA CẤT TRÁI ÁC QUỶ VÀO KHO ====================
task.spawn(function()
    local plr = Players.LocalPlayer
    while true do
        task.wait(1)
        if _G.AutoStoreFruit then
            pcall(function()
                -- Quét trong Backpack
                local backpack = plr:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool:GetAttribute("OriginalName") then
                            local fruitName = tool:GetAttribute("OriginalName")
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", fruitName, tool)
                            print("[Gemini Hub]: Đã lưu trữ trái ác quỷ từ Túi đồ: " .. tostring(fruitName))
                            task.wait(0.5)
                        end
                    end
                end
                -- Quét trên tay nhân vật (Character)
                local char = plr.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") and tool:GetAttribute("OriginalName") then
                            local fruitName = tool:GetAttribute("OriginalName")
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", fruitName, tool)
                            print("[Gemini Hub]: Đã lưu trữ trái ác quỷ từ Nhân vật: " .. tostring(fruitName))
                            task.wait(0.5)
                        end
                    end
                end
            end)
        end
    end
end)

-- ==================== TỰ ĐỘNG CỘNG ĐIỂM CHỈ SỐ (AUTO STATS) ====================
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().AutoStats then
            pcall(function()
                local points = Player.Data.Points.Value
                if points > 0 then
                    local stats = getgenv().StatsToUpgrade or {"Melee", "Defense", "Blox Fruit"}
                    if #stats > 0 then
                        local pointsPerStat = math.floor(points / #stats)
                        if pointsPerStat > 0 then
                            for _, stat in ipairs(stats) do
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stat, pointsPerStat)
                            end
                        else
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stats[1], points)
                        end
                    end
                end
            end)
        end
    end
end)

-- ==================== CƠ SỞ DỮ LIỆU QUEST & QUÁI (SEA 1 -> SEA 3) ====================
local Mon, NameQuest, LevelQuest, NameMon, CFrameQuest, CFrameMon

function CheckQuest()
    local lvl = Player.Data.Level.Value
    local TeamSelf = Player.Team and Player.Team.Name or "Pirates"
    
    -- ------------------ DỮ LIỆU ĐẢO SEA 1 ------------------
    if lvl <= 9 then
        if TeamSelf == "Marines" then
            Mon = "Trainee" NameQuest = "MarineQuest" LevelQuest = 1 NameMon = "Trainee"
            CFrameQuest = CFrame.new(-2709.67944,24.5206585,2104.24585) CFrameMon = CFrame.new(-2709.67944,24.5206585,2104.24585)
        else
            Mon = "Bandit" NameQuest = "BanditQuest1" LevelQuest = 1 NameMon = "Bandit"
            CFrameQuest = CFrame.new(1045.9626464844,27.002508163452,1560.8203125) CFrameMon = CFrame.new(1045.9626464844,27.002508163452,1560.8203125)
        end
    elseif lvl >= 10 and lvl <= 14 then
        Mon = "Monkey" NameQuest = "JungleQuest" LevelQuest = 1 NameMon = "Monkey"
        CFrameQuest = CFrame.new(-1598.08911,35.5501175,153.377838) CFrameMon = CFrame.new(-1448.5180664062,67.853012084961,11.465796470642)
    elseif lvl >= 15 and lvl <= 29 then
        Mon = "Gorilla" NameQuest = "JungleQuest" LevelQuest = 2 NameMon = "Gorilla"
        CFrameQuest = CFrame.new(-1598.08911,35.5501175,153.377838) CFrameMon = CFrame.new(-1129.8836669922,40.46354675293,-525.42370605469)
    elseif lvl >= 30 and lvl <= 39 then
        Mon = "Pirate" NameQuest = "BuggyQuest1" LevelQuest = 1 NameMon = "Pirate"
        CFrameQuest = CFrame.new(-1141.07483,4.10001802,3831.5498) CFrameMon = CFrame.new(-1103.5134277344,13.752052307129,3896.0910644531)
    elseif lvl >= 40 and lvl <= 59 then
        Mon = "Brute" NameQuest = "BuggyQuest1" LevelQuest = 2 NameMon = "Brute"
        CFrameQuest = CFrame.new(-1141.07483,4.10001802,3831.5498) CFrameMon = CFrame.new(-1140.0837402344,14.809885025024,4322.9213867188)
    elseif lvl >= 60 and lvl <= 74 then
        Mon = "Desert Bandit" NameQuest = "DesertQuest" LevelQuest = 1 NameMon = "Desert Bandit"
        CFrameQuest = CFrame.new(894.488647,5.14000702,4392.43359) CFrameMon = CFrame.new(924.7998046875,6.4486746788025,4481.5859375)
    elseif lvl >= 75 and lvl <= 89 then
        Mon = "Desert Officer" NameQuest = "DesertQuest" LevelQuest = 2 NameMon = "Desert Officer"
        CFrameQuest = CFrame.new(894.488647,5.14000702,4392.43359) CFrameMon = CFrame.new(1608.2822265625,8.6142244338989,4371.0073242188)
    elseif lvl >= 90 and lvl <= 99 then
        Mon = "Snow Bandit" NameQuest = "SnowQuest" LevelQuest = 1 NameMon = "Snow Bandit"
        CFrameQuest = CFrame.new(1389.74451,88.1519318,-1298.90796) CFrameMon = CFrame.new(1354.3479003906,87.272773742676,-1393.9465332031)
    elseif lvl >= 100 and lvl <= 119 then
        Mon = "Snowman" NameQuest = "SnowQuest" LevelQuest = 2 NameMon = "Snowman"
        CFrameQuest = CFrame.new(1389.74451,88.1519318,-1298.90796) CFrameMon = CFrame.new(1200,144,-1550)
    elseif lvl >= 120 and lvl <= 149 then
        Mon = "Chief Petty Officer" NameQuest = "MarineQuest2" LevelQuest = 1 NameMon = "Chief Petty Officer"
        CFrameQuest = CFrame.new(-5039.58643,27.3500385,4324.68018) CFrameMon = CFrame.new(-4881.2309570312,22.652044296265,4273.7524414062)
    elseif lvl >= 150 and lvl <= 174 then
        Mon = "Sky Bandit" NameQuest = "SkyQuest" LevelQuest = 1 NameMon = "Sky Bandit"
        CFrameQuest = CFrame.new(-4839.53027,716.368591,-2619.44165) CFrameMon = CFrame.new(-4953.20703125,295.74420166016,-2899.2290039062)
    elseif lvl >= 175 and lvl <= 189 then
        Mon = "Dark Master" NameQuest = "SkyQuest" LevelQuest = 2 NameMon = "Dark Master"
        CFrameQuest = CFrame.new(-4839.53027,716.368591,-2619.44165) CFrameMon = CFrame.new(-5259.8447265625,391.39767456055,-2229.0354003906)
    elseif lvl >= 190 and lvl <= 209 then
        Mon = "Prisoner" NameQuest = "PrisonerQuest" LevelQuest = 1 NameMon = "Prisoner"
        CFrameQuest = CFrame.new(5308.93115,1.65517521,475.120514) CFrameMon = CFrame.new(5098.9736328125,-0.3204058110714,474.23733520508)
    elseif lvl >= 210 and lvl <= 249 then
        Mon = "Dangerous Prisoner" NameQuest = "PrisonerQuest" LevelQuest = 2 NameMon = "Dangerous Prisoner"
        CFrameQuest = CFrame.new(5308.93115,1.65517521,475.120514) CFrameMon = CFrame.new(5654.5634765625,15.633401870728,866.29919433594)
    elseif lvl >= 250 and lvl <= 274 then
        Mon = "Toga Warrior" NameQuest = "ColosseumQuest" LevelQuest = 1 NameMon = "Toga Warrior"
        CFrameQuest = CFrame.new(-1580.04663,6.35000277,-2986.47534) CFrameMon = CFrame.new(-1820.21484375,51.683856964111,-2740.6650390625)
    elseif lvl >= 275 and lvl <= 299 then
        Mon = "Gladiator" NameQuest = "ColosseumQuest" LevelQuest = 2 NameMon = "Gladiator"
        CFrameQuest = CFrame.new(-1580.04663,6.35000277,-2986.47534) CFrameMon = CFrame.new(-1292.8381347656,56.380882263184,-3339.0314941406)
    elseif lvl >= 300 and lvl <= 324 then
        Mon = "Military Soldier" NameQuest = "MagmaQuest" LevelQuest = 1 NameMon = "Military Soldier"
        CFrameQuest = CFrame.new(-5313.37012,10.9500084,8515.29395) CFrameMon = CFrame.new(-5411.1645507812,11.081554412842,8454.29296875)
    elseif lvl >= 325 and lvl <= 374 then
        Mon = "Military Spy" NameQuest = "MagmaQuest" LevelQuest = 2 NameMon = "Military Spy"
        CFrameQuest = CFrame.new(-5313.37012,10.9500084,8515.29395) CFrameMon = CFrame.new(-5802.8681640625,86.262413024902,8828.859375)
    elseif lvl >= 375 and lvl <= 399 then
        Mon = "Fishman Warrior" NameQuest = "FishmanQuest" LevelQuest = 1 NameMon = "Fishman Warrior"
        CFrameQuest = CFrame.new(61122.65234375,18.497442245483,1569.3997802734) CFrameMon = CFrame.new(60878.30078125,18.482830047607,1543.7574462891)
    elseif lvl >= 400 and lvl <= 449 then
        Mon = "Fishman Commando" NameQuest = "FishmanQuest" LevelQuest = 2 NameMon = "Fishman Commando"
        CFrameQuest = CFrame.new(61122.65234375,18.497442245483,1569.3997802734) CFrameMon = CFrame.new(61922.6328125,18.482830047607,1493.9343261719)
    elseif lvl >= 450 and lvl <= 474 then
        Mon = "God's Guard" NameQuest = "SkyExp1Quest" LevelQuest = 1 NameMon = "God's Guard"
        CFrameQuest = CFrame.new(-4721.88867,843.874695,-1949.96643) CFrameMon = CFrame.new(-4710.04296875,845.27697753906,-1927.3079833984)
    elseif lvl >= 475 and lvl <= 524 then
        Mon = "Shanda" NameQuest = "SkyExp1Quest" LevelQuest = 2 NameMon = "Shanda"
        CFrameQuest = CFrame.new(-7859.09814,5544.19043,-381.476196) CFrameMon = CFrame.new(-7678.4897460938,5566.4038085938,-497.21560668945)
    elseif lvl >= 525 and lvl <= 549 then
        Mon = "Royal Squad" NameQuest = "SkyExp2Quest" LevelQuest = 1 NameMon = "Royal Squad"
        CFrameQuest = CFrame.new(-7906.81592,5634.6626,-1411.99194) CFrameMon = CFrame.new(-7624.2524414062,5658.1333007812,-1467.3542480469)
    elseif lvl >= 550 and lvl <= 624 then
        Mon = "Royal Soldier" NameQuest = "SkyExp2Quest" LevelQuest = 2 NameMon = "Royal Soldier"
        CFrameQuest = CFrame.new(-7906.81592,5634.6626,-1411.99194) CFrameMon = CFrame.new(-7836.7534179688,5645.6640625,-1790.6236572266)
    elseif lvl >= 625 and lvl <= 649 then
        Mon = "Galley Pirate" NameQuest = "FountainQuest" LevelQuest = 1 NameMon = "Galley Pirate"
        CFrameQuest = CFrame.new(5259.81982,37.3500175,4050.0293) CFrameMon = CFrame.new(5551.0219726562,78.901351928711,3930.4128417969)
    elseif lvl >= 650 and lvl <= 699 then
        Mon = "Galley Captain" NameQuest = "FountainQuest" LevelQuest = 2 NameMon = "Galley Captain"
        CFrameQuest = CFrame.new(5259.81982,37.3500175,4050.0293) CFrameMon = CFrame.new(5441.9516601562,42.502059936523,4950.09375)

    -- ------------------ DỮ LIỆU ĐẢO SEA 2 ------------------
    elseif lvl >= 700 and lvl <= 724 then
        Mon = "Raider" NameQuest = "Area1Quest" LevelQuest = 1 NameMon = "Raider"
        CFrameQuest = CFrame.new(-427.726, 72.996, 1836.182) CFrameMon = CFrame.new(68.875, 93.636, 2429.675)
    elseif lvl >= 725 and lvl <= 774 then
        Mon = "Mercenary" NameQuest = "Area1Quest" LevelQuest = 2 NameMon = "Mercenary"
        CFrameQuest = CFrame.new(-427.726, 72.996, 1836.182) CFrameMon = CFrame.new(-864.850, 122.471, 1453.151)
    elseif lvl >= 775 and lvl <= 799 then
        Mon = "Swan Pirate" NameQuest = "Area2Quest" LevelQuest = 1 NameMon = "Swan Pirate"
        CFrameQuest = CFrame.new(638.438, 71.770, 918.283) CFrameMon = CFrame.new(1068.664, 137.614, 1322.106)
    elseif lvl >= 800 and lvl <= 874 then
        Mon = "Factory Staff" NameQuest = "Area2Quest" LevelQuest = 2 NameMon = "Factory Staff"
        CFrameQuest = CFrame.new(632.699, 73.106, 918.666) CFrameMon = CFrame.new(73.079, 81.863, -27.471)
    elseif lvl >= 875 and lvl <= 899 then
        Mon = "Marine Lieutenant" NameQuest = "MarineQuest3" LevelQuest = 1 NameMon = "Marine Lieutenant"
        CFrameQuest = CFrame.new(-2440.796, 71.714, -3216.068) CFrameMon = CFrame.new(-2821.372, 75.897, -3070.089)
    elseif lvl >= 900 and lvl <= 949 then
        Mon = "Marine Captain" NameQuest = "MarineQuest3" LevelQuest = 2 NameMon = "Marine Captain"
        CFrameQuest = CFrame.new(-2440.796, 71.714, -3216.068) CFrameMon = CFrame.new(-1861.231, 80.177, -3254.698)
    elseif lvl >= 950 and lvl <= 974 then
        Mon = "Zombie" NameQuest = "ZombieQuest" LevelQuest = 1 NameMon = "Zombie"
        CFrameQuest = CFrame.new(-5497.062, 47.592, -795.237) CFrameMon = CFrame.new(-5657.777, 78.970, -928.687)
    elseif lvl >= 975 and lvl <= 999 then
        Mon = "Vampire" NameQuest = "ZombieQuest" LevelQuest = 2 NameMon = "Vampire"
        CFrameQuest = CFrame.new(-5497.062, 47.592, -795.237) CFrameMon = CFrame.new(-6037.668, 32.185, -1340.660)
    elseif lvl >= 1000 and lvl <= 1049 then
        Mon = "Snow Trooper" NameQuest = "SnowMountainQuest" LevelQuest = 1 NameMon = "Snow Trooper"
        CFrameQuest = CFrame.new(609.859, 400.120, -5372.259) CFrameMon = CFrame.new(549.147, 427.387, -5563.699)
    elseif lvl >= 1050 and lvl <= 1099 then
        Mon = "Winter Warrior" NameQuest = "SnowMountainQuest" LevelQuest = 2 NameMon = "Winter Warrior"
        CFrameQuest = CFrame.new(609.859, 400.120, -5372.259) CFrameMon = CFrame.new(1142.745, 475.640, -5199.417)
    elseif lvl >= 1100 and lvl <= 1124 then
        Mon = "Lab Subordinate" NameQuest = "IceSideQuest" LevelQuest = 1 NameMon = "Lab Subordinate"
        CFrameQuest = CFrame.new(-6064.069, 15.242, -4902.979) CFrameMon = CFrame.new(-5707.472, 15.952, -4513.392)
    elseif lvl >= 1125 and lvl <= 1174 then
        Mon = "Horned Warrior" NameQuest = "IceSideQuest" LevelQuest = 2 NameMon = "Horned Warrior"
        CFrameQuest = CFrame.new(-6064.069, 15.242, -4902.979) CFrameMon = CFrame.new(-6341.367, 15.952, -5723.162)
    elseif lvl >= 1175 and lvl <= 1199 then
        Mon = "Magma Ninja" NameQuest = "FireSideQuest" LevelQuest = 1 NameMon = "Magma Ninja"
        CFrameQuest = CFrame.new(-5428.032, 15.062, -5299.435) CFrameMon = CFrame.new(-5449.673, 76.659, -5808.201)
    elseif lvl >= 1200 and lvl <= 1249 then
        Mon = "Lava Pirate" NameQuest = "FireSideQuest" LevelQuest = 2 NameMon = "Lava Pirate"
        CFrameQuest = CFrame.new(-5428.032, 15.062, -5299.435) CFrameMon = CFrame.new(-2213.332, 49.738, -4701.451)
    elseif lvl >= 1250 and lvl <= 1274 then
        Mon = "Ship Deckhand" NameQuest = "ShipQuest1" LevelQuest = 1 NameMon = "Ship Deckhand"
        CFrameQuest = CFrame.new(1037.801, 125.092, 32911.602) CFrameMon = CFrame.new(1212.011, 150.792, 33059.246)
        if getgenv().AutoFarm and Character and Character:FindFirstChild("HumanoidRootPart") and (CFrameMon.Position - Character.HumanoidRootPart.Position).Magnitude > 5000 then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.213, 126.976, 32852.832))
        end
    elseif lvl >= 1275 and lvl <= 1299 then
        Mon = "Ship Engineer" NameQuest = "ShipQuest1" LevelQuest = 2 NameMon = "Ship Engineer"
        CFrameQuest = CFrame.new(1037.801, 125.092, 32911.602) CFrameMon = CFrame.new(919.479, 43.544, 32779.969)
        if getgenv().AutoFarm and Character and Character:FindFirstChild("HumanoidRootPart") and (CFrameMon.Position - Character.HumanoidRootPart.Position).Magnitude > 5000 then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.213, 126.976, 32852.832))
        end
    elseif lvl >= 1300 and lvl <= 1324 then
        Mon = "Ship Steward" NameQuest = "ShipQuest2" LevelQuest = 1 NameMon = "Ship Steward"
        CFrameQuest = CFrame.new(968.810, 125.092, 33244.125) CFrameMon = CFrame.new(919.439, 129.556, 33436.035)
        if getgenv().AutoFarm and Character and Character:FindFirstChild("HumanoidRootPart") and (CFrameMon.Position - Character.HumanoidRootPart.Position).Magnitude > 5000 then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.213, 126.976, 32852.832))
        end
    elseif lvl >= 1325 and lvl <= 1349 then
        Mon = "Ship Officer" NameQuest = "ShipQuest2" LevelQuest = 2 NameMon = "Ship Officer"
        CFrameQuest = CFrame.new(968.810, 125.092, 33244.125) CFrameMon = CFrame.new(1036.018, 181.439, 33315.727)
        if getgenv().AutoFarm and Character and Character:FindFirstChild("HumanoidRootPart") and (CFrameMon.Position - Character.HumanoidRootPart.Position).Magnitude > 5000 then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.213, 126.976, 32852.832))
        end
    elseif lvl >= 1350 and lvl <= 1374 then
        Mon = "Arctic Warrior" NameQuest = "FrostQuest" LevelQuest = 1 NameMon = "Arctic Warrior"
        CFrameQuest = CFrame.new(5667.658, 26.800, -6486.090) CFrameMon = CFrame.new(5966.246, 62.970, -6179.383)
        if getgenv().AutoFarm and Character and Character:FindFirstChild("HumanoidRootPart") and (CFrameMon.Position - Character.HumanoidRootPart.Position).Magnitude > 5000 then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-6508.558, 5000.035, -132.840))
        end
    elseif lvl >= 1375 and lvl <= 1424 then
        Mon = "Snow Lurker" NameQuest = "FrostQuest" LevelQuest = 2 NameMon = "Snow Lurker"
        CFrameQuest = CFrame.new(5667.658, 26.800, -6486.090) CFrameMon = CFrame.new(5407.074, 69.194, -6880.880)
    elseif lvl >= 1425 and lvl <= 1449 then
        Mon = "Sea Soldier" NameQuest = "ForgottenQuest" LevelQuest = 1 NameMon = "Sea Soldier"
        CFrameQuest = CFrame.new(-3054.445, 235.544, -10142.819) CFrameMon = CFrame.new(-3028.224, 64.675, -9775.427)
    elseif lvl >= 1450 and lvl <= 1523 then
        Mon = "Water Fighter" NameQuest = "ForgottenQuest" LevelQuest = 2 NameMon = "Water Fighter"
        CFrameQuest = CFrame.new(-3054.583, 240, -10146.0) CFrameMon = CFrame.new(-3262.930, 298.690, -10552.529)

    -- ------------------ DỮ LIỆU ĐẢO SEA 3 ------------------
    elseif lvl >= 1524 and lvl <= 1524 then
        Mon = "Pirate Millionaire" NameQuest = "PiratePortQuest" LevelQuest = 1 NameMon = "Pirate Millionaire"
        CFrameQuest = CFrame.new(-290.07, 42.90, 5581.59) CFrameMon = CFrame.new(-246.00, 47.31, 5584.10)
    elseif lvl >= 1525 and lvl <= 1574 then
        Mon = "Pistol Billionaire" NameQuest = "PiratePortQuest" LevelQuest = 2 NameMon = "Pistol Billionaire"
        CFrameQuest = CFrame.new(-290.07, 42.90, 5581.59) CFrameMon = CFrame.new(-187.33, 86.24, 6013.51)
    elseif lvl >= 1575 and lvl <= 1599 then
        Mon = "Dragon Crew Warrior" NameQuest = "DragonCrewQuest" LevelQuest = 1 NameMon = "Dragon Crew Warrior"
        CFrameQuest = CFrame.new(6737.06055, 127.417763, -712.300659) CFrameMon = CFrame.new(6709.76367, 52.3442993, -1139.02966)
    elseif lvl >= 1600 and lvl <= 1624 then
        Mon = "Dragon Crew Archer" NameQuest = "DragonCrewQuest" LevelQuest = 2 NameMon = "Dragon Crew Archer"
        CFrameQuest = CFrame.new(6737.06055, 127.417763, -712.300659) CFrameMon = CFrame.new(6668.76172, 481.376923, 329.12207)
    elseif lvl >= 1625 and lvl <= 1649 then
        Mon = "Hydra Enforcer" NameQuest = "VenomCrewQuest" LevelQuest = 1 NameMon = "Hydra Enforcer"
        CFrameQuest = CFrame.new(5206.40185546875, 1004.10498046875, 748.3504638671875) CFrameMon = CFrame.new(4547.11523, 1003.10217, 334.194824)
    elseif lvl >= 1650 and lvl <= 1699 then
        Mon = "Venomous Assailant" NameQuest = "VenomCrewQuest" LevelQuest = 2 NameMon = "Venomous Assailant"
        CFrameQuest = CFrame.new(5206.40185546875, 1004.10498046875, 748.3504638671875) CFrameMon = CFrame.new(4674.92676, 1134.82654, 996.308838)
    elseif lvl >= 1700 and lvl <= 1724 then
        Mon = "Marine Commodore" NameQuest = "MarineTreeIsland" LevelQuest = 1 NameMon = "Marine Commodore"
        CFrameQuest = CFrame.new(2482, 74, -6788) CFrameMon = CFrame.new(2519, 109, -7633)
    elseif lvl >= 1725 and lvl <= 1774 then
        Mon = "Marine Rear Admiral" NameQuest = "MarineTreeIsland" LevelQuest = 2 NameMon = "Marine Rear Admiral"
        CFrameQuest = CFrame.new(2482, 74, -6788) CFrameMon = CFrame.new(3722, 169, -7038)
    elseif lvl >= 1775 and lvl <= 1799 then
        Mon = "Fishman Raider" NameQuest = "DeepForestIsland3" LevelQuest = 1 NameMon = "Fishman Raider"
        CFrameQuest = CFrame.new(-10581.6563, 330.872955, -8761.18652) CFrameMon = CFrame.new(-10407.526367188, 331.76263427734, -8368.5166015625)
    elseif lvl >= 1800 and lvl <= 1824 then
        Mon = "Fishman Captain" NameQuest = "DeepForestIsland3" LevelQuest = 2 NameMon = "Fishman Captain"
        CFrameQuest = CFrame.new(-10581.6563, 330.872955, -8761.18652) CFrameMon = CFrame.new(-10994.701171875, 352.38140869141, -9002.1103515625)
    elseif lvl >= 1825 and lvl <= 1849 then
        Mon = "Forest Pirate" NameQuest = "DeepForestIsland" LevelQuest = 1 NameMon = "Forest Pirate"
        CFrameQuest = CFrame.new(-13234.04, 331.488495, -7625.40137) CFrameMon = CFrame.new(-13274.478515625, 332.37814331055, -7769.5805664062)
    elseif lvl >= 1850 and lvl <= 1899 then
        Mon = "Mythological Pirate" NameQuest = "DeepForestIsland" LevelQuest = 2 NameMon = "Mythological Pirate"
        CFrameQuest = CFrame.new(-13234.04, 331.488495, -7625.40137) CFrameMon = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)
    elseif lvl >= 1900 and lvl <= 1924 then
        Mon = "Jungle Pirate" NameQuest = "DeepForestIsland2" LevelQuest = 1 NameMon = "Jungle Pirate"
        CFrameQuest = CFrame.new(-12680.3818, 389.971039, -9902.01953) CFrameMon = CFrame.new(-12256.16015625, 331.73828125, -10485.836914062)
    elseif lvl >= 1925 and lvl <= 1974 then
        Mon = "Musketeer Pirate" NameQuest = "DeepForestIsland2" LevelQuest = 2 NameMon = "Musketeer Pirate"
        CFrameQuest = CFrame.new(-12680.3818, 389.971039, -9902.01953) CFrameMon = CFrame.new(-13457.904296875, 391.54565429688, -9859.177734375)
    elseif lvl >= 1975 and lvl <= 1999 then
        Mon = "Reborn Skeleton" NameQuest = "HauntedQuest1" LevelQuest = 1 NameMon = "Reborn Skeleton"
        CFrameQuest = CFrame.new(-9479.2168, 141.215088, 5566.09277) CFrameMon = CFrame.new(-8763.7236328125, 165.72299194336, 6159.8618164062)
    elseif lvl >= 2000 and lvl <= 2024 then
        Mon = "Living Zombie" NameQuest = "HauntedQuest1" LevelQuest = 2 NameMon = "Living Zombie"
        CFrameQuest = CFrame.new(-9479.2168, 141.215088, 5566.09277) CFrameMon = CFrame.new(-10144.131835938, 138.6266784668, 5838.0888671875)
    elseif lvl >= 2025 and lvl <= 2049 then
        Mon = "Demonic Soul" NameQuest = "HauntedQuest2" LevelQuest = 1 NameMon = "Demonic Soul"
        CFrameQuest = CFrame.new(-9516.99316, 172.017181, 6078.46533) CFrameMon = CFrame.new(-9505.8720703125, 172.10482788086, 6158.9931640625)
    elseif lvl >= 2050 and lvl <= 2074 then
        Mon = "Posessed Mummy" NameQuest = "HauntedQuest2" LevelQuest = 2 NameMon = "Posessed Mummy"
        CFrameQuest = CFrame.new(-9516.99316, 172.017181, 6078.46533) CFrameMon = CFrame.new(-9582.0224609375, 6.2515273094177, 6205.478515625)
    elseif lvl >= 2075 and lvl <= 2099 then
        Mon = "Peanut Scout" NameQuest = "NutsIslandQuest" LevelQuest = 1 NameMon = "Peanut Scout"
        CFrameQuest = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875) CFrameMon = CFrame.new(-2143.2419433594, 47.721984863281, -10029.995117188)
    elseif lvl >= 2100 and lvl <= 2124 then
        Mon = "Peanut President" NameQuest = "NutsIslandQuest" LevelQuest = 2 NameMon = "Peanut President"
        CFrameQuest = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875) CFrameMon = CFrame.new(-1859.3540039062, 38.103168487549, -10422.4296875)
    elseif lvl >= 2125 and lvl <= 2149 then
        Mon = "Ice Cream Chef" NameQuest = "IceCreamIslandQuest" LevelQuest = 1 NameMon = "Ice Cream Chef"
        CFrameQuest = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438) CFrameMon = CFrame.new(-872.24658203125, 65.81957244873, -10919.95703125)
    elseif lvl >= 2150 and lvl <= 2199 then
        Mon = "Ice Cream Commander" NameQuest = "IceCreamIslandQuest" LevelQuest = 2 NameMon = "Ice Cream Commander"
        CFrameQuest = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438) CFrameMon = CFrame.new(-558.06103515625, 112.04895782471, -11290.774414062)
    elseif lvl >= 2200 and lvl <= 2224 then
        Mon = "Cookie Crafter" NameQuest = "CakeQuest1" LevelQuest = 1 NameMon = "Cookie Crafter"
        CFrameQuest = CFrame.new(-2021.32007, 37.7982254, -12028.7295) CFrameMon = CFrame.new(-2374.13671875, 37.798263549805, -12125.30859375)
    elseif lvl >= 2225 and lvl <= 2249 then
        Mon = "Cake Guard" NameQuest = "CakeQuest1" LevelQuest = 2 NameMon = "Cake Guard"
        CFrameQuest = CFrame.new(-2021.32007, 37.7982254, -12028.7295) CFrameMon = CFrame.new(-1598.3070068359, 43.773197174072, -12244.581054688)
    elseif lvl >= 2250 and lvl <= 2274 then
        Mon = "Baking Staff" NameQuest = "CakeQuest2" LevelQuest = 1 NameMon = "Baking Staff"
        CFrameQuest = CFrame.new(-1927.91602, 37.7981339, -12842.5391) CFrameMon = CFrame.new(-1887.8099365234, 77.618507385254, -12998.350585938)
    elseif lvl >= 2275 and lvl <= 2299 then
        Mon = "Head Baker" NameQuest = "CakeQuest2" LevelQuest = 2 NameMon = "Head Baker"
        CFrameQuest = CFrame.new(-1927.91602, 37.7981339, -12842.5391) CFrameMon = CFrame.new(-2216.1882324219, 82.884521484375, -12869.293945312)
    elseif lvl >= 2300 and lvl <= 2324 then
        Mon = "Cocoa Warrior" NameQuest = "ChocQuest1" LevelQuest = 1 NameMon = "Cocoa Warrior"
        CFrameQuest = CFrame.new(233.22836303711, 29.876001358032, -12201.233398438) CFrameMon = CFrame.new(-21.553283691406, 80.574996948242, -12352.387695312)
    elseif lvl >= 2325 and lvl <= 2349 then
        Mon = "Chocolate Bar Battler" NameQuest = "ChocQuest1" LevelQuest = 2 NameMon = "Chocolate Bar Battler"
        CFrameQuest = CFrame.new(233.22836303711, 29.876001358032, -12201.233398438) CFrameMon = CFrame.new(582.59057617188, 77.188095092773, -12463.162109375)
    elseif lvl >= 2350 and lvl <= 2374 then
        Mon = "Sweet Thief" NameQuest = "ChocQuest2" LevelQuest = 1 NameMon = "Sweet Thief"
        CFrameQuest = CFrame.new(150.50663757324, 30.693693161011, -12774.502929688) CFrameMon = CFrame.new(165.1884765625, 76.058853149414, -12600.836914062)
    elseif lvl >= 2375 and lvl <= 2399 then
        Mon = "Candy Rebel" NameQuest = "ChocQuest2" LevelQuest = 2 NameMon = "Candy Rebel"
        CFrameQuest = CFrame.new(150.50663757324, 30.693693161011, -12774.502929688) CFrameMon = CFrame.new(134.86563110352, 77.247680664062, -12876.547851562)
    elseif lvl >= 2400 and lvl <= 2449 then
        Mon = "Candy Pirate" NameQuest = "CandyQuest1" LevelQuest = 1 NameMon = "Candy Pirate"
        CFrameQuest = CFrame.new(-1150.0400390625, 20.378934860229, -14446.334960938) CFrameMon = CFrame.new(-1310.5003662109, 26.016523361206, -14562.404296875)
    elseif lvl >= 2450 and lvl <= 2474 then
        Mon = "Isle Outlaw" NameQuest = "TikiQuest1" LevelQuest = 1 NameMon = "Isle Outlaw"
        CFrameQuest = CFrame.new(-16548.8164, 55.6059914, -172.8125) CFrameMon = CFrame.new(-16479.900390625, 226.6117401123, -300.31143188477)
    elseif lvl >= 2475 and lvl <= 2499 then
        Mon = "Island Boy" NameQuest = "TikiQuest1" LevelQuest = 2 NameMon = "Island Boy"
        CFrameQuest = CFrame.new(-16548.8164, 55.6059914, -172.8125) CFrameMon = CFrame.new(-16849.396484375, 192.86505126953, -150.78532409668)
    elseif lvl >= 2500 and lvl <= 2524 then
        Mon = "Sun-kissed Warrior" NameQuest = "TikiQuest2" LevelQuest = 1 NameMon = "Sun-kissed Warrior"
        CFrameQuest = CFrame.new(-16538, 55, 1049) CFrameMon = CFrame.new(-16347, 64, 984)
    elseif lvl >= 2525 and lvl <= 2550 then
        Mon = "Isle Champion" NameQuest = "TikiQuest2" LevelQuest = 2 NameMon = "Isle Champion"
        CFrameQuest = CFrame.new(-16541.0215, 57.3082275, 1051.46118) CFrameMon = CFrame.new(-16602.1015625, 130.38734436035, 1087.2456054688)
    elseif lvl >= 2551 and lvl <= 2574 then
        Mon = "Serpent Hunter" NameQuest = "TikiQuest3" LevelQuest = 1 NameMon = "Serpent Hunter"
        CFrameQuest = CFrame.new(-16668.03, 105.32, 1568.60) CFrameMon = CFrame.new(-16645.64, 163.09, 1352.87)
    elseif lvl >= 2575 and lvl <= 2599 then
        Mon = "Skull Slayer" NameQuest = "TikiQuest3" LevelQuest = 2 NameMon = "Skull Slayer"
        CFrameQuest = CFrame.new(-16668.03, 105.32, 1568.60) CFrameMon = CFrame.new(-16709.49, 419.68, 1751.09)
    elseif lvl >= 2600 and lvl <= 2624 then
        Mon = "Reef Bandit" NameQuest = "SubmergedQuest1" LevelQuest = 1 NameMon = "Reef Bandit"
        CFrameQuest = CFrame.new(10778.875, -2087.72437, 9265.18359) CFrameMon = CFrame.new(11019.1318, -2146.06812, 9342.3916)
    elseif lvl >= 2625 and lvl <= 2649 then
        Mon = "Coral Pirate" NameQuest = "SubmergedQuest1" LevelQuest = 2 NameMon = "Coral Pirate"
        CFrameQuest = CFrame.new(10778.875, -2087.72437, 9265.18359) CFrameMon = CFrame.new(10808.6006, -2030.36145, 9364.2334)
    elseif lvl >= 2650 and lvl <= 2674 then
        Mon = "Sea Chanter" NameQuest = "SubmergedQuest2" LevelQuest = 1 NameMon = "Sea Chanter"
        CFrameQuest = CFrame.new(10880.6855, -2086.20044, 10032.624) CFrameMon = CFrame.new(10671.2715, -2057.59155, 10047.2588)
    elseif lvl >= 2675 and lvl <= 2699 then
        Mon = "Ocean Prophet" NameQuest = "SubmergedQuest2" LevelQuest = 2 NameMon = "Ocean Prophet"
        CFrameQuest = CFrame.new(10880.6855, -2086.20044, 10032.624) CFrameMon = CFrame.new(11008.5195, -2007.72839, 10223.0791)
    elseif lvl >= 2700 and lvl <= 2724 then
        Mon = "High Disciple" NameQuest = "SubmergedQuest3" LevelQuest = 1 NameMon = "High Disciple"
        CFrameQuest = CFrame.new(9640.08789, -1992.44507, 9613.65234) CFrameMon = CFrame.new(9750.41602, -1966.93884, 9753.36035)
    elseif lvl >= 2725 then
        Mon = "Grand Devotee" NameQuest = "SubmergedQuest3" LevelQuest = 2 NameMon = "Grand Devotee"
        CFrameQuest = CFrame.new(9640.08789, -1992.44507, 9613.65234) CFrameMon = CFrame.new(9611.70508, -1993.47119, 9882.68848)
    end
end

-- ==================== HÀM HỖ TRỢ DI CHUYỂN & FLY ====================
function EnableFly()
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = Character.HumanoidRootPart
    if hrp:FindFirstChild("FarmBodyPos") then hrp.FarmBodyPos:Destroy() end
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.Name = "FarmBodyPos"
    bodyPos.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyPos.D = 500
    bodyPos.P = 10000
    bodyPos.Parent = hrp
end

function DisableFly()
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Character.HumanoidRootPart
        if hrp:FindFirstChild("FarmBodyPos") then hrp.FarmBodyPos:Destroy() end
    end
end

task.wait(1)
DisableFly()

Player.CharacterAdded:Connect(function(char)
    Character = char
    task.wait(1)
    DisableFly()
end)

function TP(cf)
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = Character.HumanoidRootPart
    DisableFly()
    local distance = (hrp.Position - cf.Position).Magnitude
    if distance < 5 then return end
    local speed = 280
    local tween = TweenService:Create(hrp, TweenInfo.new(distance / speed, Enum.EasingStyle.Linear), {CFrame = cf})
    tween:Play()
    tween.Completed:Wait()
end

local function equipTool(toolName)
    local backpack = Player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild(toolName) then
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid:EquipTool(backpack[toolName])
        end
    end
end

function Attack()
    VirtualUser:Button1Down(Vector2.new(0,0))
    VirtualUser:Button1Up(Vector2.new(0,0))
end

function GetMob(name)
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name == name and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
end

-- ==================== TỰ ĐỘNG CHUYỂN SANG THẾ GIỚI 2 (SEA 2) ====================
local function AutoGoToSea2()
    local progress = ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress")

    if progress.UsedKey == false then
        local detectiveCFrame = CFrame.new(1347.32947, 37.349369, -1325.44922)
        TP(detectiveCFrame)
        ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
        equipTool("Key")
        
    elseif progress.KilledIceBoss == false then
        local boss = Workspace.Enemies:FindFirstChild("Ice Admiral") or ReplicatedStorage:FindFirstChild("Ice Admiral")
        if boss then
            local bossHrp = boss:FindFirstChild("HumanoidRootPart")
            local bossHum = boss:FindFirstChild("Humanoid")
            
            if bossHrp and bossHum and bossHum.Health > 0 then
                repeat task.wait(0.1)
                    if not Character or not Character:FindFirstChild("HumanoidRootPart") then break end
                    local targetCFrame = bossHrp.CFrame * CFrame.new(0, 20, 0)
                    local hrp = Character.HumanoidRootPart
                    if not hrp:FindFirstChild("FarmBodyPos") then EnableFly() end
                    local bodyPos = hrp:FindFirstChild("FarmBodyPos")
                    if bodyPos then bodyPos.Position = targetCFrame.Position end
                    
                    bossHrp.CanCollide = false
                    bossHum.WalkSpeed = 0
                    Attack()
                    
                    if not Character:FindFirstChild("HasBuso") then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
                    end
                until not boss.Parent or boss.Humanoid.Health <= 0
                
                DisableFly()
                task.wait(2)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
            end
        else
            local bossSpawnCFrame = CFrame.new(1144.5270996094, 7.3292083740234, -1164.7322998047)
            TP(bossSpawnCFrame)
        end
        
    elseif progress.KilledIceBoss == true then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
    end
end

-- ==================== TỰ ĐỘNG CHUYỂN SANG THẾ GIỚI 3 (SEA 3) ====================
local function AutoGoToSea3()
    local Bartilo = CFrame.new(-461,73,300)
    local SwanZone = CFrame.new(918,125,1235)
    local JeremyPos = CFrame.new(2099,448,648)
    local DonRoom = CFrame.new(2288,15,905)

    -- Nhận chuỗi Quest từ Bartilo
    TP(Bartilo)
    task.wait(1)
    for i = 1,5 do
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(v) end) end
        end
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("StartQuest","BartiloQuest",1)
        end)
        task.wait(0.5)
    end

    -- Hạ gục 50 quái Swan Pirate
    TP(SwanZone)
    local kill = 0
    while kill < 50 do
        local mob = GetMob("Swan Pirate")
        if mob and mob:FindFirstChild("HumanoidRootPart") then
            repeat
                if not Character or not Character:FindFirstChild("HumanoidRootPart") then break end
                Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,10,0)
                Attack()
                task.wait()
            until not mob or not mob:FindFirstChild("Humanoid") or mob.Humanoid.Health <= 0
            kill = kill + 1
        else
            task.wait(1)
        end
    end

    -- Hạ gục Jeremy Boss
    TP(JeremyPos)
    local jeremy = nil
    for i = 1, 5 do
        jeremy = GetMob("Jeremy")
        if jeremy then break end
        task.wait(1)
    end
    if jeremy and jeremy:FindFirstChild("HumanoidRootPart") then
        repeat
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then break end
            Character.HumanoidRootPart.CFrame = jeremy.HumanoidRootPart.CFrame * CFrame.new(0,15,0)
            Attack()
            task.wait()
        until not jeremy or not jeremy:FindFirstChild("Humanoid") or jeremy.Humanoid.Health <= 0
    end

    -- Giải đố Colosseum mật mã bàn cờ ẩn
    local path = {
        Vector3.new(-1835,5,1670), Vector3.new(-1850,13,1750), Vector3.new(-1858,19,1712),
        Vector3.new(-1803,16,1750), Vector3.new(-1858,16,1724), Vector3.new(-1869,15,1681),
        Vector3.new(-1800,16,1684), Vector3.new(-1819,14,1717), Vector3.new(-1813,14,1724)
    }
    for _, v in pairs(path) do
        TP(CFrame.new(v))
        task.wait(0.3)
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    -- Đánh Don Swan
    TP(DonRoom)
    local don = nil
    for i = 1, 5 do
        don = GetMob("Don Swan")
        if don then break end
        task.wait(1)
    end
    if don and don:FindFirstChild("HumanoidRootPart") then
        repeat
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then break end
            Character.HumanoidRootPart.CFrame = don.HumanoidRootPart.CFrame * CFrame.new(0,20,0)
            Attack()
            task.wait()
        until not don or not don:FindFirstChild("Humanoid") or don.Humanoid.Health <= 0
    end

    -- Nói chuyện với King Red Head (Tự động bấm qua hội thoại)
    local kingPos = CFrame.new(-1928.6593, 12.3023, 1738.4456)
    TP(kingPos + Vector3.new(0,3,0))
    task.wait(1)
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") then
            if (v.Parent.Position - Character.HumanoidRootPart.Position).Magnitude < 20 then
                pcall(function() fireproximityprompt(v) end)
            end
        end
    end

    local size = workspace.CurrentCamera.ViewportSize
    local centerX, rightX = math.floor(size.X / 2), size.X - 10
    local line1Y, line2Y = math.floor(size.Y * 0.50), math.floor(size.Y * 0.40)
    local startTime = tick()
    while tick() - startTime < 10 do
        for _, y in ipairs({line1Y, line2Y}) do
            for x = centerX, rightX, 20 do
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            end
        end
    end

    -- Diệt quái xung quanh King Red Head vừa sinh ra
    local nearestMob, nearestDist = nil, math.huge
    if workspace:FindFirstChild("Enemies") then
        for _, mob in pairs(workspace.Enemies:GetChildren()) do
            if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                local dist = (Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                if dist < nearestDist then nearestDist = dist nearestMob = mob end
            end
        end
    end
    if nearestMob then
        while nearestMob.Parent and nearestMob:FindFirstChild("Humanoid") and nearestMob.Humanoid.Health > 0 do
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then break end
            Character.HumanoidRootPart.CFrame = nearestMob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
            Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            Attack()
            task.wait()
        end
    end

    -- Di chuyển trực tiếp đến Hải Trình 3
    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou") end)
end

-- ==================== MÔ-ĐUN NOCLIP (XUYÊN TƯỜNG) ====================
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().NoClip and Character then
            pcall(function()
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end)
        end
    end
end)

-- ==================== TỰ ĐỘNG BẬT HAKI VÀ TRANG BỊ VŨ KHÍ MELEE ====================
local MeleeList = {
    "Combat", "Black Leg", "Electro", "Fishman Karate", "Dragon Breath",
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw",
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if Player.Character and not Player.Character:FindFirstChild("HasBuso") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if not Character or not Character:FindFirstChild("Humanoid") then return end
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool then
                for _, name in ipairs(MeleeList) do if tool.Name == name then return end end
            end
            local backpack = Player:FindFirstChild("Backpack")
            if backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        for _, name in ipairs(MeleeList) do
                            if item.Name == name then Character.Humanoid:EquipTool(item) break end
                        end
                    end
                end
            end
        end)
    end
end)

-- ==================== TỰ ĐỘNG HÚT QUÁI GOM MỘT CHỖ (BRING MONSTER) ====================
local CurrentTarget = nil

task.spawn(function()
    while task.wait(0.15) do
        pcall(function()
            if not getgenv().BringMonster then return end
            local lvl = Player.Data.Level.Value
            
            -- Tránh hút quái khi đang làm chuỗi nhiệm vụ chuyển Sea đặc biệt
            if (lvl == 700 and game.PlaceId == 2753915131) or (lvl == 1500 and game.PlaceId == 444227216) then return end
            
            CheckQuest()
            if not Mon or not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
            local pullPos = (CurrentTarget and CurrentTarget.Parent and CurrentTarget:FindFirstChild("HumanoidRootPart")) and CurrentTarget.HumanoidRootPart.Position or Character.HumanoidRootPart.Position
            if not Workspace:FindFirstChild("Enemies") then return end
            
            for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                    local hum = enemy.Humanoid
                    local root = enemy.HumanoidRootPart
                    if hum.Health > 0 and root then
                        if (enemy.Name == Mon or enemy.Name == NameMon) then
                            local dist = (root.Position - pullPos).Magnitude
                            if dist <= getgenv().MagnetRadius and enemy ~= CurrentTarget then
                                root.CanCollide = false
                                root.Size = Vector3.new(60, 60, 60)
                                root.CFrame = CFrame.new(pullPos)
                                if enemy:FindFirstChild("Head") then enemy.Head.CanCollide = false end
                                pcall(function()
                                    local anim = hum:FindFirstChild("Animator")
                                    if anim then anim:Destroy() end
                                end)
                                if sethiddenproperty then sethiddenproperty(Player, "SimulationRadius", math.huge) end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ==================== VÒNG LẶP AUTO FARM CHÍNH (MAIN LOOP) ====================
task.spawn(function()
    while task.wait() do
        pcall(function()
            if not getgenv().AutoFarm then
                DisableFly()
                CurrentTarget = nil
                return
            end

            local currentLevel = Player.Data.Level.Value

            -- ĐIỀU KIỆN 1: Nếu đạt cấp độ 700 và đang ở Sea 1 -> Tiến hành sang Sea 2
            if currentLevel == 700 and game.PlaceId == 2753915131 then
                DisableFly()
                CurrentTarget = nil
                AutoGoToSea2()
                task.wait(1)
                return
            end

            -- ĐIỀU KIỆN 2: Nếu đạt cấp độ 1500 và đang ở Sea 2 -> Tiến hành sang Sea 3
            if currentLevel == 1500 and game.PlaceId == 444227216 then
                DisableFly()
                CurrentTarget = nil
                AutoGoToSea3()
                task.wait(1)
                return
            end

            CheckQuest()
            if not CFrameMon then return end

            -- Tự động nhận Quest dựa trên cấp độ hiện tại
            if not Player.PlayerGui or not Player.PlayerGui:FindFirstChild("Main") or not Player.PlayerGui.Main:FindFirstChild("Quest") then return end
            local questVisible = Player.PlayerGui.Main.Quest.Visible
            if not questVisible and CFrameQuest and NameQuest and LevelQuest then
                TP(CFrameQuest)
                task.wait(1)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                task.wait(0.5)
            end

            if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

            -- Tìm kiếm mục tiêu quái gần nhất trong bãi spawn quy định
            if not CurrentTarget or not CurrentTarget.Parent or CurrentTarget.Humanoid.Health <= 0 then
                CurrentTarget = nil
                local nearest, minDist = nil, math.huge
                local myPos = Character.HumanoidRootPart.Position
                if Workspace:FindFirstChild("Enemies") then
                    for _, v in ipairs(Workspace.Enemies:GetChildren()) do
                        if (v.Name == Mon or v.Name == NameMon) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                            local distToSpawn = (v.HumanoidRootPart.Position - CFrameMon.Position).Magnitude
                            if distToSpawn <= 400 then
                                local distToMe = (v.HumanoidRootPart.Position - myPos).Magnitude
                                if distToMe < minDist and distToMe <= 400 then
                                    minDist = distToMe
                                    nearest = v
                                end
                            end
                        end
                    end
                end
                if nearest then
                    CurrentTarget = nearest
                else
                    DisableFly()
                    if getgenv().AutoTPtoSpawn then
                        local distToSpawn = (myPos - CFrameMon.Position).Magnitude
                        if distToSpawn > 100 then TP(CFrameMon) end
                    end
                    task.wait(1)
                    return
                end
            end

            -- Tấn công và giữ khoảng cách thông minh khi chém quái
            local hrp = Character.HumanoidRootPart
            local monHrp = CurrentTarget.HumanoidRootPart
            local humanoidMon = CurrentTarget.Humanoid
            if not hrp:FindFirstChild("FarmBodyPos") then EnableFly() end
            local bodyPos = hrp:FindFirstChild("FarmBodyPos")
            local flyHeight = 15
            local maxY = CFrameMon.Y + 20

            local startHealth = humanoidMon.Health
            local startTime = os.clock()
            local timeout = getgenv().MonsterTimeout

            repeat
                task.wait()
                if not Character or not Character:FindFirstChild("HumanoidRootPart") or not CurrentTarget.Parent then break end
                local targetPos = monHrp.Position + Vector3.new(0, flyHeight, 0)
                if targetPos.Y > maxY then targetPos = Vector3.new(targetPos.X, maxY, targetPos.Z) end
                if bodyPos then bodyPos.Position = targetPos end

                monHrp.CanCollide = false
                humanoidMon.WalkSpeed = 0
                humanoidMon.JumpPower = 0
                Attack() 

                local elapsed = os.clock() - startTime
                local curHealth = humanoidMon.Health
                if elapsed >= timeout and curHealth >= startHealth then break end
                if curHealth < startHealth then
                    startHealth = curHealth
                    startTime = os.clock()
                end
            until not getgenv().AutoFarm or not CurrentTarget.Parent or humanoidMon.Health <= 0

            CurrentTarget = nil
            DisableFly()
        end)
    end
end)
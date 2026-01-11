--[[
    FINAL UI LIBRARY - FLOATING STYLE & DRAGGABLE FIX
    Author: Gemini (Based on User Request)
]]

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- == 1. HÀM XỬ LÝ KÉO THẢ (DRAGGABLE) ==
local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		object.Position = pos
	end

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

-- == 2. HÀM TẠO CỬA SỔ CHÍNH (WINDOW) ==
function Library:CreateWindow(Config)
    local WindowName = Config.Name or "UI Library"
    
    -- A. Tạo ScreenGui (Thùng chứa bảo vệ)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FloatingLib_"..math.random(1,9999)
    ScreenGui.ResetOnSpawn = false
    
    -- Tự động chọn nơi chứa an toàn (bypass một số anti-cheat cơ bản)
    if gethui then
        ScreenGui.Parent = gethui()
    elseif CoreGui:FindFirstChild("RobloxGui") then
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- B. DragContainer: Khung ẢO trong suốt chứa tất cả (Dùng để kéo cả cụm)
    local DragContainer = Instance.new("Frame")
    DragContainer.Name = "DragContainer"
    DragContainer.Size = UDim2.new(0, 500, 0, 350) -- Kích thước tổng thể
    DragContainer.Position = UDim2.new(0.5, -250, 0.5, -175) -- Căn giữa màn hình
    DragContainer.BackgroundTransparency = 1 -- Trong suốt
    DragContainer.Parent = ScreenGui

    -- C. TopBar: Thanh chứa các Tab (Lơ lửng bên trên)
    local TopBarFrame = Instance.new("Frame")
    TopBarFrame.Name = "TopBar"
    TopBarFrame.Size = UDim2.new(0, 420, 0, 35) -- Nhỏ hơn khung chính một chút cho đẹp
    TopBarFrame.Position = UDim2.new(0.5, -210, 0, 0) -- Nằm sát mép trên (Y=0)
    TopBarFrame.BackgroundTransparency = 1
    TopBarFrame.Parent = DragContainer

    -- Layout tự xếp các nút Tab
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 10) -- Khoảng cách giữa các nút Tab
    TabListLayout.Parent = TopBarFrame

    -- D. MainFrame: Khung nội dung chính (Nằm bên dưới)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(1, 0, 1, -45) -- Chiếm phần còn lại
    MainFrame.Position = UDim2.new(0, 0, 0, 45) -- Y=45 -> Tạo khoảng hở 10px so với TopBar (Floating Effect)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Màu nền đen tối
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = DragContainer

    -- E. HeaderBar: Thanh tiêu đề màu xám + Nút tắt
    local HeaderBar = Instance.new("Frame")
    HeaderBar.Name = "Header"
    HeaderBar.Size = UDim2.new(1, 0, 0, 30) -- Chiều cao thanh tiêu đề
    HeaderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Màu xám
    HeaderBar.BorderSizePixel = 0
    HeaderBar.Parent = MainFrame

    -- Tiêu đề (Góc trái)
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Name = "Title"
    HeaderTitle.Size = UDim2.new(1, -40, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 10, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = WindowName
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 14
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = HeaderBar

    -- Nút X (Tắt GUI)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0) -- Góc phải
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.Parent = HeaderBar

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- F. PagesFolder: Nơi chứa nội dung các trang
    local PagesFolder = Instance.new("Frame")
    PagesFolder.Name = "Pages"
    PagesFolder.Size = UDim2.new(1, -20, 1, -40)
    PagesFolder.Position = UDim2.new(0, 10, 0, 40)
    PagesFolder.BackgroundTransparency = 1
    PagesFolder.Parent = MainFrame

    -- KÍCH HOẠT KÉO THẢ:
    -- Cầm vào thanh HeaderBar -> Di chuyển cả DragContainer (chứa cả Tab lẫn Main)
    MakeDraggable(HeaderBar, DragContainer)

    -- == 3. XỬ LÝ TAB VÀ NỘI DUNG ==
    local WindowFuncs = {}
    local FirstTab = true

    function WindowFuncs:CreateTab(TabName)
        -- a. Tạo Nút Tab (Trên TopBar)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Parent = TopBarFrame
        TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Màu chưa chọn (Đen xám)
        TabButton.Size = UDim2.new(0, 100, 1, 0)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = TabName
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 150) -- Chữ xám
        TabButton.TextSize = 13
        
        -- Bo góc nút Tab
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton

        -- b. Tạo Trang Nội Dung (Trong PagesFolder)
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName.."_Page"
        Page.Parent = PagesFolder
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false -- Mặc định ẩn

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 5)
        PageLayout.Parent = Page

        -- c. Logic chuyển Tab
        local function Activate()
            -- Ẩn hết các trang khác
            for _, p in pairs(PagesFolder:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            -- Reset màu các nút Tab khác
            for _, btn in pairs(TopBarFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                end
            end
            
            -- Hiện trang này
            Page.Visible = true
            -- Làm sáng nút Tab này
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
            -- Đổi tiêu đề Header
            HeaderTitle.Text = TabName
        end

        TabButton.MouseButton1Click:Connect(Activate)

        -- Tự kích hoạt nếu là Tab đầu tiên
        if FirstTab then
            FirstTab = false
            Activate()
        end

        -- == 4. CÁC PHẦN TỬ BÊN TRONG TAB (ELEMENTS) ==
        local ElementFuncs = {}

        -- Element: Button
        function ElementFuncs:CreateButton(Cfg)
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Name = "ButtonFrame"
            BtnFrame.Size = UDim2.new(1, 0, 0, 35)
            BtnFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            BtnFrame.Parent = Page
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = BtnFrame

            local TextBtn = Instance.new("TextButton")
            TextBtn.Size = UDim2.new(1, 0, 1, 0)
            TextBtn.BackgroundTransparency = 1
            TextBtn.Text = Cfg.Name or "Button"
            TextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBtn.Font = Enum.Font.Gotham
            TextBtn.TextSize = 14
            TextBtn.Parent = BtnFrame

            TextBtn.MouseButton1Click:Connect(function()
                -- Hiệu ứng click
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
                pcall(Cfg.Callback)
            end)
        end

        -- Element: Toggle
        function ElementFuncs:CreateToggle(Cfg)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ToggleFrame.Parent = Page
            
            local TogCorner = Instance.new("UICorner")
            TogCorner.CornerRadius = UDim.new(0, 4)
            TogCorner.Parent = ToggleFrame

            local TogTitle = Instance.new("TextLabel")
            TogTitle.Size = UDim2.new(0.7, 0, 1, 0)
            TogTitle.Position = UDim2.new(0, 10, 0, 0)
            TogTitle.BackgroundTransparency = 1
            TogTitle.Text = Cfg.Name or "Toggle"
            TogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            TogTitle.Font = Enum.Font.Gotham
            TogTitle.TextXAlignment = Enum.TextXAlignment.Left
            TogTitle.Parent = ToggleFrame

            local SwitchBtn = Instance.new("TextButton")
            SwitchBtn.Size = UDim2.new(0, 24, 0, 24)
            SwitchBtn.Position = UDim2.new(1, -34, 0.5, -12)
            SwitchBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            SwitchBtn.Text = ""
            SwitchBtn.Parent = ToggleFrame
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(0, 4)
            SwitchCorner.Parent = SwitchBtn

            local State = Cfg.Default or false

            local function UpdateToggle()
                if State then
                    TweenService:Create(SwitchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}):Play()
                else
                    TweenService:Create(SwitchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                end
                pcall(Cfg.Callback, State)
            end
            
            UpdateToggle() -- Set trạng thái ban đầu

            SwitchBtn.MouseButton1Click:Connect(function()
                State = not State
                UpdateToggle()
            end)
        end

        return ElementFuncs
    end

    return WindowFuncs
end

return Library

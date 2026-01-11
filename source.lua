--[[
    CUSTOM UI LIBRARY - FLOATING TABS STYLE
    Clone Layout based on User Image
]]

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Hàm hỗ trợ kéo thả UI (Draggable)
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

function Library:CreateWindow(Config)
    local WindowName = Config.Name or "UI Library"
    
    -- 1. ScreenGui (Container chính)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomLib_"..math.random(1,9999)
    ScreenGui.Parent = CoreGui
    -- ResetOnSpawn để false để khi chết không mất UI
    ScreenGui.ResetOnSpawn = false 

    -- Container ảo để chứa cả TopBar và MainBody (để kéo thả cả 2 cùng lúc)
    local DragContainer = Instance.new("Frame")
    DragContainer.Name = "DragContainer"
    DragContainer.Size = UDim2.new(0, 500, 0, 400)
    DragContainer.Position = UDim2.new(0.5, -250, 0.5, -200)
    DragContainer.BackgroundTransparency = 1
    DragContainer.Parent = ScreenGui

    -- == PHẦN 1: THANH TAB Ở TRÊN (TOP NAVIGATION) ==
    local TopBarFrame = Instance.new("Frame")
    TopBarFrame.Name = "TopBar"
    TopBarFrame.Size = UDim2.new(0, 400, 0, 35) -- Nhỏ hơn khung chính 1 chút
    TopBarFrame.Position = UDim2.new(0.5, -200, 0, 0) -- Căn giữa phía trên
    TopBarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Màu đen
    TopBarFrame.BackgroundTransparency = 1 -- Trong suốt để chỉ hiện nút
    TopBarFrame.Parent = DragContainer

    -- Layout xếp các nút Tab ngang hàng
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 10) -- Khoảng cách giữa các tab
    TabListLayout.Parent = TopBarFrame

    -- == PHẦN 2: KHUNG NỘI DUNG CHÍNH (MAIN BODY) ==
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(1, 0, 1, -45) -- Chiếm hết phần dưới
    MainFrame.Position = UDim2.new(0, 0, 0, 45) -- Nằm dưới TopBar
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Màu đen cực tối
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = DragContainer

    -- Header Bar bên trong MainFrame (Giống hình bạn gửi: thanh xám có chữ Main)
    local HeaderBar = Instance.new("Frame")
    HeaderBar.Name = "Header"
    HeaderBar.Size = UDim2.new(1, 0, 0, 30)
    HeaderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Màu xám
    HeaderBar.BorderSizePixel = 0
    HeaderBar.Parent = MainFrame

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Name = "Title"
    HeaderTitle.Size = UDim2.new(1, 0, 1, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "Main" -- Mặc định
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 14
    HeaderTitle.Parent = HeaderBar

    -- Container chứa các trang (Pages)
    local PagesFolder = Instance.new("Frame")
    PagesFolder.Name = "Pages"
    PagesFolder.Size = UDim2.new(1, -20, 1, -40)
    PagesFolder.Position = UDim2.new(0, 10, 0, 40)
    PagesFolder.BackgroundTransparency = 1
    PagesFolder.Parent = MainFrame

    -- Kích hoạt kéo thả (Cầm vào thanh Header xám để kéo)
    MakeDraggable(HeaderBar, DragContainer)

    -- Biến lưu trữ logic
    local Tabs = {}
    local FirstTab = true

    local WindowFuncs = {}

    -- == HÀM TẠO TAB ==
    function WindowFuncs:CreateTab(TabName)
        -- 1. Tạo Nút Tab ở trên
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Parent = TopBarFrame
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Màu nút chưa chọn
        TabButton.Size = UDim2.new(0, 100, 1, 0)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = TabName
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 150) -- Màu chữ xám
        TabButton.TextSize = 14
        
        -- Tạo hình dáng nút (Bo góc trên) - Giả lập hình thang
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabButton
        
        -- Phần che góc dưới để nối liền với MainFrame (nếu cần)
        -- Ở đây mình để nút tách rời cho giống phong cách "Floating"

        -- 2. Tạo Trang nội dung (Page) bên dưới
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName.."_Page"
        Page.Parent = PagesFolder
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false -- Ẩn mặc định

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 5)
        PageLayout.Parent = Page

        -- Xử lý Logic chuyển Tab
        local function Activate()
            -- Ẩn hết các trang cũ
            for _, item in pairs(PagesFolder:GetChildren()) do
                if item:IsA("ScrollingFrame") then item.Visible = false end
            end
            -- Reset màu các nút cũ
            for _, btn in pairs(TopBarFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 20), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                end
            end

            -- Hiện trang hiện tại
            Page.Visible = true
            -- Đổi màu nút hiện tại (Sáng lên)
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
            -- Đổi tên Header
            HeaderTitle.Text = TabName
        end

        TabButton.MouseButton1Click:Connect(Activate)

        -- Nếu là tab đầu tiên thì tự kích hoạt
        if FirstTab then
            FirstTab = false
            Activate()
        end

        -- == CÁC ELEMENT BÊN TRONG TAB ==
        local ElementFuncs = {}

        function ElementFuncs:CreateButton(Cfg)
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Size = UDim2.new(1, 0, 0, 35)
            BtnFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
                pcall(Cfg.Callback)
            end)
        end
        
        function ElementFuncs:CreateToggle(Cfg)
            -- Code toggle đơn giản (Bạn có thể phát triển thêm)
            local TogFrame = Instance.new("Frame")
            TogFrame.Size = UDim2.new(1, 0, 0, 35)
            TogFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            TogFrame.Parent = Page
            local TogCorner = Instance.new("UICorner"); TogCorner.Parent = TogFrame

            local TogTitle = Instance.new("TextLabel")
            TogTitle.Size = UDim2.new(0.7, 0, 1, 0)
            TogTitle.Position = UDim2.new(0, 10, 0, 0)
            TogTitle.BackgroundTransparency = 1
            TogTitle.Text = Cfg.Name
            TogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            TogTitle.Font = Enum.Font.Gotham
            TogTitle.TextXAlignment = Enum.TextXAlignment.Left
            TogTitle.Parent = TogFrame

            local TogBtn = Instance.new("TextButton")
            TogBtn.Size = UDim2.new(0, 24, 0, 24)
            TogBtn.Position = UDim2.new(1, -34, 0.5, -12)
            TogBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            TogBtn.Text = ""
            TogBtn.Parent = TogFrame
            local TogBtnCorner = Instance.new("UICorner"); TogBtnCorner.CornerRadius = UDim.new(0,4); TogBtnCorner.Parent = TogBtn

            local State = Cfg.Default or false
            
            local function UpdateState()
                if State then
                    TweenService:Create(TogBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}):Play()
                else
                    TweenService:Create(TogBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                end
                pcall(Cfg.Callback, State)
            end
            UpdateState()

            TogBtn.MouseButton1Click:Connect(function()
                State = not State
                UpdateState()
            end)
        end

        return ElementFuncs
    end

    return WindowFuncs
end

return Library

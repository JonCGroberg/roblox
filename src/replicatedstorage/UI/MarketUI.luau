local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Types = require(ReplicatedStorage.Core.Types)
local Config = require(ReplicatedStorage.Core.Config)

local MarketUI = {}

function MarketUI:Init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	self.screenGui = playerGui:FindFirstChild("MarketUI") or Instance.new("ScreenGui")
	self.screenGui.Name = "MarketUI"
	self.screenGui.Parent = playerGui

	self.prices = {} -- [resourceId] = MarketPrice
	self.history = {} -- { MarketTransaction }
	self.historyPanelVisible = false
	self.filterType = "all" -- "all", "buy", "sell"
	self.searchQuery = ""

	self:CreateMarketPanel()
	self:UpdateMarketPanel()
	self:CreateHistoryButton()
	self:CreateFilterButtons()
	self:CreateSearchBox()

	self:RequestPrices()

	-- Listen for price updates
	local priceEvent = ReplicatedStorage:FindFirstChild("MarketPricesUpdate")
	if priceEvent then
		priceEvent.OnClientEvent:Connect(function(prices)
			self.prices = prices
			self:UpdateMarketPanel()
		end)
	end

	-- Listen for transaction result
	local txEvent = ReplicatedStorage:FindFirstChild("MarketTransactionResult")
	if txEvent then
		txEvent.OnClientEvent:Connect(function(success, msg)
			self:ShowTransactionMessage(success, msg)
		end)
	end

	-- Listen for transaction history
	local histEvent = ReplicatedStorage:FindFirstChild("MarketTransactionHistory")
	if histEvent then
		histEvent.OnClientEvent:Connect(function(history)
			self.history = history
			self:ShowHistoryPanel()
		end)
	end
end

function MarketUI:RequestPrices()
	local remote = ReplicatedStorage:FindFirstChild("MarketGetPrices")
	if remote then
		remote:FireServer()
	end
end

function MarketUI:CreateMarketPanel()
	local panel = Instance.new("Frame")
	panel.Name = "MarketPanel"
	panel.Size = UDim2.new(0, 480, 0, 420)
	panel.Position = UDim2.new(0, 40, 0, 40)
	panel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	panel.BackgroundTransparency = 0.1
	panel.BorderSizePixel = 0
	panel.Parent = self.screenGui

	local title = Instance.new("TextLabel")
	title.Text = "Market"
	title.Size = UDim2.new(1, 0, 0, 36)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.Parent = panel

	self.marketPanel = panel
end

function MarketUI:UpdateMarketPanel()
	if not self.marketPanel then
		return
	end
	-- Clear old rows
	for _, child in ipairs(self.marketPanel:GetChildren()) do
		if child:IsA("Frame") and child.Name == "MarketRow" then
			child:Destroy()
		end
	end

	local resources = Config.RESOURCES.ITEMS
	local y = 40
	for _, resource in ipairs(resources) do
		local row = Instance.new("Frame")
		row.Name = "MarketRow"
		row.Size = UDim2.new(1, -20, 0, 48)
		row.Position = UDim2.new(0, 10, 0, y)
		row.BackgroundTransparency = 1
		row.Parent = self.marketPanel

		local name = Instance.new("TextLabel")
		name.Text = resource.name
		name.Size = UDim2.new(0.25, 0, 1, 0)
		name.Position = UDim2.new(0, 0, 0, 0)
		name.BackgroundTransparency = 1
		name.TextColor3 = Color3.fromRGB(220, 220, 255)
		name.TextSize = 18
		name.Font = Enum.Font.Gotham
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.Parent = row

		local price = Instance.new("TextLabel")
		local priceData = self.prices and self.prices[resource.id]
		price.Text = priceData and tostring(priceData.currentPrice) or "-"
		price.Size = UDim2.new(0.15, 0, 1, 0)
		price.Position = UDim2.new(0.25, 0, 0, 0)
		price.BackgroundTransparency = 1
		price.TextColor3 = Color3.fromRGB(255, 255, 180)
		price.TextSize = 18
		price.Font = Enum.Font.GothamBold
		price.TextXAlignment = Enum.TextXAlignment.Left
		price.Name = "PriceLabel"
		price.Parent = row

		-- Enhanced price trend visualization
		if priceData and priceData.priceHistory and #priceData.priceHistory > 1 then
			local trendFrame = Instance.new("Frame")
			trendFrame.Name = "TrendFrame"
			trendFrame.Size = UDim2.new(0.3, 0, 0.8, 0)
			trendFrame.Position = UDim2.new(0.4, 0, 0.1, 0)
			trendFrame.BackgroundTransparency = 1
			trendFrame.Parent = row

			-- Calculate trend data
			local history = priceData.priceHistory
			local min, max = history[1], history[1]
			for _, v in ipairs(history) do
				if v < min then
					min = v
				end
				if v > max then
					max = v
				end
			end
			local range = max - min
			if range == 0 then
				range = 1
			end

			-- Create trend line
			local line = Instance.new("Frame")
			line.Name = "TrendLine"
			line.Size = UDim2.new(1, 0, 0, 2)
			line.Position = UDim2.new(0, 0, 0.5, 0)
			line.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
			line.BorderSizePixel = 0
			line.Parent = trendFrame

			-- Add data points
			local n = math.min(20, #history)
			for i = #history - n + 1, #history do
				local v = history[i]
				local point = Instance.new("Frame")
				point.Size = UDim2.new(0.05, 0, 0.05, 0)
				point.Position = UDim2.new((i - #history + n - 1) / n, 0, 1 - ((v - min) / range), 0)
				point.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				point.BorderSizePixel = 0
				point.Parent = trendFrame

				-- Add prediction indicator if it's the last point
				if i == #history then
					local prediction = Instance.new("Frame")
					prediction.Size = UDim2.new(0.1, 0, 0.1, 0)
					prediction.Position = UDim2.new(1, 0, 0.5, 0)
					prediction.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
					prediction.BorderSizePixel = 0
					prediction.Parent = point
				end
			end
		end

		local buyBtn = Instance.new("TextButton")
		buyBtn.Text = "Buy"
		buyBtn.Size = UDim2.new(0.15, -5, 0.8, 0)
		buyBtn.Position = UDim2.new(0.7, 0, 0.1, 0)
		buyBtn.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
		buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyBtn.TextSize = 16
		buyBtn.Font = Enum.Font.GothamBold
		buyBtn.Parent = row
		buyBtn.MouseButton1Click:Connect(function()
			self:PromptBuySell(resource.id, "buy")
		end)

		local sellBtn = Instance.new("TextButton")
		sellBtn.Text = "Sell"
		sellBtn.Size = UDim2.new(0.15, -5, 0.8, 0)
		sellBtn.Position = UDim2.new(0.85, 5, 0.1, 0)
		sellBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 80)
		sellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		sellBtn.TextSize = 16
		sellBtn.Font = Enum.Font.GothamBold
		sellBtn.Parent = row
		sellBtn.MouseButton1Click:Connect(function()
			self:PromptBuySell(resource.id, "sell")
		end)

		y = y + 52
	end
end

function MarketUI:PromptBuySell(resourceId, action)
	local amount = tonumber(game:GetService("Players").LocalPlayer:PromptInput("Enter amount to " .. action .. ":"))
	if not amount or amount <= 0 then
		return
	end
	local remoteName = action == "buy" and "MarketBuy" or "MarketSell"
	local remote = ReplicatedStorage:FindFirstChild(remoteName)
	if remote then
		remote:FireServer(resourceId, amount)
	end
end

function MarketUI:ShowTransactionMessage(success, msg)
	if self.txMsgLabel then
		self.txMsgLabel:Destroy()
	end
	local label = Instance.new("TextLabel")
	label.Name = "TxMsgLabel"
	label.Text = msg
	label.Size = UDim2.new(1, 0, 0, 32)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 0.2
	label.BackgroundColor3 = success and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 120, 120)
	label.TextColor3 = Color3.fromRGB(30, 30, 30)
	label.TextSize = 18
	label.Font = Enum.Font.GothamBold
	label.Parent = self.marketPanel
	self.txMsgLabel = label
	-- Auto-hide after 2.5 seconds
	task.spawn(function()
		task.wait(2.5)
		if label and label.Parent then
			label:Destroy()
		end
	end)
end

function MarketUI:CreateHistoryButton()
	local btn = Instance.new("TextButton")
	btn.Name = "HistoryBtn"
	btn.Text = "History"
	btn.Size = UDim2.new(0, 100, 0, 32)
	btn.Position = UDim2.new(1, -110, 0, 5)
	btn.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
	btn.TextColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextSize = 16
	btn.Font = Enum.Font.GothamBold
	btn.Parent = self.marketPanel
	btn.MouseButton1Click:Connect(function()
		if self.historyPanelVisible then
			self:HideHistoryPanel()
		else
			self:RequestHistory()
		end
	end)
	self.historyBtn = btn
end

function MarketUI:RequestHistory()
	local remote = ReplicatedStorage:FindFirstChild("MarketTransactionHistory")
	if remote then
		remote:FireServer()
	end
end

function MarketUI:ShowHistoryPanel()
	if self.historyPanel then
		self.historyPanel:Destroy()
	end
	local panel = Instance.new("Frame")
	panel.Name = "HistoryPanel"
	panel.Size = UDim2.new(0, 440, 0, 260)
	panel.Position = UDim2.new(0, 20, 0, 190)
	panel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	panel.BackgroundTransparency = 0.1
	panel.BorderSizePixel = 0
	panel.Parent = self.marketPanel

	local title = Instance.new("TextLabel")
	title.Text = "Transaction History"
	title.Size = UDim2.new(1, 0, 0, 32)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.Parent = panel

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -10, 1, -42)
	scroll.Position = UDim2.new(0, 5, 0, 37)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Parent = panel

	-- Filter and search transactions
	local filteredHistory = {}
	for _, tx in ipairs(self.history) do
		if
			(self.filterType == "all" or tx.type == self.filterType)
			and (self.searchQuery == "" or string.find(string.lower(tx.resourceId), self.searchQuery))
		then
			table.insert(filteredHistory, tx)
		end
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(40 * #filteredHistory, 200))

	for i, tx in ipairs(filteredHistory) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 36)
		row.Position = UDim2.new(0, 0, 0, (i - 1) * 38)
		row.BackgroundTransparency = 1
		row.Parent = scroll

		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(0.7, 0, 1, 0)
		desc.Position = UDim2.new(0, 0, 0, 0)
		desc.BackgroundTransparency = 1
		desc.TextColor3 = tx.type == "buy" and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 180, 120)
		desc.TextSize = 15
		desc.Font = Enum.Font.Gotham
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.Text =
			string.format("%s %dx %s @ %d", tx.type == "buy" and "Bought" or "Sold", tx.amount, tx.resourceId, tx.price)
		desc.Parent = row

		local time = Instance.new("TextLabel")
		time.Size = UDim2.new(0.3, 0, 1, 0)
		time.Position = UDim2.new(0.7, 0, 0, 0)
		time.BackgroundTransparency = 1
		time.TextColor3 = Color3.fromRGB(180, 180, 255)
		time.TextSize = 14
		time.Font = Enum.Font.Gotham
		time.TextXAlignment = Enum.TextXAlignment.Right
		time.Text = os.date("%X", tx.timestamp)
		time.Parent = row
	end

	self.historyPanel = panel
	self.historyPanelVisible = true
end

function MarketUI:HideHistoryPanel()
	if self.historyPanel then
		self.historyPanel:Destroy()
		self.historyPanel = nil
	end
	self.historyPanelVisible = false
end

function MarketUI:CreateFilterButtons()
	local filterFrame = Instance.new("Frame")
	filterFrame.Name = "FilterFrame"
	filterFrame.Size = UDim2.new(0, 320, 0, 32)
	filterFrame.Position = UDim2.new(0, 10, 0, 110)
	filterFrame.BackgroundTransparency = 1
	filterFrame.Parent = self.marketPanel

	local function createFilterBtn(text, type, x)
		local btn = Instance.new("TextButton")
		btn.Text = text
		btn.Size = UDim2.new(0.3, -5, 1, 0)
		btn.Position = UDim2.new(x, 0, 0, 0)
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 14
		btn.Font = Enum.Font.Gotham
		btn.Parent = filterFrame

		btn.MouseButton1Click:Connect(function()
			self.filterType = type
			self:UpdateFilterButtons()
			self:ShowHistoryPanel()
		end)

		return btn
	end

	self.filterButtons = {
		all = createFilterBtn("All", "all", 0),
		buy = createFilterBtn("Buys", "buy", 0.33),
		sell = createFilterBtn("Sells", "sell", 0.66),
	}

	self:UpdateFilterButtons()
end

function MarketUI:UpdateFilterButtons()
	for type, btn in pairs(self.filterButtons) do
		btn.BackgroundColor3 = type == self.filterType and Color3.fromRGB(120, 180, 255) or Color3.fromRGB(60, 60, 80)
	end
end

function MarketUI:CreateSearchBox()
	local searchFrame = Instance.new("Frame")
	searchFrame.Name = "SearchFrame"
	searchFrame.Size = UDim2.new(0, 320, 0, 32)
	searchFrame.Position = UDim2.new(0, 10, 0, 150)
	searchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	searchFrame.BorderSizePixel = 0
	searchFrame.Parent = self.marketPanel

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Size = UDim2.new(1, -10, 1, -10)
	searchBox.Position = UDim2.new(0, 5, 0, 5)
	searchBox.BackgroundTransparency = 1
	searchBox.Text = ""
	searchBox.PlaceholderText = "Search transactions..."
	searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
	searchBox.TextSize = 14
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.Parent = searchFrame

	searchBox.Changed:Connect(function(prop)
		if prop == "Text" then
			self.searchQuery = searchBox.Text:lower()
			self:ShowHistoryPanel()
		end
	end)
end

return MarketUI

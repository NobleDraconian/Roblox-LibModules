--[[
	Slider.lua, written by @Fm-Trick

	local slider, changed_event = Slider.new(Function changed_function nil, GuiObject Parent nil, Number min 0, Number max 1, Boolean round false)
	
	slider:Disconnect() -- disconnect all input events
	
	slider:Reconnect() -- reconnect all input events
	
	slider:Destroy() -- destroy the slider UI and Object.
--]]

local UserInput = game:GetService("UserInputService")

local Slider = {}
	Slider.__index = Slider
	Slider.Cloner = script:WaitForChild("Slider")
	
	local CONTROLLER_DEADZONE = .15

	function Slider.new(changed_function, parent, map_min, map_max, round)	
		local self = setmetatable({}, Slider)
		self.Value = 0;
		self.Connections = {}
		self.Destroy = {}
		
		self.Bar = Slider.Cloner:Clone()
		self.Bar.Parent = parent
		self.Slider = self.Bar.Slider
		
		self.Min = map_min or 0
		self.Max = map_max or 1
		self.Round = round == nil and false or round
		
		self.Label = self.Bar:FindFirstChild("Label")
		
		self.Changed = Instance.new("BindableEvent")
		table.insert(self.Destroy, self.Changed)
		table.insert(self.Destroy, self.Bar)
		if changed_function then
			table.insert(self.Connections, self.Changed.Event:Connect(function(new_val, old_val)
				changed_function(new_val, old_val)
			end))
		end
		self:Reconnect()
		
		return self, self.Changed.Event
	end
	
	
	function Slider:Set(value, do_tween)
		value = math.clamp(value, self.Min, self.Max)
		self.Value = value
		
		local percent = (value - self.Min) / (self.Max - self.Min)
		
		
		self:Update(percent)
		
		if do_tween then
			self.Slider:TweenPosition(UDim2.new(percent,0,.5,0), "Out", "Linear", .5, true)
		else
			self.Slider.Position = UDim2.new(percent,0,.5,0)
		end
	end
	
	function Slider:Update(percent)
		local old_val = self.Value
		local new_val = self.Min + ((self.Max - self.Min) * percent)
		if self.Round then
			new_val = math.floor(new_val + .5)
		end
		self.Value = new_val
		if self.Label then
			self.Label.Text = tostring(new_val)
		end
		if self.Value ~= old_val then
			self.Changed:Fire(new_val, old_val)
		end
	end
	
	function Slider:Reconnect()
		local bar = self.Bar
		local slider = self.Slider
		local bar_size = bar.AbsoluteSize
		local b_i_b = bar.InputBegan:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
				self.Listening = true
			end
		end)
		local s_i_b = slider.InputBegan:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
				self.Listening = true
			end
		end)
		local i_e = UserInput.InputEnded:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
				self.Listening = nil
			end
		end)
		local selection_g = slider.SelectionGained:Connect(function()
			self.Listening = true
		end)
		local selection_l = slider.SelectionLost:Connect(function()
			self.Listening = nil
		end)
		local mouse_movement = UserInput.InputChanged:Connect(function(io)
			if self.Listening == true then
				local percent
				if io.KeyCode == Enum.KeyCode.Thumbstick1 then
					local movement = io.Position.X
					if math.abs(movement) > CONTROLLER_DEADZONE then
						percent = slider.Position.X.Scale + (movement > 0 and .01 or -.01)
					end
				elseif io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch then
					local bar_start, bar_end = bar.AbsolutePosition, bar.AbsolutePosition + bar_size
					local mouse_pos = io.Position
					local distance = bar_end.X - bar_start.X
					local difference_mouse = mouse_pos.X - bar_start.X
					percent = difference_mouse / (bar_size.X)
				end
				if percent then
					percent = math.clamp(percent, 0, 1)
					slider.Position = UDim2.new(percent,0,.5,0)
					self:Update(percent)
				end
			end
		end)
		table.insert(self.Connections, s_i_b)
		table.insert(self.Connections, b_i_b)
		table.insert(self.Connections, selection_g)
		table.insert(self.Connections, mouse_movement)
		table.insert(self.Connections, i_e)
		table.insert(self.Connections, selection_l)
	end
	
	function Slider:Disconnect()
		for i=1,#self.Connections do
			local c = self.Connections[i]
			c:Disconnect()
		end
	end
	
	function Slider:Destroy()
		for i=1,#self.Destroy do
			local d = self.Destroy[i]
			d:Destroy()
		end
		self.Destroy = {}
		self:Disconnect()
		self = nil
	end

return Slider
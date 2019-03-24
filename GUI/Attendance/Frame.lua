local Type, Version = "NastrandirRaidToolsAttendance", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 800
local height = 400

local WIDTH = {
    DROPDOWN = 150,
    BUTTON = 100
}

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        local raids = self:GetRaidList()
        if table.getn(raids.order) >= 1 then
            self.start_raid:SetList(raids.list, raids.order)
            self.start_raid:SetValue(raids.order[math.min(12, table.getn(raids.order))])

            self.end_raid:SetList(raids.list, raids.order)
            self.end_raid:SetValue(raids.order[1])
        end

        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local Roster = NastrandirRaidTools:GetModule("Roster")
        self.states = Attendance:GetStates()
        self.roster = Roster:GetRaidmember()
        self.data:SetRows(table.getn(self.roster) + 1)
        self.data:SetColumns(table.getn(self.states) + 1)

        table.sort(self.roster, function(a, b)
            local name_a = Roster:GetCharacterName(a)
            local name_b = Roster:GetCharacterName(b)

            return name_a < name_b
        end)

        table.sort(self.states, function(a, b)
            local order_a = Attendance:GetState(a).Order
            local order_b = Attendance:GetState(b).Order

            return order_a < order_b
        end)

        for i=1,table.getn(self.roster) do
            self.data:SetText(i+1, 1, Roster:GetCharacterName(self.roster[i]))
            self.data:SetData(i+1, 1, self.roster[i])
        end

        for i=1,table.getn(self.states) do
            local state = Attendance:GetState(self.states[i])
            self.data:SetText(1, i+1, state.Name)
            self.data:SetData(1, i+1, self.states[i])
        end

        self.start_raid:SetCallback("OnValueChanged", function(dropdown, event, value)
            local Attendance = NastrandirRaidTools:GetModule("Attendance")
            local date = Attendance:GetRaid(value).date
            local raids = self:FilterRaidList(date)
            self.end_raid:SetList(raids.list, raids.order)
            self.end_raid:SetValue(raids.order[1])
        end)
        self.analyse:SetCallback("OnClick", function(button, mouseButton)
            self:Analyse()
        end)
        self.raids:SetCallback("OnClick", function(button, mouseButton)
            local Attendance = NastrandirRaidTools:GetModule("Attendance")
            Attendance:ShowRaidList()
        end)
        self.configuration:SetCallback("OnClick", function(button, mouseButton)
            local Attendance  = NastrandirRaidTools:GetModule("Attendance")
            Attendance:ShowConfiguration()
        end)
    end,
    ["SetWidth"] = function(self, w)
        self.widget:SetWidth(w)
    end,
    ["SetHeight"] = function(self, h)
        self.widget:SetHeight(h)
    end,
    ["OnHeightSet"] = function(self, height)
        self.top_bar:SetHeight(40)
        self.view:SetHeight(self.widget.frame:GetHeight() - self.top_bar.frame:GetHeight())
    end,
    ["OnWidthSet"] = function(self, width)
        self.widget:SetWidth(width)
        self.top_bar:SetWidth(width)
        self.top_bar.spacer:SetWidth(width - 2 * WIDTH.DROPDOWN - 3 * WIDTH.BUTTON - 7)
    end,
    ["GetRaidList"] = function(self)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        return Attendance:GetRaidList()
    end,
    ["FilterRaidList"] = function(self, start_date)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        return Attendance:GetRaidList(tonumber(start_date))
    end,
    ["Analyse"] = function(self)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local Roster = NastrandirRaidTools:GetModule("Roster")

        local start_raid = self.start_raid:GetValue()
        local end_raid = self.end_raid:GetValue()
        local start_date = Attendance:GetRaid(start_raid).date
        local end_date = Attendance:GetRaid(end_raid).date

        local attendance_data = {}
        local raid_list = Attendance:GetRaidList(start_date, end_date).order
        for _, raid_uid in ipairs(raid_list) do
            local raid = Attendance:GetRaid(raid_uid)

            for index, entry in ipairs(Attendance:GetRaidParticipation(raid_uid)) do
                local main_uid = Roster:GetMainUID(entry.member)

                if not attendance_data[main_uid] then
                    attendance_data[main_uid] = {
                        state = nil,
                        timestamp = nil,
                        duration = 0,
                        states = {}
                    }
                end

                local player = attendance_data[main_uid]
                if not player.state then
                    -- First occurence in the actual raid
                    player.state = entry.state
                    player.timestamp = entry.time
                else
                    local duration = NastrandirRaidTools:GetDuration(player.timestamp, entry.time)
                    player.duration = player.duration + duration
                    player.states[player.state] = (player.states[player.state] or 0) + duration
                    player.state = entry.state
                    player.timestamp = entry.time
                end
            end

            for main_uid, player in pairs(attendance_data) do
                if player.state then
                    local duration = NastrandirRaidTools:GetDuration(player.timestamp, raid.end_time)
                    player.duration = player.duration + duration
                    player.states[player.state] = (player.states[player.state] or 0) + duration
                    player.state = nil
                    player.timestamp = nil
                end
            end
        end

        local tmp_db = NastrandirRaidTools:GetModuleDB("Temporary")
        tmp_db = attendance_data

        for p=1,table.getn(self.roster) do
            for s=1,table.getn(self.states) do
                local player_uid = self.data:GetData(p+1, 1)
                local state_uid = self.data:GetData(1, s+1)

                if attendance_data[player_uid] then
                    local total = attendance_data[player_uid].duration
                    local time = 0
                    if attendance_data[player_uid].states[state_uid] then
                        time = attendance_data[player_uid].states[state_uid]
                    else
                        --print("State not found", self.data:GetText(1, s+1), ":", self.data:GetData(1, s+1))
                    end

                    local str = string.format("%d%%", ((time / total) * 100) + 0.5)
                    self.data:SetText(p+1, s+1, str)
                else
                    self.data:SetText(p+1, s+1, "0%")
                end


            end
        end
    end
}


local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetLayout("Flow")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local top_bar = AceGUI:Create("SimpleGroup")
    widget.top_bar = top_bar
    top_bar:SetLayout("Flow")
    top_bar:SetWidth(widget.frame:GetWidth())
    top_bar.frame:SetBackdropColor(0, 0, 0, 0)
    widget:AddChild(top_bar)

    local start_raid = AceGUI:Create("Dropdown")
    top_bar.start_raid = start_raid
    start_raid:SetWidth(WIDTH.DROPDOWN)
    start_raid:SetLabel("Start")
    top_bar:AddChild(start_raid)

    local end_raid = AceGUI:Create("Dropdown")
    top_bar.end_raid = end_raid
    end_raid:SetWidth(WIDTH.DROPDOWN)
    end_raid:SetLabel("End")
    top_bar:AddChild(end_raid)

    local analyse = AceGUI:Create("Button")
    top_bar.analyse = analyse
    analyse:SetText("Analyse")
    analyse:SetWidth(WIDTH.BUTTON)
    top_bar:AddChild(analyse)

    local spacer = AceGUI:Create("NastrandirRaidToolsSpacer")
    top_bar.spacer = spacer
    spacer:SetHeight(20)
    spacer:SetWidth(1)
    spacer:SetBackdropColor(0, 0, 0, 0)
    top_bar:AddChild(spacer)

    local raids = AceGUI:Create("Button")
    top_bar.analyse = raids
    raids:SetText("Raids")
    raids:SetWidth(WIDTH.BUTTON)
    top_bar:AddChild(raids)

    local configuration = AceGUI:Create("Button")
    top_bar.analyse = configuration
    configuration:SetText("Configuration")
    configuration:SetWidth(WIDTH.BUTTON)
    top_bar:AddChild(configuration)

    local view = AceGUI:Create("SimpleGroup")
    widget.view = view
    view:SetLayout("Fill")
    view:SetWidth(widget.frame:GetWidth())
    view:SetHeight(widget.frame:GetHeight() - 50)
    view.frame:SetBackdropColor(0, 0, 0, 0)
    widget:AddChild(view)

    local data = AceGUI:Create("NastrandirRaidToolsTable")
    view.data = data
    data:SetRows(25)
    data:SetColumns(5)
    view:AddChild(data)

    local widget = {
        frame = widget.frame,
        widget = widget,
        top_bar = top_bar,
        start_raid = start_raid,
        end_raid = end_raid,
        analyse = analyse,
        raids = raids,
        configuration = configuration,
        view = view,
        data = data,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
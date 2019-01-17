local Type, Version = "NastrandirRaidToolsAttendanceConfigurationStatesEdit", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 800
local height = 400

local WIDTH = {
    NAME = 0.77,
    COUNT_IN = 0.17,
    MESSAGES_EDIT = 0.95,

}

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        self.name:SetCallback("OnEnterPressed", function()
            self.widget:SetTitle(self.name:GetText())
            self:Save()
        end)

        self.track_alts:SetCallback("OnValueChanged", function()
            self:Save()
        end)

        self.enter:SetCallback("OnEnterPressed", function()
            self:Save()
        end)

        self.swap:SetCallback("OnEnterPressed", function()
            self:Save()
        end)

        self.leave:SetCallback("OnEnterPressed", function()
            self:Save()
        end)

        self.button_down:SetCallback("OnClick", function()
            print("Searching for", self.order + 1)

            local other_uid = self:GetStateByOrder(self.order + 1)
            print("Found", other_uid)

            if other_uid then
                print("Updating other state in DB")
                local db = NastrandirRaidTools:GetModuleDB("Attendance")
                db.states[other_uid].Order = self.order

                print("Updating myself in DB")
                self.order = self.order + 1
                self:Save()

                self.states_widget:Initialize()
            end
        end)

        self.button_up:SetCallback("OnClick", function()
            local other_uid = self:GetStateByOrder(self.order - 1)

            if other_uid then
                local db = NastrandirRaidTools:GetModuleDB("Attendance")
                db.states[other_uid].Order = self.order

                self.order = self.order - 1
                self:Save()

                self.states_widget:Initialize()
            end
        end)
    end,
    ["SetWidth"] = function(self, w)
        self.widget:SetWidth(w)
    end,
    ["SetHeight"] = function(self, h)
        self.widget:SetHeight(h)
    end,
    ["OnHeightSet"] = function(self, height)

    end,
    ["OnWidthSet"] = function(self, width)
        self.name:SetWidth(width * WIDTH.NAME)
        self.track_alts:SetWidth(width * WIDTH.COUNT_IN)
        self.messages:SetWidth(width)

        local w = self.messages.frame:GetWidth()
        self.enter:SetWidth(WIDTH.MESSAGES_EDIT * w)
        self.swap:SetWidth(WIDTH.MESSAGES_EDIT * w)
        self.leave:SetWidth(WIDTH.MESSAGES_EDIT * w)
    end,
    ["SetUID"] = function(self, uid)
        self.uid = uid
    end,
    ["SetStatesWidget"] = function(self, widget)
        self.states_widget = widget
    end,
    ["Load"] = function(self)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        if not db.states[self.uid] then
            db.states[self.uid] = {
                Name = "New State",
                TrackAlts = true,
                Order = self:GetStatesCount() + 1,
                LogMessages = {
                    Enter = "",
                    Swap = "",
                    Leave = ""
                }
            }
        end

        local state = db.states[self.uid]
        self.widget:SetTitle(state.Name)
        self.name:SetText(state.Name)
        self.track_alts:SetValue(state.TrackAlts or false)
        self.enter:SetText(state.LogMessages.Enter)
        self.swap:SetText(state.LogMessages.Swap)
        self.leave:SetText(state.LogMessages.Leave)
        self.order = state.Order
    end,
    ["Save"] = function(self)
        print("Saving", self.uid)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        db.states[self.uid] = {
            Name = self.name:GetText(),
            TrackAlts = self.track_alts:GetValue(),
            Order = self.order,
            LogMessages = {
                Enter = self.enter:GetText(),
                Swap = self.swap:GetText(),
                Leave = self.leave:GetText()
            }
        }
    end,
    ["GetStatesCount"] = function(self)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        local count = 0
        for uid, state in pairs(db.states) do
            count = count + 1
        end

        return count
    end,
    ["GetStateByOrder"] = function(self, order)
        print("Searching", order)

        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        for uid, state in pairs(db.states) do
            print("Checking state", uid, "with order", state.Order)
            if state.Order == order then
                return uid
            end
        end
    end
}


local function Constructor()
    local widget = AceGUI:Create("InlineGroup")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget:SetLayout("Flow")
    widget:SetTitle("StateName")

    local top_bar = AceGUI:Create("SimpleGroup")
    widget.top_bar = top_bar
    top_bar:SetWidth(widget.frame:GetWidth())
    top_bar:SetHeight(30)
    top_bar:SetLayout("Flow")
    widget:AddChild(top_bar)

    local spacer = AceGUI:Create("NastrandirRaidToolsSpacer")
    widget.spacer = spacer
    spacer:SetWidth(0.62 * top_bar.frame:GetWidth())
    spacer:SetHeight(30)
    spacer:SetBackdropColor(0, 0, 0, 0)
    top_bar:AddChild(spacer)

    local button_down = AceGUI:Create("Button")
    top_bar.button_down = button_down
    button_down:SetText("Down")
    button_down:SetWidth(0.1 * top_bar.frame:GetWidth())
    top_bar:AddChild(button_down)

    local button_up = AceGUI:Create("Button")
    top_bar.button_up = button_up
    button_up:SetText("Up")
    button_up:SetWidth(0.1 * top_bar.frame:GetWidth())
    top_bar:AddChild(button_up)


    local name = AceGUI:Create("EditBox")
    widget.name = name
    name:SetLabel("Name")
    name:SetText("StateName")
    name:SetWidth(widget.frame:GetWidth() * 0.77)
    widget:AddChild(name)

    local track_alts = AceGUI:Create("CheckBox")
    widget.track_alts = track_alts
    track_alts:SetLabel("Track Alts")
    track_alts:SetWidth(widget.frame:GetWidth() * 0.17)
    widget:AddChild(track_alts)

    local messages = AceGUI:Create("InlineGroup")
    widget.messages = messages
    messages:SetWidth(widget.frame:GetWidth())
    messages:SetTitle("Messages")
    widget:AddChild(messages)

    local enter = AceGUI:Create("EditBox")
    messages.enter = enter
    enter:SetWidth(messages.frame:GetWidth())
    enter:SetLabel("Enter")
    messages:AddChild(enter)

    local swap = AceGUI:Create("EditBox")
    messages.swap = swap
    swap:SetWidth(messages.frame:GetWidth())
    swap:SetLabel("Character Swap")
    messages:AddChild(swap)

    local leave = AceGUI:Create("EditBox")
    messages.leave = leave
    leave:SetWidth(messages.frame:GetWidth())
    leave:SetLabel("Leave")
    messages:AddChild(leave)

    local widget = {
        frame = widget.frame,
        widget = widget,
        button_down = button_down,
        button_up = button_up,
        name = name,
        track_alts = track_alts,
        messages = messages,
        enter = enter,
        swap = swap,
        leave = leave,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
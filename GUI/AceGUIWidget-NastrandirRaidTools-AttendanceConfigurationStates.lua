local Type, Version = "NastrandirRaidToolsAttendanceConfigurationStates", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 800
local height = 400

local WIDTH = {
    SCROLL_FRAME = 0.97,
    ADD_BUTTON = 0.97
}

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        self.scroll_frame:ReleaseChildren()

        self.add_state:SetCallback("OnClick", function()
            self:NewState()
        end)

        self:LoadStates()
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
        self.scroll_frame:SetWidth(WIDTH.SCROLL_FRAME * width)
        self.add_state:SetWidth(WIDTH.ADD_BUTTON * width)
    end,
    ["NewState"] = function(self)
        -- Get UID
        local uid = NastrandirRaidTools:CreateUID("Attendance-State")

        -- Add to the GUI
        self:AddState(uid)
    end,
    ["AddState"] = function(self, uid)
        local state_frame = AceGUI:Create("NastrandirRaidToolsAttendanceConfigurationStatesEdit")
        state_frame:Initialize()
        state_frame:SetUID(uid)
        state_frame:SetStatesWidget(self)
        state_frame:Load()
        self.scroll_frame:AddChild(state_frame)
    end,
    ["LoadStates"] = function(self)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.states then
            db.states = {}
        end

        local state_list = {}
        for uid, state in pairs(db.states) do
            table.insert(state_list, {
                uid = uid,
                state = state
            })
        end

        table.sort(state_list, function(a, b)
            return a.state.Order < b.state.Order
        end)

        for index, entry in ipairs(state_list) do
            self:AddState(entry.uid)
        end
    end
}


local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget:SetLayout("Flow")
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local scroll_frame = AceGUI:Create("ScrollFrame")
    widget.scroll_frame = scroll_frame
    scroll_frame:SetWidth(widget.frame:GetWidth())
    scroll_frame:SetHeight(400)
    scroll_frame:SetLayout("Flow")
    widget:AddChild(scroll_frame)

    local add_state = AceGUI:Create("Button")
    widget.add_state = add_state
    add_state:SetWidth(widget.frame:GetWidth())
    add_state:SetText("Add State")
    widget:AddChild(add_state)

    local widget = {
        frame = widget.frame,
        widget = widget,
        scroll_frame = scroll_frame,
        add_state = add_state,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
local Type, Version = "NastrandirRaidToolsAttendanceRaidDetails", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 800
local height = 28

local WIDTH = {
    NAME = 1,
    DATE = 1,
    TIME = 0.49,
    SPACER = 0.45
}

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        self.bottom:ReleaseChildren()

        self.delete:SetCallback("OnClick", function()
            self:AskDelete()
        end)

        self.save:SetCallback("OnClick", function()
            self:Save()
        end)
    end,
    ["SetWidth"] = function(self, w)
        self.widget:SetWidth(w)
    end,
    ["SetHeight"] = function(self, h)
        self.widget:SetHeight(h)
    end,
    ["OnWidthSet"] = function(self, width)
        self.name:SetWidth(WIDTH.NAME * self.widget.frame:GetWidth())
        self.date:SetWidth(WIDTH.DATE * self.widget.frame:GetWidth())
        self.start_time:SetWidth(WIDTH.TIME * self.widget.frame:GetWidth())
        self.end_time:SetWidth(WIDTH.TIME * self.widget.frame:GetWidth())
        self.spacer:SetWidth(WIDTH.SPACER * self.widget.frame:GetWidth())
    end,
    ["SetUID"] = function(self, uid)
        self.uid = uid
    end,
    ["GetUID"] = function(self)
        return self.uid
    end,
    ["AskDelete"] = function(self)
        local question = AceGUI:Create("InlineGroup")
        question:SetLayout("Flow")
        question:SetWidth(self.bottom.frame:GetWidth())
        question:SetTitle("Are you sure?")
        self.bottom:AddChild(question)

        local spacer_left = AceGUI:Create("SimpleGroup")
        spacer_left:SetWidth(question.frame:GetWidth() / 4 - 5)
        spacer_left:SetLayout("Flow")
        spacer_left:SetHeight(25)
        spacer_left.frame:SetBackdropColor(0, 0, 0, 0)
        question:AddChild(spacer_left)

        local button_no = AceGUI:Create("Button")
        button_no:SetText("No")
        button_no:SetWidth(question.frame:GetWidth() / 4)
        button_no:SetCallback("OnClick", function()
            local Attendance = NastrandirRaidTools:GetModule("Attendance")
            Attendance:ShowRaid(self.uid)
        end)
        question:AddChild(button_no)

        local button_yes = AceGUI:Create("Button")
        button_yes:SetText("Yes")
        button_yes:SetWidth(question.frame:GetWidth() / 4)
        button_yes:SetCallback("OnClick", function()
            self:Delete()
            local Attendance = NastrandirRaidTools:GetModule("Attendance")
            Attendance:ShowRaidList()
        end)
        question:AddChild(button_yes)

        local spacer_right = AceGUI:Create("SimpleGroup")
        spacer_right:SetWidth(question.frame:GetWidth() / 4 - 5)
        spacer_right:SetLayout("Flow")
        spacer_right:SetHeight(25)
        spacer_right.frame:SetBackdropColor(0, 0, 0, 0)
        question:AddChild(spacer_right)
    end,
    ["Delete"] = function(self)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        db.raids[self.uid] = nil

        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaidList()
    end,
    ["Save"] = function(self)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        db.raids[self.uid] = {
            name = self.name:GetText(),
            date = tonumber(self.date:GetText()),
            start_time = tonumber(self.start_time:GetText()),
            end_time = tonumber(self.end_time:GetText())
        }

        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaidList()
    end,
    ["Load"] = function(self)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        local raid = db.raids[self.uid]
        self.name:SetText(raid.name)
        self.date:SetText(raid.date)
        self.start_time:SetText(raid.start_time)
        self.end_time:SetText(raid.end_time)
    end
}


local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget:SetLayout("Flow")
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local name = AceGUI:Create("EditBox")
    widget.name = name
    name:SetLabel("Name")
    name:SetWidth(WIDTH.NAME * widget.frame:GetWidth())
    widget:AddChild(name)

    local date = AceGUI:Create("EditBox")
    widget.date = date
    date:SetLabel("Date (YYYYMMDD)")
    date:SetWidth(WIDTH.DATE * widget.frame:GetWidth())
    widget:AddChild(date)

    local start_time = AceGUI:Create("EditBox")
    widget.start_time = start_time
    start_time:SetLabel("Start Time (HHMM)")
    start_time:SetWidth(WIDTH.TIME * widget.frame:GetWidth())
    widget:AddChild(start_time)

    local end_time = AceGUI:Create("EditBox")
    widget.end_time = end_time
    end_time:SetLabel("End Time (HHMM)")
    end_time:SetWidth(WIDTH.TIME * widget.frame:GetWidth())
    widget:AddChild(end_time)

    local spacer = AceGUI:Create("NastrandirRaidToolsSpacer")
    widget.spacer = spacer
    spacer:SetWidth(WIDTH.SPACER * widget.frame:GetWidth())
    widget:AddChild(spacer)

    local delete = AceGUI:Create("Button")
    widget.delete = delete
    delete:SetText("Delete")
    widget:AddChild(delete)

    local save = AceGUI:Create("Button")
    widget.save = save
    save:SetText("Save")
    widget:AddChild(save)

    local bottom = AceGUI:Create("SimpleGroup")
    widget.bottom = bottom
    bottom:SetWidth(widget.frame:GetWidth())
    bottom:SetLayout("Flow")
    bottom.frame:SetBackdropColor(0, 0, 0, 0)
    widget:AddChild(bottom)

    local widget = {
        frame = widget.frame,
        widget = widget,
        name = name,
        date = date,
        start_time = start_time,
        end_time = end_time,
        delete = delete,
        save = save,
        spacer = spacer,
        bottom = bottom,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
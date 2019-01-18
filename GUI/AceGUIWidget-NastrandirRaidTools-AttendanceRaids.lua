local Type, Version = "NastrandirRaidToolsAttendanceRaids", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width = 820
local height = 500

local WIDTH = {
    SCROLL_FRAME = 0.97,
}

local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width)
        self:SetHeight(height)
    end,
    ["Initialize"] = function(self)
        self.scroll_frame:ReleaseChildren()

        self.add_raid:SetCallback("OnClick", function()
            self:NewRaid()
        end)

        self:LoadRaids()
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
    end,
    ["NewRaid"] = function(self)
        -- Get UID
        local uid = NastrandirRaidTools:CreateUID("Attendance-Raid")

        -- Do the DB stuff
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        db.raids[uid] = {
            name = "New Raid",
            date = NastrandirRaidTools:Today(),
            start_time = 2000,
            end_time = 2300
        }

        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        Attendance:ShowRaid(uid)
    end,
    ["AddRaid"] = function(self, uid, title)
        local raid = AceGUI:Create("NastrandirRaidToolsAttendanceRaidsRaid")
        raid:Initialize()
        raid:SetUID(uid)
        raid:SetTitle(title)
        self.scroll_frame:AddChild(raid)
    end,
    ["LoadRaids"] = function(self)
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.raids then
            db.raids = {}
        end

        local raid_list = {}
        for uid, raid in pairs(db.raids) do
            table.insert(raid_list, {
                uid = uid,
                raid = raid
            })
        end

        table.sort(raid_list, function(a, b)
            return a.raid.date > b.raid.date
        end)

        for index, entry in ipairs(raid_list) do
            local raid_date = NastrandirRaidTools:SplitDate(entry.raid.date)
            self:AddRaid(entry.uid, string.format("%s, %02d.%02d.%04d", entry.raid.name, raid_date.day, raid_date.month, raid_date.year))
        end
    end
}


local function Constructor()
    local widget = AceGUI:Create("SimpleGroup")
    widget:SetHeight(height)
    widget:SetWidth(width)
    widget:SetLayout("Flow")
    widget.frame:SetBackdropColor(0, 0, 0, 0)

    local top_bar = AceGUI:Create("SimpleGroup")
    widget.top_bar = top_bar
    top_bar:SetWidth(widget.frame:GetWidth())
    top_bar:SetHeight(30)
    top_bar:SetLayout("Flow")
    top_bar.frame:SetBackdropColor(0, 0, 0, 0)
    widget:AddChild(top_bar)

    local spacer = AceGUI:Create("NastrandirRaidToolsSpacer")
    top_bar.spacer = spacer
    spacer:SetWidth(0.62 * top_bar.frame:GetWidth())
    spacer:SetHeight(30)
    spacer:SetBackdropColor(0, 0, 0, 0)
    top_bar:AddChild(spacer)

    local add_raid = AceGUI:Create("Button")
    top_bar.add_raid = add_raid
    add_raid:SetWidth(0.25 * top_bar.frame:GetWidth())
    add_raid:SetText("Add Raid")
    top_bar:AddChild(add_raid)

    local scroll_frame = AceGUI:Create("ScrollFrame")
    widget.scroll_frame = scroll_frame
    scroll_frame:SetWidth(widget.frame:GetWidth())
    scroll_frame:SetHeight(400)
    scroll_frame:SetLayout("Flow")
    widget:AddChild(scroll_frame)

    local widget = {
        frame = widget.frame,
        widget = widget,
        add_raid = add_raid,
        scroll_frame = scroll_frame,
        type = Type
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
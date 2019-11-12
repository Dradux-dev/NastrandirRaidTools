local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidLog", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 500

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    widget.entries = {}

    function widget:SetRaid(uid)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local log = Attendance:GetRaidLog(uid)

        StdUi:ObjectList(
            widget,
            widget.entries,
            function(parent, value, i, key)
                -- Create
                local itemFrame = StdUi:NastrandirRaidTools_Attendance_RaidLogEntry(parent)
                itemFrame:SetData(value)
                return itemFrame
            end,
            function(parent, itemFrame, value, i, key)
                itemFrame:SetData(value)
            end,
            log,
            2,
            0,
            0
        )
    end

    return widget
end)
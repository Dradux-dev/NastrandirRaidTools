local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidRecordingTimelineNow", function(self, parent)
    local width = 12
    local height = 12

    local button = CreateFrame("BUTTON", "RaidRecordingTimelineNow", parent, "OptionsListButtonTemplate")
    self:InitWidget(button)
    self:SetObjSize(button, width, height)

    local icon = button:CreateTexture(nil, "OVERLAY")
    button.icon = icon
    icon:SetBlendMode("ADD")
    icon:SetWidth(width)
    icon:SetHeight(height)
    icon:SetPoint("LEFT", button, "LEFT", 0, 0)
    icon:SetTexture("Interface\\AddOns\\NastrandirRaidTools\\media\\icons\\circle")

    function button:SetTime(time)
        button.time = time
    end

    button:SetScript("OnEnter", function()
        button.highlight:Hide()
    end)

    button:SetScript("OnClick", function()
        if button.time then
            parent:SetTime(button.time)
        end
    end)

    return button
end)
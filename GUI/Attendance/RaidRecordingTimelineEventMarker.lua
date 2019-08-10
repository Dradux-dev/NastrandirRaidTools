local StdUi = LibStub("StdUi")
local count = 0

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_RaidRecordingTimelineEventMarker", function(self, parent, displayType)
    local width = 16
    local height = 16

    count = count + 1

    local button = CreateFrame("BUTTON", "RaidRecordingTimelineEventMarker"..count, parent, "OptionsListButtonTemplate")
    self:InitWidget(button)
    self:SetObjSize(button, width, height)

    local topicon = button:CreateTexture(nil, "OVERLAY")
    button.topicon = topicon
    topicon:SetBlendMode("ADD")
    topicon:SetWidth(width)
    topicon:SetHeight(height)
    topicon:SetPoint("LEFT", button, "LEFT", 0, 0)
    topicon:SetTexture("Interface\\AddOns\\NastrandirRaidTools\\media\\icons\\marker-top")

    local bottomicon = button:CreateTexture(nil, "OVERLAY")
    button.bottomicon = bottomicon
    bottomicon:SetBlendMode("ADD")
    bottomicon:SetWidth(width)
    bottomicon:SetHeight(height)
    bottomicon:SetPoint("LEFT", button, "LEFT", 0, 0)
    bottomicon:SetTexture("Interface\\AddOns\\NastrandirRaidTools\\media\\icons\\marker-bottom")

    local tooltip = StdUi:FrameTooltip(button, "|cFFFF0000Title|r\nFirst line of text.\nSecond line of text.", "RaidRecordingTimelineEventMarker"..count .. "_Tooltip", "TOPRIGHT", false)
    button.tooltip = tooltip
    tooltip:Hide()

    function button:SetTime(time)
        button.time = time
    end

    function button:SetData(data)
        local Attendance = NastrandirRaidTools:GetModule("Attendance")
        local Roster = NastrandirRaidTools:GetModule("Roster")

        local add_empty_line = false

        local time = NastrandirRaidTools:SplitTime(button.time or 1900)
        local text = string.format("%02d:%02d\n", time.hours, time.minutes)

        for index, entry in ipairs(data) do
            if entry.event == "section_changed" then
                add_empty_line = true
            elseif entry.event == "state_changed" then
                if add_empty_line then
                    text = text .. "\n"
                    add_empty_line = false
                end

                local main = Roster:GetCharacter(entry.main)
                if entry.old then
                    local old_state = Attendance:GetState(entry.old)
                    local new_state = Attendance:GetState(entry.new)

                    text = text .. string.format("%s: %s -> %s\n",
                            NastrandirRaidTools:ClassColorText(main.name, main.class),
                            NastrandirRaidTools:ColorText(old_state.Name, unpack(old_state.color or {1, 1,1 ,1, 1})),
                            NastrandirRaidTools:ColorText(new_state.Name, unpack(new_state.color or {1, 1,1 ,1, 1}))
                    )
                else
                    local new_state = Attendance:GetState(entry.new)

                    text = text .. string.format("%s: -> %s\n",
                            NastrandirRaidTools:ClassColorText(main.name, main.class),
                            NastrandirRaidTools:ColorText(new_state.Name, unpack(new_state.color or {1, 1,1 ,1, 1}))
                    )
                end
            elseif entry.event == "character_changed" then
                if add_empty_line then
                    text = text .. "\n"
                    add_empty_line = false
                end

                local main = Roster:GetCharacter(entry.main)
                local old = Roster:GetCharacter(entry.old)
                local new = Roster:GetCharacter(entry.new)

                text = text .. string.format("%s: %s -> %s\n",
                        NastrandirRaidTools:ClassColorText(main.name, main.class),
                        NastrandirRaidTools:ClassColorText(old.name, old.class),
                        NastrandirRaidTools:ClassColorText(new.name, new.class)
                )
            end
        end

        button.tooltip:SetText(text)
    end

    function button:SetDisplayType(displayType)
        if displayType=="TOP" then
            button.topicon:Show()
            button.bottomicon:Hide()
            button.tooltip.anchor = "TOPRIGHT"
        elseif displayType=="BOTTOM" then
            button.topicon:Hide()
            button.bottomicon:Show()
            button.tooltip.anchor = "BOTTOMRIGHT"
        else
            print(string.format("%s: Unknown displayType %s", "NastrandirRaidTools_Attendance_RaidRecordingTimelineEventMarker", displayType))
        end
    end

    button:SetScript("OnEnter", function()
        button.highlight:Hide()
        button.tooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        button.tooltip:Hide()
    end)

    button:SetScript("OnClick", function()
        if button.time then
            parent:SetTime(button.time)
        end
    end)

    button:SetDisplayType(displayType)
    return button
end)
local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Roster_ColumnFrame", function(self, parent, width, height)
    width = width or 180
    height = height or 300


    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local title = StdUi:Label(widget, "", 14)
    widget.title = title
    title:SetTextColor(1, 1, 0, 1)
    title:SetJustifyH("CENTER")
    title:SetJustifyV("CENTER")
    StdUi:GlueTop(title, widget, 0, 0)

    local contentPanel, contentFrame, contentChild, contentBar = StdUi:ScrollFrame(widget, widget:GetWidth(), height - (16 + 24))
    widget.content = {
        panel = contentPanel,
        frame = contentFrame,
        child = contentChild,
        bar = contentBar,
        children = {}
    }
    StdUi:GlueTop(contentPanel, widget, 0, -16, "LEFT")

    local button = StdUi:NastrandirRaidTools_MenuButton(widget, "Add")
    widget.button = button
    button:SetWidth(width)
    StdUi:GlueBottom(button, widget, 0, 0, true)

    function widget:SetName(title)
        widget.titletext = title
        widget.title:SetText((title or "") .. " (" .. (widget.count or 0) .. ")")
    end

    function widget:SetCount(count)
        widget.count = count
        widget.title:SetText((widget.titletext or "") .. " (" .. (widget.count or 0) .. ")")
    end

    widget.createButton = function(uid, name, class)
        return StdUi:NastrandirRaidTools_Roster_ClassButton(widget.content.child, uid, name, class)
    end

    function widget:GetClassButton(member)
        if member.button then
            ViragDevTool_AddData(member, member.name .. " already has a button")
            return member.button
        end

        if not widget.unusedButtons then
            widget.unusedButtons = {}
        end

        if #widget.unusedButtons >= 1 then
            local button = widget.unusedButtons[1]
            table.remove(widget.unusedButtons, 1)
            ViragDevTool_AddData(button, "Reusing button of " .. button:GetName() .. " for " .. member.name)
            button:SetUID(member.uid)
            button:SetName(member.name)
            button:SetClass(member.class)
            member.button = button
        else
            ViragDevTool_AddData(member, "Creating new button for " .. member.name)
            local button = widget.createButton(member.uid, member.name, member.class)
            member.button = button
        end

        return member.button
    end

    function widget:AddMember(member)
        if not widget.members then
            widget.members = {}
        end

        member.button = widget:GetClassButton(member)
        member.button:Show()
        table.insert(widget.members, member)

        widget:SetCount((widget.count or 0) + 1)
    end

    function widget:ReleaseMember()
        if not widget.members then
            widget.members = {}
        end

        -- Move all buttons to unused
        for _, member in ipairs(widget.members) do
            if member.button then
                member.button:Hide()
                table.insert(widget.unusedButtons, member.button)
                member.button = nil
            end
        end

        widget.members = {}
        widget:SetCount(0)
    end

    function widget:ShowAddButton()
        widget.button:Show()
    end

    function widget:HideAddButton()
        widget.button:Hide()
    end

    function widget:SetAddFunction(func)
        widget.button:SetScript("OnClick", func)
    end

    function widget:Sort()
        local actual_shown = {}
        for _, member in ipairs(widget.members) do
            if member.button and member.button:IsShown() then
                table.insert(actual_shown, {
                    name = member.name,
                    class = member.class,
                    uid = member.uid,
                    button = member.button
                })
            end
        end

        table.sort(actual_shown, function(a, b)
            local new_player = "New Player"

            if a.name == new_player and b.name ~= new_player then
                return false
            elseif a.name ~= new_player and b.name == new_player then
                return true
            end

            if a.class < b.class then
                return true
            elseif a.class > b.class then
                return false
            end

            return a.name < b.name
        end)

        for index, entry in ipairs(actual_shown) do
            entry.button:ClearAllPoints()

            if index == 1 then
                StdUi:GlueTop(entry.button, widget.content.child, 0, 0, "LEFT")
            else
                local lastButton = actual_shown[index - 1].button
                StdUi:GlueBelow(entry.button, lastButton, 0, 0)
            end
        end
    end

    function widget:Filter(options)
        local count = 0

        local name = options.name
        local only_raidmember = options.raidmember
        local show_alts = options.alts

        if not widget.members then
            widget.members = {}
        end

        for index, entry in ipairs(widget.members) do
            local add = true

            local Roster = NastrandirRaidTools:GetModule("Roster")
            local character = Roster:GetCharacter(entry.uid)

            -- Hide name mismatch
            if name ~= "" and not character.name:lower():match(name:lower()) then
                add = false
            end

            -- Hide non raidmembers
            if only_raidmember and not character.raidmember then
                add = false
            end

            -- Hide alts
            if not show_alts and character.main then
                add = false
            end

            if add then
                entry.button:Show()
                count = count + 1
            else
                entry.button:Hide()
            end

            widget:SetCount(count)
            widget:Sort()
        end
    end

    widget:SetScript("OnShow", function()
        widget.content.frame:SetWidth(widget:GetWidth() - widget.content.bar:GetWidth() - 5)
        widget.content.child:SetWidth(widget:GetWidth())
        widget.content.panel:SetWidth(widget:GetWidth())
    end)

    return widget
end)
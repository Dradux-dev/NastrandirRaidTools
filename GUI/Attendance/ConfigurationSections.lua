local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("NastrandirRaidTools_Attendance_ConfigurationSections", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 44

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local add = StdUi:Button(widget, 80, 24, "Add Section")
    widget.add = add
    StdUi:GlueTop(add, widget, 10, -10, "LEFT")

    function widget:DrawSections()
        if not widget.itemFrames then
            widget.itemFrames = {}
        end

        local _, totalHeight = StdUi:ObjectList(
                widget,
                widget.itemFrames ,
                function(parent, data, i)
                    local itemFrame = StdUi:NastrandirRaidTools_Attendance_ConfigurationSectionEdit(parent)
                    itemFrame:SetUID(data)
                    itemFrame:Load()
                    return itemFrame
                end,
                function(parent, itemFrame, data, i)
                    itemFrame:SetUID(data)
                    itemFrame:Load()
                end,
                widget.sections,
                5,
                10,
                -40
        )

        widget:SetHeight(height + totalHeight)
    end

    function widget:Load()
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.sections then
            db.sections = {}
        end

        widget.sections = NastrandirRaidTools:GetSortedKeySet(db.sections, function(a, b)
            return db.sections[a].name < db.sections[b].name
        end)

        widget:DrawSections()
    end

    function widget:NewSection()
        -- Get UID
        local uid = NastrandirRaidTools:CreateUID("Attendance-Section")
        local db = NastrandirRaidTools:GetModuleDB("Attendance")

        if not db.sections then
            db.sections = {}
        end

        if not db.sections[uid] then
            db.sections[uid] = {
                name = "New Section",
                usable = true,
                values = {}
            }
        end

        widget:Load()
    end

    widget.add:SetScript("OnClick", function()
        widget:NewSection()
    end)

    widget:SetScript("OnShow", function()
        widget:Load()
    end)

    return widget
end)
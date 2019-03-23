local StdUi = LibStub("StdUi")

local GetFirstClass = function(allowed_classes)
    for k,_ in pairs(allowed_classes) do
        return k
    end
end

StdUi:RegisterWidget("NastrandirRaidTools_Roster", function(self, parent)
    local width = parent:GetWidth() or 600
    local height = parent:GetHeight() or 400
    local column_width = (width - 22)/ 4
    local column_height = 380

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local title = StdUi:Label(widget, "Current Roster", 18, "GameFontNormal", widget:GetWidth() - 20, 24)
    widget.title = title
    StdUi:GlueTop(title, widget, 10, -20, "LEFT")


    local name = StdUi:SimpleEditBox(widget, 300, 24, "")
    widget.name = name
    StdUi:AddLabel(widget, name, "Name", "TOP")
    StdUi:GlueBelow(name, title, 0, -30, "LEFT")

    local raidmember = StdUi:Checkbox(widget, "Only Raidmember", 150, 24)
    widget.raidmember = raidmember
    raidmember:SetChecked(true)
    StdUi:GlueRight(raidmember, name, 10, 0)

    local alts = StdUi:Checkbox(widget, "Show Alts", 150, 24)
    widget.alts = alts
    StdUi:GlueRight(alts, raidmember, 10, 0)

    local tankColumn = StdUi:NastrandirRaidTools_Roster_ColumnFrame(widget, column_width, column_height)
    widget.tankColumn = tankColumn
    tankColumn:SetName("Tanks")
    tankColumn:SetCount(0)
    tankColumn:ShowAddButton()
    StdUi:GlueBelow(tankColumn, name, 0, -20, "LEFT")

    local healColumn = StdUi:NastrandirRaidTools_Roster_ColumnFrame(widget, column_width, column_height)
    widget.healColumn = healColumn
    healColumn:SetName("Healer")
    healColumn:SetCount(0)
    healColumn:ShowAddButton()
    StdUi:GlueRight(healColumn, tankColumn, 0, 0)

    local rangedColumn = StdUi:NastrandirRaidTools_Roster_ColumnFrame(widget, column_width, column_height)
    widget.rangedColumn = rangedColumn
    rangedColumn:SetName("Ranges")
    rangedColumn:SetCount(0)
    rangedColumn:ShowAddButton()
    StdUi:GlueRight(rangedColumn, healColumn, 0, 0)

    local meleeColumn = StdUi:NastrandirRaidTools_Roster_ColumnFrame(widget, column_width, column_height)
    widget.meleeColumn = meleeColumn
    meleeColumn:SetName("Melees")
    meleeColumn:SetCount(0)
    meleeColumn:ShowAddButton()
    StdUi:GlueRight(meleeColumn, rangedColumn, 0, 0)

    function widget:NewMemberFunction(column, class, role)
        return function(button, mouseButton)
            local Roster = NastrandirRaidTools:GetModule("Roster")
            local RosterDB = NastrandirRaidTools:GetModuleDB("Roster")

            if not RosterDB.characters then
                RosterDB.characters = {}
            end

            local uid = Roster:CreateUID()

            RosterDB.characters[uid] = {
                name = "New Player",
                raidmember = true,
                class = class,
                role = role,
                alts = {}
            }

            widget:AddMember(column, uid)
            Roster:ShowDetails(uid)
        end
    end

    function widget:AddMember(column, uid)
        local RosterDB = NastrandirRaidTools:GetModuleDB("Roster")
        local member = RosterDB.characters[uid]

        column:AddMember({
            uid = uid,
            name = member.name,
            class = member.class
        })
    end

    function widget:LoadRoster(current_roster)
        local RosterDB = NastrandirRaidTools:GetModuleDB("Roster")

        if not RosterDB.characters then
            RosterDB.characters = {}
        end

        tankColumn:ReleaseMember()
        healColumn:ReleaseMember()
        rangedColumn:ReleaseMember()
        meleeColumn:ReleaseMember()

        for uid, member in pairs(RosterDB.characters) do
            if member.role == NastrandirRaidTools.role_types.tank then
                widget:AddMember(tankColumn, uid)
            elseif member.role == NastrandirRaidTools.role_types.heal then
                widget:AddMember(healColumn, uid)
            elseif member.role == NastrandirRaidTools.role_types.ranged then
                widget:AddMember(rangedColumn, uid)
            elseif member.role == NastrandirRaidTools.role_types.melee then
                widget:AddMember(meleeColumn, uid)
            end
        end

        widget:FilterAll()

        tankColumn:Sort()
        healColumn:Sort()
        rangedColumn:Sort()
        meleeColumn:Sort()
    end

    function widget:FilterAll()
        local options = {
            name = name:GetText(),
            raidmember = raidmember:GetChecked(),
            alts = alts:GetChecked()
        }

        widget:Filter(options, tankColumn)
        widget:Filter(options, healColumn)
        widget:Filter(options, rangedColumn)
        widget:Filter(options, meleeColumn)
    end

    function widget:Filter(options, column)
        column:Filter(options)
    end

    name:SetScript("OnTextChanged", function()
        widget:FilterAll()
    end)
    name:SetScript("OnEnterPressed", function()
        widget:FilterAll()
    end)
    raidmember.OnValueChanged = function()
        widget:FilterAll()
    end
    alts.OnValueChanged = function()
        widget:FilterAll()
    end

    tankColumn:SetAddFunction(widget:NewMemberFunction(tankColumn, GetFirstClass(NastrandirRaidTools:GetTankClasses()), NastrandirRaidTools.role_types.tank))
    healColumn:SetAddFunction(widget:NewMemberFunction(healColumn, GetFirstClass(NastrandirRaidTools:GetHealClasses()), NastrandirRaidTools.role_types.heal))
    rangedColumn:SetAddFunction(widget:NewMemberFunction(rangedColumn, GetFirstClass(NastrandirRaidTools:GetRangedClasses()), NastrandirRaidTools.role_types.ranged))
    meleeColumn:SetAddFunction(widget:NewMemberFunction(meleeColumn, GetFirstClass(NastrandirRaidTools:GetMeleeClasses()), NastrandirRaidTools.role_types.melee))
    widget:LoadRoster()
    return widget
end)
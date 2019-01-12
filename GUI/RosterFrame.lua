local AceGUI = LibStub("AceGUI-3.0")

local TITLE_HEIGHT = 100
local FILTERBAR_HEIGHT = 50

NastrandirRaidTools.RosterFrame = {}

local GetFirstClass = function(allowed_classes)
    for k,v in pairs(allowed_classes) do
        return k
    end
end



function NastrandirRaidTools.RosterFrame:Init()
    NastrandirRaidTools.roster_frame = {}
    NastrandirRaidTools.RosterFrame:InitCurrentRoster()
end

function NastrandirRaidTools.RosterFrame:InitCurrentRoster()
    local roster_frame = NastrandirRaidTools.roster_frame
    local content_panel = NastrandirRaidTools:GetContentPanel()
    local width = content_panel.frame:GetWidth()
    local height = content_panel.frame:GetHeight()
    local column_width = (width - 22)/ 4

    local current_roster = AceGUI:Create("SimpleGroup")
    roster_frame.current_roster = current_roster
    current_roster:SetWidth(width)
    current_roster:SetLayout("Flow")
    current_roster.frame:SetBackdropColor(0, 0, 0, 0)
    content_panel:AddChild(current_roster)

    local title = AceGUI:Create("Heading")
    current_roster.title = title
    title:SetWidth(current_roster.frame:GetWidth())
    title:SetText("Current Roster")
    current_roster:AddChild(title)

    local filter_bar = AceGUI:Create("InlineGroup")
    current_roster.filter_bar = filter_bar
    filter_bar:SetWidth(current_roster.frame:GetWidth())
    filter_bar:SetLayout("Flow")
    filter_bar:SetTitle("Filter")
    filter_bar.frame:SetBackdropColor(0, 0, 0, 0)
    current_roster:AddChild(filter_bar)

    local edit_name = AceGUI:Create("EditBox")
    filter_bar.edit_name = edit_name
    edit_name:SetLabel("Name")
    edit_name:SetCallback("OnTextChanged", function(editbox, event, text)
        NastrandirRaidTools.RosterFrame:FilterAll(current_roster)
    end)
    edit_name:SetCallback("OnEnterPressed", function(editbox, event, text)
        NastrandirRaidTools.RosterFrame:FilterAll(current_roster)
    end)
    filter_bar:AddChild(edit_name)

    local checkbox_raidmember = AceGUI:Create("CheckBox")
    filter_bar.checkbox_raidmember = checkbox_raidmember
    checkbox_raidmember:SetLabel("Only Raidmember")
    checkbox_raidmember:SetType("checkbox")
    checkbox_raidmember:SetValue(true)
    checkbox_raidmember:SetCallback("OnValueChanged", function(checkbox, event, value)
        NastrandirRaidTools.RosterFrame:FilterAll(current_roster)
    end)
    filter_bar:AddChild(checkbox_raidmember)

    local checkbox_alts = AceGUI:Create("CheckBox")
    filter_bar.checkbox_alts = checkbox_alts
    checkbox_alts:SetLabel("Show Alts")
    checkbox_alts:SetType("checkbox")
    checkbox_alts:SetValue(false)
    checkbox_alts:SetCallback("OnValueChanged", function (checkbox, event, value)
        NastrandirRaidTools.RosterFrame:FilterAll(current_roster)
    end)
    filter_bar:AddChild(checkbox_alts)

    local columns = AceGUI:Create("InlineGroup")
    current_roster.columns = columns
    columns:SetWidth(current_roster.frame:GetWidth())
    columns:SetLayout("Flow")
    columns:SetTitle("Roster")
    current_roster:AddChild(columns)

    local tank_column = AceGUI:Create("NastrandirRaidToolsRosterColumnFrame")
    current_roster.tank_column = tank_column
    tank_column:Initialize()
    tank_column:SetWidth(column_width)
    tank_column:SetHeight(height - TITLE_HEIGHT - FILTERBAR_HEIGHT)
    tank_column:SetName("Tanks")
    tank_column:SetCount(0)
    tank_column:ShowAddButton()
    tank_column:SetAddFunction(NastrandirRaidTools.RosterFrame:NewMember(tank_column, GetFirstClass(NastrandirRaidTools:GetTankClasses()), "TANK"))
    columns:AddChild(tank_column)

    local healer_column = AceGUI:Create("NastrandirRaidToolsRosterColumnFrame")
    current_roster.healer_column = healer_column
    healer_column:Initialize()
    healer_column:SetWidth(column_width)
    healer_column:SetHeight(height - TITLE_HEIGHT - FILTERBAR_HEIGHT)
    healer_column:SetName("Healer")
    healer_column:SetCount(0)
    healer_column:ShowAddButton()
    healer_column:SetAddFunction(NastrandirRaidTools.RosterFrame:NewMember(healer_column, GetFirstClass(NastrandirRaidTools:GetHealClasses()), "HEAL"))
    columns:AddChild(healer_column)

    local ranged_column = AceGUI:Create("NastrandirRaidToolsRosterColumnFrame")
    current_roster.ranged_column = ranged_column
    ranged_column:Initialize()
    ranged_column:SetWidth(column_width)
    ranged_column:SetHeight(height - TITLE_HEIGHT - FILTERBAR_HEIGHT)
    ranged_column:SetName("Ranges")
    ranged_column:SetCount(0)
    ranged_column:ShowAddButton()
    ranged_column:SetAddFunction(NastrandirRaidTools.RosterFrame:NewMember(ranged_column, GetFirstClass(NastrandirRaidTools:GetRangedClasses()), "RANGED"))
    columns:AddChild(ranged_column)

    local melee_column = AceGUI:Create("NastrandirRaidToolsRosterColumnFrame")
    current_roster.melee_column = melee_column
    melee_column:Initialize()
    melee_column:SetWidth(column_width)
    melee_column:SetHeight(height - TITLE_HEIGHT - FILTERBAR_HEIGHT)
    melee_column:SetName("Melees")
    melee_column:SetCount(0)
    melee_column:ShowAddButton()
    melee_column:SetAddFunction(NastrandirRaidTools.RosterFrame:NewMember(melee_column, GetFirstClass(NastrandirRaidTools:GetMeleeClasses()), "MELEE"))
    columns:AddChild(melee_column)

    NastrandirRaidTools.RosterFrame:LoadRoster(current_roster)
end

function NastrandirRaidTools.RosterFrame:NewMember(column, class, role)
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

        NastrandirRaidTools.RosterFrame:AddMember(column, uid)
        Roster:ShowDetails(uid)
    end
end

function NastrandirRaidTools.RosterFrame:AddMember(column, uid)
    local RosterDB = NastrandirRaidTools:GetModuleDB("Roster")

    local member = RosterDB.characters[uid]

    local button = AceGUI:Create("NastrandirRaidToolsRosterClassButton")
    button:Initialize()
    button:SetName(member.name)
    button:SetClass(member.class)
    button:SetKey(uid)
    column:AddMember(button)
end

function NastrandirRaidTools.RosterFrame:LoadRoster(current_roster)
    local RosterDB = NastrandirRaidTools:GetModuleDB("Roster")

    if not RosterDB.characters then
        RosterDB.characters = {}
    end

    current_roster.tank_column:ReleaseMember()
    current_roster.healer_column:ReleaseMember()
    current_roster.ranged_column:ReleaseMember()
    current_roster.melee_column:ReleaseMember()

    for uid, member in pairs(RosterDB.characters) do
        if member.role == "TANK" then
            NastrandirRaidTools.RosterFrame:AddMember(current_roster.tank_column, uid)
        elseif member.role == "HEAL" then
            NastrandirRaidTools.RosterFrame:AddMember(current_roster.healer_column, uid)
        elseif member.role == "RANGED" then
            NastrandirRaidTools.RosterFrame:AddMember(current_roster.ranged_column, uid)
        elseif member.role == "MELEE" then
            NastrandirRaidTools.RosterFrame:AddMember(current_roster.melee_column, uid)
        end
    end

    NastrandirRaidTools.RosterFrame:FilterAll(current_roster)

    current_roster.tank_column:Sort()
    current_roster.healer_column:Sort()
    current_roster.ranged_column:Sort()
    current_roster.melee_column:Sort()
end

function NastrandirRaidTools.RosterFrame:FilterAll(current_roster)
    NastrandirRaidTools.RosterFrame:Filter(current_roster, current_roster.tank_column)
    NastrandirRaidTools.RosterFrame:Filter(current_roster, current_roster.healer_column)
    NastrandirRaidTools.RosterFrame:Filter(current_roster, current_roster.ranged_column)
    NastrandirRaidTools.RosterFrame:Filter(current_roster, current_roster.melee_column)
end

function NastrandirRaidTools.RosterFrame:Filter(current_roster, column)
    local name = current_roster.filter_bar.edit_name:GetText()
    local only_raidmember = current_roster.filter_bar.checkbox_raidmember:GetValue()
    local show_alts = current_roster.filter_bar.checkbox_alts:GetValue()

    column:Filter(name, only_raidmember, show_alts)
end
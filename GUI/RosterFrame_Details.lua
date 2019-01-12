local AceGUI = LibStub("AceGUI-3.0")

local TITLE_HEIGHT = 100
local FILTERBAR_HEIGHT = 50

NastrandirRaidTools.RosterFrame_Details = {}

function NastrandirRaidTools.RosterFrame_Details:Init(uid)
    local Roster = NastrandirRaidTools:GetModule("Roster")
    local content_panel = NastrandirRaidTools:GetContentPanel()

    local roster_details = AceGUI:Create("SimpleGroup")
    NastrandirRaidTools.roster_details = roster_details
    roster_details:SetLayout("Flow")
    roster_details:SetWidth(content_panel.frame:GetWidth())
    roster_details.frame:SetBackdropColor(0, 0, 0, 0)
    content_panel:AddChild(roster_details)

    local title = AceGUI:Create("Heading")
    roster_details.title = title
    title:SetWidth(roster_details.frame:GetWidth())
    title:SetText("Details")
    roster_details:AddChild(title)

    local config = AceGUI:Create("SimpleGroup")
    roster_details.config = config
    config:SetLayout("Flow")
    config:SetWidth(roster_details.frame:GetWidth() - 205)
    config.frame:SetBackdropColor(0, 0, 0, 0)
    roster_details:AddChild(config)

    local base_group = AceGUI:Create("InlineGroup")
    config.base_group = base_group
    base_group:SetLayout("Flow")
    base_group:SetWidth(config.frame:GetWidth())
    base_group:SetTitle("Base data")
    config:AddChild(base_group)

    local name = AceGUI:Create("EditBox")
    config.name = name
    name:SetLabel("Name")
    name:SetWidth(config.frame:GetWidth())
    base_group:AddChild(name)

    roster_details.selected_role = nil
    local role = AceGUI:Create("Dropdown")
    config.role = role
    role:SetLabel("Role")
    role:SetList({
        TANK = "TANK",
        HEAL = "HEAL",
        RANGED = "RANGED",
        MELEE = "MELEE"
    })
    role:SetCallback("OnValueChanged", function(dropdown, event, key)
        roster_details.selected_role = key

        roster_details.config.class:SetList(NastrandirRaidTools:GetAllowedClasses(key))
    end)
    role:SetWidth(config.frame:GetWidth() * 0.48)
    base_group:AddChild(role)

    roster_details.selected_key = nil
    local class = AceGUI:Create("Dropdown")
    config.class = class
    class:SetLabel("Class")
    class:SetCallback("OnValueChanged", function(dropdown, event, key)
        roster_details.selected_key = key
    end)
    class:SetWidth(config.frame:GetWidth() * 0.48)
    base_group:AddChild(class)

    local raidmember = AceGUI:Create("CheckBox")
    config.raidmember = raidmember
    raidmember:SetLabel("Is Raidmember")
    raidmember:SetType("checkbox")
    raidmember:SetValue(false)
    raidmember:SetWidth(config.frame:GetWidth() * 0.75)
    base_group:AddChild(raidmember)

    local button_save = AceGUI:Create("Button")
    config.button_save = button_save
    button_save:SetText("Save")
    button_save:SetWidth(config.frame:GetWidth() * 0.2)
    button_save:SetCallback("OnClick", NastrandirRaidTools.RosterFrame_Details:Save(roster_details, uid))
    base_group:AddChild(button_save)

    local action_group = AceGUI:Create("InlineGroup")
    config.action_group = action_group
    action_group:SetTitle("Actions")
    action_group:SetWidth(config.frame:GetWidth())
    action_group:SetLayout("Flow")
    config:AddChild(action_group)

    local dropdown_mains = AceGUI:Create("Dropdown")
    config.dropdown_mains = dropdown_mains
    dropdown_mains:SetLabel("Make Alt of")
    local mains = Roster:GetMainCharacters()
    local mains_name = {}
    for k,v in pairs(mains) do
        table.insert(mains_name, k)
    end
    table.sort(mains_name, function(a, b)
        return mains[a] < mains[b]
    end)
    dropdown_mains:SetList(mains, mains_name)
    dropdown_mains:SetCallback("OnValueChanged", NastrandirRaidTools.RosterFrame_Details:MakeAltOf(uid))
    dropdown_mains:SetWidth(action_group.frame:GetWidth() * 0.48)
    action_group:AddChild(dropdown_mains)

    local button_delete = AceGUI:Create("Button")
    config.button_delete = button_delete
    button_delete:SetWidth(action_group.frame:GetWidth() * 0.24)
    button_delete:SetText("Delete")
    button_delete:SetCallback("OnClick", NastrandirRaidTools.RosterFrame_Details:AskDelete(roster_details, uid))
    action_group:AddChild(button_delete)

    local button_makemain = AceGUI:Create("Button")
    config.button_makemain = button_makemain
    button_makemain:SetWidth(action_group.frame:GetWidth() * 0.24)
    button_makemain:SetText("Make Main")
    button_makemain:SetCallback("OnClick", NastrandirRaidTools.RosterFrame_Details:MakeMain(uid))
    action_group:AddChild(button_makemain)

    local spacer = AceGUI:Create("SimpleGroup")
    roster_details.spacer = spacer
    spacer:SetLayout("Flow")
    spacer:SetWidth(5)
    spacer.frame:SetBackdropColor(0, 0, 0, 0)
    roster_details:AddChild(spacer)

    local alts = AceGUI:Create("SimpleGroup")
    roster_details.alts = alts
    alts:SetLayout("Flow")
    alts:SetWidth(180)
    alts.frame:SetBackdropColor(0, 0, 0, 0)
    roster_details:AddChild(alts)

    local button_main = AceGUI:Create("NastrandirRaidToolsRosterClassButton")
    alts.button_main = button_main
    button_main:Initialize()
    button_main:SetName("Main")
    button_main:SetClass("MONK")
    button_main:SetWidth(alts.frame:GetWidth())
    alts:AddChild(button_main)

    local spacer_alts = AceGUI:Create("SimpleGroup")
    alts.spacer = spacer_alts
    spacer_alts:SetLayout("Flow")
    spacer_alts:SetWidth(alts.frame:GetWidth())
    spacer_alts:SetHeight(10)
    spacer_alts.frame:SetBackdropColor(0, 0, 0, 0)
    alts:AddChild(spacer_alts)

    local alt_column = AceGUI:Create("NastrandirRaidToolsRosterColumnFrame")
    alts.alt_column = alt_column
    alt_column:Initialize()
    alt_column:SetName("Alts")
    alt_column:SetHeight(content_panel.frame:GetHeight() - 70)
    alt_column:HideAddButton()
    alt_column:ReleaseMember()
    alts:AddChild(alt_column)

    NastrandirRaidTools.RosterFrame_Details:LoadData(roster_details, uid)
end

function NastrandirRaidTools.RosterFrame_Details:LoadData(roster_details, uid)
    local Roster = NastrandirRaidTools:GetModule("Roster")
    local member = Roster:GetCharacter(uid)

    -- Load base informations
    roster_details.config.name:SetText(member.name)
    roster_details.config.role:SetValue(member.role)
    roster_details.config.class:SetList(NastrandirRaidTools:GetAllowedClasses(member.role))
    roster_details.config.class:SetValue(member.class)
    roster_details.config.raidmember:SetValue(member.raidmember)

    -- Setup main character button
    local main = member
    if member.main then
        main = Roster:GetCharacter(member.main)
    end

    roster_details.alts.button_main:SetName(main.name)
    roster_details.alts.button_main:SetClass(main.class)
    roster_details.alts.button_main:SetKey(member.main or uid)

    -- Load Alts
    for alt_uid, alt in pairs(Roster:GetAlts(member.main or uid)) do
        local button = AceGUI:Create("NastrandirRaidToolsRosterClassButton")
        button:Initialize()
        button:SetName(alt.name)
        button:SetClass(alt.class)
        button:SetKey(alt_uid)
        roster_details.alts.alt_column:AddMember(button)
    end

    roster_details.alts.alt_column:Sort()
end

function NastrandirRaidTools.RosterFrame_Details:Save(roster_details, uid)
    return function()
        local Roster = NastrandirRaidTools:GetModule("Roster")
        local config = roster_details.config

        local character = Roster:GetCharacter(uid)

        character.name = config.name:GetText()
        character.role = roster_details.selected_role or character.role
        character.class = roster_details.selected_key or character.class
        character.raidmember = config.raidmember:GetValue()

        Roster:ShowDetails(uid)
    end
end

function NastrandirRaidTools.RosterFrame_Details:MakeAltOf(uid)
    return function(dropdown, event, value)
        local Roster = NastrandirRaidTools:GetModule("Roster")
        local character = Roster:GetCharacter(uid)
        local main = Roster:GetCharacter(value)

        if not main.alts then
            main.alts = {}
        end

        if character.alts then
            for index, alt_uid in pairs(character.alts) do
                if alt_uid ~= value then
                    local alt = Roster:GetCharacter(alt_uid)
                    alt.alts = nil
                    alt.main = value

                    table.insert(main.alts, alt_uid)
                end
            end
        end

        character.alts = nil
        character.main = value
        table.insert(main.alts, uid)
        main.main = nil

        Roster:ShowDetails(uid)
    end
end

function NastrandirRaidTools.RosterFrame_Details:MakeMain(uid)
    return function()
        local Roster = NastrandirRaidTools:GetModule("Roster")
        local character = Roster:GetCharacter(uid)

        if character.main then
            character.main = nil
            character.alts = {}
        end

        Roster:ShowDetails(uid)
    end
end

function NastrandirRaidTools.RosterFrame_Details:AskDelete(roster_details, uid)
    return function()
        local question = AceGUI:Create("InlineGroup")
        question:SetLayout("Flow")
        question:SetWidth(roster_details.config.frame:GetWidth())
        question:SetTitle("Are you sure?")
        roster_details.config:AddChild(question)

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
            local Roster = NastrandirRaidTools:GetModule("Roster")
            Roster:ShowDetails(uid)
        end)
        question:AddChild(button_no)

        local button_yes = AceGUI:Create("Button")
        button_yes:SetText("Yes")
        button_yes:SetWidth(question.frame:GetWidth() / 4)
        button_yes:SetCallback("OnClick", function()
            NastrandirRaidTools.RosterFrame_Details:Delete(uid)
        end)
        question:AddChild(button_yes)

        local spacer_right = AceGUI:Create("SimpleGroup")
        spacer_right:SetWidth(question.frame:GetWidth() / 4 - 5)
        spacer_right:SetLayout("Flow")
        spacer_right:SetHeight(25)
        spacer_right.frame:SetBackdropColor(0, 0, 0, 0)
        question:AddChild(spacer_right)
    end
end

function NastrandirRaidTools.RosterFrame_Details:Delete(uid)
    local Roster = NastrandirRaidTools:GetModule("Roster")

    local character = Roster:GetCharacter(uid)
    if character.alts then
        for alt_uid, alt in pairs(character.alts) do
            Roster:DeleteCharacter(alt_uid)
        end
    end

    Roster:DeleteCharacter(uid)

    if character.main then
        Roster:ShowDetails(character.main)
    else
        Roster:ShowCurrentRoster()
    end
end
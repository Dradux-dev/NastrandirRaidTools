NastrandirRaidTools.MainFrame = {}

local AceGUI = LibStub("AceGUI-3.0")

function NastrandirRaidTools.MainFrame:Init()
    local db = NastrandirRaidTools.db.profile

    local main_frame = AceGUI:Create("Frame")
    NastrandirRaidTools.main_frame = main_frame
    main_frame:SetTitle("Nastrandir Raid Tools")
    main_frame:SetStatusText("v 0.1")
    main_frame:SetLayout("Flow")
    main_frame:SetWidth(db.window.width)
    main_frame:SetHeight(db.window.height)
    main_frame:ClearAllPoints()
    main_frame:SetPoint(db.window.anchorTo, UIParent, db.window.anchorFrom, db.window.x, db.window.y)
    main_frame:Hide()

    NastrandirRaidTools.MainFrame:InitSidePanel()
    NastrandirRaidTools.MainFrame:InitSpacer()
    NastrandirRaidTools.MainFrame:InitContentPanel()
end

function NastrandirRaidTools.MainFrame:InitSidePanel()
    local main_frame = NastrandirRaidTools.main_frame
    local db = NastrandirRaidTools.db.profile

    local side_panel = AceGUI:Create("SimpleGroup")
    main_frame.side_panel = side_panel
    side_panel:SetWidth(db.window.side_panel_width)
    side_panel:SetHeight(main_frame.content:GetHeight() - db.window.spacer)
    side_panel:SetFullHeight(true)
    side_panel:SetLayout("Fill")
    main_frame:AddChild(side_panel)

    local scroll_frame = AceGUI:Create("ScrollFrame")
    side_panel.scroll_frame = scroll_frame
    scroll_frame:SetLayout("Flow")
    side_panel:AddChild(scroll_frame)
end

function NastrandirRaidTools.MainFrame:InitSpacer()
    local main_frame = NastrandirRaidTools.main_frame
    local db = NastrandirRaidTools.db.profile

    local spacer = AceGUI:Create("SimpleGroup")
    main_frame.spacer = spacer
    spacer:SetWidth(db.window.spacer)
    spacer:SetHeight(main_frame.content:GetHeight() - db.window.spacer)
    spacer:SetFullHeight(true)
    spacer:SetLayout("Fill")
    spacer.frame:SetBackdropColor(1, 0, 0, 0)
    main_frame:AddChild(spacer)
end

function NastrandirRaidTools.MainFrame:InitContentPanel()
    local main_frame = NastrandirRaidTools.main_frame
    local db = NastrandirRaidTools.db.profile

    local content_panel = AceGUI:Create("SimpleGroup")
    main_frame.content_panel = content_panel
    content_panel:SetWidth(main_frame.content:GetWidth() - db.window.side_panel_width - db.window.spacer)
    content_panel:SetHeight(main_frame.content:GetHeight() - db.window.spacer)
    content_panel:SetFullHeight(true)
    content_panel:SetLayout("Fill")
    main_frame:AddChild(content_panel)

    local scroll_frame = AceGUI:Create("ScrollFrame")
    content_panel.scroll_frame = scroll_frame
    scroll_frame:SetLayout("Flow")
    content_panel:AddChild(scroll_frame)
end
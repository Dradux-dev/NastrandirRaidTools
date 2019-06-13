local StdUi = LibStub("StdUi")

local function getWindowConfiguration()
    local db = NastrandirRaidTools.db.profile

    local window = {
        x = db.window.x or 0,
        y = db.window.y or 0,
        width = db.window.width or 1400,
        height = db.window.height or 600,
        anchor = {
            from = "CENTER",
            to = "CENTER"
        },
        inset = {
            top = 40,
            bottom = 40,
            left = 10,
            right = 10
        }
    }

    window.side_panel = {
        x = window.inset.left,
        y = -window.inset.top,
        width = db.window.side_panel_width or 220,
        height = window.height - (window.inset.top + window.inset.bottom),
        margin = {
            top = 0,
            bottom = 0,
            left = 0,
            right = 10
        }
    }

    window.content = {
        x =  window.inset.left + window.side_panel.width + window.side_panel.margin.right,
        y = -window.inset.top,
        width = window.width - (window.inset.left + window.side_panel.width + window.side_panel.margin.right + window.inset.right),
        height = window.height - (window.inset.top + window.inset.bottom)
    }

    window.version = {
        x = 0,
        y = 10,
        inside = true
    }

    return window
end

StdUi:RegisterWidget("NastrandirRaidTools_MainFrame", function(self)
    local config = getWindowConfiguration()

    local window = StdUi:Window(UIParent, "Nastrandir Raid Tools", config.width, config.height)
    self:InitWidget(window)
    self:SetObjSize(window, config.width, config.height)
    window:SetPoint("CENTER")
    window:SetFrameLevel(7)

    local menuPanel, menuFrame, menuChild, menuBar = StdUi:ScrollFrame(window, config.side_panel.width, config.side_panel.height)
    window.menu = {
        panel = menuPanel,
        frame = menuFrame,
        child = menuChild,
        bar = menuBar,
        children = {}
    }
    StdUi:GlueTop(menuPanel, window, config.side_panel.x, config.side_panel.y, "LEFT")

    local contentPanel, contentFrame, contentChild, contentBar = StdUi:ScrollFrame(window, config.content.width, config.content.height)
    window.content = {
        panel = contentPanel,
        frame = contentFrame,
        child = contentChild,
        bar = contentBar,
        children = {}
    }
    StdUi:GlueTop(contentPanel, window, config.content.x, config.content.y, "LEFT")

    local versionLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.versionLabel = versionLabel
    versionLabel:SetJustifyH("CENTER")
    versionLabel:SetJustifyV("CENTER")
    versionLabel:SetTextColor(1, 1, 1, 1)
    versionLabel:SetText("0.2.1")
    StdUi:GlueBottom(versionLabel, window, config.version.x, config.version.y, config.version.inside)

    window:SetScript("OnShow", function()
        NastrandirRaidTools:CreateMenu()
    end)

    window:Hide()
    NastrandirRaidTools.window = window

    local options_dropdown = CreateFrame("Frame", "PullButtonsOptionsDropDown", nil, "L_UIDropDownMenuTemplate")
    NastrandirRaidTools.options_dropdown = options_dropdown

    return window
end)

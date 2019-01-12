NastrandirRaidTools.Skins = {}
NastrandirRaidTools.Skins.ElvUI = {}


NastrandirRaidTools.Skins.ElvUI.GetSkinModule = function()
    if IsAddOnLoaded("ElvUI") then
        local E, L, V, P, G = unpack(ElvUI)
        if E then
            local S = E:GetModule("Skins")
            return S
        end
    end
end

NastrandirRaidTools.Skins.ElvUI.CloseButton = function(button)
    local S = NastrandirRaidTools.Skins.ElvUI.GetSkinModule()
    if S then
        S:HandleCloseButton(button)
    end
end
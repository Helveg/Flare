Flare = LibStub("AceAddon-3.0"):NewAddon("Flare", "AceConsole-3.0", "AceComm-3.0", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0")

local options = {
    name = "Flare",
    handler = Flare,
    type = 'group',
    args = {
        view = {
          name = "Open Flare",
          desc = "View the NinjaList interface",
          type = "execute",
          func = "ViewInterfaceFrame"
        }
    },
}

Flare:RegisterChatCommand("flare", "HandleCommand")
Flare:RegisterEvent("GROUP_ROSTER_CHANGED")

function Flare:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("FlareDB");
    -- Register the options table for the addon with AceConfigRegistry.
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Flare", options, {'flare'})
    -- Use the registered table to create an Interface Options GUI for the addon settings.
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Flare", "Flare NinjaList");
    Flare:Print("Initialized!")
end

function Flare:OnEnable()

end

function Flare:OnDisable()

end

function Flare:ViewInterfaceFrame()
    if _G["FlareInterfaceFrame"] ~= nil then
        return true
    end
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Flare")
    frame:SetStatusText("De conclusie is duidelijk.")
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        _G["FlareInterfaceFrame"] = nil
    end)
    frame:SetLayout("List")
    frame:SetHeight(450)
    frame:SetPoint("TOPLEFT", 20, -100)

    _G["FlareInterfaceFrame"] = frame.frame
    tinsert(UISpecialFrames, "FlareInterfaceFrame")

    local topgroup = AceGUI:Create("SimpleGroup")
    topgroup:SetFullWidth(true)
    topgroup:SetLayout("Flow")
    frame:AddChild(topgroup)

    local editbox = AceGUI:Create("EditBox")
    editbox:SetLabel("Player name:")
    editbox:SetWidth(200)
    topgroup:AddChild(editbox)

    local searchbutton = AceGUI:Create("Button")
    searchbutton:SetText("Search")
    searchbutton:SetWidth(80)
    topgroup:AddChild(searchbutton)

    local clearbutton = AceGUI:Create("Button")
    clearbutton:SetText("Absolve")
    clearbutton:SetWidth(80)
    topgroup:AddChild(clearbutton)

    local scrollwrapper = AceGUI:Create("SimpleGroup")
    scrollwrapper:SetFullWidth(true)
    scrollwrapper:SetHeight(300)
    scrollwrapper:SetLayout("Fill")
    frame:AddChild(scrollwrapper)

    local scrollframe = AceGUI:Create("ScrollFrame")
    scrollframe:SetLayout("List")
    scrollwrapper:AddChild(scrollframe)

    for i = 1, 100 do
        local rubendidit = AceGUI:Create("Label")
        rubendidit:SetText("Ruben is ne vuile ninja")
        scrollframe:AddChild(rubendidit)
    end
end

function Flare:GROUP_ROSTER_CHANGED()
    print("Flare: Group roster changed!")
end

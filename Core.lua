Flare = LibStub("AceAddon-3.0"):NewAddon("Flare", "AceConsole-3.0", "AceComm-3.0", "AceEvent-3.0")

local options = {
    name = "Flare",
    handler = Flare,
    type = 'group',
    args = {

    },
}


function Flare:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("FlareDB");
    -- Register the options table for the addon with AceConfigRegistry.
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Flare", options)
    -- Use the registered table to create an Interface Options GUI for the addon settings.
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Flare", "Flare NinjaList");
    Flare:Print("Initialized!")
end

function Flare:OnEnable()

end

function Flare:OnDisable()

end

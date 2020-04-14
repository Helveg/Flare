Flare = LibStub("AceAddon-3.0"):NewAddon("Flare", "AceEvent-3.0", "AceConsole-3.0")
myMessageVar = 10

function Flare:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.
  Flare:Print("Initialized!")
end

function Flare:OnEnable()
    -- Called when the addon is enabled
    Flare:Print("Enabled!")
end

function Flare:OnDisable()
    -- Called when the addon is disabled
    Flare:Print("Disabled!")
end

local options = {
    name = "Flare",
    handler = Flare,
    type = 'group',
    args = {
        msg = {
            type = 'input',
            name = 'My Message',
            desc = 'The message for my addon',
            set = 'SetMyMessage',
            get = 'GetMyMessage',
        },
    },
}

function Flare:GetMyMessage(info)
    print("Getting my message:", myMessageVar)
    return myMessageVar
end

function Flare:SetMyMessage(info, input)
    myMessageVar = input
end

LibStub("AceConfig-3.0"):RegisterOptionsTable("Flare", options, {"myslash", "myslashtwo"})

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
        },
        send = {
            name = "Broadcast reports",
            type = "group",
            desc = "Automatically send your new reports to certain online people.",
            args = {
                friends = {
                    name = "Friends",
                    type = "toggle",
                    desc = "Automatically send new reports to all online friends",
                    get = "GetSendFriends",
                    set = "SetSendFriends"
                },
                guild = {
                    name = "Guild",
                    type = "toggle",
                    desc = "Automatically send new reports to all online guildmembers",
                    get = "GetSendGuild",
                    set = "SetSendGuild"
                },
                group = {
                    name = "Group",
                    type = "toggle",
                    desc = "Automatically send new reports to your group members, except for the target",
                    get = "GetSendGroup",
                    set = "SetSendGroup"
                },
            }
        },
        receive = {
            name = "Receive reports",
            type = "group",
            desc = "Automatically send your new reports to certain online people.",
            args = {
                friends = {
                    name = "Friends",
                    type = "select",
                    desc = "Automatically receive new reports from friends",
                    values = {always="Always", popup="Ask in popup", command="Ask in chat", never="Never"},
                    get = "GetReceiveFriends",
                    set = "SetReceiveFriends"
                },
                guild = {
                    name = "Guild",
                    type = "select",
                    desc = "Automatically receive new reports from guildmembers",
                    values = {always="Always", popup="Ask in popup", command="Ask in chat", never="Never"},
                    get = "GetReceiveGuild",
                    set = "SetReceiveGuild"
                },
                group = {
                    name = "Group",
                    type = "select",
                    desc = "Automatically receive new reports from group members",
                    values = {always="Always", popup="Ask in popup", command="Ask in chat", never="Never"},
                    get = "GetReceiveGroup",
                    set = "SetReceiveGroup"
                },
            }
        }
    },
}

Flare:RegisterChatCommand("flare", "HandleCommand")

function Flare:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("FlareDB");
    -- Register the options table for the addon with AceConfigRegistry.
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Flare", options, {'flarecfg'})
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

function Flare:HandleCommand(args)
    args = {self:GetArgs(args, 100)}
    local action = args[1]
    table.remove(args, 1)
    local actions = {
        rate = Flare.ViewRatingFrame
    }
    if actions[action] ~= nil then
        actions[action](self, args)
    end
end

function Flare:ViewRatingFrame(args)
    local player = args[1]
    self:PrintMsg("Rating player: " .. player)
end

function Flare:GetGroupMemberNames()

function Flare:GetSendFriends()
    if self.db.global.broadcast_report.friends == nil then
        return true
    end
    return self.db.global.broadcast_report.friends
end

function Flare:SetSendFriends(info, v)
    self.db.global.broadcast_report.friends = v
end

function Flare:GetSendGuild()
    if self.db.global.broadcast_report.guild == nil then
        return true
    end
    return self.db.global.broadcast_report.guild
end

function Flare:SetSendGuild(info, v)
    self.db.global.broadcast_report.guild = v
end

function Flare:GetSendGroup()
    if self.db.global.broadcast_report.group == nil then
        return true
    end
    return self.db.global.broadcast_report.group
end

function Flare:SetSendGroup(info, v)
    self.db.global.broadcast_report.group = v
end

function Flare:GetReceiveFriends()
    if self.db.global.accept_report.friends == nil then
        return "always"
    end
    return self.db.global.accept_report.friends
end

function Flare:SetReceiveFriends(info, v)
    self.db.global.accept_report.friends = v
end

function Flare:GetReceiveGuild()
    if self.db.global.accept_report.guild == nil then
        return "always"
    end
    return self.db.global.accept_report.guild
end

function Flare:SetReceiveGuild(info, v)
    self.db.global.accept_report.guild = v
end

function Flare:GetReceiveGroup()
    if self.db.global.accept_report.group == nil then
        return "popup"
    end
    return self.db.global.accept_report.group
end

function Flare:SetReceiveGroup(info, v)
    self.db.global.accept_report.group = v
end

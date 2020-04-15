Flare = LibStub("AceAddon-3.0"):NewAddon("Flare", "AceConsole-3.0", "AceComm-3.0", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local uuid = LibStub("UUID")

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
    Flare.partyCheckTicker = C_Timer.NewTicker(1, function() Flare:PartyCheck() end)
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

    local tableHeading = AceGUI:Create("Heading")
    tableHeading:SetText("Reports")
    tableHeading:SetFullWidth(true)
    tableHeading:SetHeight(20)
    topgroup:AddChild(tableHeading)

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
        rate = Flare.ViewRatingFrame,
        report = Flare.ViewRatingFrame,
        view = Flare.ViewInterfaceFrame
    }
    if action == nil then
        action = "view"
    end
    if actions[action] ~= nil then
        actions[action](self, action, args)
    end
end

function Flare:ViewRatingFrame(action, args)
    if self.reportFrame then
        return true
    end
    local player = args[1]
    local report = {
        player=player,
        category="ninja",
    }

    local frame = AceGUI:Create("Window")
    frame:SetTitle("Flare - Create report")
    frame:SetHeight(355)
    frame:SetWidth(200)
    frame:EnableResize(false)
    frame:SetLayout("Flow")
    frame:SetPoint("CENTER", 200, 0)
    frame:SetCallback("OnClose", function(widget)
        self.reportFrame = nil
        widget:Release()
    end)

    local playerDropDown = AceGUI:Create("Dropdown")
    playerDropDown:SetRelativeWidth(1.0)
    playerDropDown:SetLabel("Player")
    local players = {}
    if player then
        players[player] = player
    end
    for player in pairs(self.partyMembers) do
        players[player] = player
    end
    playerDropDown:SetList(players)
    if player ~= nil then
        playerDropDown:SetValue(player)
    end
    frame:AddChild(playerDropDown)

    local ninjaRadio = AceGUI:Create("CheckBox")
    ninjaRadio:SetLabel("Ninja")
    ninjaRadio:SetValue(true)
    ninjaRadio:SetType("radio")
    frame:AddChild(ninjaRadio)

    local rudeRadio = AceGUI:Create("CheckBox")
    rudeRadio:SetLabel("Rude")
    rudeRadio:SetType("radio")
    frame:AddChild(rudeRadio)

    local unskilledRadio = AceGUI:Create("CheckBox")
    unskilledRadio:SetLabel("Unskilled")
    unskilledRadio:SetType("radio")
    frame:AddChild(unskilledRadio)

    local itemBox = AceGUI:Create("EditBox")
    itemBox:SetLabel("Item")
    itemBox:SetCallback("OnEnterPressed", function(self, event, value)
        report.item = value
    end)
    frame:AddChild(itemBox)

    ninjaRadio:SetCallback("OnValueChanged", function(self, event, value)
        if value then
            rudeRadio:SetValue(false)
            unskilledRadio:SetValue(false)
            itemBox:SetDisabled(false)
            report.category = "ninja"
        end
    end)
    rudeRadio:SetCallback("OnValueChanged", function(self, event, value)
        if value then
            ninjaRadio:SetValue(false)
            unskilledRadio:SetValue(false)
            itemBox:SetDisabled(true)
            report.category = "rude"
        end
    end)
    unskilledRadio:SetCallback("OnValueChanged", function(self, event, value)
        if value then
            ninjaRadio:SetValue(false)
            rudeRadio:SetValue(false)
            itemBox:SetDisabled(true)
            report.category = "unskilled"
        end
    end)

    local commentBox = AceGUI:Create("MultiLineEditBox")
    commentBox:SetHeight(100)
    commentBox:SetLabel("Comment")
    commentBox:SetCallback("OnEnterPressed", function(self, event, value)
        report.comment = value
    end)
    frame:AddChild(commentBox)

    local reportButton = AceGUI:Create("Button")
    reportButton:SetRelativeWidth(1.0)
    reportButton:SetText("Report")
    frame:AddChild(reportButton)

    reportButton:SetCallback("OnClick", function()
        Flare:CreateReport(report)
        frame:Hide()
    end)

    self.reportFrame = frame

end

function Flare:CreateReport(report)
    report.timestamp = date("%y-%m-%d %H:%M:%S")
    report.id = uuid.getv4()
    local reports = self:GetReportsTable()
    reports[report.id] = report
    self:StoreReportsTable(reports)
end

function Flare:GetReportsTable()
    return self.db.realm.reports or {}
end

function Flare:StoreReportsTable(reports)
    self.db.realm.reports = reports
end

function Flare:IsInParty()
    return GetNumGroupMembers() > 0
end

function Flare:PartyCheck()
    if self.partyMembers == nil then
        self.partyMembers = {}
    end
    local num = GetNumGroupMembers()
    local stillInParty = {}
    for i = 1, num - 1 do
        local player = {uid="party"..i, name=UnitName("party" .. i)}
        if self.partyMembers[player.name] == nil then
            self:OnPlayerJoinedParty(player)
        end
        stillInParty[player.name] = true
    end
    for name in pairs(self.partyMembers) do
        if stillInParty[name] == nil then
            local player = self.partyMembers[name]
            self:OnPlayerLeftParty(player)
        end
    end
end

function Flare:OnPlayerJoinedParty(player)
    self:Print(player.name .. " joined the party. 0 known incidents")
    self.partyMembers[player.name] = player
end

function Flare:OnPlayerLeftParty(player)
    self:Print(player.name .. " left the party. 0 known incidents")
    self.partyMembers[player.name] = nil
end

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

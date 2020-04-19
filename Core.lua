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

local bunnyLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Flare", {
type = "data source",
text = "Flare",
icon = "Interface\\AddOns\\Flare\\Icons\\flare.blp",
OnClick = function() Flare:ViewInterfaceFrame() end,
})
local icon = LibStub("LibDBIcon-1.0")

function Flare:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("FlareDB");
    -- Register the options table for the addon with AceConfigRegistry.
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Flare", options, {'flarecfg'})
    -- Use the registered table to create an Interface Options GUI for the addon settings.
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Flare", "Flare NinjaList");
    Flare.partyCheckTicker = C_Timer.NewTicker(1, function() Flare:PartyCheck() end)
    self.db2 = LibStub("AceDB-3.0"):New("BunniesDB", { profile = { minimap = { hide = false, }, }, })
    icon:Register("Flare", bunnyLDB, self.db2.profile.minimap)
    self:CreatePartyButtons()
    self:RegisterChatCommand("flare", "HandleCommand")
end

function Flare:OnEnable()

end

function Flare:OnDisable()

end

function Flare:ViewInterfaceFrame()
    local flare = self
    if _G["FlareInterfaceFrame"] ~= nil then
        return true
    end
    local frame = AceGUI:Create("Frame")
    self.interfaceFrame = frame
    frame:SetTitle("Flare")
    frame:SetStatusText("Small Indie Addon Company.")
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        _G["FlareInterfaceFrame"] = nil
        self.interfaceFrame = nil
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

    local reportbutton = AceGUI:Create("Button")
    reportbutton:SetText("Report")
    reportbutton:SetWidth(80)
    topgroup:AddChild(reportbutton)
    reportbutton:SetCallback("OnClick", function()
        if flare.reportFrame then
            flare.reportFrame:Hide()
        end
        Flare:ViewReportFrame("report", {editbox:GetText()})
    end)

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
    self.scrollframe = scrollframe
    scrollframe:SetLayout("List")
    scrollwrapper:AddChild(scrollframe)

    local reports = self:GetReportsTable()
    for report_id in pairs(reports) do
        local report = reports[report_id]
        self:AddReportLabel(scrollframe, report)
    end
end

function Flare:AddReportLabel(scrollframe, report)
    local flare = self
    local reportLabel = AceGUI:Create("InteractiveLabel")
    reportLabel:SetFullWidth(true)
    local text = self:GetReportLabelText(report)
    reportLabel:SetText(text)
    reportLabel:SetCallback("OnEnter", function() SetCursor("INSPECT_CURSOR") end)
    reportLabel:SetCallback("OnLeave", function() SetCursor(nil) end)
    reportLabel:SetCallback("OnClick", function()
        if flare.reportFrame then
            flare.reportFrame:Hide()
        end
        flare:ViewReportFrame("view", {report.player, report}, true)
    end)
    scrollframe:AddChild(reportLabel)
end

function Flare:GetReportLabelText(report)
    local text = "["..report.category.."] "
    if report.category == "ninja" and report.item and #report.item > 0 then
        return text..report.player.." ninja'd "..report.item.." @ "..report.timestamp
    end
    return text..report.player.." @ "..report.timestamp
end

function Flare:HandleCommand(args)
    args = {self:GetArgs(args, 100)}
    local action = args[1]
    table.remove(args, 1)
    local actions = {
        rate = Flare.ViewReportFrame,
        report = Flare.ViewReportFrame,
        view = Flare.ViewInterfaceFrame
    }
    if action == nil then
        action = "view"
    end
    if actions[action] ~= nil then
        actions[action](self, action, args)
    end
end

function Flare:ViewReportFrame(action, args, viewing)
    if self.reportFrame then
        return true
    end
    local player = args[1]
    local report = {
        player=player,
        category="ninja",
    }
    if viewing then
        report = args[2]
    end

    local frame = AceGUI:Create("Window")
    if viewing then
        frame:SetTitle("Flare - Viewing report")
    else
        frame:SetTitle("Flare - Create report")
    end
    local height = 355
    if viewing and report.category ~= "ninja" then
        height = 330
    end
    frame:SetHeight(height)
    frame:SetWidth(200)
    frame:EnableResize(false)
    frame:SetLayout("Flow")
    if self.interfaceFrame then
        frame:SetPoint("TOPLEFT", self.interfaceFrame.frame, "TOPRIGHT", 0, 0)
    else
        frame:SetPoint("CENTER", 200, 0)
    end
    _G["FlareReportFrame"] = frame.frame
    tinsert(UISpecialFrames, "FlareReportFrame")
    frame:SetCallback("OnClose", function(widget)
        _G["FlareReportFrame"] = nil
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
    ninjaRadio:SetValue(report.category == "ninja")
    ninjaRadio:SetType("radio")
    frame:AddChild(ninjaRadio)

    local rudeRadio = AceGUI:Create("CheckBox")
    rudeRadio:SetLabel("Rude")
    rudeRadio:SetValue(report.category == "rude")
    rudeRadio:SetType("radio")
    frame:AddChild(rudeRadio)

    local unskilledRadio = AceGUI:Create("CheckBox")
    unskilledRadio:SetLabel("Unskilled")
    unskilledRadio:SetValue(report.category == "unskilled")
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

    if not viewing then
        local reportButton = AceGUI:Create("Button")
        reportButton:SetRelativeWidth(1.0)
        reportButton:SetText("Report")
        frame:AddChild(reportButton)

        reportButton:SetCallback("OnClick", function()
            Flare:CreateReport(report)
            frame:Hide()
        end)
    elseif report.category == "ninja" then
        local showItemButton = AceGUI:Create("Button")
        showItemButton:SetRelativeWidth(1.0)
        showItemButton:SetText("Show item")
        frame:AddChild(showItemButton)

        showItemButton:SetCallback("OnClick", function()
            Flare:Print("On "..report.timestamp.." "..report.player.." ninja'd: "..report.item)
        end)
    end

    if viewing then
        playerDropDown:SetDisabled(true)
        ninjaRadio:SetDisabled(true)
        rudeRadio:SetDisabled(true)
        unskilledRadio:SetDisabled(true)
        itemBox:SetDisabled(true)
        itemBox:SetText(report.item)
        commentBox:SetDisabled(true)
        commentBox:SetText(report.comment)
    end
    self.reportFrame = frame
end

function Flare:CreateReport(report)
    report.timestamp = date("%y-%m-%d %H:%M:%S")
    report.id = uuid.getv4()
    report.item = report.item or ""
    report.comment = report.comment or ""
    local reports = self:GetReportsTable()
    reports[report.id] = report
    self:StoreReportsTable(reports)
    if self.interfaceFrame then
        self:AddReportLabel(self.scrollframe, report)
    end
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
        local player = {name=UnitName("party" .. i)}
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
    Flare:CheckPlayer(player)
    self.partyMembers[player.name] = player
end

function Flare:OnPlayerLeftParty(player)
    self.partyMembers[player.name] = nil
end

function Flare:CheckPlayer(player)
    local reports = self:GetReportsTable()
    local marks = {}
    local player_reports = {}
    for k in pairs(reports) do
        local report = reports[k]
        if report.player == player.name then
            table.insert(player_reports, report)
            marks[report.category] = (marks[report.category] or 0) + 1
        end
    end
    if #player_reports > 0 then
        self:Warn(player, player_reports, marks)
    end
end

function Flare:Warn(player, reports, marks)
    local msg = "Flare has detected "..player.name.." is marked as: "
    msg = msg..get_marks_string(marks)
    message(msg)
end

function get_marks_string(marks)
    local categories = {}
    for k in pairs(marks) do
        table.insert(categories, k)
    end
    local m = categories[1].." (x"..marks[categories[1]]..")"
    if #categories < 2 then
        return m
    end
    local i = 2
    while i < #categories do
         m = m..", "..categories[i].." (x"..marks[categories[i]]..")"
         i = i + 1
    end
    return m.." and "..categories[i].." (x"..marks[categories[i]]..")"
end

function Flare:CreatePartyButtons()
    local flare = self
    self.partyButtons = {}
    for i = 1, 4 do
        local f = CreateFrame("Frame", nil, _G["PartyMemberFrame"..i])
        f:SetPoint("TOPLEFT", 0, 0)
        f:SetFrameStrata("HIGH")
        f:SetWidth(16) -- Set these to whatever height/width is needed
        f:SetHeight(16) -- for your Texture

        local t = f:CreateTexture(nil,"OVERLAY")
        t:SetTexture("Interface\\AddOns\\Flare\\Icons\\report.blp")
        t:SetAllPoints(f)
        f.texture = t

        f:SetScript("OnMouseDown", function (self, button)
            if button=='LeftButton' then
                if flare.reportFrame then
                    flare.reportFrame:Hide()
                end
                flare:ViewReportFrame("report", {UnitName("party" .. i)})
            end
        end)
        f:Show()
        table.insert(self.partyButtons, f)
    end
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

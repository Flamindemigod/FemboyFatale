-- A lot of this module is heavily derived from Buff The Group
-- https://github.com/Fostecks/BuffTheGroup
-- I'm moving a lot of the code into a this module but rewriting it to be a lot more maintainable than it is currently
-- However Bitrock(Fostecks) and garlicmoon should still be considered the primary author of this code.
-- As the functionailty will be unchanged
FemboyFatale = FemboyFatale or {}
local r = FemboyFatale
FFBuffs = FFBuffs or {}
local s = FFBuffs

s.name = r.name .. "Buffs"
s.displayName = "FFBuffs"
s.defaults = {
    enabled = true,
    gradientMode = true,
    showOnlyDPS = false,
    singleColumnMode = false,
    trackedBuffs = {},
    framePositions = {},
    maxRows = 6,
    startR = 117,
    startG = 222,
    startB = 120,
    endR = 222,
    endG = 117,
    endB = 117
}

s.debug = 1

s.showUI = false
s.groupSize = 0
s.units = {}
s.panels = {}
s.frames = {}
s.fragments = {}

local iota = FFUtils.Iota()

s.data = {
    roleIcons = {
        [LFG_ROLE_DPS] = "/esoui/art/lfg/lfg_icon_dps.dds",
        [LFG_ROLE_TANK] = "/esoui/art/lfg/lfg_icon_tank.dds",
        [LFG_ROLE_HEAL] = "/esoui/art/lfg/lfg_icon_healer.dds",
        [LFG_ROLE_INVALID] = "/esoui/art/crafting/gamepad/crafting_alchemy_trait_unknown.dds"
    },
    buffs = {
        {id = iota(), abilityId = 61771, decayedId = nil}, -- Powerful Assault  
        {
            id = iota(),
            abilityId = 93109,
            icon = "/esoui/art/icons/procs_006.dds",
            decayedId = nil
        }, -- Major Slayer
        {id = iota(), abilityId = 109966, decayedId = nil}, -- Major Courage
        {id = iota(), abilityId = 61747, decayedId = nil}, -- Major Force
        {id = iota(), abilityId = 62195, decayedId = nil}, -- Major Berserk
        {id = iota(), abilityId = 61744, decayedId = nil}, -- Minor Berserk
        {id = iota(), abilityId = 147417, decayedId = nil}, -- Minor Courage
        {id = iota(), abilityId = 61687, decayedId = nil}, -- Major Sorcery
        {id = iota(), abilityId = 61685, decayedId = nil}, -- Minor Sorcery
        {id = iota(), abilityId = 61665, decayedId = nil}, -- Major Brutality
        {id = iota(), abilityId = 61691, decayedId = nil}, -- Minor Prophecy
        {id = iota(), abilityId = 61694, decayedId = nil}, -- Major Resolve
        {id = iota(), abilityId = 61693, decayedId = nil}, -- Minor Resolve
        {id = iota(), abilityId = 61706, decayedId = nil}, -- Minor Intellect
        {id = iota(), abilityId = 61737, decayedId = nil}, -- Empower
        {id = iota(), abilityId = 61709, decayedId = nil}, -- Major Heroism
        {id = iota(), abilityId = 40079, decayedId = nil}, -- Radiating Regeneration
        {id = iota(), abilityId = 61736, decayedId = nil}, -- Major Expedition
        {id = iota(), abilityId = 163401, decayedId = nil}, -- Spalder of Ruin
        {id = iota(), abilityId = 88490, decayedId = nil}, -- Minor Toughness
        {id = iota(), abilityId = 61704, decayedId = nil}, -- Minor Endurance
        {id = iota(), abilityId = 61666, decayedId = nil}, -- Minor Savagery
        {id = iota(), abilityId = 61735, decayedId = nil}, -- Minor Expedition
        {id = iota(), abilityId = 172055, decayedId = 172056}, -- Pillager's Profit Cooldown
        {id = iota(), abilityId = 166731, decayedId = nil}, -- Rallying Cry
        {
            id = iota(),
            abilityId = 32834,
            icon = "/esoui/art/icons/achievement_u28_arena_hircine_boss_2_flavor.dds",
            decayedId = nil
        }, -- Sanctuary
        {id = iota(), abilityId = 61506, decayedId = nil}, -- Echoing Vigor
        {id = iota(), abilityId = 40079, decayedId = nil}, -- Radiating Regen
        {id = iota(), abilityId = 61722, decayedId = nil}, -- Major Protection
        {id = iota(), abilityId = 61716, decayedId = nil}, -- Major Evasion
        {id = iota(), abilityId = 61715, decayedId = nil}, -- Minor Evasion
        {id = iota(), abilityId = 61721, decayedId = nil}, -- Minor Protection
        {id = iota(), abilityId = 76936, decayedId = nil}, -- Robes of Transmutation
        {id = iota(), abilityId = 61746, decayedId = nil} -- Minor Force
    }
}

for _, v in pairs(s.data.buffs) do
    v.icon = v.icon or GetAbilityIcon(v.abilityId)
    s.defaults.trackedBuffs[v.id] = {
        enabled = false,
        stackmode = false,
        progressMode = false
    }

    s.defaults.framePositions[v.id] = {
        left = 1300,
        top = 150 + (v.id - 1) * 10 % 1000
    }
end

function s.resetInner()
    for _, buff in pairs(s.data.buffs) do
        for i = 1, GROUP_SIZE_MAX do
            s.frames[buff.id].panels[i].panel:ClearAnchors()
            s.frames[buff.id].panels[i].panel:SetHidden(true)
        end
    end

    s.groupSize = GetGroupSize()
    s.units = {}

    for _, buff in pairs(s.data.buffs) do
        local i = buff.id
        s.frames[buff.id].frame:GetNamedChild("Icon"):SetTexture(buff.icon)
    end

    local panelIndex = FFUtils.Iota();
    for i = 1, GROUP_SIZE_MAX do
        if (i <= s.groupSize or i == 1 and s.groupSize == 0) then
            local unitTag = (i == 1 and s.groupSize == 0) and "player" or
                                GetGroupUnitTagByIndex(i)
            if (not s.sv.showOnlyDPS or GetGroupMemberSelectedRole(unitTag) ==
                LFG_ROLE_DPS) then
                s.units[unitTag] = {
                    panelId = panelIndex(),
                    self = AreUnitsEqual("player", unitTag),
                    buffs = {}
                }
                for _, buff in pairs(s.data.buffs) do
                    s.units[unitTag].buffs[buff.id] = {
                        hasBuff = false,
                        endTime = 0,
                        buffDuration = 0,
                        stackCount = 0
                    }
                end
            end
        end
    end

    for _, buff in pairs(s.data.buffs) do
        panelIndex = FFUtils.Iota()
        for i = 1, GROUP_SIZE_MAX do
            local pIndex = panelIndex()
            local soloPanel = i == 1 and s.groupSize == 0
            local unitTag = soloPanel and "player" or GetGroupUnitTagByIndex(i)
            if (not s.sv.showOnlyDPS or GetGroupMemberSelectedRole ==
                LFG_ROLE_DPS) then
                if (i <= s.groupSize or soloPanel) then
                    s.frames[buff.id].panels[pIndex].name:SetText(
                        GetUnitDisplayName(unitTag))
                    s.frames[buff.id].panels[pIndex].role:SetTexture(s.data
                                                                         .roleIcons[GetGroupMemberSelectedRole(
                                                                         unitTag)])
                    s.updateStatus(buff.id, unitTag)
                    s.updateRange(buff.id, pIndex,
                                  IsUnitInGroupSupportRange(unitTag))

                    if (pIndex == 1) then
                        s.frames[buff.id].panels[pIndex].panel:SetAnchor(
                            TOPLEFT, FFBuffFrame, TOPLEFT, 0, 0)
                    elseif (pIndex <= s.sv.maxRows) then
                        s.frames[buff.id].panels[pIndex].panel:SetAnchor(
                            TOPLEFT, s.frames[buff.id].panels[pIndex - 1].panel,
                            BOTTOMLEFT, 0, 0)
                    else
                        s.frames[buff.id].panels[pIndex].panel:SetAnchor(
                            TOPLEFT, s.frames[buff.id].panels[pIndex -
                                s.sv.maxRows].panel, TOPRIGHT, 0, 0)
                    end
                    s.frames[buff.id].panels[pIndex].panel:SetHidden(false)
                else
                    s.frames[buff.id].panels[pIndex].panel:SetAnchor(TOPLEFT,
                                                                     FFBuffFrame,
                                                                     TOPLEFT, 0,
                                                                     0)
                    s.frames[buff.id].panels[pIndex].panel:SetHidden(true)
                end
            end
        end
    end
end

function s.updateRange(id, pIndex, inRange)
    if (inRange) then
        s.frames[id].panels[pIndex].panel:SetAlpha(1)
    else
        s.frames[id].panels[pIndex].panel:SetAlpha(0.5)
    end
end

function s.updateStatus(id, unitTag)
    local unit = s.units[unitTag]
    local buffData = unit.buffs[id]
    local panel = s.frames[id].panels[unit.panelId]
    local now = GetFrameTimeMilliseconds() / 1000

    if (s.sv.trackedBuffs[id].stackMode) then
        panel.stat:SetText(string.format("%d", buffData.stackCount))
        local startR, startG, startB = s.sv.startR, s.sv.startG, s.sv.startB
        local endR, endG, endB = s.sv.endR, s.sv.endG, s.sv.endB

        local progress = s.sv.gradientMode and
                             FFUtils.Clamp(
                                 1 - buffData.stackCount / s.groupSize, 0, 1) or
                             0
        local r, g, b = (s.sv.gradientMode and
                            FFUtils.Interpolate(startR, endR, progress) or
                            startR) / 255,
                        (s.sv.gradientMode and
                            FFUtils.Interpolate(startG, endG, progress) or
                            startG) / 255,
                        (s.sv.gradientMode and
                            FFUtils.Interpolate(startB, endB, progress) or
                            startB) / 255

        if (buffData.stackCount > 0) then
            panel.stat:SetText(string.format("%d", buffData.stackCount))
            if (unit.self) then
                panel.bg:SetCenterColor(r, g, b, 1 - 0.4 * progress)
            else
                panel.bg:SetCenterColor(r, g, b, 0.8 - 0.5 * progress)
            end
        else
            panel.bg:SetCenterColor(0, 0, 0, 0)
            panel.stat:SetText("0")
            if (not buffData.hasBuff) then buffData.endTime = nil end
        end
    elseif (buffData.endTime) then
        local buffRemaining = buffData.endTime - now

        local startR, startG, startB = s.sv.startR, s.sv.startG, s.sv.startB
        local endR, endG, endB = s.sv.endR, s.sv.endG, s.sv.endB

        local progress = FFUtils.Clamp(
                             1 - buffRemaining / buffData.buffDuration, 0, 1)
        local backdropSize = s.sv.trackedBuffs[id].progressMode and
                                 (1 - progress) * 160 or 160;
        progress = s.sv.gradientMode and progress or 0

        local r, g, b = (s.sv.gradientMode and
                            FFUtils.Interpolate(startR, endR, progress) or
                            startR) / 255,
                        (s.sv.gradientMode and
                            FFUtils.Interpolate(startG, endG, progress) or
                            startG) / 255,
                        (s.sv.gradientMode and
                            FFUtils.Interpolate(startB, endB, progress) or
                            startB) / 255

        if (buffRemaining > 0) then
            panel.stat:SetText(string.format("%.1f", buffRemaining))
            if (unit.self) then
                panel.bg:SetCenterColor(r, g, b, 1 - 0.4 * progress)
            else
                panel.bg:SetCenterColor(r, g, b, 0.8 - 0.5 * progress)
            end
            panel.bg:SetWidth(backdropSize)
        elseif (buffData.endTime == -1) then
            panel.stat:SetText("")
            if (unit.self) then
                panel.bg:SetCenterColor(r, g, b, 1)
            else
                panel.bg:SetCenterColor(r, g, b, 0.8)
            end
        else
            panel.bg:SetCenterColor(0, 0, 0, 0)
            panel.stat:SetText("0")
            if (not buffData.hasBuff) then buffData.endTime = nil end
        end
    end
end

function s.handleCommandInput(args)
    s.sv.enabled = not s.sv.enabled
    s.logger.info(s.sv.enabled and "Enabled" or "Disabled")
    r.reset()
end

function s.init()
    s.logger = FFUtils.Logger(s.displayName, s.debug)
    s.logger.trace("Initialized Logger")
    s.InitializeControls()
    s.logger.trace("Initialized Control")
    SLASH_COMMANDS["/ff/buff"] = s.handleCommandInput
    SLASH_COMMANDS["/ff/buff/refresh"] = s.reset
    s.logger.trace("Registered Slash Commands")
    r.EM:RegisterForEvent(s.name, EVENT_PLAYER_ACTIVATED, s.reset)
    r.EM:RegisterForEvent(s.name, EVENT_RAID_TRIAL_STARTED, s.reset)
    r.EM:RegisterForEvent(s.name, EVENT_UNIT_CREATED, s.reset)
    r.EM:RegisterForEvent(s.name, EVENT_GROUP_MEMBER_JOINED, s.reset)
    r.EM:RegisterForEvent(s.name, EVENT_GROUP_MEMBER_LEFT, s.reset)
    s.logger.trace("Registered Base Events")
end

function s.InitializeControls()
    for _, buff in pairs(s.data.buffs) do
        local frame = r.WM:CreateControlFromVirtual("FFBuffFrame" .. buff.id,
                                                    FFBuffUI, "FFBuffFrame",
                                                    buff.id)
        frame:SetHandler("OnMoveStop",
                         function() s.onMoveStop(buff.id, frame) end)

        s.frames[buff.id] = {frame = frame, panels = {}}

        for i = 1, GROUP_SIZE_MAX do
            local panel = r.WM:CreateControlFromVirtual(
                              "FFBuffPanel" .. buff.id .. "_" .. i, frame,
                              "FFBuffPanel", i)
            s.frames[buff.id].panels[i] = {
                panel = panel,
                container = panel:GetNamedChild("Container"),
                bg = panel:GetNamedChild("Backdrop"),
                name = panel:GetNamedChild("Name"),
                role = panel:GetNamedChild("Role"),
                stat = panel:GetNamedChild("Stat")
            }
            s.frames[buff.id].panels[i].container:SetEdgeColor(0, 0, 0, 0)
            s.frames[buff.id].panels[i].container:SetCenterColor(0, 0, 0, 0.5)
            s.frames[buff.id].panels[i].bg:SetEdgeColor(0, 0, 0, 0)
            s.frames[buff.id].panels[i].bg:SetCenterColor(0, 0, 0, 0)
            s.frames[buff.id].panels[i].stat:SetColor(1, 1, 1, 1)
            s.frames[buff.id].panels[i].stat:SetText("0")
        end

        frame:ClearAnchors()
        frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                        s.sv.framePositions[buff.id].left,
                        s.sv.framePositions[buff.id].top)
        s.fragments[buff.id] = ZO_HUDFadeSceneFragment:New(frame)
    end
end

function s.onMoveStop(id, frame)
    s.sv.framePositions[id].left = frame:GetLeft()
    s.sv.framePositions[id].top = frame:GetTop()
end

function s.reset()
    s.logger.trace("refreshing state")
    if (s.sv.enabled and (GetGroupSize() > 0 or s.debug)) then
        s.resetInner()
        if (not s.showUI) then
            s.showUI = true
            r.EM:AddFilterForEvent(s.name, EVENT_UNIT_CREATED,
                                   REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
            r.EM:RegisterForEvent(s.name, EVENT_GROUP_MEMBER_ROLE_CHANGED,
                                  s.groupMemberRoleChanged)
            r.EM:RegisterForEvent(s.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE,
                                  s.groupSupportRangeUpdate)
            r.EM:RegisterForEvent(s.name, EVENT_EFFECT_CHANGED, s.effectChanged)
            r.EM:RegisterForUpdate(s.name .. "Cycle", 100, s.refreshUI)
            if (not s.debug) then
                r.EM:AddFilterForEvent(s.name, EVENT_EFFECT_CHANGED,
                                       REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
            end
        end
        for index, fragment in pairs(s.fragments) do
            if (s.sv.trackedBuffs[index].enabled) then
                SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
                SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
            else
                SCENE_MANAGER:GetScene("hud"):RemoveFragment(fragment)
                SCENE_MANAGER:GetScene("hudui"):RemoveFragment(fragment)
            end
        end
    else
        if (s.showUI) then
            s.showUI = false
            r.EM:UnregisterForEvent(s.name, EVENT_UNIT_CREATED)
            r.EM:UnregisterForEvent(s.name, EVENT_GROUP_MEMBER_JOINED)
            r.EM:UnregisterForEvent(s.name, EVENT_GROUP_MEMBER_LEFT)
            r.EM:UnregisterForEvent(s.name, EVENT_GROUP_MEMBER_ROLE_CHANGED)
            r.EM:UnregisterForEvent(s.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
            r.EM:UnregisterForEvent(s.name, EVENT_EFFECT_CHANGED)

            r.EM:UnregisterForEvent(s.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
            r.EM:UnregisterForEvent(s.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
            r.EM:UnregisterForEvent(s.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
        end
        for _, fragment in pairs(s.fragments) do
            SCENE_MANAGER:GetScene("hud"):RemoveFragment(fragment)
            SCENE_MANAGER:GetScene("hudui"):RemoveFragment(fragment)
        end
    end
end

function s.effectChanged(_, changeType, _, _, unitTag, beginTime, endTime, _, _,
                         _, _, _, _, _, _, abilityId, _)
    for _, buff in pairs(s.data.buffs) do
        if (s.sv.trackedBuffs[buff.id].enabled and buff.abilityId == abilityId and
            s.units[unitTag]) then
            local unitBuff = s.units[unitTag].buffs[buff.id]
            if (buff.decayedId) then
                if (changeType == EFFECT_RESULT_GAINED) then
                    unitBuff.hasBuff = true
                    unitBuff.endTime = -1
                    unitBuff.buffDuration = -1
                elseif (changeType == EFFECT_RESULT_FADED) then
                    unitBuff.hasBuff = true
                    unitBuff.endTime = (GetGameTimeMilliseconds() +
                                           GetAbilityDuration(buff.decayedId) +
                                           GetAbilityDuration(abilityId)) / 1000
                    unitBuff.buffDuration =
                        GetAbilityDuration(buff.decayedId) / 1000
                end
            else
                if (changeType == EFFECT_RESULT_FADED) then
                    unitBuff.hasBuff = false
                    unitBuff.endTime = 0
                    unitBuff.stackCount = unitBuff.stackCount - 1
                elseif ((changeType == EFFECT_RESULT_GAINED or changeType ==
                    EFFECT_RESULT_UPDATED) and beginTime == 0 or endTime == 0 or
                    beginTime == endTime) then
                    unitBuff.hasBuff = true
                    unitBuff.endTime = -1
                    unitBuff.buffDuration = -1
                elseif (changeType == EFFECT_RESULT_GAINED) then
                    unitBuff.hasBuff = true
                    unitBuff.endTime = endTime
                    unitBuff.buffDuration = endTime - beginTime
                    unitBuff.stackCount = unitBuff.stackCount + 1
                else
                    unitBuff.hasBuff = true
                    unitBuff.endTime = endTime
                    unitBuff.buffDuration = endTime - beginTime
                end
            end
        end
    end
end

function s.groupMemberRoleChanged(_, unitTag, newRole)
    local unit = s.units[unitTag]
    if (unit) then
        for _, buff in pairs(s.data.buffs) do
            s.frames[buff.id].panels[unit.panelId].role:SetTexture(s.data
                                                                       .roleIcons[newRole])
            zo_callLater(s.reset, 500)
        end
    end
end

function s.groupSupportRangeUpdate(_, unitTag, inRange)
    local unit = s.units[unitTag]
    if (unit) then
        for _, buff in pairs(s.data.buffs) do
            s.updateRange(buff.id, s.units[unitTag].panelId, inRange)
        end
    end
end

function s.refreshUI()
    for _, buff in pairs(s.data.buffs) do
        for unitTag, unit in pairs(s.units) do
            s.updateStatus(buff.id, unitTag)
        end
    end
end

function s.menu(root)
    parent = {
        type = "submenu",
        name = s.displayName,
        controls = {
            {type = "description", text = "Does Buff Tracking", width = "full"},
            {
                type = "checkbox",
                name = "Enabled",
                tooltip = "Toggles the UI",
                default = s.defaults.enabled,
                getFunc = function() return s.sv.enabled end,
                setFunc = function(value)
                    s.sv.enabled = value
                    r.reset()
                end
            }, {
                type = "checkbox",
                name = "Show Only DPS",
                tooltip = "Shows only players marked as DPS in the BTG group frames",
                default = s.defaults.showOnlyDPS,
                getFunc = function() return s.sv.showOnlyDPS end,
                setFunc = function(value)
                    s.sv.showOnlyDPS = value
                    zo_callLater(s.reset, 500)
                end
            }, {
                type = "checkbox",
                name = "Single Column Mode",
                tooltip = "Lays out the frames in a single column instead of a 6x2 layout",
                default = s.defaults.singleColumnMode,
                getFunc = function() return s.sv.singleColumnMode end,
                setFunc = function(value)
                    s.sv.singleColumnMode = value
                    if (value) then
                        s.sv.maxRows = GROUP_SIZE_MAX
                    else
                        s.sv.maxRows = 6
                    end
                    zo_callLater(s.reset, 500)
                end
            }, {
                type = "checkbox",
                name = "Gradient Mode",
                tooltip = "Changes whether the buff duration will decay using a color gradient",
                default = s.defaults.gradientMode,
                getFunc = function() return s.sv.gradientMode end,
                setFunc = function(value)
                    s.sv.gradientMode = value
                end
            }, {
                type = "colorpicker",
                name = "Buff Start Color",
                tooltip = "Sets the color of the start of the gradient for a tracked buff.",
                getFunc = function()
                    local red = s.sv.startR / 255.0
                    local green = s.sv.startG / 255.0
                    local blue = s.sv.startB / 255.0
                    return red, green, blue
                end,
                setFunc = function(red, green, blue, alpha)
                    s.sv.startR = red * 255
                    s.sv.startG = green * 255
                    s.sv.startB = blue * 255
                    zo_callLater(s.reset, 500)
                end
            }, {
                type = "colorpicker",
                name = "Buff End Color",
                tooltip = "Sets the color of the end of the gradient for a tracked buff.",
                getFunc = function()
                    local red = s.sv.endR / 255.0
                    local green = s.sv.endG / 255.0
                    local blue = s.sv.endB / 255.0
                    return red, green, blue
                end,
                setFunc = function(red, green, blue, alpha)
                    s.sv.endR = red * 255
                    s.sv.endG = green * 255
                    s.sv.endB = blue * 255
                    zo_callLater(s.reset, 500)
                end
            }, {type = "header", name = " Major Buffs"},
            -- 'Major' buffs inserted here
            {type = "header", name = " Minor Buffs"},
            -- 'Minor' buffs inserted here
            {type = "header", name = " Misc Buffs"}, -- 'Misc' buffs inserted here
            {
                type = "button",
                name = "Deselect All",
                width = "half",
                func = function()
                    for _, buff in pairs(s.data.buffs) do
                        s.sv.trackedBuffs[buff.id].enabled = false
                    end
                    r.reset()
                end
            }, {
                type = "button",
                name = "Reset Positions",
                width = "half",
                func = function()
                    for _, buff in pairs(s.data.buffs) do
                        s.sv.framePositions[buff.id] = {
                            left = 1300,
                            top = 150 + (buff.id - 1) * 10 % 1000
                        }
                        s.frames[buff.id].frame:ClearAnchors()
                        s.frames[buff.id].frame:SetAnchor(TOPLEFT, GuiRoot,
                                                          TOPLEFT, s.sv
                                                              .framePositions[buff.id]
                                                              .left, s.sv
                                                              .framePositions[buff.id]
                                                              .top)
                    end
                end
            }

        }
    }

    local majorInsert = 9
    local minorInsert = 10
    local etcInsert = 11
    for j, buff in pairs(s.data.buffs) do
        local buffName = GetAbilityName(buff.abilityId)
        local buffOption = {
            type = "submenu",
            name = buffName,
            icon = buff.icon,
            controls = {
                {
                    type = "checkbox",
                    name = "Enabled",
                    width = "half",
                    default = s.defaults.trackedBuffs[buff.id].enabled,
                    getFunc = function()
                        return s.sv.trackedBuffs[buff.id].enabled
                    end,
                    setFunc = function(value)
                        s.sv.trackedBuffs[buff.id].enabled = value
                        zo_callLater(s.reset, 500)
                    end
                }, {
                    type = "checkbox",
                    name = "Stack Mode",
                    width = "half",
                    disabled = function()
                        return not s.sv.trackedBuffs[buff.id].enabled
                    end,
                    default = false,
                    getFunc = function()
                        return s.sv.trackedBuffs[buff.id].stackMode
                    end,
                    setFunc = function(value)
                        s.sv.trackedBuffs[buff.id].stackMode = value
                        zo_callLater(s.reset, 500)
                    end
                }, {
                    type = "checkbox",
                    name = "Progress Mode",
                    width = "half",
                    disabled = function()
                        return not s.sv.trackedBuffs[buff.id].enabled
                    end,
                    default = false,
                    getFunc = function()
                        return s.sv.trackedBuffs[buff.id].progressMode
                    end,
                    setFunc = function(value)
                        s.sv.trackedBuffs[buff.id].progressMode = value
                        zo_callLater(s.reset, 500)
                    end
                }

            }
        }
        if (buffName:find("Major")) then
            table.insert(parent.controls, majorInsert, buffOption)
            majorInsert = majorInsert + 1
            minorInsert = minorInsert + 1
            etcInsert = etcInsert + 1
        elseif (buffName:find("Minor")) then
            table.insert(parent.controls, minorInsert, buffOption)
            minorInsert = minorInsert + 1
            etcInsert = etcInsert + 1
        else
            table.insert(parent.controls, etcInsert, buffOption)
            etcInsert = etcInsert + 1
        end
    end
    root[#root + 1] = parent
end

r.modules = r.modules or {}
r.modules[2] = s

r.defaults = r.defaults or {};
r.defaults[s.name] = s.defaults

FemboyFatale = FemboyFatale or {}
local r = FemboyFatale
FFShalks = FFShalks or {}
local s = FFShalks
s.name = r.name .. "Shalks"
s.displayName = "FFShalks"
s.defaults = {
    enabled = true,
    framePosition = {left = 1300, top = 150},
    gradientMode = true,
    singleColumnMode = false,
    maxRows = 6,
    progressMode = true,
    stages = {
        {
            startColor = {R = 117, G = 222, B = 120},
            endColor = {R = 222, G = 117, B = 117}
        }, {
            startColor = {R = 143, G = 196, B = 144},
            endColor = {R = 196, G = 143, B = 143}
        }
    }
}
s.debug = 1
s.data = {
    roleIcons = {
        [LFG_ROLE_DPS] = "/esoui/art/lfg/lfg_icon_dps.dds",
        [LFG_ROLE_TANK] = "/esoui/art/lfg/lfg_icon_tank.dds",
        [LFG_ROLE_HEAL] = "/esoui/art/lfg/lfg_icon_healer.dds",
        [LFG_ROLE_INVALID] = "/esoui/art/crafting/gamepad/crafting_alchemy_trait_unknown.dds"
    },
    shalks = {
        {id = 86015, proc = 6}, -- Deep Fissure
        {id = 86009, proc = 6}, -- Scorch
        {id = 86019, proc = 3} -- Sub Assault
    }
}

for _, v in pairs(s.data.shalks) do v.icon = v.icon or GetAbilityIcon(v.id) end

s.showUI = false
s.groupSize = 0
s.units = {}

function s.resetInner()
    for i = 1, GROUP_SIZE_MAX do
        s.frame.panels[i].panel:ClearAnchors()
        s.frame.panels[i].panel:SetHidden(true)
    end
    s.groupSize = GetGroupSize()
    s.units = {}

    s.frame.frame:GetNamedChild("Icon"):SetTexture(s.data.shalks[1].icon)

    local panelIndex = FFUtils.Iota();
    for i = 1, GROUP_SIZE_MAX do
        if (i <= s.groupSize or i == 1 and s.groupSize == 0) then
            local unitTag = (i == 1 and s.groupSize == 0) and "player" or
                                GetGroupUnitTagByIndex(i)
            if (unitTag and not s.sv.showOnlyDPS or
                GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_DPS) then
                s.units[unitTag] = {
                    panelId = panelIndex(),
                    self = AreUnitsEqual("player", unitTag),
                    buff = {
                        stage = 0,
                        hasBuff = false,
                        endTime = 0,
                        buffDuration = 0
                    }
                }
            end
        end
    end

    panelIndex = FFUtils.Iota()
    for i = 1, GROUP_SIZE_MAX do
        local pIndex = panelIndex()
        local soloPanel = i == 1 and s.groupSize == 0
        local unitTag = soloPanel and "player" or GetGroupUnitTagByIndex(i)
        if (not s.sv.showOnlyDPS or GetGroupMemberSelectedRole == LFG_ROLE_DPS) then
            if (i <= s.groupSize or soloPanel) then
                s.frame.panels[pIndex].name:SetText(GetUnitDisplayName(unitTag))
                s.frame.panels[pIndex].role:SetTexture(
                    s.data.roleIcons[GetGroupMemberSelectedRole(unitTag)])
                s.updateStatus(unitTag)
                s.updateRange(pIndex, IsUnitInGroupSupportRange(unitTag))

                if (pIndex == 1) then
                    s.frame.panels[pIndex].panel:SetAnchor(TOPLEFT, FFBuffFrame,
                                                           TOPLEFT, 0, 0)
                elseif (pIndex <= s.sv.maxRows) then
                    s.frame.panels[pIndex].panel:SetAnchor(TOPLEFT, s.frame
                                                               .panels[pIndex -
                                                               1].panel,
                                                           BOTTOMLEFT, 0, 0)
                else
                    s.frame.panels[pIndex].panel:SetAnchor(TOPLEFT, s.frame
                                                               .panels[pIndex -
                                                               s.sv.maxRows]
                                                               .panel, TOPRIGHT,
                                                           0, 0)
                end
                s.frame.panels[pIndex].panel:SetHidden(false)
            else
                s.frame.panels[pIndex].panel:SetAnchor(TOPLEFT, FFBuffFrame,
                                                       TOPLEFT, 0, 0)
                s.frame.panels[pIndex].panel:SetHidden(true)
            end
        end
    end

end

function s.groupMemberRoleChanged()
    s.logger.trace("s.groupMemberRoleChanged")
    local unit = s.units[unitTag]
    if (unit) then
        s.frame.panels[unit.panelId].role:SetTexture(s.data.roleIcons[newRole])
        zo_callLater(s.reset, 500)
    end
end

function s.groupSupportRangeUpdate()
    s.logger.trace("s.groupSupportRangeUpdate")
    local unit = s.units[unitTag]
    if (unit) then s.updateRange(s.units[unitTag].panelId, inRange) end
end

function s.effectChanged(_, changeType, _, _, unitTag, beginTime, endTime, _, _,
                         _, _, _, _, _, _, abilityId, _)
    s.logger.trace("s.effectChanged")
    for _, shalk in pairs(s.data.shalks) do
        if (shalk.id == abilityId and s.units[unitTag]) then
            local unitBuff = s.units[unitTag].buff
            if (changeType == EFFECT_RESULT_GAINED or changeType ==
                EFFECT_RESULT_UPDATED) then
                unitBuff.hasBuff = true
                unitBuff.stage = 1
                unitBuff.endTime = endTime
                unitBuff.buffDuration = endTime - beginTime
            elseif (changeType == EFFECT_RESULT_FADED) then
                if (unitBuff.stage == 1) then
                    unitBuff.hasBuff = true
                    unitBuff.stage = 2
                    unitBuff.endTime = unitBuff.endTime + shalk.proc
                    unitBuff.buffDuration = shalk.proc
                end
            end
        end
    end
end

function s.refreshUI()
    s.logger.trace("s.refreshUI")
    for unitTag, unit in pairs(s.units) do s.updateStatus(unitTag) end
end

function s.updateStatus(unitTag)
    s.logger.trace("s.updateStatus")
    if (not unitTag) then return nil end
    local unit = s.units[unitTag]
    local buffData = unit.buff
    local panel = s.frame.panels[unit.panelId]
    local now = GetFrameTimeMilliseconds() / 1000
    local stage = s.sv.stages[buffData.stage]
    if (stage == nil) then return nil end
    if (buffData.endTime) then
        local buffRemaining = buffData.endTime - now

        local startR, startG, startB = stage.startColor.R, stage.startColor.G,
                                       stage.startColor.B
        local endR, endG, endB = stage.endColor.R, stage.endColor.G,
                                 stage.endColor.B

        local progress = s.sv.gradientMode and
                             FFUtils.Clamp(
                                 1 - buffRemaining / buffData.buffDuration, 0, 1) or
                             0
        local backdropSize = s.sv.progressMode and (1 - progress) * 160 or 160;

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
        else
            panel.bg:SetCenterColor(0, 0, 0, 0.5)
            panel.stat:SetText("0")
            panel.bg:SetWidth(160)
            if (buffData.stage == 2) then
                buffData.hasBuff = false
                buffData.stage = 0
            end
            if (not buffData.hasBuff) then buffData.endTime = nil end
        end
    end
end
function s.updateRange(pIndex, inRange)
    s.logger.trace("s.updateRange")
    if (inRange) then
        s.frame.panels[pIndex].panel:SetAlpha(1)
    else
        s.frame.panels[pIndex].panel:SetAlpha(0.5)
    end
end

function s.reset()
    s.logger.trace("refreshing state")
    if (s.sv.enabled and (GetGroupSize() > 0 or s.debug >= 1)) then
        s.resetInner()
        if (not s.showUI) then
            s.showUI = true
            r.EM:AddFilterForEvent(s.name, EVENT_UNIT_CREATED,
                                   REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
            r.EM:RegisterForEvent(s.name, EVENT_GROUP_MEMBER_ROLE_CHANGED,
                                  s.groupMemberRoleChanged)
            r.EM:RegisterForEvent(s.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE,
                                  s.groupSupportRangeUpdate)
            for _, v in pairs(s.data.shalks) do
                r.EM:RegisterForEvent(s.name .. v.id, EVENT_EFFECT_CHANGED,
                                      s.effectChanged)
                r.EM:AddFilterForEvent(s.name .. v.id, EVENT_EFFECT_CHANGED,
                                       REGISTER_FILTER_ABILITY_ID, v.id)
            end
            r.EM:RegisterForUpdate(s.name .. "Cycle", 100, s.refreshUI)
            if (not s.debug) then
                r.EM:AddFilterForEvent(s.name, EVENT_EFFECT_CHANGED,
                                       REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
            end
            if (s.sv.enabled) then
                SCENE_MANAGER:GetScene("hud"):AddFragment(s.fragment)
                SCENE_MANAGER:GetScene("hudui"):AddFragment(s.fragment)
            else
                SCENE_MANAGER:GetScene("hud"):RemoveFragment(s.fragment)
                SCENE_MANAGER:GetScene("hudui"):RemoveFragment(s.fragment)
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
        SCENE_MANAGER:GetScene("hud"):RemoveFragment(s.fragment)
        SCENE_MANAGER:GetScene("hudui"):RemoveFragment(s.fragment)
    end
end

function s.onMoveStop()
    s.sv.framePosition.left = s.frame.frame:GetLeft()
    s.sv.framePosition.top = s.frame.frame:GetTop()
end

function s.initializeControls()
    local frame = r.WM:CreateControlFromVirtual("FFBuffFrame" .. "Shalks",
                                                FFBuffUI, "FFBuffFrame")
    frame:SetHandler("OnMoveStop", s.onMoveStop)
    s.frame = {frame = frame, panels = {}}
    for i = 1, GROUP_SIZE_MAX do
        local panel = r.WM:CreateControlFromVirtual(
                          "FFBuffPanel" .. "Shalks" .. "_" .. i, frame,
                          "FFBuffPanel", i)
        s.frame.panels[i] = {
            panel = panel,
            container = panel:GetNamedChild("Container"),
            bg = panel:GetNamedChild("Backdrop"),
            name = panel:GetNamedChild("Name"),
            role = panel:GetNamedChild("Role"),
            stat = panel:GetNamedChild("Stat")
        }
        s.frame.panels[i].container:SetEdgeColor(0, 0, 0, 0)
        s.frame.panels[i].container:SetCenterColor(0, 0, 0, 0.5)
        s.frame.panels[i].bg:SetEdgeColor(0, 0, 0, 0)
        s.frame.panels[i].bg:SetCenterColor(0, 0, 0, 0.5)
        s.frame.panels[i].stat:SetColor(1, 1, 1, 1)
        s.frame.panels[i].stat:SetText("0")
    end
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.sv.framePosition.left,
                    s.sv.framePosition.top)
    s.fragment = ZO_HUDFadeSceneFragment:New(frame)
end

function s.init()
    s.logger = FFUtils.Logger(s.displayName, s.debug)
    s.logger.trace("Initialized Logger")
    s.initializeControls()
    s.logger.trace("Initialized Control")
    r.EM:RegisterForEvent(s.name, EVENT_PLAYER_ACTIVATED, s.reset)
    r.EM:RegisterForEvent(s.name, EVENT_RAID_TRIAL_STARTED, s.reset)
    r.EM:RegisterForEvent(s.name, EVENT_UNIT_CREATED, s.reset)
    r.EM:RegisterForEvent(s.name, EVENT_GROUP_MEMBER_JOINED, s.reset)
    r.EM:RegisterForEvent(s.name, EVENT_GROUP_MEMBER_LEFT, s.reset)
end

function s.menu(root)
    parent = {
        type = "submenu",
        name = s.displayName,
        controls = {
            {type = "description", text = "Shalks Go Brr", width = "full"}, {
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
            }, {type = "header", name = "First Stage Color"}, {
                type = "colorpicker",
                width = "half",
                name = "Start",
                tooltip = "Sets the color of the start of the gradient for the first stage of shalks.",
                getFunc = function()
                    local red = s.sv.stages[1].startColor.R / 255.0
                    local green = s.sv.stages[1].startColor.G / 255.0
                    local blue = s.sv.stages[1].startColor.B / 255.0
                    return red, green, blue
                end,
                setFunc = function(red, green, blue, alpha)
                    s.sv.stages[1].startColor.R = red * 255
                    s.sv.stages[1].startColor.G = green * 255
                    s.sv.stages[1].startColor.B = blue * 255
                    zo_callLater(s.reset, 500)
                end
            }, {
                type = "colorpicker",
                width = "half",
                name = "End",
                tooltip = "Sets the color of the end of the gradient for the first stage of shalks.",
                getFunc = function()
                    local red = s.sv.stages[1].endColor.R / 255.0
                    local green = s.sv.stages[1].endColor.G / 255.0
                    local blue = s.sv.stages[1].endColor.B / 255.0
                    return red, green, blue
                end,
                setFunc = function(red, green, blue, alpha)
                    s.sv.stages[1].endColor.R = red * 255
                    s.sv.stages[1].endColor.G = green * 255
                    s.sv.stages[1].endColor.B = blue * 255
                    zo_callLater(s.reset, 500)
                end
            }, {type = "header", name = "Second Stage Color"}, {
                type = "colorpicker",
                width = "half",
                name = "Start",
                tooltip = "Sets the color of the start of the gradient for the second stage of shalks.",
                getFunc = function()
                    local red = s.sv.stages[1].startColor.R / 255.0
                    local green = s.sv.stages[1].startColor.G / 255.0
                    local blue = s.sv.stages[1].startColor.B / 255.0
                    return red, green, blue
                end,
                setFunc = function(red, green, blue, alpha)
                    s.sv.stages[1].startColor.R = red * 255
                    s.sv.stages[1].startColor.G = green * 255
                    s.sv.stages[1].startColor.B = blue * 255
                    zo_callLater(s.reset, 500)
                end
            }, {
                type = "colorpicker",
                width = "half",
                name = "End",
                tooltip = "Sets the color of the end of the gradient for the second stage of shalks.",
                getFunc = function()
                    local red = s.sv.stages[1].endColor.R / 255.0
                    local green = s.sv.stages[1].endColor.G / 255.0
                    local blue = s.sv.stages[1].endColor.B / 255.0
                    return red, green, blue
                end,
                setFunc = function(red, green, blue, alpha)
                    s.sv.stages[1].endColor.R = red * 255
                    s.sv.stages[1].endColor.G = green * 255
                    s.sv.stages[1].endColor.B = blue * 255
                    zo_callLater(s.reset, 500)
                end
            }

        }
    }
    root[#root + 1] = parent
end

r.modules = r.modules or {}
r.modules[3] = s

r.defaults = r.defaults or {}
r.defaults[s.name] = s.defaults

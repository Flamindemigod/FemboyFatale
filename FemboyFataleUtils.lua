FFUtils = {}

function FFUtils.Iota()
    local __iota = 1
    return function()
        local i = __iota
        __iota = __iota + 1
        return i
    end
end

function FFUtils.Logger(moduleName, traceMode)
    -- traceMode is a u2
    -- 0 No logging
    -- 1 info
    -- 2 debug
    -- 3 trace
    return {
        info = function(msg)
            if (traceMode < 1) then return nil end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Info: " .. msg)
        end,
        debug = function(msg)
            if (traceMode < 2) then return nil end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Debug: " .. msg)
        end,
        trace = function(msg)
            if (traceMode < 3) then return nil end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Trace: " .. msg)
        end
    }
end

-- Straight up yoinked from Buff the Group
-- https://github.com/Fostecks/BuffTheGroup
-- Repo hasnt been updated for a while
-- Bitrock(Fostecks) being Lazy
function FFUtils.Interpolate(a, b, coefficient) return a + (b - a) * coefficient end

-- Straight up yoinked from Buff the Group
-- https://github.com/Fostecks/BuffTheGroup
-- Repo hasnt been updated for a while
-- Bitrock(Fostecks) being Lazy
function FFUtils.Clamp(i, min, max) return math.max(min, math.min(max, i)) end

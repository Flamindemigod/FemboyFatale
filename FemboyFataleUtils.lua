FFUtils = {}

function FFUtils.Iota()
    local __iota = 1
    return function()
        local i = __iota
        __iota = __iota + 1
        return i
    end
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

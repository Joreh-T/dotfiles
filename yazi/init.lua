---@diagnostic disable: undefined-global
-- Starship prompt plugin for yazi
-- https://github.com/Rolv-Apneseth/starship.yazi
-- ./plugins/starship.yazi/
-- require("starship"):setup()

-- require("easyjump"):setup()

-- This plugin provides cross-instance yank ability, which means you can yank
-- files in one instance, and then paste them in another instance.
-- require("session"):setup({
-- 	sync_yanked = true,
-- })

-- https://github.com/yazi-rs/plugins/tree/main/git.yazi

require("git"):setup {
}

local MONTHS = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}

-- file size and modify time, shown in the linemode
function Linemode:size_and_mtime()
    local time = math.floor(self._file.cha.mtime or 0)
    local time_str
    if time == 0 then
        time_str = ""
    else
        local now_year   = tonumber(os.date("%Y"))
        local file_year  = tonumber(os.date("%Y", time))
        local month_idx  = tonumber(os.date("%m", time))
        local day        = tonumber(os.date("%d", time))
        local month      = MONTHS[month_idx] or "???"

        if file_year == now_year then
            time_str = string.format("%s %2d %s", month, day, os.date("%H:%M", time))
        else
            time_str = string.format("%s %2d  %d", month, day, file_year)
        end
    end

    local size = self._file:size()
    return string.format("%s %s", size and ya.readable_size(size) or "-", time_str)
end
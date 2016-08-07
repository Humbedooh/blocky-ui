local JSON = require 'cjson'
local elastic = require 'elastic'
function parse(r)
    local b = r:requestbody()
    get = {}
    if b and #b > 0 then
        local okay, _get = pcall(function() return JSON.decode(b) end)
        if okay then
            get = _get
        end
    end
    return get
end

return {
    parse = parse
}
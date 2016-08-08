
local elastic = require 'elastic'
local JSON = require 'cjson'
local input = require 'parse'

function handle(r)
    r.content_type = "application/json"
    local get = r:parseargs()
    local post = input.parse(r)
    
    if get.delete then
        local doc = elastic.get('ban', get.delete)
        if doc then
            elastic.delete('ban', get.delete)
        end
    end
    
    local bans = elastic.count({}, 'ban')
    local whitelisted = elastic.count({}, 'whitelist')
    
    local banSize = 20
    if get.hits then
        banSize = tonumber(get.hits) or 20
    end
    
    banList = elastic.raw ({
            sort = {
                {epoch = "desc"}
            },
            size = banSize
        }, 'ban')
    local bl = {}
    if banList and banList.hits.hits then
        for k, v in pairs(banList.hits.hits) do
            local b = v._source
            b.ip = v._id
            if b.ip ~= get.delete then
                table.insert(bl, b)
            end
        end
    end
    r:puts(JSON.encode{
        okay = true,
        banned = bans,
        whitelisted = whitelisted,
        banlist = bl
    })
    
    return apache2.OK
end

local elastic = require 'elastic'
local JSON = require 'cjson'
local input = require 'parse'

function handle(r)
    r.content_type = "application/json"
    local get = r:parseargs()
    local post = input.parse(r)
    
    local bans = elastic.count({}, 'ban')
    local whitelisted = elastic.count({}, 'whitelist')
    
    banSize = 20
    if get.hits then
        banSize = tonumber(get.hits) or 20
    end
    
    banList = elastic.raw ({
            sort = {
                {epoch = "desc"}
            },
            size = banSize,
            query = {
            }
        }, 'ban')
    
    r:puts(JSON.encode{
        okay = true,
        banned = bans,
        whitelisted = whitelisted,
        banlist = banList
    })
    
    return apache2.OK
end

local elastic = require 'elastic'
local JSON = require 'cjson'
local input = require 'parse'

function handle(r)
    r.content_type = "application/json"
    
    local whitelist = elastic.find('*', 9999, 'whitelist', 'epoch')
    local greylist = elastic.find('*', 9999, 'tmpwhite', 'removeTime')
    local banList = elastic.raw ({
            sort = {
                {epoch = "desc"}
            },
            size = 1000
        }, 'ban')
    local bl = {}
    if banList and banList.hits.hits then
        for k, v in pairs(banList.hits.hits) do
            local b = v._source
            b.ip = v._id
            local good = false
            for xk, xv in pairs(whitelist) do
                if b.ip == xv.request_id then
                    good = true
                    break
                end
            end
            for xk, xv in pairs(greylist) do
                if b.ip == xv.request_id and xv.removeTime > (os.time() - 86400) then
                    good = true
                    break
                end
            end
            if not good then
                table.insert(bl, b)
            end
        end
    end
    local list = {}
    for k, v in pairs(whitelist) do
        table.insert(list, { ip = v.request_id, unban = true, target = "*" })
    end
    for k, v in pairs(greylist) do
        if v.removeTime > (os.time() - 86400) then
            table.insert(list, { ip = v.request_id, unban = true, target = "*" })
        end
    end
    for k, v in pairs(bl) do
        if v.epoch > (os.time() - (86400*7)) then
            table.insert(list, { ip = v.ip, reason = v.reason, target = "*" })
        end
    end
    if #list > 0 then
        r:puts(JSON.encode(list))
    else
        r:puts("[]")
    end
    return apache2.OK
end
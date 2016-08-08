
local elastic = require 'elastic'
local JSON = require 'cjson'
local input = require 'parse'

function handle(r)
    r.content_type = "application/json"
    local get = r:parseargs()
    local post = input.parse(r)
    
    if get.delete then
        local doc = elastic.get('rule', get.delete)
        if doc then
            elastic.delete('rule', get.delete)
            r.usleep(500000)
        end
    end
    
    if post.addrule then
        local name = post.addrule.name
        local t = post.addrule.type
        local limit = post.addrule.limit
        local span = post.addrule.span or 24
        local tbl = {}
        for k, v in pairs(post.addrule.query) do
            table.insert(tbl, v)
        end
        local id = r:sha1(math.random(1, os.time()) .. r.clock() .. r.useragent_ip)
        if #tbl > 0 then
            local doc = {
                name = name,
                ['type'] = t,
                limit = limit,
                span = span,
                query = tbl
            }
            if post.addrule.id then
                local xdoc = elastic.get('rule', post.addrule.id)
                if xdoc then
                    elastic.update('rule', post.addrule.id, doc)
                end
            else
                elastic.index(r, id, 'rule', doc)
            end
            r.usleep(1000000)
        end
    end
    
    ruleList = elastic.raw ({
            size = 999
        }, 'rule')
    local rl = {}
    if ruleList and ruleList.hits.hits then
        for k, v in pairs(ruleList.hits.hits) do
            local b = v._source
            b.id = v._id
            table.insert(rl, b)
        end
    end
    r:puts(JSON.encode{
        okay = true,
        rules = rl
    })
    
    return apache2.OK
end

local elastic = require 'elastic'
local JSON = require 'cjson'
local input = require 'parse'

function handle(r)
    r.content_type = "application/json"
    local get = r:parseargs()
    local post = input.parse(r)
    
    if get.delete then
        local docid = get.delete:gsub("/", "_")
        local doc = elastic.get('ban', docid)
        if doc then
            elastic.delete('ban', docid)
            doc.removeTime = os.time()
            elastic.index(r, docid, 'tmpwhite', doc)
        end
    end
    
    if get.track and get.rule then
        local rule = elastic.get('rule', get.rule)
        if rule then
            local q = {}
            for k, v in pairs(rule.query) do
                local key, v = v:match("^(%S+)=(.+)")
                local num = v:match("^(%d+)$")
                local str = v:match('"(.+)"')
                if num then
                    table.insert(q, { term = { [key] = tonumber(num) }})
                elseif str then
                    table.insert(q, { term = { [key] = str }})
                end
            end
            table.insert(q, { term = { clientip = get.track }})
            local res = elastic.raw({
                size = 500,
                sort = {
                    {
                        ['@timestamp'] = {
                            order = 'desc'
                        }
                    }
                },
                query = {
                    bool = {
                        must = q
                    }
                }
            }, '', 'loggy-*')
            r:puts(JSON.encode{
                okay = true,
                ip = get.track,
                rule = rule,
                res = res
            })
        end
        return apache2.OK
    end
    
    if get.qq then
        local res = elastic.raw({
            size = 500,
            sort = {
                {
                    ['@timestamp'] = {
                        order = 'desc'
                    }
                }
            },
            query = {
                query_string = {
                    default_field = "message",
                    query = get.qq
                }
            }
        }, '', 'loggy-*')
        r:puts(JSON.encode{
            okay = true,
            res = res
        })
        return apache2.OK
    end
    
    if get.deletewhite then
        local docid = get.deletewhite:gsub("/", "_")
        local doc = elastic.get('whitelist',docid)
        if doc then
            elastic.delete('whitelist', docid)
        end
    end
    local corrected = nil
    if post.ban then
        local reason = post.ban.reason
        local ip = post.ban.ip
        -- cidr calcs: Find what iptables would expect the real CIDR to be.
        if ip.match("/") then
            local a,b,c,d = ip:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)")
            local block = tonumber(ip:match("/(%d+)"))
            local bignum = bit32.lshift(tonumber(a), 24) + bit32.lshift(tonumber(b), 16) + bit32.lshift(tonumber(c), 8) + tonumber(d)
            local lowest = bit32.lshift(bit32.rshift(bignum, 32-block), 32-block)
            local realcidr = ("%d.%d.%d.%d/%d"):format(
                bit32.rshift(lowest, 24),
                bit32.rshift(lowest % 2^24, 16),
                bit32.rshift(lowest % 2^16, 8),
                lowest % 256,
                block
            )
            if ip ~= realcidr then
                ip = realcidr
                corrected = realcidr
            end            
        end
        local docid = ip:gsub("/", "_")
        local target = post.ban.target or '*'
        local who = r.user or "nobody"

        local doc = {
            ip = ip,
            target = target,
            reason = "Banned by " .. who .. ": " .. reason,
            epoch = os.time(),
            banTime = os.time()
        }
        local xdoc = elastic.get('ban', docid)
        if xdoc then
            elastic.update('ban', docid, doc)
        else
            elastic.index(r, docid, 'ban', doc)
        end
        r.usleep(1000000)
    end
    
    if post.whitelist then
        local reason = post.whitelist.reason
        local ip = post.whitelist.ip
        local docid = ip:gsub("/", "_")
        local target = '*'
        local who = r.user or "nobody"

        local doc = {
            ip = ip,
            target = target,
            reason = "Whitelisted by " .. who .. ": " .. reason,
            epoch = os.time()
        }
        
        local xdoc = elastic.get('whitelist', docid)
        if xdoc then
            elastic.update('whitelist', docid, doc)
        else
            elastic.index(r, docid, 'whitelist', doc)
        end
        r.usleep(1000000)
    end
    
    local bans = elastic.count({}, 'ban')
    local whitelist = elastic.find('*', 9999, 'whitelist')
    
    local banSize = 25
    if get.hits then
        banSize = tonumber(get.hits) or 25
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
        correction = corrected,
        banned = bans,
        whitelisted = #whitelist,
        whitelist = whitelist,
        banlist = bl
    })
    
    return apache2.OK
end
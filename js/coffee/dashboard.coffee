loadDashboard = (howMany) ->
    fetch("./api/dashboard.lua" + (if howMany then ('?hits='+howMany) else ''), null, renderDashboard)
    
renderDashboard = (json) ->
    main = get('bread')
    h2 = mk('h2', {}, "Currently " + json.banned + " IP" + (if json.banned != 1 then 's' else '') + " banned, " + json.whitelisted + " IP" + (if json.whitelisted != 1 then 's' else '') + " whitelisted.")
    app(main, h2)
    
    if isArray json.banlist and json.banlist.length > 0
        ul = mk('ul')
        for ip in json.banlist
            li = mk('li', {}, ip.ip + ": " + ip.reason)
            app(ul, li)
        app(main, ul)
        if json.banlist.length < json.banned
            howMany = (parseInt(json.banlist.Length / 20)+1) * 20
            app(main, mk('a', { href:"javascript:void(loadDashboard("+howMany+"));"}, "Show more..."))
    
    
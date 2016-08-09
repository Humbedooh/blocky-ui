loadDashboard = (howMany) ->
    fetch("./api/dashboard.lua" + (if howMany then ('?hits='+howMany) else ''), null, renderDashboard)
    
renderDashboard = (json, edit) ->
    main = get('bread')
    main.innerHTML = ""
    if edit
        alert("Ban list updated!")
    h2 = mk('h2', {}, "Currently " + json.banned + " IP" + (if json.banned != 1 then 's' else '') + " banned, " + json.whitelisted + " IP" + (if json.whitelisted != 1 then 's' else '') + " whitelisted.")
    app(main, h2)
    
    if isArray(json.banlist) and json.banlist.length > 0
        ul = mk('ul')
        for ip in json.banlist
            renewDate = new Date(ip.epoch * 1000.0).toUTCString()
            ipname = ip.ip
            if ip.dns and ip.dns != ip.ip
                ipname += " (" + ip.dns + ")"
            pt = ""
            tracker = ""
            if ip.rid
                pt = " - "
                tracker = mk('a', { href: "javascript:void(trackBan('" + ip.ip+"', '" + ip.rid + "'));"}, "Track")
            li = mk('li', {style: "font-size: 0.8rem;"}, [mk('kbd', {}, ipname), ": " + ip.reason + " - Ban last renewed renewed " + renewDate + " - ", mk('a', { href: "javascript:void(deleteBan('" + ip.ip+"'));"}, "Remove ban"), pt, tracker])
            app(ul, li)
        app(main, ul)
        if json.banlist.length < json.banned
            howMany = (parseInt(json.banlist.Length / 20)+1) * 20
            app(main, mk('a', { href:"javascript:void(loadDashboard("+howMany+"));"}, "Show more..."))
    
    
deleteBan = (ip) ->
    fetch("./api/dashboard.lua?delete=" + ip, true, renderDashboard)

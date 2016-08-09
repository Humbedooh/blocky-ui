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

trackBan = (ip, rid) ->
    fetch("./api/dashboard.lua?track=" + ip + "&rule=" + rid, null, showTrack)
    
showTrack = (json) ->
    main = get('bread')
    div = get('tracker')
    if not div
        div = mk('div', { id: 'tracker', style: "border: 1px dotted #333; padding: 10px; font-size: 0.75rem;"})
        app(main, div)
    div.innerHTML = "<h3>Tracking data for " + json.ip + " using rule '" + json.rule.name + "':</h3>"
    
    tbl = mk('table')
    app(div, tbl)
    for item, i in json.res.hits.hits
        if i > 10
            break
        source = item._source
        if i == 0
            tr = mk('tr')
            for k, v of source
                td = mk('td', {style: "font-weight: bold;"}, k)
                app(tr, td)
            app(tbl, tr)
        tr = mk('tr')
        for k, v of source
            td = mk('td', {}, v)
            app(tr, td)
        app(tbl, tr)
    
    
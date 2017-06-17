
loadDashboard = (howMany) ->
    fetch("./api/dashboard.lua" + (if howMany then ('?hits='+howMany) else ''), null, renderDashboard)
    
findRule = () ->
    ip = get('findrule').value
    if ip
        fetch("./api/dashboard.lua?hits=9999", {ip: ip}, showRule)
    return false
        
showRule = (json, state) ->
    found = false
    if isArray(json.banlist) and json.banlist.length > 0
        main = get('bread')
        main.innerHTML = ""
        ul = mk('ul', {style: 'text-align: left;'})
        for ip in json.banlist
            if ip.ip == state.ip
                found = true
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
    if not found
        alert("No bans found for #{state.ip}!")
    
renderDashboard = (json, edit) ->
    main = get('bread')
    main.innerHTML = ""
    if edit
        alert("Ban list updated!")
    h2 = mk('h2', {}, "Currently " + json.banned.pretty() + " IP" + (if json.banned != 1 then 's' else '') + " banned, " + json.whitelisted + " IP" + (if json.whitelisted != 1 then 's' else '') + " whitelisted.")
    app(main, h2)
    
    if isArray(json.banlist) and json.banlist.length > 0
        ul = mk('ul')
        for ip in json.banlist
            renewDate = new Date(ip.epoch * 1000.0).toUTCString()
            ipname = ip.ip.replace("_", "/")
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
            howMany = (parseInt(json.banlist.length / 25)+1) * 25
            app(main, mk('a', { href:"javascript:void(loadDashboard("+howMany+"));"}, "Show more..."))

loadQQ = () ->
    main = get('bread')
    main.innerHTML = ""
    qqf = mk('form', { onsubmit: "return doQQ();" })
    qqt = mk('input', { type: "text", style: "width: 500px;", id: "qq", placeholder: "Quick query..."})
    app(qqf, qqt)
    app(main, qqf)

loadFindRule = () ->
    main = get('bread')
    main.innerHTML = ""
    qqf = mk('form', { onsubmit: "return findRule();" })
    qqt = mk('input', { type: "text", style: "width: 500px;", id: "findrule", placeholder: "IP address or CIDR block to find..."})
    app(qqf, qqt)
    app(main, qqf)

doQQ = () ->
    qq = get('qq').value
    fetch("./api/dashboard.lua?qq=" + qq, null, showQQ)
    return false
    
deleteBan = (ip) ->
    if currentTab == 'manual'
        alert("Ban removed!")
        manualBan()
    else
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
    
    tbl = mk('table', { border: "1"})
    app(div, tbl)
    for item, i in json.res.hits.hits
        if i > 100
            break
        source = item._source
        if i == 0
            tr = mk('tr')
            for k, v of source
                if k != 'time' and k != 'timestamp' and not k.match(/geo/)
                    td = mk('td', {style: "font-weight: bold;"}, k)
                    app(tr, td)
            app(tbl, tr)
        tr = mk('tr')
        for k, v of source
            if k != 'time' and k != 'timestamp' and not k.match(/geo/)
                td = mk('td', {}, v + "")
                app(tr, td)
        app(tbl, tr)
    
showQQ = (json) ->
    main = get('bread')
    div = get('tracker')
    if not div
        div = mk('div', { id: 'tracker', style: "border: 1px dotted #333; padding: 10px; font-size: 0.75rem;"})
        app(main, div)
    if not isArray(json.res.hits.hits)
        json.res.hits.hits = []
    div.innerHTML = "<h3>Quick query results (" + json.res.hits.hits.length + "):</h3>"
    
    tbl = mk('table', { border: "1"})
    app(div, tbl)
    for item, i in json.res.hits.hits
        if i > 100
            break
        source = item._source
        if i == 0
            tr = mk('tr')
            for k, v of source
                if k != 'time' and k != 'timestamp' and not k.match(/geo/)
                    td = mk('td', {style: "font-weight: bold;"}, k)
                    app(tr, td)
            app(tbl, tr)
        tr = mk('tr')
        for k, v of source
            if k != 'time' and k != 'timestamp' and not k.match(/geo/)
                td = mk('td', {}, v + "")
                app(tr, td)
        app(tbl, tr)
    if json.res.hits.hits.length == 0
        app(div, txt("No results were found"))
    
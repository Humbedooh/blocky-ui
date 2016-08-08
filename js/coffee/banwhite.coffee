manualBan = () ->
    main = get('bread')
    div = get('addrule')
    if not div
        div = mk('div', {id: "addrule"})
        app(main, div)
    div.innerHTML = ""
    
    
    form = mk('form')
    
    # IP to ban
    fd = mk('div', {style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"})
    fdd = mk('div', { style: "float: left; width: 150px; font-weight: bold;"}, "IP to ban: ")
    fid = mk('div', { style: "float: left; width: 350px;"}, mk('input', { style: 'width: 200px;', type:'text', 'id':'ip'}))
    fih = mk('div', { style: "float: left; width: 250px; font-style: italic;"}, "The IPv4/IPv6 address to ban")
    app(fd, fdd)
    app(fd, fid)
    app(fd, fih)
    app(form, fd)
    
    # Reason for ban
    fd = mk('div', {style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"})
    fdd = mk('div', { style: "float: left; width: 150px; font-weight: bold;"}, "Reason for ban: ")
    fid = mk('div', { style: "float: left; width: 350px;"}, mk('input', { style: 'width: 200px;', type:'text', 'id':'reason'}))
    fih = mk('div', { style: "float: left; width: 250px; font-style: italic;"}, "A short description of why this ban is in place")
    app(fd, fdd)
    app(fd, fid)
    app(fd, fih)
    app(form, fd)
    
    
    # Target
    fd = mk('div', {style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"})
    fdd = mk('div', { style: "float: left; width: 150px; font-weight: bold;"}, "Target machine(s) to ban on: ")
    fid = mk('div', { style: "float: left; width: 350px;"}, mk('input', { style: 'width: 200px;', type:'text', 'id':'target', value: '*'}))
    fih = mk('div', { style: "float: left; width: 250px; font-style: italic;"}, "The target machine hostname to ban on. Default is *, which means all machines. Can also be a specific machine, like eos.apache.org.")
    app(fd, fdd)
    app(fd, fid)
    app(fd, fih)
    app(form, fd)
    
    fd = mk('div', {style: "width: 100%; relative; overflow: auto;"})
    btn = mk('input', {type: 'button', class: 'btn btn-success', value: "Ban IP", onclick: 'submitBan();'})
    app(fd, btn)
    app(form, fd)
    app(div, form)
    
submitBan = () ->
    ip = get('ip').value
    if ip.length <= 6
        alert("Please enter a valid IP address!")
        return
    reason = get('reason').value
    if reason.length == 0
        alert("Please enter a reason for the ban!")
        return
    target = get('target').value
    if target.length == 0
        alert("Please enter a target machine name or use * for all machines.")
        return
    postJSON("./api/dashboard.lua", {
        ban: {
            ip: ip,
            reason: reason,
            target: target
        }
    }, null, () ->
        alert("Ban added!")
        manualBan()
        )
    
deleteWhite = (ip) ->
    alert("IP removed from whitelist")
    fetch("./api/dashboard.lua?deletewhite=" + ip, null, renderWhitelist)
    
whiteList = () ->
    fetch("./api/dashboard.lua", null, renderWhitelist)

renderWhitelist = (json) ->
    main = get('bread')
    div = get('addrule')
    if not div
        div = mk('div', {id: "addrule"})
        app(main, div)
    div.innerHTML = ""
    
    if isArray(json.whitelist) and json.whitelist.length > 0
        app(div, mk('h3', {}, "Currently whitelisted IPs:"))
        ul = mk('ul')
        for ip in json.whitelist
            li = mk('li', {style: "font-size: 0.8rem;"}, [mk('kbd', {}, ip.ip), ": " + ip.reason + " - ", mk('a', { href: "javascript:void(deleteWhite('" + ip.ip+"'));"}, "Remove whitelisting")])
            app(ul, li)
        app(div, ul)
    else
        app(div, mk('h4', {}, "There are no whitelisted IPs at the moment."))
        
        
    form = mk('form')
    app(form, mk('h3', {}, "Whitelist a new IP:"))
    # IP to whitelist
    fd = mk('div', {style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"})
    fdd = mk('div', { style: "float: left; width: 150px; font-weight: bold;"}, "IP to whitelist: ")
    fid = mk('div', { style: "float: left; width: 350px;"}, mk('input', { style: 'width: 200px;', type:'text', 'id':'ip'}))
    fih = mk('div', { style: "float: left; width: 250px; font-style: italic;"}, "The IPv4/IPv6 address to whitelist")
    app(fd, fdd)
    app(fd, fid)
    app(fd, fih)
    app(form, fd)
    
    # Reason for whitelisting
    fd = mk('div', {style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"})
    fdd = mk('div', { style: "float: left; width: 150px; font-weight: bold;"}, "Reason for whitelisting: ")
    fid = mk('div', { style: "float: left; width: 350px;"}, mk('input', { style: 'width: 200px;', type:'text', 'id':'reason'}))
    fih = mk('div', { style: "float: left; width: 250px; font-style: italic;"}, "A short description of why this whitelisting is in place")
    app(fd, fdd)
    app(fd, fid)
    app(fd, fih)
    app(form, fd)
    
    fd = mk('div', {style: "width: 100%; relative; overflow: auto;"})
    btn = mk('input', {type: 'button', class: 'btn btn-success', value: "Whitelist IP", onclick: 'submitWhite();'})
    app(fd, btn)
    app(form, fd)
    
    app(div, form)
    
submitWhite = () ->
    ip = get('ip').value
    if ip.length <= 6
        alert("Please enter a valid IP address!")
        return
    reason = get('reason').value
    if reason.length == 0
        alert("Please enter a reason for the whitelisting!")
        return
    postJSON("./api/dashboard.lua", {
        whitelist: {
            ip: ip,
            reason: reason
        }
    }, null, () ->
        alert("Whitelisting added!")
        whiteList()
        )
    
    
loadDashboard = () ->
    fetch("./api/dashboard.lua", null, renderDashboard)
    
renderDashboard = (json) ->
    main = get('bread')
    h2 = mk('h2', {}, "Currently " + json.banned + " IP" + (if json.banned != 1 then 's' else '') + " banned, " + json.whitelisted + " IP" + (if json.whitelisted != 1 then 's' else '') + " whitelisted.")
    app(main, h2)
    
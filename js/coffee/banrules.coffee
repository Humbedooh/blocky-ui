loadRules = () ->
    fetch("./api/rules.lua", null, renderRules)
    
banRules = []

renderRules = (json) ->
    main = get('bread')
    app(main, mk('a', { style: "font-size: 2rem;", href: "javascript:void(addRule());"}, "Add a new rule"))
    app(main, mk('br'))
    if isArray(json.rules) and json.rules.length > 0
        banRules = json.rules
        app(main, mk('h3', {}, "Current rules:"))
        ul = mk('ul')
        for item in json.rules
            li = mk('li', {}, item.name)
            app(ul, li)
        app(main, ul)
    else
        app(main, mk('h3', {}, "Doesn't seem like there are any rules yet..."))
    
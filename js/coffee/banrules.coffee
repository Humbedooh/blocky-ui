loadRules = () ->
    fetch("./api/rules.lua", null, renderRules)
    
banRules = []

ruleTypes = {
    httpd_visits: 'HTTPd visit count'
    httpd_traffic: 'HTTPd traffic count'
}

ruleSpans = {
    24: "One day (24 hours)"
    168: "One week (168 hours)"
    720: "One month (720 hours)"
}

renderRules = (json, edit) ->
    main = get('bread')
    main.innerHTML = ""
    if edit
        alert("Rules updated!")
    app(main, mk('a', { style: "font-size: 2rem;", href: "javascript:void(addRule());"}, "Add a new rule"))
    app(main, mk('br'))
    if isArray(json.rules) and json.rules.length > 0
        json.rules.sort((a,b) ->
            as =  a.name
            bs =  b.name
            if as < bs
                return 1
            if as == bs
                return 0
            if as > bs
                return -1
            return 0
        )
        banRules = json.rules
        app(main, mk('h3', {}, "Current rules:"))
        ul = mk('ul')
        for item, i in json.rules
            li = mk('li', {}, [item.name + " - ", mk('a', {href:"javascript:void(addRule("+i+"));"}, "Edit rule")])
            app(ul, li)
        app(main, ul)
    else
        app(main, mk('h3', {}, "Doesn't seem like there are any rules yet..."))
    
addRule = (rule) ->
    main = get('bread')
    div = get('addrule')
    if not div
        div = mk('div', {id: "addrule"})
        app(main, div)
    div.innerHTML = ""
    
    
    form = mk('form')
    rule = banRules[rule] || {}
    
    # Rule name
    fd = mk('div', {style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"})
    fdd = mk('div', { style: "float: left; width: 150px; font-weight: bold;"}, "Rule name: ")
    fid = mk('div', { style: "float: left; width: 350px;"}, mk('input', { style: 'width: 200px;', type:'text', 'id':'name', value: rule.name}))
    fih = mk('div', { style: "float: left; width: 250px; font-style: italic;"}, "A short description of what this rule is for.")
    app(fd, fdd)
    app(fd, fid)
    app(fd, fih)
    app(form, fd)
    
    # Rule type
    options = []
    options.push(mk('option', {value: "0", disabled: 'true', selected:'true'},"Select a rule type:"))
    for k,v of ruleTypes
        options.push(mk('option', {selected: (if rule.type == k then 'selected' else null), value: k}, v))
    fd = mk('div', {style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"})
    fdd = mk('div', { style: "float: left; width: 150px; font-weight: bold;"}, "Type of rule:")
    fid = mk('div', { style: "float: left; width: 350px;"}, mk('select', { style: 'width: 200px;', 'id':'type'}, options))
    fih = mk('div', { style: "float: left; width: 250px; font-style: italic;"}, "The type of rule (traffic or doc count)")
    app(fd, fdd)
    app(fd, fid)
    app(fd, fih)
    app(form, fd)
    
    # Rule limit
    fd = mk('div', {style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"})
    fdd = mk('div', { style: "float: left; width: 150px; font-weight: bold;"}, "Rule limit: ")
    fid = mk('div', { style: "float: left; width: 350px;"}, mk('input', { style: 'width: 200px;', type:'text', 'id':'limit', value: rule.limit}))
    fih = mk('div', { style: "float: left; width: 250px; font-style: italic;"}, "The limit (doc count or traffic in bytes) that triggers a ban.")
    app(fd, fdd)
    app(fd, fid)
    app(fd, fih)
    app(form, fd)
    
    # Rule span
    options = []
    options.push(mk('option', {value: "0", disabled: 'true', selected:'true'},"Select a timespan for the limit:"))
    for k,v of ruleSpans
        options.push(mk('option', {selected: (if rule.span == k then 'selected' else null), value: k}, v))
    fd = mk('div', {style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"})
    fdd = mk('div', { style: "float: left; width: 150px; font-weight: bold;"}, "Timespan to apply limit to:")
    fid = mk('div', { style: "float: left; width: 350px;"}, mk('select', { style: 'width: 200px;', 'id':'span'}, options))
    fih = mk('div', { style: "float: left; width: 250px; font-style: italic;"}, "How far back to search for the limit being broken, typically one day.")
    app(fd, fdd)
    app(fd, fid)
    app(fd, fih)
    app(form, fd)
    
    # Queries
    fd = mk('div', {style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"})
    fdd = mk('div', { style: "float: left; width: 150px; font-weight: bold;"}, "Query data")
    fid = mk('div', { style: "float: left; width: 350px;"}, mk('textarea', { style: 'width: 320px; height: 100px;', placeholder: "One query per line, in the format: key=\"string\" or key=num", 'id':'rules'}, (rule.query||[]).join("\n")))
    fih = mk('div', { style: "float: left; width: 250px; font-style: italic;"}, "The queries to apply to this search.")
    app(fd, fdd)
    app(fd, fid)
    app(fd, fih)
    app(form, fd)
    
    # Submit
    fd = mk('div', {style: "width: 100%; relative; overflow: auto;"})
    btn = mk('input', {type: 'button', class: 'btn btn-success', value: "Save rule", onclick: 'submitRule("'+(rule.id||"")+'");'})
    app(fd, btn)
    app(form, fd)
        
    app(div, form)
    
submitRule = (id) ->
    name = get('name').value
    if name.length == 0
        alert("Please enter a title for this rule!")
        return
    type = get('type').value
    if not type or parseInt(type) <= 0
        alert("Please select a rule type!")
        return
    limit = parseInt(get('limit').value)
    if limit <= 0 or get('limit').value.length == 0
        alert("Please enter a sane ban limit!")
        return
    span = get('span').value
    if not span or parseInt(span) <= 0
        alert("Please select a timespan!")
        return
    span = parseInt(span)
    query = []
    lines = get('rules').value.split(/\r?\n/)
    for line in lines
        if line.match(/^\S+=".+"$/) or line.match(/\S+=[0-9.]+$/)
            query.push(line)
        else
            alert("Query lines need to be of format 'key=\"string\"' or 'key=num'!")
            return
    if query.length < 2
        alert("The query set needs to have at least two queries!")
        return
    
    if id and id.length > 0
        postJSON("./api/rules.lua", {
            addrule: {
                id: id,
                name: name,
                type: type,
                limit: limit,
                span: span,
                query: query
            }
        }, true, renderRules)
    else
        postJSON("./api/rules.lua", {
            addrule: {
                name: name,
                type: type,
                limit: limit,
                span: span,
                query: query
            }
        }, true, renderRules)
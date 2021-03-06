
currentTab = null

loadTabs = (stab) ->
    tabs = {
        recent: 'Recent activity',
        search: 'Search the archive'
        findban: 'Find a ban',
        rules: 'Ban rules',
        manual: 'Manual ban',
        whitelist: 'Whitelist'
    }
    
    main = new HTML('div', { id: 'dialog'})
    document.getElementById('wrapper').innerHTML = ""
    document.getElementById('wrapper').appendChild(main)
    
    tdiv = new HTML('div', {class: 'tabs'})
    main.inject(tdiv)
    for k,v of tabs
        if (stab and stab == k) or (not stab and k == 'recent')
            currentTab = k
            tab = new HTML('div', {class: 'tablink tablink_selected'}, v)
            title = new HTML('h2', {}, v+":")
            main.inject(title)
        else
            tab = new HTML('div', {class: 'tablink', onclick: "loadTabs('" + k + "');"}, v)
        tdiv.inject(tab)
    
    
    bread = new HTML('div', { class: 'bread', id: 'bread'})
    main.inject(bread)
    loadBread(stab or 'recent')

loadBread = (what) ->
    if what == 'recent'
        loadDashboard();
    if what == 'rules'
        loadRules();
    if what == 'whitelist'
        whiteList();
    if what == 'manual'
        manualBan();
    if what == 'search'
        loadQQ();
    if what == 'findban'
        loadFindRule();
    


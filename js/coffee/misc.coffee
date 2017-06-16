
API = 1
oldPopup = false

popup = (title, body) ->
    if oldPopup
        p = get('popupdiv')
        if not p
            d = mk('div')
            set(d, 'id', 'popupdiv')
            set(d, 'title', title)
            p = mk('p')
            app(d, mk('img', { style: "margin: 0 auto;", src: "images/logo.png", width: "128", height: "128"}))
            app(p, txt(body))
            app(d, p)
            document.body.appendChild(d)

        $('#popupdiv').dialog()
    else
            document.body.innerHTML = ""
            div = mk('div', {style:'text-align: center; margin-top: 20px;'})
            app(div, mk('img', {src:'images/logo.png', width:'128', height:'128', style:'margin: 0 auto;'}))
            app(div, mk('br'))
            app(div, mk('h1',{ class:'error-number'}, title))
            app(div, mk('h2',{},body))
            app(document.body, div)
            


Number.prototype.pretty = (fix) ->
    if (fix)
        return String(this.toFixed(fix)).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    return String(this.toFixed(0)).replace(/(\d)(?=(\d{3})+$)/g, '$1,');


fetch = (url, xstate, callback, snap) ->
    xmlHttp = null;
    # Set up request object
    if window.XMLHttpRequest
        xmlHttp = new XMLHttpRequest();
    else
        xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    xmlHttp.withCredentials = true
    # GET URL
    if location.href.match(/^file:/)
            url = "https://papersplease.online" + url
            
    xmlHttp.open("GET",  url, true);
    xmlHttp.send(null);

    xmlHttp.onreadystatechange = (state) ->
        if xmlHttp.readyState == 4 and xmlHttp.status == 500
            if snap
                snap(xstate)
        if xmlHttp.readyState == 4 and xmlHttp.status == 200
            if callback
                # Try to parse as JSON and deal with cache objects, fall back to old style parse-and-pass
                try
                    response = JSON.parse(xmlHttp.responseText)
                    if response && response.loginRequired
                        location.href = "/oauth.html"
                        return
                    callback(response, xstate);
                catch e
                    callback(JSON.parse(xmlHttp.responseText), xstate)

post = (url, args, xstate, callback, snap) ->
    xmlHttp = null;
    # Set up request object
    if window.XMLHttpRequest
        xmlHttp = new XMLHttpRequest();
    else
        xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    xmlHttp.withCredentials = true
    # Construct form data
    ar = []
    for k,v of args
        if v and v != ""
            ar.push(k + "=" + escape(v))
    fdata = ar.join("&")


    # POST URL
    xmlHttp.open("POST", url, true);
    xmlHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xmlHttp.send(fdata);

    xmlHttp.onreadystatechange = (state) ->
        if xmlHttp.readyState == 4 and xmlHttp.status == 500
            if snap
                snap(xstate)
        if xmlHttp.readyState == 4 and xmlHttp.status == 200
            if callback
                # Try to parse as JSON and deal with cache objects, fall back to old style parse-and-pass
                try
                    response = JSON.parse(xmlHttp.responseText)
                    callback(response, xstate);
                catch e
                    callback(JSON.parse(xmlHttp.responseText), xstate)


postJSON = (url, json, xstate, callback, snap) ->
    xmlHttp = null;
    # Set up request object
    if window.XMLHttpRequest
        xmlHttp = new XMLHttpRequest();
    else
        xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    xmlHttp.withCredentials = true
    # Construct form data
    fdata = JSON.stringify(json)

    # POST URL
    xmlHttp.open("POST", url, true);
    xmlHttp.setRequestHeader("Content-type", "application/json");
    xmlHttp.send(fdata);

    xmlHttp.onreadystatechange = (state) ->
        if xmlHttp.readyState == 4 and xmlHttp.status == 500
            if snap
                snap(xstate)
        if xmlHttp.readyState == 4 and xmlHttp.status == 200
            if callback
                # Try to parse as JSON and deal with cache objects, fall back to old style parse-and-pass
                try
                    response = JSON.parse(xmlHttp.responseText)
                    if response && response.loginRequired
                        location.href = "/oauth.html"
                        return
                    callback(response, xstate);
                catch e
                    callback(JSON.parse(xmlHttp.responseText), xstate)

mk = (t, s, tt) ->
    r = document.createElement(t)
    if s
        for k, v of s
            if v
                r.setAttribute(k, v)
    if tt
        if typeof tt == "string"
            app(r, txt(tt))
        else
            if isArray tt
                for k in tt
                    if typeof k == "string"
                        app(r, txt(k))
                    else
                        app(r, k)
            else
                app(r, tt)
    return r

app = (a,b) ->
    if isArray b
        for item in b
            if typeof item == "string"
                item = txt(item)
            a.appendChild(item)
    else
        return a.appendChild(b)

set = (a, b, c) ->
    return a.setAttribute(b,c)

txt = (a) ->
    return document.createTextNode(a)

get = (a) ->
    return document.getElementById(a)

swi = (obj) ->
    switchery = new Switchery(obj, {
                color: '#26B99A'
            })

cog = (div, size = 200) ->
    idiv = document.createElement('div')
    idiv.setAttribute("class", "icon")
    idiv.setAttribute("style", "text-align: center; vertical-align: middle; height: 500px;")
    i = document.createElement('i')
    i.setAttribute("class", "fa fa-spin fa-cog")
    i.setAttribute("style", "font-size: " + size + "pt !important; color: #AAB;")
    idiv.appendChild(i)
    idiv.appendChild(document.createElement('br'))
    idiv.appendChild(document.createTextNode('Loading, hang on tight..!'))
    div.innerHTML = ""
    div.appendChild(idiv)

globArgs = {}

isArray = ( value ) ->
    value and
        typeof value is 'object' and
        value instanceof Array and
        typeof value.length is 'number' and
        typeof value.splice is 'function' and
        not ( value.propertyIsEnumerable 'length' )

Array.prototype.remove = (a) ->
    for item, i in this
        if item == a
            this.splice(i, 1)
            break
    return this

showHide = (id, caller) ->
    obj = get(id)
    if obj
            if caller
                        obj.style.left = (caller.getBoundingClientRect().left + document.body.scrollLeft + document.documentElement.scrollLeft) + "px"
                        obj.style.top = (2 + caller.getBoundingClientRect().bottom + document.body.scrollTop + document.documentElement.scrollTop) + "px"
                        obj.style.position = "absolute"
                        obj.style.zIndex = "200"
                        obj.style.background = "#EEE"
            obj.style.display = if (obj.style.display == 'none') then 'block' else 'none'
            
sortTable = (tbody, col, asc) ->
            rows = tbody.childNodes
            rlen = rows.length
            arr = []
            nasc = tbody.getAttribute("sort_" + col)
            if nasc
                asc = parseInt(nasc)
            nasc = asc * -1
            tbody.setAttribute("sort_" + col, nasc)
            for row, i in rows
                elem = {
                        cells: [],
                        dom: row
                }
                for cell, j in row.childNodes
                    elem.cells.push(parseFloat(cell.innerText) || cell.innerText.toLowerCase())
                arr.push(elem)
            
            for k in rows
                        try
                                    tbody.removeChild(k)
                        catch
                                    #
                        
            arr.sort( (a,b) ->
                rv = if (a.cells[col] == b.cells[col]) then 0 else (if (a.cells[col] > b.cells[col]) then asc else (-1 * asc))
                return rv
            )
            
            for row in arr
                tbody.appendChild(row.dom)



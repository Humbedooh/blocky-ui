// Generated by CoffeeScript 1.9.3
var API, HTML, addRule, app, banRules, cog, currentTab, deleteBan, deleteRule, deleteWhite, doQQ, fetch, findRule, get, globArgs, isArray, isHash, loadBread, loadDashboard, loadFindRule, loadQQ, loadRules, loadTabs, manualBan, mk, oldPopup, popup, post, postJSON, renderDashboard, renderRules, renderWhitelist, ruleSpans, ruleTypes, set, showHide, showManuals, showQQ, showRule, showTrack, sortTable, submitBan, submitRule, submitWhite, swi, trackBan, txt, whiteList;

loadRules = function() {
  return fetch("./api/rules.lua", null, renderRules);
};

banRules = [];

ruleTypes = {
  httpd_visits: 'HTTPd visit count',
  httpd_traffic: 'HTTPd traffic count'
};

ruleSpans = {
  1: "1 hour",
  12: "12 hours",
  24: "One day (24 hours)",
  168: "One week (168 hours)",
  720: "One month (720 hours)"
};

renderRules = function(json, edit) {
  var i, item, l, len, li, main, ref, ul;
  main = get('bread');
  main.innerHTML = "";
  if (edit) {
    alert("Rules updated!");
  }
  app(main, mk('input', {
    type: "button",
    onclick: "addRule();",
    value: "Add a new rule"
  }));
  app(main, mk('br'));
  if (isArray(json.rules) && json.rules.length > 0) {
    json.rules.sort(function(a, b) {
      var as, bs;
      as = a.name;
      bs = b.name;
      if (as < bs) {
        return 1;
      }
      if (as === bs) {
        return 0;
      }
      if (as > bs) {
        return -1;
      }
      return 0;
    });
    banRules = json.rules;
    app(main, mk('h3', {}, "Current rules:"));
    ul = mk('ul');
    ref = json.rules;
    for (i = l = 0, len = ref.length; l < len; i = ++l) {
      item = ref[i];
      li = mk('li', {}, [
        item.name + " - ", mk('a', {
          href: "javascript:void(addRule(" + i + "));"
        }, "Edit rule")
      ]);
      app(ul, li);
    }
    return app(main, ul);
  } else {
    return app(main, mk('h3', {}, "Doesn't seem like there are any rules yet..."));
  }
};

addRule = function(rule) {
  var btn, div, fd, fdd, fid, fih, form, k, main, options, v;
  main = get('bread');
  div = get('addrule');
  if (!div) {
    div = mk('div', {
      id: "addrule"
    });
    app(main, div);
  }
  div.innerHTML = "";
  form = mk('form');
  rule = banRules[rule] || {};
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"
  });
  fdd = mk('div', {
    style: "float: left; width: 150px; font-weight: bold;"
  }, "Rule name: ");
  fid = mk('div', {
    style: "float: left; width: 350px;"
  }, mk('input', {
    style: 'width: 200px;',
    type: 'text',
    'id': 'name',
    value: rule.name
  }));
  fih = mk('div', {
    style: "float: left; width: 250px; font-style: italic;"
  }, "A short description of what this rule is for.");
  app(fd, fdd);
  app(fd, fid);
  app(fd, fih);
  app(form, fd);
  options = [];
  options.push(mk('option', {
    value: "0",
    disabled: 'true',
    selected: 'true'
  }, "Select a rule type:"));
  for (k in ruleTypes) {
    v = ruleTypes[k];
    options.push(mk('option', {
      selected: (rule.type === k ? 'selected' : null),
      value: k
    }, v));
  }
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"
  });
  fdd = mk('div', {
    style: "float: left; width: 150px; font-weight: bold;"
  }, "Type of rule:");
  fid = mk('div', {
    style: "float: left; width: 350px;"
  }, mk('select', {
    style: 'width: 200px;',
    'id': 'type'
  }, options));
  fih = mk('div', {
    style: "float: left; width: 250px; font-style: italic;"
  }, "The type of rule (traffic or doc count)");
  app(fd, fdd);
  app(fd, fid);
  app(fd, fih);
  app(form, fd);
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"
  });
  fdd = mk('div', {
    style: "float: left; width: 150px; font-weight: bold;"
  }, "Rule limit: ");
  fid = mk('div', {
    style: "float: left; width: 350px;"
  }, mk('input', {
    style: 'width: 200px;',
    type: 'text',
    'id': 'limit',
    value: rule.limit
  }));
  fih = mk('div', {
    style: "float: left; width: 250px; font-style: italic;"
  }, "The limit (doc count or traffic in bytes) that triggers a ban.");
  app(fd, fdd);
  app(fd, fid);
  app(fd, fih);
  app(form, fd);
  options = [];
  options.push(mk('option', {
    value: "0",
    disabled: 'true',
    selected: 'true'
  }, "Select a timespan for the limit:"));
  for (k in ruleSpans) {
    v = ruleSpans[k];
    options.push(mk('option', {
      selected: (rule.span === parseInt(k) ? 'selected' : null),
      value: k
    }, v));
  }
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"
  });
  fdd = mk('div', {
    style: "float: left; width: 150px; font-weight: bold;"
  }, "Timespan to apply limit to:");
  fid = mk('div', {
    style: "float: left; width: 350px;"
  }, mk('select', {
    style: 'width: 200px;',
    'id': 'span'
  }, options));
  fih = mk('div', {
    style: "float: left; width: 250px; font-style: italic;"
  }, "How far back to search for the limit being broken, typically one day.");
  app(fd, fdd);
  app(fd, fid);
  app(fd, fih);
  app(form, fd);
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"
  });
  fdd = mk('div', {
    style: "float: left; width: 150px; font-weight: bold;"
  }, "Query data");
  fid = mk('div', {
    style: "float: left; width: 350px;"
  }, mk('textarea', {
    style: 'width: 320px; height: 100px;',
    placeholder: "One query per line, in the format: key=\"string\" or key=num",
    'id': 'rules'
  }, (rule.query || []).join("\n")));
  fih = mk('div', {
    style: "float: left; width: 250px; font-style: italic;"
  }, "The queries to apply to this search.");
  app(fd, fdd);
  app(fd, fid);
  app(fd, fih);
  app(form, fd);
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto;"
  });
  btn = mk('input', {
    type: 'button',
    "class": 'btn btn-success',
    value: "Save rule",
    onclick: 'submitRule("' + (rule.id || "") + '");'
  });
  app(fd, btn);
  if (rule.id) {
    btn = mk('input', {
      type: 'button',
      style: "margin-left: 50px;",
      "class": 'btn btn-danger',
      value: "Delete rule",
      onclick: 'deleteRule("' + (rule.id || "") + '");'
    });
    app(fd, btn);
  }
  app(form, fd);
  return app(div, form);
};

submitRule = function(id) {
  var l, len, limit, line, lines, name, query, span, type;
  name = get('name').value;
  if (name.length === 0) {
    alert("Please enter a title for this rule!");
    return;
  }
  type = get('type').value;
  if (!type || parseInt(type) <= 0) {
    alert("Please select a rule type!");
    return;
  }
  limit = parseInt(get('limit').value);
  if (limit <= 0 || get('limit').value.length === 0) {
    alert("Please enter a sane ban limit!");
    return;
  }
  span = get('span').value;
  if (!span || parseInt(span) <= 0) {
    alert("Please select a timespan!");
    return;
  }
  span = parseInt(span);
  query = [];
  lines = get('rules').value.split(/\r?\n/);
  for (l = 0, len = lines.length; l < len; l++) {
    line = lines[l];
    if (line.match(/^\S+=".+"$/) || line.match(/\S+=[0-9.]+$/)) {
      query.push(line);
    } else {
      alert("Query lines need to be of format 'key=\"string\"' or 'key=num'!");
      return;
    }
  }
  if (query.length < 2) {
    alert("The query set needs to have at least two queries!");
    return;
  }
  if (id && id.length > 0) {
    return postJSON("./api/rules.lua", {
      addrule: {
        id: id,
        name: name,
        type: type,
        limit: limit,
        span: span,
        query: query
      }
    }, true, renderRules);
  } else {
    return postJSON("./api/rules.lua", {
      addrule: {
        name: name,
        type: type,
        limit: limit,
        span: span,
        query: query
      }
    }, true, renderRules);
  }
};

deleteRule = function(id) {
  return fetch("./api/rules.lua?delete=" + id, true, renderRules);
};

manualBan = function() {
  var btn, div, fd, fdd, fid, fih, form, main, mdiv;
  main = get('bread');
  div = get('addrule');
  if (!div) {
    div = mk('div', {
      id: "addrule"
    });
    app(main, div);
  }
  div.innerHTML = "";
  form = mk('form');
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"
  });
  fdd = mk('div', {
    style: "float: left; width: 150px; font-weight: bold;"
  }, "IP to ban: ");
  fid = mk('div', {
    style: "float: left; width: 350px;"
  }, mk('input', {
    style: 'width: 200px;',
    type: 'text',
    'id': 'ip'
  }));
  fih = mk('div', {
    style: "float: left; width: 450px; font-style: italic;"
  }, "The IPv4/IPv6 address (or CIDR block) to ban");
  app(fd, fdd);
  app(fd, fid);
  app(fd, fih);
  app(form, fd);
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"
  });
  fdd = mk('div', {
    style: "float: left; width: 150px; font-weight: bold;"
  }, "Reason for ban: ");
  fid = mk('div', {
    style: "float: left; width: 350px;"
  }, mk('input', {
    style: 'width: 200px;',
    type: 'text',
    'id': 'reason'
  }));
  fih = mk('div', {
    style: "float: left; width: 450px; font-style: italic;"
  }, "A short description of why this ban is in place");
  app(fd, fdd);
  app(fd, fid);
  app(fd, fih);
  app(form, fd);
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"
  });
  fdd = mk('div', {
    style: "float: left; width: 150px; font-weight: bold;"
  }, "Target machine(s) to ban on: ");
  fid = mk('div', {
    style: "float: left; width: 350px;"
  }, mk('input', {
    style: 'width: 200px;',
    type: 'text',
    'id': 'target',
    value: '*'
  }));
  fih = mk('div', {
    style: "float: left; width: 450px; font-style: italic;"
  }, "The target machine hostname to ban on. Default is *, which means all machines. Can also be a specific machine, like eos.apache.org.");
  app(fd, fdd);
  app(fd, fid);
  app(fd, fih);
  app(form, fd);
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto;"
  });
  btn = mk('input', {
    type: 'button',
    "class": 'btn btn-success',
    value: "Ban IP",
    onclick: 'submitBan();'
  });
  app(fd, btn);
  app(form, fd);
  app(div, form);
  mdiv = new HTML('div', {
    id: 'mbans'
  });
  app(div, mdiv);
  return fetch("./api/dashboard.lua?manual=true", null, showManuals);
};

showManuals = function(json, state) {
  var header, ip, ipname, l, len, li, main, pt, ref, renewDate, tracker, ul;
  if (isArray(json.manuals) && json.manuals.length > 0) {
    main = get('mbans');
    header = new HTML('h3', {}, "Manual bans applied:");
    app(main, header);
    ul = mk('ul');
    ref = json.manuals;
    for (l = 0, len = ref.length; l < len; l++) {
      ip = ref[l];
      renewDate = new Date(ip.epoch * 1000.0).toUTCString();
      ipname = ip.ip.replace("_", "/");
      if (ip.dns && ip.dns !== ip.ip) {
        ipname += " (" + ip.dns + ")";
      }
      pt = "";
      tracker = "";
      if (ip.rid) {
        pt = " - ";
        tracker = mk('a', {
          href: "javascript:void(trackBan('" + ip.ip + "', '" + ip.rid + "'));"
        }, "Track");
      }
      li = mk('li', {
        style: "font-size: 0.8rem;"
      }, [
        mk('kbd', {}, ipname), ": " + ip.reason + " - Ban last renewed renewed " + renewDate + " - ", mk('a', {
          href: "javascript:void(deleteBan('" + ip.ip + "'));"
        }, "Remove ban"), pt, tracker
      ]);
      app(ul, li);
    }
    return app(main, ul);
  }
};

submitBan = function() {
  var ip, reason, target;
  ip = get('ip').value;
  if (ip.length <= 6) {
    alert("Please enter a valid IP address!");
    return;
  }
  reason = get('reason').value;
  if (reason.length === 0) {
    alert("Please enter a reason for the ban!");
    return;
  }
  target = get('target').value;
  if (target.length === 0) {
    alert("Please enter a target machine name or use * for all machines.");
    return;
  }
  return postJSON("./api/dashboard.lua", {
    ban: {
      ip: ip,
      reason: reason,
      target: target
    }
  }, null, function(json, state) {
    if (json.correction) {
      alert("Ban applied, CIDR corrected to: " + json.correction + "!");
    } else {
      alert("Ban applied!");
    }
    return manualBan();
  });
};

deleteWhite = function(ip) {
  alert("IP removed from whitelist");
  return fetch("./api/dashboard.lua?deletewhite=" + ip, null, renderWhitelist);
};

whiteList = function() {
  return fetch("./api/dashboard.lua", null, renderWhitelist);
};

renderWhitelist = function(json) {
  var btn, div, fd, fdd, fid, fih, form, ip, l, len, li, main, ref, ul;
  main = get('bread');
  div = get('addrule');
  if (!div) {
    div = mk('div', {
      id: "addrule"
    });
    app(main, div);
  }
  div.innerHTML = "";
  if (isArray(json.whitelist) && json.whitelist.length > 0) {
    app(div, mk('h3', {}, "Currently whitelisted IPs:"));
    ul = mk('ul');
    ref = json.whitelist;
    for (l = 0, len = ref.length; l < len; l++) {
      ip = ref[l];
      li = mk('li', {
        style: "font-size: 0.8rem;"
      }, [
        mk('kbd', {}, ip.ip), ": " + ip.reason + " - ", mk('a', {
          href: "javascript:void(deleteWhite('" + ip.ip + "'));"
        }, "Remove whitelisting")
      ]);
      app(ul, li);
    }
    app(div, ul);
  } else {
    app(div, mk('h4', {}, "There are no whitelisted IPs at the moment."));
  }
  form = mk('form');
  app(form, mk('h3', {}, "Whitelist a new IP:"));
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"
  });
  fdd = mk('div', {
    style: "float: left; width: 150px; font-weight: bold;"
  }, "IP to whitelist: ");
  fid = mk('div', {
    style: "float: left; width: 350px;"
  }, mk('input', {
    style: 'width: 200px;',
    type: 'text',
    'id': 'ip'
  }));
  fih = mk('div', {
    style: "float: left; width: 250px; font-style: italic;"
  }, "The IPv4/IPv6 address to whitelist");
  app(fd, fdd);
  app(fd, fid);
  app(fd, fih);
  app(form, fd);
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto; border-bottom: 1px solid #CCC; padding-bottom: 6px; margin-bottom: 6px;"
  });
  fdd = mk('div', {
    style: "float: left; width: 150px; font-weight: bold;"
  }, "Reason for whitelisting: ");
  fid = mk('div', {
    style: "float: left; width: 350px;"
  }, mk('input', {
    style: 'width: 200px;',
    type: 'text',
    'id': 'reason'
  }));
  fih = mk('div', {
    style: "float: left; width: 250px; font-style: italic;"
  }, "A short description of why this whitelisting is in place");
  app(fd, fdd);
  app(fd, fid);
  app(fd, fih);
  app(form, fd);
  fd = mk('div', {
    style: "width: 100%; relative; overflow: auto;"
  });
  btn = mk('input', {
    type: 'button',
    "class": 'btn btn-success',
    value: "Whitelist IP",
    onclick: 'submitWhite();'
  });
  app(fd, btn);
  app(form, fd);
  return app(div, form);
};

submitWhite = function() {
  var ip, reason;
  ip = get('ip').value;
  if (ip.length <= 6) {
    alert("Please enter a valid IP address!");
    return;
  }
  reason = get('reason').value;
  if (reason.length === 0) {
    alert("Please enter a reason for the whitelisting!");
    return;
  }
  return postJSON("./api/dashboard.lua", {
    whitelist: {
      ip: ip,
      reason: reason
    }
  }, null, function() {
    alert("Whitelisting added!");
    return whiteList();
  });
};

loadDashboard = function(howMany) {
  return fetch("./api/dashboard.lua" + (howMany ? '?hits=' + howMany : ''), null, renderDashboard);
};

findRule = function() {
  var ip;
  ip = get('findrule').value;
  if (ip) {
    fetch("./api/dashboard.lua?hits=9999", {
      ip: ip
    }, showRule);
  }
  return false;
};

showRule = function(json, state) {
  var found, ip, ipname, l, len, li, main, pt, ref, renewDate, tracker, ul;
  found = false;
  if (isArray(json.banlist) && json.banlist.length > 0) {
    main = get('bread');
    main.innerHTML = "";
    ul = mk('ul', {
      style: 'text-align: left;'
    });
    ref = json.banlist;
    for (l = 0, len = ref.length; l < len; l++) {
      ip = ref[l];
      if (ip.ip === state.ip) {
        found = true;
        renewDate = new Date(ip.epoch * 1000.0).toUTCString();
        ipname = ip.ip;
        if (ip.dns && ip.dns !== ip.ip) {
          ipname += " (" + ip.dns + ")";
        }
        pt = "";
        tracker = "";
        if (ip.rid) {
          pt = " - ";
          tracker = mk('a', {
            href: "javascript:void(trackBan('" + ip.ip + "', '" + ip.rid + "'));"
          }, "Track");
        }
        li = mk('li', {
          style: "font-size: 0.8rem;"
        }, [
          mk('kbd', {}, ipname), ": " + ip.reason + " - Ban last renewed renewed " + renewDate + " - ", mk('a', {
            href: "javascript:void(deleteBan('" + ip.ip + "'));"
          }, "Remove ban"), pt, tracker
        ]);
        app(ul, li);
      }
    }
    app(main, ul);
  }
  if (!found) {
    return alert("No bans found for " + state.ip + "!");
  }
};

renderDashboard = function(json, edit) {
  var h2, howMany, ip, ipname, l, len, li, main, pt, ref, renewDate, tracker, ul;
  main = get('bread');
  main.innerHTML = "";
  if (edit) {
    alert("Ban list updated!");
  }
  h2 = mk('h2', {}, "Currently " + json.banned.pretty() + " IP" + (json.banned !== 1 ? 's' : '') + " banned, " + json.whitelisted + " IP" + (json.whitelisted !== 1 ? 's' : '') + " whitelisted.");
  app(main, h2);
  if (isArray(json.banlist) && json.banlist.length > 0) {
    ul = mk('ul');
    ref = json.banlist;
    for (l = 0, len = ref.length; l < len; l++) {
      ip = ref[l];
      renewDate = new Date(ip.epoch * 1000.0).toUTCString();
      ipname = ip.ip.replace("_", "/");
      if (ip.dns && ip.dns !== ip.ip) {
        ipname += " (" + ip.dns + ")";
      }
      pt = "";
      tracker = "";
      if (ip.rid) {
        pt = " - ";
        tracker = mk('a', {
          href: "javascript:void(trackBan('" + ip.ip + "', '" + ip.rid + "'));"
        }, "Track");
      }
      li = mk('li', {
        style: "font-size: 0.8rem;"
      }, [
        mk('kbd', {}, ipname), ": " + ip.reason + " - Ban last renewed renewed " + renewDate + " - ", mk('a', {
          href: "javascript:void(deleteBan('" + ip.ip + "'));"
        }, "Remove ban"), pt, tracker
      ]);
      app(ul, li);
    }
    app(main, ul);
    if (json.banlist.length < json.banned) {
      howMany = (parseInt(json.banlist.length / 25) + 1) * 25;
      return app(main, mk('a', {
        href: "javascript:void(loadDashboard(" + howMany + "));"
      }, "Show more..."));
    }
  }
};

loadQQ = function() {
  var main, qqf, qqt;
  main = get('bread');
  main.innerHTML = "";
  qqf = mk('form', {
    onsubmit: "return doQQ();"
  });
  qqt = mk('input', {
    type: "text",
    style: "width: 500px;",
    id: "qq",
    placeholder: "Quick query..."
  });
  app(qqf, qqt);
  return app(main, qqf);
};

loadFindRule = function() {
  var main, qqf, qqt;
  main = get('bread');
  main.innerHTML = "";
  qqf = mk('form', {
    onsubmit: "return findRule();"
  });
  qqt = mk('input', {
    type: "text",
    style: "width: 500px;",
    id: "findrule",
    placeholder: "IP address or CIDR block to find..."
  });
  app(qqf, qqt);
  return app(main, qqf);
};

doQQ = function() {
  var qq;
  qq = get('qq').value;
  fetch("./api/dashboard.lua?qq=" + qq, null, showQQ);
  return false;
};

deleteBan = function(ip) {
  if (currentTab === 'manual') {
    alert("Ban removed!");
    return manualBan();
  } else {
    return fetch("./api/dashboard.lua?delete=" + ip, true, renderDashboard);
  }
};

trackBan = function(ip, rid) {
  return fetch("./api/dashboard.lua?track=" + ip + "&rule=" + rid, null, showTrack);
};

showTrack = function(json) {
  var div, i, item, k, l, len, main, ref, results, source, tbl, td, tr, v;
  main = get('bread');
  div = get('tracker');
  if (!div) {
    div = mk('div', {
      id: 'tracker',
      style: "border: 1px dotted #333; padding: 10px; font-size: 0.75rem;"
    });
    app(main, div);
  }
  div.innerHTML = "<h3>Tracking data for " + json.ip + " using rule '" + json.rule.name + "':</h3>";
  tbl = mk('table', {
    border: "1"
  });
  app(div, tbl);
  ref = json.res.hits.hits;
  results = [];
  for (i = l = 0, len = ref.length; l < len; i = ++l) {
    item = ref[i];
    if (i > 100) {
      break;
    }
    source = item._source;
    if (i === 0) {
      tr = mk('tr');
      for (k in source) {
        v = source[k];
        if (k !== 'time' && k !== 'timestamp' && !k.match(/geo/)) {
          td = mk('td', {
            style: "font-weight: bold;"
          }, k);
          app(tr, td);
        }
      }
      app(tbl, tr);
    }
    tr = mk('tr');
    for (k in source) {
      v = source[k];
      if (k !== 'time' && k !== 'timestamp' && !k.match(/geo/)) {
        td = mk('td', {}, v + "");
        app(tr, td);
      }
    }
    results.push(app(tbl, tr));
  }
  return results;
};

showQQ = function(json) {
  var div, i, item, k, l, len, main, ref, source, tbl, td, tr, v;
  main = get('bread');
  div = get('tracker');
  if (!div) {
    div = mk('div', {
      id: 'tracker',
      style: "border: 1px dotted #333; padding: 10px; font-size: 0.75rem;"
    });
    app(main, div);
  }
  if (!isArray(json.res.hits.hits)) {
    json.res.hits.hits = [];
  }
  div.innerHTML = "<h3>Quick query results (" + json.res.hits.hits.length + "):</h3>";
  tbl = mk('table', {
    border: "1"
  });
  app(div, tbl);
  ref = json.res.hits.hits;
  for (i = l = 0, len = ref.length; l < len; i = ++l) {
    item = ref[i];
    if (i > 100) {
      break;
    }
    source = item._source;
    if (i === 0) {
      tr = mk('tr');
      for (k in source) {
        v = source[k];
        if (k !== 'time' && k !== 'timestamp' && !k.match(/geo/)) {
          td = mk('td', {
            style: "font-weight: bold;"
          }, k);
          app(tr, td);
        }
      }
      app(tbl, tr);
    }
    tr = mk('tr');
    for (k in source) {
      v = source[k];
      if (k !== 'time' && k !== 'timestamp' && !k.match(/geo/)) {
        td = mk('td', {}, v + "");
        app(tr, td);
      }
    }
    app(tbl, tr);
  }
  if (json.res.hits.hits.length === 0) {
    return app(div, txt("No results were found"));
  }
};

HTML = (function() {
  function HTML(type, params, children) {

    /* create the raw element, or clone if passed an existing element */
    var child, key, l, len, subkey, subval, val;
    if (typeof type === 'object') {
      this.element = type.cloneNode();
    } else {
      this.element = document.createElement(type);
    }

    /* If params have been passed, set them */
    if (isHash(params)) {
      for (key in params) {
        val = params[key];

        /* Standard string value? */
        if (typeof val === "string" || typeof val === 'number') {
          this.element.setAttribute(key, val);
        } else if (isArray(val)) {

          /* Are we passing a list of data to set? concatenate then */
          this.element.setAttribute(key, val.join(" "));
        } else if (isHash(val)) {

          /* Are we trying to set multiple sub elements, like a style? */
          for (subkey in val) {
            subval = val[subkey];
            if (!this.element[key]) {
              throw "No such attribute, " + key + "!";
            }
            this.element[key][subkey] = subval;
          }
        }
      }
    }

    /* If any children have been passed, add them to the element */
    if (children) {

      /* If string, convert to textNode using txt() */
      if (typeof children === "string") {
        this.element.inject(txt(children));
      } else {

        /* If children is an array of elems, iterate and add */
        if (isArray(children)) {
          for (l = 0, len = children.length; l < len; l++) {
            child = children[l];

            /* String? Convert via txt() then */
            if (typeof child === "string") {
              this.element.inject(txt(child));
            } else {

              /* Plain element, add normally */
              this.element.inject(child);
            }
          }
        } else {

          /* Just a single element, add it */
          this.element.inject(children);
        }
      }
    }
    return this.element;
  }

  return HTML;

})();


/**
 * prototype injector for HTML elements:
 * Example: mydiv.inject(otherdiv)
 */

HTMLElement.prototype.inject = function(child) {
  var item, l, len;
  if (isArray(child)) {
    for (l = 0, len = child.length; l < len; l++) {
      item = child[l];
      if (typeof item === 'string') {
        item = txt(item);
      }
      this.appendChild(item);
    }
  } else {
    if (typeof child === 'string') {
      child = txt(child);
    }
    this.appendChild(child);
  }
  return child;
};

API = 1;

oldPopup = false;

popup = function(title, body) {
  var d, div, p;
  if (oldPopup) {
    p = get('popupdiv');
    if (!p) {
      d = mk('div');
      set(d, 'id', 'popupdiv');
      set(d, 'title', title);
      p = mk('p');
      app(d, mk('img', {
        style: "margin: 0 auto;",
        src: "images/logo.png",
        width: "128",
        height: "128"
      }));
      app(p, txt(body));
      app(d, p);
      document.body.appendChild(d);
    }
    return $('#popupdiv').dialog();
  } else {
    document.body.innerHTML = "";
    div = mk('div', {
      style: 'text-align: center; margin-top: 20px;'
    });
    app(div, mk('img', {
      src: 'images/logo.png',
      width: '128',
      height: '128',
      style: 'margin: 0 auto;'
    }));
    app(div, mk('br'));
    app(div, mk('h1', {
      "class": 'error-number'
    }, title));
    app(div, mk('h2', {}, body));
    return app(document.body, div);
  }
};

Number.prototype.pretty = function(fix) {
  if (fix) {
    return String(this.toFixed(fix)).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
  }
  return String(this.toFixed(0)).replace(/(\d)(?=(\d{3})+$)/g, '$1,');
};

fetch = function(url, xstate, callback, snap) {
  var xmlHttp;
  xmlHttp = null;
  if (window.XMLHttpRequest) {
    xmlHttp = new XMLHttpRequest();
  } else {
    xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
  }
  xmlHttp.withCredentials = true;
  if (location.href.match(/^file:/)) {
    url = "https://papersplease.online" + url;
  }
  xmlHttp.open("GET", url, true);
  xmlHttp.send(null);
  return xmlHttp.onreadystatechange = function(state) {
    var e, response;
    if (xmlHttp.readyState === 4 && xmlHttp.status === 500) {
      if (snap) {
        snap(xstate);
      }
    }
    if (xmlHttp.readyState === 4 && xmlHttp.status === 200) {
      if (callback) {
        try {
          response = JSON.parse(xmlHttp.responseText);
          if (response && response.loginRequired) {
            location.href = "/oauth.html";
            return;
          }
          return callback(response, xstate);
        } catch (_error) {
          e = _error;
          return callback(JSON.parse(xmlHttp.responseText), xstate);
        }
      }
    }
  };
};

post = function(url, args, xstate, callback, snap) {
  var ar, fdata, k, v, xmlHttp;
  xmlHttp = null;
  if (window.XMLHttpRequest) {
    xmlHttp = new XMLHttpRequest();
  } else {
    xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
  }
  xmlHttp.withCredentials = true;
  ar = [];
  for (k in args) {
    v = args[k];
    if (v && v !== "") {
      ar.push(k + "=" + escape(v));
    }
  }
  fdata = ar.join("&");
  xmlHttp.open("POST", url, true);
  xmlHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  xmlHttp.send(fdata);
  return xmlHttp.onreadystatechange = function(state) {
    var e, response;
    if (xmlHttp.readyState === 4 && xmlHttp.status === 500) {
      if (snap) {
        snap(xstate);
      }
    }
    if (xmlHttp.readyState === 4 && xmlHttp.status === 200) {
      if (callback) {
        try {
          response = JSON.parse(xmlHttp.responseText);
          return callback(response, xstate);
        } catch (_error) {
          e = _error;
          return callback(JSON.parse(xmlHttp.responseText), xstate);
        }
      }
    }
  };
};

postJSON = function(url, json, xstate, callback, snap) {
  var fdata, xmlHttp;
  xmlHttp = null;
  if (window.XMLHttpRequest) {
    xmlHttp = new XMLHttpRequest();
  } else {
    xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
  }
  xmlHttp.withCredentials = true;
  fdata = JSON.stringify(json);
  xmlHttp.open("POST", url, true);
  xmlHttp.setRequestHeader("Content-type", "application/json");
  xmlHttp.send(fdata);
  return xmlHttp.onreadystatechange = function(state) {
    var e, response;
    if (xmlHttp.readyState === 4 && xmlHttp.status === 500) {
      if (snap) {
        snap(xstate);
      }
    }
    if (xmlHttp.readyState === 4 && xmlHttp.status === 200) {
      if (callback) {
        try {
          response = JSON.parse(xmlHttp.responseText);
          if (response && response.loginRequired) {
            location.href = "/oauth.html";
            return;
          }
          return callback(response, xstate);
        } catch (_error) {
          e = _error;
          return callback(JSON.parse(xmlHttp.responseText), xstate);
        }
      }
    }
  };
};

mk = function(t, s, tt) {
  var k, l, len, r, v;
  r = document.createElement(t);
  if (s) {
    for (k in s) {
      v = s[k];
      if (v) {
        r.setAttribute(k, v);
      }
    }
  }
  if (tt) {
    if (typeof tt === "string") {
      app(r, txt(tt));
    } else {
      if (isArray(tt)) {
        for (l = 0, len = tt.length; l < len; l++) {
          k = tt[l];
          if (typeof k === "string") {
            app(r, txt(k));
          } else {
            app(r, k);
          }
        }
      } else {
        app(r, tt);
      }
    }
  }
  return r;
};

app = function(a, b) {
  var item, l, len, results;
  if (isArray(b)) {
    results = [];
    for (l = 0, len = b.length; l < len; l++) {
      item = b[l];
      if (typeof item === "string") {
        item = txt(item);
      }
      results.push(a.appendChild(item));
    }
    return results;
  } else {
    return a.appendChild(b);
  }
};

set = function(a, b, c) {
  return a.setAttribute(b, c);
};

txt = function(a) {
  return document.createTextNode(a);
};

get = function(a) {
  return document.getElementById(a);
};

swi = function(obj) {
  var switchery;
  return switchery = new Switchery(obj, {
    color: '#26B99A'
  });
};

cog = function(div, size) {
  var i, idiv;
  if (size == null) {
    size = 200;
  }
  idiv = document.createElement('div');
  idiv.setAttribute("class", "icon");
  idiv.setAttribute("style", "text-align: center; vertical-align: middle; height: 500px;");
  i = document.createElement('i');
  i.setAttribute("class", "fa fa-spin fa-cog");
  i.setAttribute("style", "font-size: " + size + "pt !important; color: #AAB;");
  idiv.appendChild(i);
  idiv.appendChild(document.createElement('br'));
  idiv.appendChild(document.createTextNode('Loading, hang on tight..!'));
  div.innerHTML = "";
  return div.appendChild(idiv);
};

globArgs = {};

isArray = function(value) {
  return value && typeof value === 'object' && value instanceof Array && typeof value.length === 'number' && typeof value.splice === 'function' && !(value.propertyIsEnumerable('length'));
};

Array.prototype.remove = function(a) {
  var i, item, l, len;
  for (i = l = 0, len = this.length; l < len; i = ++l) {
    item = this[i];
    if (item === a) {
      this.splice(i, 1);
      break;
    }
  }
  return this;
};

showHide = function(id, caller) {
  var obj;
  obj = get(id);
  if (obj) {
    if (caller) {
      obj.style.left = (caller.getBoundingClientRect().left + document.body.scrollLeft + document.documentElement.scrollLeft) + "px";
      obj.style.top = (2 + caller.getBoundingClientRect().bottom + document.body.scrollTop + document.documentElement.scrollTop) + "px";
      obj.style.position = "absolute";
      obj.style.zIndex = "200";
      obj.style.background = "#EEE";
    }
    return obj.style.display = obj.style.display === 'none' ? 'block' : 'none';
  }
};

sortTable = function(tbody, col, asc) {
  var arr, cell, elem, i, j, k, l, len, len1, len2, len3, m, n, nasc, o, ref, results, rlen, row, rows;
  rows = tbody.childNodes;
  rlen = rows.length;
  arr = [];
  nasc = tbody.getAttribute("sort_" + col);
  if (nasc) {
    asc = parseInt(nasc);
  }
  nasc = asc * -1;
  tbody.setAttribute("sort_" + col, nasc);
  for (i = l = 0, len = rows.length; l < len; i = ++l) {
    row = rows[i];
    elem = {
      cells: [],
      dom: row
    };
    ref = row.childNodes;
    for (j = m = 0, len1 = ref.length; m < len1; j = ++m) {
      cell = ref[j];
      elem.cells.push(parseFloat(cell.innerText) || cell.innerText.toLowerCase());
    }
    arr.push(elem);
  }
  for (n = 0, len2 = rows.length; n < len2; n++) {
    k = rows[n];
    try {
      tbody.removeChild(k);
    } catch (_error) {

    }
  }
  arr.sort(function(a, b) {
    var rv;
    rv = a.cells[col] === b.cells[col] ? 0 : (a.cells[col] > b.cells[col] ? asc : -1 * asc);
    return rv;
  });
  results = [];
  for (o = 0, len3 = arr.length; o < len3; o++) {
    row = arr[o];
    results.push(tbody.appendChild(row.dom));
  }
  return results;
};

currentTab = null;

loadTabs = function(stab) {
  var bread, currentTaB, k, main, tab, tabs, tdiv, title, v;
  tabs = {
    recent: 'Recent activity',
    search: 'Search the archive',
    findban: 'Find a ban',
    rules: 'Ban rules',
    manual: 'Manual ban',
    whitelist: 'Whitelist'
  };
  main = new HTML('div', {
    style: {
      position: 'relative',
      display: 'inline-block',
      background: "#eee",
      width: '90%',
      maxWidth: '1600px',
      minWidth: '1200px',
      height: '700px',
      borderRadius: '3px'
    }
  });
  document.getElementById('wrapper').innerHTML = "";
  document.getElementById('wrapper').appendChild(main);
  tdiv = new HTML('div', {
    "class": 'tabs'
  });
  main.inject(tdiv);
  for (k in tabs) {
    v = tabs[k];
    if ((stab && stab === k) || (!stab && k === 'recent')) {
      currentTaB = K;
      tab = new HTML('div', {
        "class": 'tablink tablink_selected'
      }, v);
      title = new HTML('h2', {}, v + ":");
      main.inject(title);
    } else {
      tab = new HTML('div', {
        "class": 'tablink',
        onclick: "loadTabs('" + k + "');"
      }, v);
    }
    tdiv.inject(tab);
  }
  bread = new HTML('div', {
    "class": 'bread',
    id: 'bread'
  });
  main.inject(bread);
  return loadBread(stab || 'recent');
};

loadBread = function(what) {
  if (what === 'recent') {
    loadDashboard();
  }
  if (what === 'rules') {
    loadRules();
  }
  if (what === 'whitelist') {
    whiteList();
  }
  if (what === 'manual') {
    manualBan();
  }
  if (what === 'search') {
    loadQQ();
  }
  if (what === 'findban') {
    return loadFindRule();
  }
};

Number.prototype.pretty = function(fix) {
  if (fix) {
    return String(this.toFixed(fix)).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
  }
  return String(this.toFixed(0)).replace(/(\d)(?=(\d{3})+$)/g, '$1,');
};

isArray = function(value) {
  return value && typeof value === 'object' && value instanceof Array && typeof value.length === 'number' && typeof value.splice === 'function' && !(value.propertyIsEnumerable('length'));
};


/* isHash: function to detect if an object is a hash */

isHash = function(value) {
  return value && typeof value === 'object' && !isArray(value);
};

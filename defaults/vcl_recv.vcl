sub vcl_recv {
    # Only cache GET and HEAD requests (pass through POST requests).
    if (req.method != "GET" && req.method != "HEAD") {
        set req.http.X-VC-Cacheable = "NO:Request method:" + req.method;
        return(pass);
    }

    # Implementing websocket support.
    if (req.http.Upgrade ~ "(?i)websocket") {
        return (pipe);
    }

    # Do not cache ajax requests.
    if (req.http.X-Requested-With == "XMLHttpRequest") {
        set req.http.X-VC-Cacheable = "NO:Requested with: XMLHttpRequest";
        return(pass);
    }

    # Strip hash, server does not need it.
    if (req.url ~ "\#") {
        set req.url = regsub(req.url, "\#.*$", "");
    }

    # Strip a trailing ? if it exists
    if (req.url ~ "\?$") {
        set req.url = regsub(req.url, "\?$", "");
    }

    
    set req.http.vckey = ";" + req.http.Cookie;
    set req.http.vckey = regsuball(req.http.vckey, "; +", ";");
    set req.http.vckey = regsuball(req.http.vckey, ";(VCKEY-[a-zA-Z0-9-_]+)=", "; \1=");
    set req.http.vckey = regsuball(req.http.vckey, ";[^ ][^;]*", "");
    set req.http.vckey = regsuball(req.http.vckey, "^[; ]+|[; ]+$", "");

    
    set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(__[a-z]+|wooTracker|VCKEY-[a-zA-Z0-9-_]+)=[^;]*", "");
    set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");
    if (req.http.Cookie ~ "^\s*$") {
        unset req.http.Cookie;
    }
    

    
    # Strip query parameters from all urls (so they cache as a single object).
    
    
    if (req.url ~ "(\?|&)(utm_[a-z]+|gclid|cx|ie|cof|siteurl|fbclid)=") {
        set req.url = regsuball(req.url, "&(utm_[a-z]+|gclid|cx|ie|cof|siteurl|fbclid)=([A-z0-9_\-\.%25]+)", "");
        set req.url = regsuball(req.url, "\?(utm_[a-z]+|gclid|cx|ie|cof|siteurl|fbclid)=([A-z0-9_\-\.%25]+)", "?");
        set req.url = regsub(req.url, "\?&", "?");
        set req.url = regsub(req.url, "\?$", "");
    }
    
    

    ### Pagespeed
    # Based on the suggestions https://www.modpagespeed.com/doc/downstream-caching
    
    ### End of Pagespeed
}
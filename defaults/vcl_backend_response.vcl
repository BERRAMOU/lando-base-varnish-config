sub vcl_backend_response {
    set beresp.http.X-VC-Req-Host = bereq.http.host;
    set beresp.http.X-VC-Req-URL = bereq.url;
    set beresp.http.X-VC-Req-URL-Base = regsub(bereq.url, "\?.*$", "");

    if (beresp.grace < 2m) {
        set beresp.grace = 2m;
    }

    # Overwrite ttl with X-VC-TTL.
    if (beresp.http.X-VC-TTL) {
        set beresp.ttl = std.duration(beresp.http.X-VC-TTL + "s", 0s);
    }

    if (beresp.http.Set-Cookie) {
        set beresp.ttl = 0s;
    }

    if (bereq.http.X-VC-Cacheable ~ "^NO") {
        set beresp.http.X-VC-Cacheable = bereq.http.X-VC-Cacheable;
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;

    } else if (beresp.ttl <= 0s) {
        if (!beresp.http.X-VC-Cacheable) {
            set beresp.http.X-VC-Cacheable = "NO:Not cacheable, ttl: "+ beresp.ttl;
        }
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;

    } else if (beresp.http.Cache-Control ~ "private") {
        set beresp.http.X-VC-Cacheable = "NO:Cache-Control=private";
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;

    } else if (beresp.http.Cache-Control ~ "no-cache") {
        set beresp.http.X-VC-Cacheable = "NO:Cache-Control=no-cache";
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;

    } else if (beresp.http.X-VC-Enabled ~ "true") {
        if (!beresp.http.X-VC-Cacheable) {
            set beresp.http.X-VC-Cacheable = "YES:Is cacheable, ttl: " + beresp.ttl;
        }

    } else if (beresp.http.X-VC-Enabled ~ "false") {
        if (!beresp.http.X-VC-Cacheable) {
            set beresp.http.X-VC-Cacheable = "NO:Disabled";
        }
        set beresp.ttl = 0s;
    }

    if (beresp.status == 404 || beresp.status >= 500) {
        set beresp.ttl = 0s;
        set beresp.grace = 15s;
    }

    # Set ban-lurker friendly custom headers.
    set beresp.http.X-Url = bereq.url;
    set beresp.http.X-Host = bereq.http.host;

    if (beresp.http.Surrogate-Control ~ "BigPipe/1.0") {
        set beresp.do_stream = true;
        set beresp.ttl = 0s;
    }

    

    return(deliver);
}

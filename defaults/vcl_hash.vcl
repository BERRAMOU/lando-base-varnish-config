sub vcl_hash {
    set req.http.hash = req.url;
    if (req.http.host) {
        set req.http.hash = req.http.hash + "#" + req.http.host;
    } else {
        set req.http.hash = req.http.hash + "#" + server.ip;
    }

    if (req.http.X-Forwarded-Proto ~ "https") {
        set req.http.hash = req.http.hash + req.http.X-Forwarded-Proto;
    }

    if (req.http.vckey) {
        hash_data(req.http.vckey);
        unset req.http.vckey;
    }

    

    
}

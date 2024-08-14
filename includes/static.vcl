sub vcl_backend_response {
    # Bypass cache for files > N MB
    if (std.integer(beresp.http.Content-Length, 0) > 10485760) {
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;
        return (deliver);
    }
}



sub vcl_recv {
    if (req.url ~ "(?i)\.(asc|doc|xls|ppt|csv|svg|jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|pdf|txt|tar|wav|bmp|rtf|js|flv|swf|html|htm|webp)(\?.*)?$") {
        
        # Do not use memory to cache static files.
        return (pass);
        
        # unset cookie only if no http auth
        if (!req.http.Authorization) {
            unset req.http.Cookie;
        }
        return(hash);
    }
}

sub vcl_backend_response {
    
}

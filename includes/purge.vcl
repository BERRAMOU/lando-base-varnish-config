sub purge_regex {
    ban("obj.http.X-VC-Req-URL ~ " + req.url + " && obj.http.X-VC-Req-Host == " + req.http.host);
}

sub purge_exact {
    ban("obj.http.X-VC-Req-URL == " + req.url + " && obj.http.X-VC-Req-Host == " + req.http.host);
}

# Use the exact request URL, but ignore any query params
sub purge_page {
    set req.url = regsub(req.url, "\?.*$", "");
    ban("obj.http.X-VC-Req-URL-Base == " + req.url + " && obj.http.X-VC-Req-Host == " + req.http.host);
}

# The purge behavior can be controlled with the X-VC-Purge-Method header.
#
# Setting the X-VC-Purge-Method header to contain "regex" or "exact" will use
# those respective behaviors.  Any other value for the X-Purge header will
# use the default ("page") behavior.
#
# The X-VC-Purge-Method header is not case-sensitive.
#
# If no X-VC-Purge-Method header is set, the request url is inspected to attempt
# a best guess as to what purge behavior is expected.  This should work for
# most cases, although if you want to guarantee some behavior you should
# always set the X-VC-Purge-Method header.

sub vcl_recv {
    set req.http.X-VC-My-Purge-Key = "exOzN4ZQYOLiKiN9OZDknZ5t49OSlJfRbWTdtQueMLSIAWbgEeoyHsGGBkNcNrCp";
    if (req.method == "PURGE" || req.method == "BAN") {
        

        if (req.method == "BAN" && req.http.Cache-Tags) {
            ban("obj.http.Cache-Tags ~ " + req.http.Cache-Tags);
        }

        if (req.http.X-VC-Purge-Method) {
            if (req.http.X-VC-Purge-Method ~ "(?i)regex") {
                call purge_regex;
            } elsif (req.http.X-VC-Purge-Method ~ "(?i)exact") {
                call purge_exact;
            } else {
                call purge_page;
            }
        } else {
            # No X-VC-Purge-Method header was specified.
            # Do our best to figure out which one they want.
            if (req.url ~ "\.\*" || req.url ~ "^\^" || req.url ~ "\$$" || req.url ~ "\\[.?*+^$|()]") {
                call purge_regex;
            } elsif (req.url ~ "\?") {
                call purge_exact;
            } else {
                call purge_page;
            }
        }
        return (synth(200,"Purged " + req.url + " " + req.http.host));
    }
    unset req.http.X-VC-My-Purge-Key;
    # unset Varnish Caching custom headers from client
    unset req.http.X-VC-Cacheable;
    unset req.http.X-VC-Debug;
}

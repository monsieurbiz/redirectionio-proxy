sub vcl_recv {
    if (req.url ~ "\.(jpg|jpeg|png|gif|ico|css|js|svg|woff|eot|ttf|swf)") {
        return (pass);
    }
    if (req.url == "/check" && req.method == "HEAD") {
        return(pass);
    }
    if (req.method == "PRI") {
        /* We do not support SPDY or HTTP/2.0 */
        return (synth(405));
    }
    if (req.method != "GET" && req.method != "HEAD"
        && req.method != "PUT" && req.method != "POST"
        && req.method != "TRACE" && req.method != "OPTIONS"
        && req.method != "DELETE") {
        /* Non-RFC2616 or CONNECT which is weird. */
        return (pipe);
    }

    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }
    # if (req.http.Authorization) {
    #     return (pass);
    # }
    # if (req.http.Cookie) {
    #     # we don't need cookies for now
    #     unset req.http.cookie;
    # }
    set req.http.Surrogate-Capability = "abc=ESI/1.0";

    return (hash);
}

sub vcl_backend_response {

    if (beresp.http.surrogate-control ~ "ESI/1.0") {
        unset beresp.http.surrogate-control;
        set beresp.do_esi = true;
    }

    if (beresp.status >= 500 && bereq.is_bgfetch) {
        return (abandon);
    }
    if (bereq.uncacheable) {
        return (deliver);
    }
    if (
        beresp.ttl <= 0s
        || beresp.http.Cache-Control ~ "no-cache|no-store|private"
        || beresp.http.Set-Cookie
        || beresp.http.Vary == "*"
    ) {
        set beresp.ttl = 120s;
        set beresp.uncacheable = true;
        return (deliver);
    }

    # Allow stale content, in case the backend goes down.
    # make Varnish keep all objects for 24 hours beyond their TTL
    set beresp.grace = 24h;

    return (deliver);
}
sub vcl_deliver {
    # Keep ban-lurker headers only if debugging is enabled
    if (!resp.http.X-Cache-Debug) {
        # Remove ban-lurker friendly custom headers when delivering to client
        unset resp.http.X-Url;
        unset resp.http.X-Host;
    }
    if (resp.http.Vary == "") {
        unset resp.http.Vary;
    }

    return (deliver);
}

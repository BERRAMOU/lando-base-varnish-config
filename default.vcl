vcl 4.0;

include "includes/backend.vcl";

import std;
import geoip;

sub vcl_recv {
    if (req.method == "GET" && req.url == "/.vchealthz") {
        return (synth(204, "OK"));
    }
}



include "includes/purge.vcl";
include "includes/mobile.vcl";

include "defaults/vcl_recv.vcl";

include "preset.vcl";

include "includes/static.vcl";

include "defaults/vcl_hash.vcl";
include "defaults/vcl_pipe.vcl";
include "defaults/vcl_backend_response.vcl";
include "defaults/vcl_backend_error.vcl";
include "defaults/vcl_deliver.vcl";
include "defaults/vcl_hit.vcl";
include "defaults/vcl_miss.vcl";

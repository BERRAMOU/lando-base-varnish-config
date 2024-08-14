import directors;

backend backend1 {
    .host = "appserver";
    .port = "80";
	.first_byte_timeout = 60s;
	.connect_timeout = 3.5s;
	.between_bytes_timeout = 60s;
}

sub vcl_init {
	new backends = directors.round_robin();
	backends.add_backend(backend1);
}

sub vcl_recv {
	set req.backend_hint = backends.backend();
}

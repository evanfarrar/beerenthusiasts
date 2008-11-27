-module (inets_helper).
-export ([start/0]).

start() ->
    %db_backend:init(),
    db_backend:start(),
    inets:start(),
    inets:start(httpd, [
                        {port, 8000},
                        {document_root, "./content/wwwroot"},
                        {server_root, "."},
                        {bind_address, "192.168.1.4"},
                        {server_name, "192.167.1.4"},
                        {modules, [wf_inets, mod_head, mod_get]},
                        {mime_types, [{"css", "text/css"}, {"js", "text/javascript"}, {"html", "text/html"}]}
                       ]),
    io:format("~n~n---~n"),
    io:format("Nitrogen is now running, using inets:httpd().~n"),
    io:format("Open your browser to: http://localhost:8000/web/index~n"),
    io:format("---~n~n").


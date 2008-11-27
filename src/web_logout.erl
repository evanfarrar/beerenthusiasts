-module (web_logout).
-include ("wf.inc").
-export ([main/0]).

main () ->
    case wf:user() of
        undefined ->
            wf:redirect ("index");
        _ ->
            wf:clear_user(),
            wf:redirect ("index")
    end.
    

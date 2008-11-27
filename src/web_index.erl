-module (web_index).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    Body = #body { body= #panel { style="margin: 50px;", 
                                 body=[
                                       #link {text="Register  ", url="register"},
                                       #link {text="Login  ", url="login"},
                                       #br{}, #br{},
                                       #textbox {id=search, postback=search},
                                       #br{},
                                       #button {text="Search", postback=search},                                       
                                       #flash { id=flash },
                                       #panel { id=test }
                                      ]}},
    wf:render(Body).


event (search) ->
    Terms = replace (hd(wf:q(search)), " ", "+"),
    wf:redirect ("search?terms="++Terms);

event (_) -> 
    ok.

replace([], _, _) -> [];
replace(String, S1, S2) when is_list(String), is_list(S1), is_list(S2) ->
    Length = length(S1),
    case string:substr(String, 1, Length) of
        S1 ->
            S2 ++ replace(string:substr(String, Length + 1), S1, S2);
        _ ->
            [hd(String)|replace(tl(String), S1, S2)]
    end.
  

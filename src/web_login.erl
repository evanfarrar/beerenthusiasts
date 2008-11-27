-module (web_login).
-include ("wf.inc").
-export ([main/0, event/1]).

main() ->
     Body = #body { body=#panel { style="margin: 50px;", 
                                 body=["Login:",
                                       #br{},
                                       "Username: ",
                                       #textbox { id=username, postback=login },
                                       #br{},
                                       "Password: ",
                                       #password { id=pass, postback=login },
                                       #br{},
                                       #button {id=submit, text="Login", postback=login},
                                       #flash { id=flash },
                                       #panel { id=test }
                                      ]}},

    wf:wire(submit, username, #validate { attach_to=username, validators=[#is_required { text="Error: no username given." }] }),

    wf:render(Body).

event (login) ->
    case db_backend:validate(hd(wf:q(username)), hd(wf:q(pass))) of
        {valid, _ID} ->
            wf:flash ("Correct"),
            wf:user(hd(wf:q(username))),
            wf:redirect("your_page");
        _ ->
            wf:flash ("Incorrect")
    end;

event (_) -> 
    ok.

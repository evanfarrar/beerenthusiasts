-module (web_register).
-include ("wf.inc").
-export ([main/0, event/1]).

main() ->
    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=["Register:",
                                       #br{},
                                       "Username: ",
                                       #textbox {id=username, postback=register},
                                       #br{},
                                       "Email Address: ",
                                       #textbox {id=email_address, postback=register},
                                       #br{},
                                       "Password: ",
                                       #password {id=pass, postback=register},
                                       #br{},       
                                       "Retype Password: ",
                                       #password {id=pass, postback=register},
                                       #br{},              
                                       #button {id=submit, text="Register", postback=register},
                                       #br{},
                                       "Already Register? ",
                                       #link {text="Login Here", url="login"},
                                       #br{},
                                       #flash { id=flash },
                                       #panel { id=test }
                                      ]}},
    wf:render(Body).

event (register) ->
    db_backend:add_user (hd(wf:q(username)), hd(wf:q(email_address)), hd(wf:q(pass))),
    wf:redirect("login");

event (_) -> 
    ok.

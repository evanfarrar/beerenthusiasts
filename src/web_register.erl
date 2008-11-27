-module (web_register).
-include ("wf.inc").
-export ([main/0, event/1]).

main() ->
    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=["Register:",
                                       #br{},
                                       "Username: ",
                                       #textbox { id=username, postback=register },
                                       #br{},
                                       "Email Address: ",
                                       #textbox { id=email_address, postback=register },
                                       #br{},
                                       "Password: ",
                                       #password { id=pass, postback=register },
                                       #br{},       
                                       "Retype Password: ",
                                       #password { id=pass2, postback=register },
                                       #br{},              
                                       #button { id=submit, text="Register", postback=register },
                                       #br{},
                                       "Already Register? ",
                                       #link { text="Login Here", url="login" },
                                       #br{},
                                       #flash { id=flash },
                                       #panel { id=test }
                                      ]}},

    wf:wire(submit, username, #validate { attach_to=username, validators=[#is_required { text="Required." }] }),
    wf:wire(submit, email_address, #validate { attach_to=email_address, validators=[#is_required { text="Required." }] }),
    wf:wire(submit, email_address, #validate { attach_to=email_address, validators=[#is_email { text="Required: proper email address." }] }),
    wf:wire(submit, pass, #validate { attach_to=pass2, validators=[#confirm_password { text="Error: Passwords do not match", password=pass2 }] }),
    
    wf:render(Body).

event (register) ->
    case db_backend:add_user (hd(wf:q(username)), hd(wf:q(email_address)), hd(wf:q(pass))) of
        ok ->
            wf:redirect("login");
        aborted ->
            wc:flash ("Error: Please try again.")
    end;

event (_) -> 
    ok.

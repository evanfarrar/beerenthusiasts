%%% This file is part of beerenthusiasts.
%%% 
%%% beerenthusiasts is free software: you can redistribute it and/or modify
%%% it under the terms of the GNU Affero General Public License as published by
%%% the Free Software Foundation, either version 3 of the License, or
%%% (at your option) any later version.
%%% 
%%% beerenthusiasts is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU Affero General Public License for more details.
%%% 
%%% You should have received a copy of the GNU Affero General Public License
%%% along with beerenthusiasts.  If not, see <http://www.gnu.org/licenses/>.

-module (web_register).
-include ("wf.inc").
-export ([main/0, event/1]).

main() ->
    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=["Register:",
                                       #br{},
                                       "Username: ",
                                       #textbox { id=username },
                                       #br{},
                                       "Email Address: ",
                                       #textbox { id=email_address },
                                       #br{},
                                       "Password: ",
                                       #password { id=pass },
                                       #br{},       
                                       "Retype Password: ",
                                       #password { id=pass2 },
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
    wf:wire(submit, username, #validate { attach_to=username, validators=[#custom { text="Username already registered.", function=(fun (X, Y) -> is_username_used (X, Y) end) }] }),
    wf:wire(submit, username, #validate { attach_to=username, validators=[#custom { text="Error: No spaces allowed in username.", function=(fun (X, Y) -> check_username (X, Y) end) }] }),
    wf:wire(submit, username, #validate { attach_to=username, validators=[#min_length { text="Error: Username must be at least 3 characters.", length=3 }] }),
    wf:wire(submit, email_address, #validate { attach_to=email_address, validators=[#is_required { text="Required." }] }),
    wf:wire(submit, email_address, #validate { attach_to=email_address, validators=[#is_email { text="Required: Proper email address." }] }),
    wf:wire(submit, pass, #validate { attach_to=pass2, validators=[#confirm_password { text="Error: Passwords do not match", password=pass2 }] }),
    wf:wire(submit, pass, #validate { attach_to=pass, validators=[#min_length { text="Error: Passwords must be at least 8 characters.", length=8 }] }),
    
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

is_username_used (_, _) ->
    db_backend:is_username_used (hd(wf:q(username))).

check_username (_, _) ->
    case string:chr (hd(wf:q(username)), $ ) of
        0 ->
            true;
        _ ->
            false
    end.

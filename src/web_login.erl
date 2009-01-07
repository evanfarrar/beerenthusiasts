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

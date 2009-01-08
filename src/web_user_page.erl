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

-module (web_user_page).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    User = hd(wf:q(user)),
    Recipes = couchdb_util:doc_get_all (User),    
    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=[User ++ " Recipes:",
                                       #br{},
                                       %rfc4627:encode(Recipes),
                                       #flash { id=flash },
                                       #panel { id=test }
                                      ]}},
    wf:render(Body).

event (_) ->
    ok.

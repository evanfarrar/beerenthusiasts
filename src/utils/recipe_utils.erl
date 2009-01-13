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

-module (recipe_utils).
-include ("wf.inc").
-export ([get_user_recipes/2, save_recipe/4, delete_recipe/0, get_recipe/1]).

-include_lib ("stdlib/include/qlc.hrl").

%%% Return recipes 10 at a time
get_user_recipes (Username, PageNum) ->
    Options = [{count, 10}, {skip, integer_to_list(PageNum*10)}],
    couchdb_utils:view_access("recipes", "user_recipes", Username, Options).

save_recipe (ID, Username, RecipeName, Recipe) ->
    JSON = {obj,
            [{username, Username},
             {name, RecipeName},
             {ingredients, 
              {obj, 
               lists:foldr (fun (X, L) -> [create_json (X) | L] end, [], Recipe) }}]},
    if 
        ID =:= [] ->
            couchdb_utils:doc_create ("recipes", JSON);
        true ->
            couchdb_utils:doc_create ("recipes", ID, JSON)
    end.

delete_recipe () ->
    ok.

get_recipe (Name) ->
    case rfc4627:decode(couchdb_utils:doc_get ("recipes", Name)) of                
        {error, Reason} ->
            io:format (Reason),
            [];
        {ok, {obj, Doc}, _} -> 
            Doc
    end.    

create_json ({Type, Type}) ->
    {Type, list_to_binary(hd(wf:q(Type)))}; 
create_json ({Type, List}) ->   
    {list_to_binary(Type), [[list_to_binary(hd(wf:q(X))) || X <- L] || L <- List]}.
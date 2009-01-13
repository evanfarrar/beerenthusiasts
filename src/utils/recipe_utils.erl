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
-export ([get_user_recipes/2, create_recipe/0, delete_recipe/0, get_recipe/0, save_recipe/0]).

-include_lib ("stdlib/include/qlc.hrl").

get_user_recipes (Username, PageNum) ->
    Options = [{count, 10}, {skip, integer_to_list(PageNum*10)}],
    couchdb_util:view_access("recipes", "user_recipes", Username, Options).

create_recipe () ->
    ok.

delete_recipe () ->
    ok.

get_recipe () ->
    ok.

save_recipe () ->
    ok.

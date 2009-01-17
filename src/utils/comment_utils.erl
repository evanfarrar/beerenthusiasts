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

-module (comment_utils).
-include ("wf.inc").
-include ("config.inc").
-export ([create_recipe_comments_view/1, save_comment/5]).

create_recipe_comments_view (RecipeID) ->
    couchdb_utils:view_create (?COUCHDB_COMMENTS_DB_NAME, RecipeID, <<"javascript">>, [{all, list_to_binary("function(doc)\n{\n if (doc.recipeid == \"" ++ RecipeID ++ "\")\n {\n  emit(null, doc); \n }\n}")}], []).

save_comment (ID, RecipeID, Username, Title, Comment) ->
    JSON = {obj,
            [{recipeid, RecipeID},
             {username, Username},
             {title, Title},
             {comment, Comment}]}, 
    if 
        ID =:= [] ->
            couchdb_utils:doc_create (?COUCHDB_COMMENTS_DB_NAME, JSON);
        true ->
            couchdb_utils:doc_create (?COUCHDB_COMMENTS_DB_NAME, ID, JSON)
    end.

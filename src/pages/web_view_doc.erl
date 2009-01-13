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

-module (web_view_doc).
-include ("wf.inc").
-compile(export_all).

main() ->
  case wf:user() of
    undefined -> Header = "./wwwroot/new_user_template.html";
    _ -> Header = "./wwwroot/user_template.html"
  end,
  #template { file=Header }.
  
title() -> "Beer Enthusiasts".

body() -> 

    DocId = wf:q (doc_id),
    User = wf:q (user),
    Doc = rfc4627:encode(couchdb_util:doc_get (User, DocId)),

    ["Recipe:",
     #br{},
     Doc,
     #flash { id=flash },
     #panel { id=test }
    ].
event (_) ->
    ok.
 

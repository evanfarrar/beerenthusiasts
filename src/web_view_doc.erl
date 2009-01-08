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
-export ([main/0, event/1]).

main () ->    
    case wf:user() of        
        undefined ->
            Header = "new_user_header";
        _ ->
            Header = "user_header",
            ok
    end,
    

    DocId = wf:q (doc_id),
    User = wf:q (user),
    Doc = rfc4627:encode(couchdb_util:doc_get (User, DocId)),

    Template = #template {file="main_template", title="View Recipe",
                          section1 = #panel { style="margin: 50px;", 
                                              body=[
                                                    #file { file=Header },     
                                                    "Recipe:",
                                                    #br{},
                                                    Doc,
                                                    #flash { id=flash },
                                                    #panel { id=test }
                                      ]}},
    wf:render(Template).

event (_) ->
    ok.
 

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

-module (web_edit_recipe).
-include ("wf.inc").
-compile(export_all).

-define (FERMENTABLE, "fermentables").
-define (HOP, "hops").
-define (OTHER, "others").

%% Just learning... 

main() ->

  case wf:user() of
        undefined ->
            wf:redirect("register"),
            Header = "";
        _ -> Header = "./wwwroot/user_template.html"
    end,
  #template { file=Header }.
  
title() -> "Beer Enthusiasts".

body () ->    
    
    ID = wf:q(id),
    case ID of
        [] ->
            Doc = [],
            ok;    
        _ ->            
            Doc = recipe_utils:get_recipe (ID)
    end,
    
    Fermentables = spawn (web_edit_recipe, id_loop, [[], ?FERMENTABLE]),
    Hops = spawn (web_edit_recipe, id_loop, [[], ?HOP]),
    Others = spawn (web_edit_recipe, id_loop, [[], ?OTHER]),
    
    case lists:keysearch ("name", 1, Doc) of
        {value, {{_, _}, {_, Name}, {_, {obj, List}}}} ->
            wf:update (name_panel, [#textbox {text=Name}]),
            build_page (List, Fermentables, Hops, Others);
        false ->
            wf:update (name_panel, [#textbox { id=name }]),
            wf:update (yeast_panel, #textbox { id='yeast' }),
            wf:update (instructions_panel, #textarea { id='instructions' }),
            wf:update (notes_panel, #textarea { id='notes' }),
            wf:update (desc_panel, #textarea { id='description' }),
            event ({add, ferms, Fermentables}),
            event ({add, hops, Hops}),
            event ({add, others, Others}),
            ok
    end,    

    wf:wire(save, name, #validate { attach_to=name, validators=[#is_required { text="Required." }] }),

    
    ["Name:",
     #br{},
     #panel { id=name_panel },
     #br{},
     "Fermentables:",                                       
     #br{},
     #panel { id=fermentables_flash },
     #br{},                                                    
     "Hops:",
     #br{},
     #panel { id=hops_flash },
     #br{},                                                    
     "Other:",
     #br{},
     #panel { id=others_flash },                                                    
     #br{},
     "Yeast:",
     #br{},
     #panel { id=yeast_panel },
     #br{},
     "Instructions:",
     #br{},
     #panel { id=instructions_panel },                                    
     #br{},
     "Post Brewing Notes:",
     #br{},
     #panel { id=notes_panel },                                            
     #br{},
     "Final Beer Description:",
     #br{},
     #panel { id=desc_panel },
     #br{},
     #button { id=save, text="Save", postback={save, ID, Fermentables, Hops, Others} },
     #flash { id=flash }
    ].

event({save, ID, Fermentables, Hops, Others}) ->
    Fermentables ! {get_list, self()},
    receive
        Fermentables_List ->            
            Hops ! {get_list, self()},
            receive
                Hops_List ->
                    Others ! {get_list, self()},
                    receive
                        Others_List ->
                            store_recipe (ID, [Fermentables_List] ++ [Hops_List] ++ [Others_List] ++ 
                                          [{yeast, yeast}, {instructions, instructions}, {notes, notes}, {description, description}]),
                            wf:flash ("Successfully Saved Recipe.")
                    end
            end
    end;

event({add, ferms, Fermentables}) ->
    event({add, ferms, Fermentables}, "", "", "");
event({add, hops, Hops}) ->
    event({add, hops, Hops}, "", "", "");
event({add, others, Others}) ->
    event({add, others, Others}, "", "", "");        
event(_) ->
    ok.

event({add, ferms, Fermentables}, Text1, Text2, Text3) ->
    Fermentables ! {add_to_list, self()},
    receive
        [One, Two, Three] ->
            wf:insert_bottom (fermentables_flash, new_fermentables(Fermentables, One, Two, Three, Text1, Text2, Text3));
        Other ->
            io:format ("~w~n", [Other])           
    end;

event({add, hops, Hops}, Text1, Text2, Text3) ->    
    Hops ! {add_to_list, self()},
    receive
        [One, Two, Three] ->
            wf:insert_bottom (hops_flash, new_hops(Hops, One, Two, Three, Text1, Text2, Text3)); 
        Other ->
            io:format ("~w~n", [Other])           
    end;

event({add, others, Others}, Text1, Text2, Text3) ->    
    Others ! {add_to_list, self()},
    receive
        [One, Two, Three] ->
            wf:insert_bottom (others_flash, new_others(Others, One, Two, Three, Text1, Text2, Text3));
        Other ->
            io:format ("~w~n", [Other])           
    end.

id_loop (List, Type) ->    
    receive
        {add_to_list, PID} ->
            Len = integer_to_list(length (List)+1),
            Additions = [list_to_atom(Type++Len++"1"), list_to_atom(Type++Len++"2"), list_to_atom(Type++Len++"3")],
            PID ! Additions,
            id_loop ([Additions | List], Type);
        {get_list, PID} ->
            PID ! {Type, List},
            id_loop (List, Type);
        _ ->
            id_loop (List, Type)
    end.

store_recipe (ID, Recipe) ->
    recipe_utils:recipe_create (ID, wf:user(), wf:q(name), Recipe).

new_fermentables (PID, One, Two, Three, Text1, Text2, Text3) ->
    new_flash (ferms, PID, [#textbox { id=One, text=Text1 },
               #dropdown { id=Two,  
                           options=[#option{text="oz", value="oz"},
                                    #option{text="lb", value="lb"},
                                    #option{text="gram", value="gram"}],
                           value=Text2 },        
               #textbox { id=Three, text=Text3 }]).

new_hops (PID, One, Two, Three, Text1, Text2, Text3) ->
    new_flash (hops, PID, [#textbox { id=One, text=Text1 },
                #dropdown { id=Two,  
                           options=[#option{text="oz", value="oz"},                                    
                                    #option{text="gram", value="gram"}],
                            value=Text2 },        
               #textbox { id=Three, text=Text3 }]).

new_others (PID, One, Two, Three, Text1, Text2, Text3) ->
    new_flash (others, PID, [#textbox { id=One, text=Text1 },
               #dropdown { id=Two,  
                           options=[#option{text="oz", value="oz"},                                    
                                    #option{text="gram", value="gram"}],
                           value=Text2 },        
               #textbox { id=Three, text=Text3 }]).
    
new_flash (Type, PID, Body) -> 
    FlashID = wf:temp_id(),
                                                %class=flash, 
    InnerPanel = #panel { actions=#effect_blinddown 
                          { target=FlashID, duration=0.4 }, 
                          body=[
                                #panel { class=flash_content, body=Body ++[  #link { text="[New]", 
                                                                                     actions=#event { type=click, target=FlashID, 
                                                                                                      postback={add, Type, PID}}}, 
                                                                             #link { class=flash_close_button, text="[Remove]", 
                                                                                     actions=#event { type=click, target=FlashID, 
                                                                                                      actions=#effect_blindup {}, 
                                                                                                      postback={delete, Type, PID}}}]}]},
    [#panel { id=FlashID, style="display: none;", body=InnerPanel}].

build_page ([], _, _, _) ->
    ok;
build_page ([{Type, List} | T], Fermentables, Hops, Others) ->
    if
        Type == "fermentables" ->            
            if 
                length (List) == 0 ->
                    event({add, ferms, Fermentables});
                true ->
                    [event({add, ferms, Fermentables}, Text1, Text2, Text3) || [Text1, Text2, Text3] <- List]
            end,
            build_page (T, Fermentables, Hops, Others);
        Type == "hops" ->
            if 
                length (List) == 0 ->
                    event({add, hops, Hops});
                true ->
                    [event({add, hops, Hops}, Text1, Text2, Text3) || [Text1, Text2, Text3] <- List]
            end,
            build_page (T, Fermentables, Hops, Others);
        Type == "others" ->
            if 
                length (List) == 0 ->
                    event({add, others, Others});
                true ->
                    [event({add, others, Others}, Text1, Text2, Text3) || [Text1, Text2, Text3] <- List]
            end,
            build_page (T, Fermentables, Hops, Others);
        Type == "yeast" ->           
            wf:update (yeast_panel, [#textbox { id=name, text=List }]),
            build_page (T, Fermentables, Hops, Others);
        Type == "instructions" ->
            wf:update (instructions_panel, #textarea { id='instructions', text=List }),
            build_page (T, Fermentables, Hops, Others);
        Type == "notes" ->
            wf:update (notes_panel, #textarea { id='notes', text=List }),
            build_page (T, Fermentables, Hops, Others);
        Type == "description" ->
            wf:update (desc_panel, #textarea { id='description', text=List }),
            build_page (T, Fermentables, Hops, Others) 
    end.



-module (web_edit_recipe).
-include ("wf.inc").
-export ([main/0, event/1, id_loop/2]).

-define (FERMENTABLE, "fermentables").
-define (HOP, "hops").
-define (OTHER, "others").

%% Just learning... 

main() ->
    case wf:user() of        
        undefined ->
            wf:redirect ("register");
        _ ->
            ok
    end,
    
    Fermentables = spawn (web_edit_recipe, id_loop, [[['fermentables_11', 'fermentables_12', 'fermentables_13']], ?FERMENTABLE]),
    Hops = spawn (web_edit_recipe, id_loop, [[['hops_11', 'hops_12', 'hops_13']], ?HOP]),
    Others = spawn (web_edit_recipe, id_loop, [[['others_11', 'others_12', 'others_13']], ?OTHER]),

    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=[
                                       "Fermentables:",                                       
                                       #br{},
                                       #textbox { id='fermentables_11' },
                                       #dropdown { id='fermentables_12', 
                                                   options=[#option{text="oz", value="oz"},
                                                            #option{text="lb", value="lb"},
                                                            #option{text="gram", value="gram"}]},
                                       #textbox { id='fermentables_13' },                 
                                       #link { text="[New]", postback={add_ferms, Fermentables} },
                                       #br{},
                                       #panel { id=fermentables_flash },
                                       #br{},

                                       "Hops:",
                                       #br{},
                                       #textbox { id='hops_11' },
                                       #dropdown { id='hops_12', 
                                                   options=[#option{text="oz", value="oz"},
                                                            #option{text="gram", value="gram"}]},
                                       #textbox { id='hops_13' },                 
                                       #link { text="[New]", postback={add_hops, Hops} },
                                       #br{},
                                       #panel { id=hops_flash },
                                       #br{},

                                       "Other:",
                                       #br{},
                                       #textbox { id='others_11' },
                                       #dropdown { id='others_12', 
                                                   options=[#option{text="oz", value="oz"},
                                                            #option{text="gram", value="gram"}]},
                                       #textbox { id='others_13' },                 
                                       #link { text="[New]", postback={add_others, Others} },
                                       #br{},
                                       #panel { id=others_flash },

                                       #br{},
                                       "Yeast:",
                                       #br{},
                                       #textbox { id='yeast' },
                                       #br{},
                                       "Instructions:",
                                       #br{},
                                       #textarea { id='instructions' },
                                       #br{},
                                       "Post Brewing Notes:",
                                       #br{},
                                       #textarea { id='notes' },
                                       #br{},
                                       "Final Beer Description:",
                                       #br{},
                                       #textarea { id='description' },
                                       #br{},
                                       #button { text="Save", postback={save, Fermentables, Hops, Others} },
                                       #panel { id=test }
                                      ]}},
    wf:render(Body).

event({save, Fermentables, Hops, Others}) ->
    Fermentables ! {get_list, self()},
    receive
        Fermentables_List ->            
            Hops ! {get_list, self()},
            receive
                Hops_List ->
                    Others ! {get_list, self()},
                    receive
                        Others_List ->
                            store_recipe ([Fermentables_List] ++ [Hops_List] ++ [Others_List] ++ [{yeast, yeast}, {instructions, instructions}, {notes, notes}, {description, description}])
                    end
            end
    end;

event({add_ferms, Fermentables}) ->    
    Fermentables ! {add_to_list, self()},
    receive
        [One, Two, Three] ->
               wf:insert_bottom (fermentables_flash, new_fermentables(One, Two, Three));
        Other ->
            io:format ("~w~n", [Other])           
    end;        

event({add_hops, Hops}) ->    
    Hops ! {add_to_list, self()},
    receive
        [One, Two, Three] ->
            wf:insert_bottom (hops_flash, new_hops(One, Two, Three));
        Other ->
            io:format ("~w~n", [Other])           
    end;        

event({add_others, Others}) ->    
    Others ! {add_to_list, self()},
    receive
        [One, Two, Three] ->
            wf:insert_bottom (others_flash, new_others(One, Two, Three));
        Other ->
            io:format ("~w~n", [Other])           
    end;        

event(_) ->
    ok.

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

store_recipe (List) ->
    JSON = {obj,
            [{ingredients, 
              {obj, 
               lists:foldr (fun (X, L) -> [create_json (X) | L] end, [], List) }}]},
    %io:format ("~w~n", [JSON]),
    couchdb_util:doc_create(wf:user(), JSON).

create_json ({Type, Type}) ->
    {Type, list_to_binary(hd(wf:q(Type)))}; 
create_json ({Type, List}) ->   
    {list_to_binary(Type), [[list_to_binary(hd(wf:q(X))) || X <- L] || L <- List]}.

new_fermentables (One, Two, Three) ->
    new_flash ([#textbox { id=One },
               #dropdown { id=Two,  
                           options=[#option{text="oz", value="oz"},
                                    #option{text="lb", value="lb"},
                                    #option{text="gram", value="gram"}]},        
               #textbox { id=Three }]).

new_hops (One, Two, Three) ->
    new_flash ([#textbox { id=One },
               #dropdown { id=Two,  
                           options=[#option{text="oz", value="oz"},                                    
                                    #option{text="gram", value="gram"}]},        
               #textbox { id=Three }]).

new_others (One, Two, Three) ->
    new_flash ([#textbox { id=One },
               #dropdown { id=Two,  
                           options=[#option{text="oz", value="oz"},                                    
                                    #option{text="gram", value="gram"}]},        
               #textbox { id=Three }]).
    
new_flash (Body) ->
    FlashID = wf:temp_id(),
                                                %class=flash, 
    InnerPanel = #panel { actions=#effect_blinddown 
                          { target=FlashID, duration=0.4 }, 
                          body=[
                                #panel { class=flash_content, body=Body ++[ #link { class=flash_close_button, text="[Remove]", 
                                                                             actions=#event { type=click, target=FlashID, 
                                                                                              actions=#effect_blindup {}}}]}]},
    [#panel { id=FlashID, style="display: none;", body=InnerPanel}].



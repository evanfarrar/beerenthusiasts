-module (web_index).
-include ("wf.inc").
-export ([main/0, event/1]).

%% Just learning... 

main() ->
    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=[#textbox { id=myTextbox1 },
                                       #textbox { id=myTextbox2 },
                                       #textbox { id=myTextbox3 },                 
                                       #button { text="Add", postback=add },
                                       #br{},
                                       #flash { id=flash },
                                       #button { text="Submit", postback=go },
                                       #panel { id=test }
                                      ]}},
    wf:render(Body).

event(go) ->
    A = wf:q(myTextbox1),    
    wf:update (test, A);

event(add) ->
    wf:flash(    [ #textbox { id=myTextbox1, postback=go },
                   #textbox { id=myTextbox2, postback=go },
                   #textbox { id=myTextbox3, postback=go } ]);

event(_) -> ok.

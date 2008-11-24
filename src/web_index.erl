-module (web_index).
-include ("wf.inc").
-export ([main/0, event/1]).

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
                                       %%"Hello there"2
                                      ]}},
    wf:render(Body).

event(go) ->
    A = wf:q(myTextbox1),    
    wf:update (test, A);

event(add) ->
    %% A = wf:q(myTextbox),
    wf:flash(    [ #textbox { id=myTextbox1, postback=go },
                   #textbox { id=myTextbox2, postback=go },
                   #textbox { id=myTextbox3, postback=go } ]);
%% wf:flash(A),
    %%wf:update(test, "This is a test.");

event(_) -> ok.

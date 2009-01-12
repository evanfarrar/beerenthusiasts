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

-module (web_calc).
-include ("wf.inc").
-export ([main/0, event/1]).

main() ->
  Cell1 = #tablecell { body = [#br{},
	                       "Original: ",
	                       #br{},
	                       "Final: " ] },
  Cell2 = #tablecell { body = ["Measurement",
	                       #br{},
	                       #textbox { id=myTextboxOG, text="1.050"},
	                       #br{},
	                       #textbox { id=myTextboxFG, text="1.010" } ] },
  Cell3 = #tablecell { body =  ["Scale",
	                        #br{},
	                        #dropdown{id = meas, options=[#option{text="Specific Gravity", value="SG", selected=true},
		                                              #option{text="Degrees Plato", value="DP"}]}]},
  Cell4 = #tablecell { body = ["Temperature",
	                       #br{},
	                       #textbox { id=myTextboxT1, text="60" },
	                       #br{},
	                       #textbox { id=myTextboxT2, text="60" } ] },
  Cell5 = #tablecell { body = ["Scale",
	                       #br{},
	                       #dropdown{id = temp, options=[#option{text="Fahrenheit", value="F", selected=true},
		                                             #option{text="Celsius", value="C"}]}]},
  Row1 =  #tablerow {cells = [Cell1, Cell2, Cell3, Cell4, Cell5] },
  Body =  #body { body= #panel { style="margin: 50px;", body=["Gravity/ ABV Calculator",
	                                                      #table {rows=[Row1]},
	                                                      #button { text="Submit", postback=go },
		                                              #button { text="Reset", postback=reset },
						              #panel { id=test1 },
		                                              #panel { id=test2 },
		                                              #panel { id=test3 },
		                                              #panel { id=test4 }] } },
	wf:render(Body).
	
event(go) ->
  MScale = hd(wf:q(meas)),
  TScale = hd(wf:q(temp)),
  case MScale of 
    "SG" -> io:format("SG~n");
    "DP" -> io:format("DP~n")
  end,
  case TScale of 
    "F" -> io:format("F~n");
    "C" -> io:format("C~n")
  end,
  {OG,_} = string:to_float(string:concat(hd(wf:q(myTextboxOG)),".0")),
  wf:update(test1,io_lib:format("OG: ~10.3f~n", [OG])),
  {FG,_} = string:to_float(string:concat(hd(wf:q(myTextboxFG)),".0")),
  wf:update(test2,io_lib:format("FG: ~10.3f~n", [FG])),
  ABW = (76.08*(OG-FG))/(1.775-OG),
  wf:update(test3,io_lib:format("ABW: ~10.2f%~n", [ABW])),
  ABV = ABW*(FG/0.794),
  wf:update(test4,io_lib:format("ABV: ~10.2f%~n", [ABV]));
	
event(reset) ->
  wf:redirect([]);
	
event(_) -> ok.

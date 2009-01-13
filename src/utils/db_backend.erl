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

-module (db_backend).
-include ("wf.inc").
-include ("config.inc").
-export ([init/0, start/0, stop/0, validate/2, add_user/3, is_username_used/1]).

-include_lib ("stdlib/include/qlc.hrl").

%%% Initialize database and tables. Only run once!
init () ->
    mnesia:create_schema ([node()]),
    mnesia:start(),
    %mnesia:delete_table (users),
    mnesia:create_table (users, [{attributes, record_info (fields, users)}, {disc_copies, [node()]}]),
    mnesia:stop().   

%%% Start the database
start () ->
    crypto:start(),
    mnesia:start().

%%% Stop the database
stop () ->
    mnesia:stop().

%%% Add a user to the mnesia database
add_user (Username, EmailAddress, Password) ->
    <<PasswordDigest:160>> = crypto:sha(Password),
    Row = #users{username=Username, email_address=EmailAddress, password=PasswordDigest},   
    case write (Row) of
        {atomic, Val} ->
            couchdb_utils:db_create (Username),
            ok;
        {aborted, Reason} ->
            io:format ("Adding user failed!~nRow: ~s aborted.~nReason: ~s~n", [Row, Reason]),
            aborted
    end.

%%% Return true if the Username or EmailAddress match the Input
check (Username, EmailAddress, Input) ->
    if 
        Username == Input ; EmailAddress == Input ->
            true;
        true ->
            false
    end.

%%% Return valid if the Username and Password match, not_valid otherwise
validate (Username, Password) ->
    <<PasswordDigest:160>> = crypto:sha(Password),
    case do (qlc:q ([X#users.username || X <- mnesia:table(users), check (X#users.username, X#users.email_address, Username), X#users.password == PasswordDigest])) of
        fail ->
            not_valid;
        Results ->        
            if 
                length (Results) == 1 ->
                    {valid, hd(Results)};
                true ->
                    not_valid
            end
    end.

%%% Checks the database to see if a username is already registered
is_username_used (Username) ->    
    case do (qlc:q ([X#users.username || X <- mnesia:table(users), string:equal(X#users.username, Username)])) of
        aborted ->
            false;
        Results ->        
            if 
                length (Results) == 1 ->
                    false;
                true ->
                    true
            end
    end.


%%% Run Query Q
do (Q) ->
    F = fun() -> qlc:e(Q) end,
    case mnesia:transaction (F) of
        {atomic, Val} ->
            Val;
        {aborted, Reason} ->
            io:format ("Query: ~s aborted.~nReason: ~s~n", [Q, Reason]),
            aborted    
    end.
                
write (Row) ->
    F = fun() ->
                mnesia:write (Row)
        end,
    mnesia:transaction (F).
    

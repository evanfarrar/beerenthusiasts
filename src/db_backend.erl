-module (db_backend).
-include ("wf.inc").
-export ([init/0, start/0, stop/0, validate/2, add_user/3]).

-include_lib ("stdlib/include/qlc.hrl").

-record (users, {username, email_address, password}).

%%% Initialize database and tables. Only run once!
init () ->
    mnesia:create_schema ([node()]),
    mnesia:start(),
    mnesia:delete_table (users),
    mnesia:create_table (users, [{attributes, record_info (fields, users)}, {disc_copies, [node()]}]),
    mnesia:stop().   

%%% Start the database
start () ->
    mnesia:start().

%%% Stop the database
stop () ->
    mnesia:stop().

%%% Add a user to the mnesia database
add_user (Username, EmailAddress, Password) ->
    Row = #users{username=Username, email_address=EmailAddress, password=Password},   
    case write (Row) of
        {atomic, Val} ->
            couchdb_util:db_create (Username),
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
    case do (qlc:q ([X#users.username || X <- mnesia:table(users), check (X#users.username, X#users.email_address, Username), X#users.password == Password])) of
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
    

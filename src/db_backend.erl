-module (db_backend).
-include ("wf.inc").
-export ([init/0, start/0, stop/0, validate/2, add_user/3]).

-include_lib ("stdlib/include/qlc.hrl").

-record (users, {username, email_address, password}).

init () ->
    mnesia:create_schema ([node()]),
    mnesia:start(),
    mnesia:delete_table (users),
    mnesia:create_table (users, [{attributes, record_info (fields, users)}, {disc_copies, [node()]}]),
    mnesia:stop().   

start () ->
    mnesia:start().


stop () ->
    mnesia:stop().

add_user (Username, EmailAddress, Password) ->
    Row = #users{username=Username, email_address=EmailAddress, password=Password},   
    F = fun() ->
                mnesia:write (Row)
        end,
    mnesia:transaction (F),
    couchdb_util:db_create (Username).

check (Username, EmailAddress, Input) ->
    if 
        Username == Input ; EmailAddress == Input ->
            true;
        true ->
            false
    end.

validate (Username, Password) ->
    Results = do (qlc:q ([X#users.username || X <- mnesia:table(users), check (X#users.username, X#users.email_address, Username), X#users.password == Password])),
    if 
        length (Results) == 1 ->
            {valid, hd(Results)};
        true ->
            not_valid
    end.

do (Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction (F),
    Val.
                

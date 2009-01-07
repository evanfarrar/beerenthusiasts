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

-module (couchdb_util).
-compile (export_all).

-define (GDB, "test").
-define (Port, "5984").
-define (Host, "localhost").

start () ->    
    application:start(inets).
    
%% API Functions

%% @spec db_create(DatabaseName::string()) -> ok | {error, Reason::term()}
%%
%% @doc Create a database

db_create(DatabaseName) when is_binary(DatabaseName) ->
    db_create(binary_to_list(DatabaseName));

db_create(DatabaseName) ->
    Path = lists:flatten(io_lib:format("/~s/", [DatabaseName])),
    _Reply = couchdb_util:put (Path, []).
    %handle_reply(_Reply).

%% @spec db_delete(DatabaseName::string()) -> ok | {error, Reason::term()}
%%
%% @doc Delete a database

db_delete(DatabaseName) when is_binary(DatabaseName) ->
    db_delete(binary_to_list(DatabaseName));

db_delete(DatabaseName) ->
    Path = lists:flatten(io_lib:format("/~s/", [DatabaseName])),
    _Reply = delete (Path, []).
    %handle_reply(_Reply).

%% @spec db_list() -> ok | {error, Reason::term()}
%%
%% @doc List databases
    
db_list() ->
    Path = "/_all_dbs",
    _Reply = get (Path, []).
    %handle_reply(_Reply).

%% @spec db_info(DatabaseName::string()) -> {ok, Info::json()} | {error, Reason::term()}
%%
%% @type json() = obj() | array() | num() | str() | true | false | null
%% @type obj() = {obj, [{key(), val()}]}
%% @type array() = [val()]
%% @type key() = str() | atom()
%% @type val() = obj() | array() | num() | str() | true | false | null
%% @type num() = int() | float()
%% @type str() = bin()
%% 
%% @doc Database info

db_info(DatabaseName) ->
    Path = lists:flatten(io_lib:format("/~s", [DatabaseName])),
    _Reply = gen_server:call(ec_listener, {get, Path, []}).
    %handle_reply(_Reply).

%% @spec doc_create(DatabaseName::string(), Doc::json()) -> {ok, Response::json()} | {error, Reason::term()}
%%
%% @doc Create document

doc_create(DatabaseName, Doc) ->
    DocJson = rfc4627:encode(Doc),
    Path = lists:flatten(io_lib:format("/~s/", [DatabaseName])),
    _Reply = post (Path, DocJson).
    %handle_reply(_Reply).

%% @spec doc_create(DatabaseName::string(), DocName::string(), Doc::json()) -> {ok, Response::json()} | {error, Reason::term()}
%%
%% @doc Create a named document

doc_create(DatabaseName, DocName, Doc) ->
    JsonDoc = rfc4627:encode(Doc),
    Path = lists:flatten(io_lib:format("/~s/~s", [DatabaseName, DocName])),
    _Reply = couchdb_util:put (Path, JsonDoc).
    %handle_reply(_Reply).

%% @spec doc_bulk_create(DatabaseName::string(), DocList) -> {ok, Response::json()} | {error, Reason::term()}
%%     DocList = [json()]
%%
%% @doc Batch create a set of documents.

doc_bulk_create(DatabaseName, DocList) ->
    BulkDoc = rfc4627:encode({obj, [{"docs", DocList}]}),
    Path = lists:flatten(io_lib:format("/~s/~s", [DatabaseName, "_bulk_docs"])),
    _Reply = post (Path, BulkDoc).
    %handle_reply(_Reply).
    
%% @spec doc_update(DatabaseName::string(), DocName::string(), Doc::json()) -> {ok, Response::json()} | {error, Reason::term()}
%%
%% @doc Update document

doc_update(DatabaseName, DocName, Doc) -> 
    doc_create(DatabaseName, DocName, Doc).

%% @spec doc_bulk_update(DatabaseName::string(), DocListRev) -> {ok, Response::json()} | {error, Reason::term()}
%%     DocListRev = [json()]
%%
%% @doc Batch update a set of documents

doc_bulk_update(DatabaseName, DocListRev) ->
    doc_bulk_create(DatabaseName, DocListRev).

%% @spec doc_delete(DatabaseName::string(), DocName::string(), Rev::string()) -> {ok, Response::json()} | {error, Reason::term()}
%%
%% @doc Delete document

doc_delete(DatabaseName, DocName, Rev) ->
    Path = lists:flatten(io_lib:format("/~s/~s", [DatabaseName, DocName])),
    _Reply = delete (Path, [{"rev", Rev}]).
    %handle_reply(_Reply).

%% @spec doc_get(DatabaseName::string(), DocName::string) -> {ok, Response::json()} | {error, Reason::term()}
%%
%% @doc Get document

doc_get(DatabaseName, DocName) ->
    doc_get(DatabaseName, DocName, []).

%% @spec doc_get(DatabaseName::string(), DocName::string(), Options::options()) -> {ok, Response::json()} | {error, Reason::term()}
%%
%% @doc Get document

doc_get(DatabaseName, DocName, Options) ->
    Path = lists:flatten(io_lib:format("/~s/~s", [DatabaseName, DocName])),
    _Reply = get (Path, Options).
    %handle_reply(_Reply).

%% @spec doc_get_all(DatabaseName::string()) -> {ok, Response::json()} | {error, Reason::term()}
%%
%% @doc Get all documents

doc_get_all(DatabaseName) ->
    doc_get_all(DatabaseName, []).
    
%% @spec doc_get_all(DatabaseName::string(), Options::options()) -> {ok, Response::json()} | {error, Reason::term()}
%%
%% @doc Get all documents

doc_get_all(DatabaseName, Options) ->
    Path = lists:flatten(io_lib:format("/~s/_all_docs", [DatabaseName])),
    _Reply = get (Path, Options).
    %handle_reply(_Reply).

%% @hidden

view_create(_ViewName, _Funs) ->
    {error, "Not implemented"}.

%% @hidden

view_update(_ViewName, _Funs, _Rev) ->
    {error, "Not implemented"}.

%% @hidden

view_delete(_ViewName, _Rev) ->
    {error, "Not implemented"}.

%% @hidden

view_get(_ViewName) ->
    {error, "Not implemented"}.

%% @hidden

view_get(_ViewName, _Rev) ->
    {error, "Not implemented"}.

%% @spec view_adhoc(DatabaseName::string(), Fun::json()) -> {ok, Response::json()} | {error, Reason::term()}
%%
%%
%% @doc Access an adhoc view

view_adhoc(DatabaseName, Fun) ->
    view_adhoc(DatabaseName, Fun, []).

%% @spec view_adhoc(DatabaseName::string(), Fun::json(), Options::options()) -> {ok, Response::json} | {error, Reason::term()}
%%
%% @doc Access an adhoc view

view_adhoc(DatabaseName, Fun, Options) ->
    Path = lists:flatten(io_lib:format("/~s/_temp_view", [DatabaseName])),
    _Reply = post (Path, Fun, "text/javascript", Options).
    %handle_reply(_Reply).

%% @hidden

view_access(DatabaseName, DesignName, ViewName) ->
    view_access(DatabaseName, DesignName, ViewName, []).

%% @hidden

view_access(DatabaseName, DesignName, ViewName, Options) ->
    Path = lists:flatten(io_lib:format("/~s/_view/~s/~s", [DatabaseName, DesignName, ViewName])),
    _Reply = get (Path, Options).
    %handle_reply(_Reply).

%%% Access Functions

get (Path, Options) ->
    QueryString = query_string(Options),
    Url = lists:flatten(io_lib:format("http://~s:~s~s~s", [?Host, ?Port, Path, QueryString])),
    _Reply = http_g_request(Url).
    %{stop, "Normal"}.

post (Path, Doc) ->   
    Url = lists:flatten(io_lib:format("http://~s:~s~s", [?Host, ?Port, Path])),
    io:format ("~s~n", [Url]),
    _Reply = http_p_request(post, Url, Doc).
    %{stop, "Normal"}.

post (Path, Doc, ContentType, Options) ->
    QueryString = query_string(Options),
    Url = lists:flatten(io_lib:format("http://~s:~s~s~s", [?Host, ?Port, Path, QueryString])),
    _Reply = http_p_request(post, Url, Doc, ContentType).
    %{stop, "Normal"}.

put (Path, Doc) ->
    Url = lists:flatten(io_lib:format("http://~s:~s~s", [?Host, ?Port, Path])),
    _Reply = http_p_request(put, Url, Doc).
    %{stop, "Normal"}.

delete (Path, Options) ->
    QueryString = query_string(Options),
    Url = lists:flatten(io_lib:format("http://~s:~s~s~s", [?Host, ?Port, Path, QueryString])),
    _Reply = http_d_request(Url).
    %{stop, "Normal"}.

query_string(Options) ->
    query_string(Options, "?", []).
query_string([], _Separator, Acc) ->
    lists:flatten(lists:reverse(Acc));
query_string([{Name, Value} | T], Separator, Acc) when is_integer(Value) ->
    query_string([{Name, integer_to_list(Value)} | T], Separator, Acc);
query_string([{Name, Value} | T], Separator, Acc) ->
    O = lists:flatten(io_lib:format("~s~s=~s", [Separator, Name, Value])),
    query_string(T, "&", [O | Acc]).

http_p_request(Method, Url, Body) ->
    http_p_request(Method, Url, Body, "application/json").
http_p_request(Method, Url, Doc, ContentType) ->
    case http:request(Method, {Url, [], ContentType, Doc}, [], []) of
        {ok, {_Status, _Header, Body}} ->
            Body;
        {error, Reason} ->
            {error, Reason}
    end.

http_g_request(Url) ->
    case http:request(Url) of
        {ok, {_Status, _Header, Body}} ->
            Body;
        {error, Reason} ->
            {error, Reason}
    end.
http_d_request(Url) ->
    case http:request(delete, {Url, []}, [], []) of
        {ok, {_Status, _Header, Body}} ->
            Body;
        {error, Reason} ->
            {error, Reason}
    end.

handle_reply(Reply) ->
    case Reply of
        {error, Reason} ->
            {error, Reason};
        R ->
            case rfc4627:decode(R) of
                {ok, Json, _Raw} ->
                    {ok, Json};
                {error, Reason} ->
                    {error, Reason}
            end
    end.

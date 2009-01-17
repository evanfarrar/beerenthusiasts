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

-ifndef(config_inc).
-define(config_inc, ok).

-define (COUCHDB_RECIPES_DB_NAME, "recipes").
-define (COUCHDB_COMMENTS_DB_NAME, "comments").
-define (COUCHDB_SERVER, "localhost").
-define (COUCHDB_PORT, "5984").

-record (users, {username, email_address, password}).

-endif.

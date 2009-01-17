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

-module (user_profile_utils).
-include ("wf.inc").
-include ("config.inc").
-export ([save_profile/7]).

save_profile (Username, Name, Address, City, State, Zip, Bio) ->
    JSON = {obj,
            [{name, Name},
             {address, Address},
             {city, City},
             {state, State},
             {zip, Zip},
             {bio, Bio}]}, 
    couchdb_utils:doc_create (?COUCHDB_PROFILES_DB_NAME, Username, JSON).

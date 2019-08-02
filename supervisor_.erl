%%%-------------------------------------------------------------------
%%% @author mhabib
%%% @copyright (C) 2019
%%%-------------------------------------------------------------------
-module(supervisor_).
-behavior(supervisor).
-export([start_link/0, init/1, stop/0]).

%%------------API------------%%
stop()->
	case whereis(local) of
		undefined -> ok;
		SPid -> exit(SPid, shutdown)
	end.


%%----Supervisor callbacks----%%
start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% supervises 3 servers
init([]) ->
	%% If more than 3 restarts occur in the last 10 seconds, the 
	%% supervisor terminates all the child processes and then itself. 
	SupFlags = {one_for_one, 3, 10},
	Server1 = {server1,{server_, start_link, [server1]}, permanent, 2000, worker, [server_]},
	Server2 = {server2,{server_, start_link, [server2]}, permanent, 2000, worker, [server_]},
	Server3 = {server3,{server_, start_link, [server3]}, permanent, 2000, worker, [server_]},
	{ok,{SupFlags, [Server1, Server2, Server3]}}.



%%%-------------------------------------------------------------------
%%% @author mhabib
%%% @copyright (C) 2019
%%%-------------------------------------------------------------------
-module(server_).
-behavior(gen_server).
-export([start_link/1, init/1, handle_call/3, handle_cast/2,
         handle_info/2, terminate/2, code_change/3]).

		 
%%------------API------------%%
start_link(Name) ->
	gen_server:start_link({local, Name}, ?MODULE, [], []).

	
%%----GenServer callbacks----%%
init([]) ->
	Counter = counters:new(1, []),
	{ok, Counter}.

%% returns the number of running functions on the server
handle_call(numberOfRunningFunctions, _From, Counter) ->
	Reply = counters:get(Counter, 1),
	{reply, Reply, Counter}.

%% runs (spawns) a given function on the server 
%% and sends the result to the client's Pid.
handle_cast({Pid, Fun, MsgRef}, Counter) ->
	spawn_link(fun()->run_fun(Pid, Fun, MsgRef, Counter) end),
	{noreply, Counter}.

handle_info (_Info, State) 			-> 
	{noreply, State}.
terminate (_Reason, _State) 		-> 
	ok.
code_change (_OldVsn, State, _Extra)-> 
	{ok, State}.


%%-------Aux Functions-------%%
run_fun(Pid, Fun, MsgRef, Counter) ->
	counters:add(Counter, 1, 1),
	Result = Fun(),
	Pid ! {Result, MsgRef},
	counters:sub(Counter, 1, 1).


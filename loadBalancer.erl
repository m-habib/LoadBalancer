%%%-------------------------------------------------------------------
%%% @author mhabib
%%% @copyright (C) 2019
%%%-------------------------------------------------------------------
-module(loadBalancer).
-export([startServers/0, stopServers/0,
		calcOnServer/3, numberOfRunningFunctions/1]).

		
%%------------API------------%%
%% Starts three servers and their supervisor.
startServers() ->
	supervisor_:start_link().

%% Stops the servers and the supervisor.
stopServers()  ->
	supervisor_:stop().

%% Returns the number of running functions on server 
%% number <Server_num>, while Server_num is in the 
%% range of [1, 3].
numberOfRunningFunctions(Server_num) ->
	Server_name = cast_to_name(Server_num),
	gen_server:call(Server_name, numberOfRunningFunctions).

%% Runs the function Fun on one of the servers. The server  
%% sends the result to PID as a message with MsgRef in the
%% following format: {Result, MsgRef}.
calcOnServer(PID, Fun, MsgRef) ->
	Min_server = getMinServer(),
	gen_server:cast(Min_server, {PID, Fun, MsgRef}),
	ok.

	
%%---------Aux Functions---------%%

%% returns the server with the min functions running
%% at the moment.
getMinServer()					->
	getMinServer([1,2,3],1).
getMinServer([], Min)			->
	cast_to_name(Min);
getMinServer([H|T], Curr_min)	->
	H_num   = numberOfRunningFunctions(H),
	Min_num = numberOfRunningFunctions(Curr_min),
	case H_num < Min_num of
		true -> getMinServer(T, H);
		false -> getMinServer(T, Curr_min)
	end.

%% casts server number to server name.
cast_to_name(Server_num) ->
	case Server_num of
		1 -> server1;
		2 -> server2;
		3 -> server3
	end.
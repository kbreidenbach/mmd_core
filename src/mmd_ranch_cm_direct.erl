-module(mmd_ranch_cm_direct).
-export([start_link/4, init/4]).

-export([loop/3]).

-include("mmd.hrl").
-define(SOCK_TIMEOUT,30*1000).

start_link(ListenerPid, Socket, Transport, Opts) ->
    Name = p6str:full_remote_sock_bin(Socket),
    Pid = spawn_link(?MODULE, init, [ListenerPid, Socket, Transport, [Name|Opts]]),
    ?ldebug("Received connection from: ~s, ~p",[Name,Socket]),
    {ok, Pid}.

init(ListenerPid, Socket, Transport, [Name|_Opts]) ->
    ok = ranch:accept_ack(ListenerPid),
    Transport:setopts(Socket,[{packet,4}]),
    loop(Socket, Name, Transport).

loop(Socket, Name, Transport) ->
    case Transport:recv(Socket, 0, ?SOCK_TIMEOUT) of
        {ok, Data} ->
            case erlang:binary_to_term(Data) of
                {msg,To,From,Msg} ->
                    To ! {mmd,From,Msg};
                {call,To,From,Msg} ->
                    gen_server:call(To,{mmd,From,Msg})
            end,
            Transport:send(Socket,<<>>),
            ?MODULE:loop(Socket, Name, Transport);
        {error,timeout} ->
            ?ldebug("Shutting down: ~s due to ~p seconds of inactivity",
                    [Name,?SOCK_TIMEOUT/1000]),
            ok = Transport:close(Socket);
        {error,closed} ->
            ?ldebug("Client closed socket: ~s",[Name]),
            ok;
        Reason ->
            ?lerr("Closing socket: ~p, due to: ~p",[Name,Reason]),
            ok = Transport:close(Socket)
    end.
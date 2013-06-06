-module(mmd_cowboy_download).

%% used to allow a page to bounce content off the webserver to generate a download (basically, save a local file)

-include("mmd_cowboy_common.hrl").

-export([init/3, handle/2, terminate/3]).

-behaviour(cowboy_http_handler).

init({_Proto,http}, Req, Cfg) ->
    {ok,Req,Cfg}.

terminate(_Reason, _Req,_State) -> ok.


handle(Req,Cfg) ->
    {Path,_} = cowboy_req:path(Req),
    {ok, Data,Req2} = cowboy_http_req:body(Req),     
%    [{_, Text}] = cowboy_http:x_www_form_urlencoded(Data, fun(Bin) -> URLDecFun(Bin, URLDecArg) end),
%    io:fwrite("In handle,Text=~p",[Text]),    
    Headers = [{<<"Content-Type">>,mimetypes:filename(Path)}],
    {ok,NewReply} = cowboy_http_req:reply(200,Headers,Data,Req2),
    
    {ok,NewReply,Cfg}.
    

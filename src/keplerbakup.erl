%%% cd ("Z:/Google Drive/Codigos/ProcessamentoParalelo/TrabII").

-module(keplerbakup).
-export([discovery/0, loop/2, generate/2, oxygen/2, hydrogen/2,makeWater/3]).

loop(HydrogenList, OxygenList) ->

    %% Define o intervalo de tempo entre o surgimento
    %% de novas moleculas em milisegundos (minimo,máximo)
    timer:sleep(crypto:rand_uniform(1000,1001)),

    Generator = spawn(kepler,generate,[HydrogenList,OxygenList]),
    Generator ! {crypto:rand_uniform(1,3)}.


generate(HydrogenList,OxygenList) ->
    receive
        {1} ->
            [spawn(kepler,oxygen,[HydrogenList,OxygenList])];

        {2} ->
            [spawn(kepler,hydrogen,[HydrogenList,OxygenList])]
    end.

oxygen(HydrogenList,OxygenList) ->
    Pid = self(),
    io:format("Oxigênio ~p foi gerado !~n",[self()]),
    timer:sleep(crypto:rand_uniform(1000,1001)),
    NewOxygenList = OxygenList ++ [Pid],
    loop(HydrogenList,NewOxygenList).
    

hydrogen(HydrogenList,OxygenList) ->
    Pid = self(),
    io:format("Hidrogênio ~p foi gerado !~n",[self()]),
    timer:sleep(crypto:rand_uniform(1000,1001)),
    NewHydrogenList = HydrogenList ++ [Pid],

    Length = lists:flatlength(NewHydrogenList),
    Lenght2 = lists:flatlength(OxygenList),

    if
        Length >= 2  ->
            if
                Lenght2 >=1 ->
                    H1 = lists:sublist(NewHydrogenList,1,1),
                    H2 = lists:sublist(NewHydrogenList,2,2),
                    O = lists:sublist(OxygenList,1,1),

                    Temp = lists:droplast(NewHydrogenList),
                    CleanHydrogenList = lists:droplast(Temp),
                    Temp2 = lists:reverse(OxygenList),
                    Temp3 = lists:droplast(Temp2),
                    CleanOxygenList = lists:reverse(Temp3),

                    spawn(kepler,makeWater,[H1,H2,O]),

                    loop(CleanHydrogenList,CleanOxygenList);

                true ->
                    loop(NewHydrogenList,OxygenList)
            end;
        true ->
            loop(NewHydrogenList,OxygenList)
    end.

makeWater(H1,H2,O) ->
    io:format("Os Hidrogênios ~p e ~p ~n criaram agua junto do Oxigênio ~p~n",[[H1],[H2],[O]]).

discovery() ->
    io:format("Kepler-20PB foi descorberto!~n",[]),
    HydrogenList = [],OxygenList = [],
    spawn(kepler,loop,[HydrogenList,OxygenList]).
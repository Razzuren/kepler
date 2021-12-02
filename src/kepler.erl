%%% cd ("Z:/Google Drive/Codigos/ProcessamentoParalelo/TrabII").

-module(kepler).
-export([discovery/0, loop/1, generate/1, oxygen/1, hydrogen/1, water/2]).

%%Loop principal
loop(WaterPid) ->

    %% Define o intervalo de tempo entre o surgimento
    %% de novas moléculas em milisegundos (minimo,máximo)
    timer:sleep(crypto:rand_uniform(1000,10001)),

    Generator = spawn(kepler,generate,[WaterPid]),
    Generator ! {crypto:rand_uniform(1,3)}.

%%Função que gera aleatoriamente
%% moléculas de Oxigênio ou Hidrogênio
generate(WaterPid) ->
    receive
        {1} ->
            [spawn(kepler,oxygen,[WaterPid])];

        {2} ->
            [spawn(kepler,hydrogen,[WaterPid])]
    end.

%%Função Oxigênio
oxygen(WaterPid) ->
    Pid = self(),
    io:format("Oxigênio ~p foi gerado !~n~n",[self()]),
    loop(WaterPid),
    timer:sleep(crypto:rand_uniform(10000,30001)),
    WaterPid ! {Pid,oxygen}.

%%Função Hidrogênio
hydrogen(WaterPid) ->
    Pid = self(),
    io:format("Hidrogênio ~p foi gerado !~n~n",[self()]),
    loop(WaterPid),
    timer:sleep(crypto:rand_uniform(10000,30001)),
    WaterPid ! {Pid,hydrogen}.

%%Função que combina as moléculas
water(HydrogenList,OxygenList) ->

    Length = lists:flatlength(HydrogenList),
    Lenght2 = lists:flatlength(OxygenList),

    if
        %%Se há dois higrogênios prontos para reagir
        Length >= 2  ->

            if
                %%Se há ao menos 1 oxigênio para reagir
                Lenght2 >=1 ->

                    %%Moléculas que irão Reagir
                    H1 = lists:sublist(HydrogenList,1,1),
                    H2 = lists:sublist(HydrogenList,2,1),
                    O = lists:sublist(OxygenList,1,1),

                    %%Remove as moléculas de suas listas
                    TempHydrogen = lists:droplast(HydrogenList),
                    CleanHydrogenList = lists:droplast(TempHydrogen),
                    CleanOxygenList = lists:droplast(OxygenList),

                    io:format("Os Hidrogênios ~p e ~p ~n reagiram com Oxigênio ~p gerando água.~n~n",[[H1],[H2],[O]]),

                    %%Loop da Geração de Água
                    water(CleanHydrogenList,CleanOxygenList);

                true ->
                    io:format("~n",[])
            end;
        true ->
            io:format("~n",[])

    end,

    receive
        {Element,oxygen}->
            Temp = OxygenList ++ [Element],
            io:format("Oxigênios prontos para reagir ~p~n~n",[Temp]),
            water(HydrogenList,Temp);

        {Element,hydrogen}->
            Temp = HydrogenList ++ [Element],
            io:format("Hidrogênios prontos para reagir ~p~n~n",[Temp]),
            water(Temp,OxygenList)
    end.

%%Função Inicial
discovery() ->
    io:format("Kepler-20PB foi descorberto!~n",[]),
    HydrogenList = [],OxygenList = [],
    WaterPid = spawn(kepler,water,[HydrogenList,OxygenList]),
    spawn(kepler,loop,[WaterPid]).

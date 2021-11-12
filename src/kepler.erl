%%% cd ("Z:/Google Drive/Codigos/ProcessamentoParalelo/TrabII").

-module(kepler).
-export([discovery/0,loop/1,generate/0,oxygen/0,hydrogen/0]).

loop(Generator) ->

  %% Define o intervalo de tempo entre o surgimento
  %% de novas moleculas em milisegundos (minimo,máximo)
  timer:sleep(crypto:rand_uniform(1000,5000)),

  %%io:format("Loop~n",[]),
  Generator ! {crypto:rand_uniform(1,3)},
  generate().

generate() ->
  receive
    {1} ->
      [spawn(kepler,oxygen,[self()])];

    {2} ->
      [spawn(kepler,hydrogen,[self()])]
  end,
  loop(self()).

oxygen() ->
  io:format("Oxygen!~p~n",[self()]).

hydrogen() ->
  io:format("Hydrogen!~p~n",[self()]).

discovery() ->
  io:format("Kepler-20PB foi descorberto!~n",[]),
  O_List = [],
  Generator = spawn(kepler,generate,[]),
  spawn(kepler,loop,[Generator]).


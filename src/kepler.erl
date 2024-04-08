-module(planet).
-export([start_simulation/0, main_loop/1, generate_molecule/1, oxygen/1, hydrogen/1, combine_molecules/2]).

% Start the planet simulation
start_simulation() ->
    HydrogenList = [],
    OxygenList = [],
    WaterPid = spawn(planet, combine_molecules, [HydrogenList, OxygenList]),
    spawn(planet, main_loop, [WaterPid]).

% Main loop for the planet simulation
main_loop(WaterPid) ->
    % Define the time interval between the emergence of new molecules in milliseconds (minimum, maximum)
    timer:sleep(crypto:rand_uniform(1000, 10001)),
    Generator = spawn(planet, generate_molecule, [WaterPid]),
    Generator ! {crypto:rand_uniform(1, 3)},
    main_loop(WaterPid).

% Function that generates molecules randomly
generate_molecule(WaterPid) ->
    receive
        {1} ->
            spawn(planet, oxygen, [WaterPid]);

        {2} ->
            spawn(planet, hydrogen, [WaterPid])
    end.

% Function representing oxygen molecule
oxygen(WaterPid) ->
    Pid = self(),
    io:format("Oxygen molecule ~p was generated!~n~n", [Pid]),
    main_loop(WaterPid),
    timer:sleep(crypto:rand_uniform(10000, 30001)),
    WaterPid ! {Pid, oxygen}.

% Function representing hydrogen molecule
hydrogen(WaterPid) ->
    Pid = self(),
    io:format("Hydrogen molecule ~p was generated!~n~n", [Pid]),
    main_loop(WaterPid),
    timer:sleep(crypto:rand_uniform(10000, 30001)),
    WaterPid ! {Pid, hydrogen}.

% Function that combines molecules to form water
combine_molecules(HydrogenList, OxygenList) ->
    case {length(HydrogenList), length(OxygenList)} of
        {Length, _} when Length >= 2 ->
            case length(OxygenList) of
                Length2 when Length2 >= 1 ->
                    H1 = hd(HydrogenList),
                    H2 = hd(tl(HydrogenList)),
                    O = hd(OxygenList),
                    TempHydrogen = tl(tl(HydrogenList)),
                    TempOxygen = tl(OxygenList),
                    io:format("Hydrogen molecules ~p and ~p reacted with Oxygen molecule ~p, producing water.~n~n", [H1, H2, O]),
                    combine_molecules(TempHydrogen, TempOxygen);
                _ ->
                    ok
            end;
        _ ->
            ok
    end,
    receive
        {Element, oxygen} ->
            Temp = OxygenList ++ [Element],
            io:format("Oxygen molecules ready to react: ~p~n~n", [Temp]),
            combine_molecules(HydrogenList, Temp);
        {Element, hydrogen} ->
            Temp = HydrogenList ++ [Element],
            io:format("Hydrogen molecules ready to react: ~p~n~n", [Temp]),
            combine_molecules(Temp, OxygenList)
    end.

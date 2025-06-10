:- dynamic(at/2).             % at(Object, Location)
:- dynamic(has/1).            % has(Item)
:- dynamic(game_state/1).     % game_state(State)
:- dynamic(knowledge/1).      % knowledge(Subject)
:- dynamic(story_progress/1). % story_progress(Stage)

init :-
    retractall(at(_, _)),
    retractall(has(_)),
    retractall(game_state(_)),
    retractall(knowledge(_)),
    retractall(story_progress(_)),

    % Anfangszustand setzen
    assertz(at(player, laboratory)),
    assertz(game_state(start)),
    assertz(story_progress(beginning)),

    % Personen platzieren
    assertz(at(marie_curie, laboratory)),
    assertz(at(pierre_curie, laboratory)),
    assertz(at(henri_becquerel, university)),

    % Objekte platzieren
    assertz(at(notebook, home)),
    assertz(at(electroscope, storage)),
    assertz(at(pitchblende_sample, storage)),
    assertz(at(money, directors_office)),

    % Starttext ausgeben
    nl, nl, nl, 
    write('Marie Curie: A Radiant Adventure'), nl,
    write('================================'), nl, nl,
    write('Paris, French Republic - 1903'), nl,
    write('You are Émilie Dubois, a young physicist and a new intern in Marie Curie\'s laboratory.'), nl, nl,
    look.

commands :-
    nl,
    write('Available Commands:'), nl,
    write('  go_to(place).         - Go to a place'), nl,
    write('  look.                 - Look around'), nl,
    write('  take(objekt).         - Take an object'), nl,
    write('  examine(objekt).      - Examine an object'), nl,
    write('  inventory.            - Show your collected objects'), nl,
    write('  talk_to(person).      - Talk to a person'), nl,
    write('  choose(option).       - Choose an option'), nl,
    write('  help.                 - Show this help'), nl,
    write('  exit_game.            - Exit the game'), nl,
    nl.

% Initiate main game loop
start :-
    init,
    commands,
    loop.

% Main game loop
loop :-
    nl, write('What do you want to do? '),
    read(Command),
    call(Command),
    story_check,
    (game_state(end) -> write('End of the game! Thank you for playing!') ; game_state(exit_game) -> write('Exiting the game. Goodbye!') ; loop).

% Exit the game
exit_game :- assertz(game_state(exit_game)).

% Help command
help :- commands.

% Show inventory command
inventory :-
    write('You have:'), nl,
    print_inventory.

print_inventory :-
    has(X),
    write('  '), write(X), nl,
    fail.
print_inventory :-
    \+ has(_),
    write('  nothing'), nl.
print_inventory.

% Look around: Shows the current location, objects, people, and exits
look :-
    at(player, Place),
    describe(Place), nl,
    write('You see:'), nl,
    write('  Objects:'), nl,
    list_objects(Place),
    write('  People:'), nl,
    list_people(Place),
    write('  Exits:'), nl,
    list_exits(Place),
    nl.

list_objects(Place) :-
    at(X, Place),
    X \= player,
    \+ is_person(X),
    write('    '), write(X), nl,
    fail.
list_objects(_).

list_people(Place) :-
    at(X, Place),
    is_person(X),
    write('    '), write(X), nl,
    fail.
list_people(_).

list_exits(Place) :-
    can_go(Place, Exit),
    write('    '), write(Exit), nl,
    fail.
list_exits(_).

describe(laboratory) :- write('You are in the laboratory of Marie Curie. At first glance, everything seems chaotic.'), nl,
                        write('But if you take a closer look, you see that it is actually neatly organised.'), nl,
                        write('The air is charged with the excitement of scientific discovery.'), nl.
describe(home) :- write('Your are at home, a small, but cozy student apartment.'), nl.
describe(storage) :- write('You are in a storage room, filled with various scientific equipment and samples.'), nl.
describe(palais_de_l_institut_de_france) :- write('You are at the Palais de l\'Institut de France, that accommodates the Académie des sciences,'), nl,
                                            write('a prestigious institution in Paris. You feel a mix of excitement and nervousness as you enter '), nl,
                                            write('this hallowed ground.'), nl.
describe(university) :- write('You are at Sorbonne, a renowned university in Paris, known for its rich history and academic excellence.'), nl,
                        write('You can almost feel the weight of knowledge in the air.'), nl.
describe(directors_office) :- write('You are in the director\'s office of the university. It is a large room, filled with bookshelves and a big desk.'), nl,
                              write('The walls are adorned with portraits of famous scientists and scholars.'), nl.

is_person(marie_curie).
is_person(pierre_curie).
is_person(henri_becquerel).

% go_to command: Moves the player to a different location
go_to(Place) :-
    at(player, Hier),
    \+ can_go(Hier, Place),
    write('You can not go there.'), nl,
    !.
go_to(Place) :-
    ((Place = directors_office), \+ story_progress(steal_money)) ->
        write('You do not have the permisson to enter this room!'), nl,
        !
    ;
    ((Place = university ; Place = storage), \+ knowledge(met_marie)) ->
        write('Try talking to Marie Curie first!'), nl,
        !
    ;
    ((Place = laboratory), knowledge(evacuated_lab) , \+ knowledge(return_to_research)) ->
        write('The laboratory is contaminated with nitric acid, you can not enter it, without risking your health!'), nl,
        !
    ;
    at(player, Hier),
    retract(at(player, Hier)),
    assertz(at(player, Place)),
    look.

can_go(laboratory, storage).
can_go(laboratory, university).
can_go(laboratory, home).
can_go(home, laboratory).
can_go(storage, laboratory).
can_go(university, laboratory).
can_go(university, directors_office).
can_go(directors_office, university).

% Take command: Takes an object from the current location
take(Objekt) :-
    at(player, Place),
    \+ at(Objekt, Place),
    write('The object does not exist here.'), nl,
    !.

take(Objekt) :-
    at(player, Place),
    at(Objekt, Place),
    is_person(Objekt),
    write('Why are you trying to kidnap that person, you creep?'), nl,
    !.

take(Objekt) :-
    at(player, Place),
    at(Objekt, Place),
    retract(at(Objekt, Place)),
    assertz(has(Objekt)),
    write('You take the '), write(Objekt), write('.'), nl,
    examine(Objekt).

% Examine command: Examines an object
examine(Objekt) :-
    (has(Objekt) ; (at(player, Place), at(Objekt, Place))),
    examine_object(Objekt),
    !.

examine_object(notebook) :-
    write('A small notebook. You record your scientific observations in it.'), nl,
    write('It also includes your plans to go to Paris and your plans to research with Marie Curie.'), nl.

examine_object(electroscope) :-
    write('A delicate glass container, within which two thin gold leaves dangle from a metal rod.'), nl,
    write('It almost looks like a work of art, when the gold leaves spring apart on contact with electric charge.'), nl,
    assertz(knowledge(electroscope)).

examine_object(pitchblende_sample) :-
    write('A mystery black rock, with a seamingly oily surface.'), nl,
    assertz(knowledge(pitchblende_sample)).

examine_object(chemistry_book) :-
    write('An advanced book on chemistry. It contains complex formulas and theories.'), nl,
    write('Studying this book will strengthen your knowledge considerably.'), nl,
    assertz(knowledge(chemistry_book)).
examine_object(money) :-
    write('A stack of money. It is a lot of money, but you do not know if it is enough to clean the laboratory.'), nl,
    assertz(knowledge(directors_office_money)).
examine_object(beakers) :-
    write('A set of beakers, used for mixing and holding liquids in experiments.'), nl,
    assertz(knowledge(beakers)).
examine_object(filter_paper) :-
    write('A roll of filter paper, used for filtering liquids in experiments.'), nl,
    assertz(knowledge(filter_paper)).
examine_object(bunsen_burner) :-
    write('A bunsen burner, used for heating substances in experiments.'), nl,
    assertz(knowledge(bunsen_burner)).
examine_object(_Objekt) :-
    write('You can not examine this.'), nl.

% Talk to command: Talks to a person
talk_to(Person) :-
    at(player, Place),
    at(Person, Place),
    \+ is_person(Person),
    write('Why are you trying to talk to an object?'), nl,
    !.
talk_to(Person) :-
    at(player, Place),
    at(Person, Place),
    is_person(Person),
    write('You approach '), write(Person), write('.'), nl, nl,
    talk_to_text(Person),
    !.
talk_to(_Person) :- write('This person does not exist.'), nl.

talk_to_text(marie_curie) :-
    (
        ((story_progress(research_one_element), knowledge(research_one_element));(story_progress(research_both_elements), knowledge(research_both_elements))) ->
            write('Marie looks at you with a smile: "Lets start right now!"'), nl,
            write('She continues: "We need the new beakers, filter paper and bunsen burners, please go to the storage and get them for me.'), nl,
            write('The rest is already prepared."'), nl,
            assertz(knowledge(knows_to_get_chemistry_equipment))
        ;
        story_progress(return_to_research), knowledge(return_to_research) ->
            write('Marie seems excited: "I am now sure that there are 2 elements within the pitchblende.'), nl,
            write('I hope you are as excited as I am for finally finding out, what is going on within this stones."'), nl,
            assertz(knowledge(heard_knowledge_of_elements_in_pitchblende))
        ;
        story_progress(secure_funding), knowledge(secure_funding) ->
            write('Marie looks at you with a serious expression: "I hope Henri finally knows whether we will get the funding!"'), nl
        ;
        story_progress(went_hospital), knowledge(went_hospital) ->
            write('Marie looks at you with concern: "Do you really want to keep researching after that accident?"'), nl,
            assertz(knowledge(continoue_research_decision))
        ;
        story_progress(cleaned_lab_yourself), knowledge(cleaned_lab_yourself) ->
            write('Marie smiles bittersweet: "You saved us a lot of work, but at what cost? Look at your arms! They are scarred for the rest of your life!'), nl,
            write('Go talk to Pierre, he will help you."'), nl
        ;
        story_progress(evacuated_lab), knowledge(evacuated_lab) ->
            write('Marie looks relieved: "I am glad you are safe. The laboratory is a mess, but we cannot afford to clean it. Go talk to Henri, to talk about the funding!"'), nl,
            assertz(knowledge(need_money))
        ;
        story_progress(measured_radiation), knowledge(measured_radiation) ->
            write('Marie is smiling: "The radiation is stronger than uranium, I have the theory, that there are two other elements in it."'), nl,
            assertz(knowledge(heard_theory))
        ;
        knowledge(met_marie) ->
            write('I think you can do this yourself. You are a talented physicist.'), nl,
            write('If you struggle, try examining everything you have first.'), nl
        ;
            write('Marie Curie, the famous physicist, is standing in front of you. She is busy with her experiments.'), nl,
            write('She notices you and smiles: "Ah, you are the new assistent. Welcome to my laboratory!"'), nl,
            write('She continues: "I am currently working on the properties of pitchblende. It is a fascinating material.'), nl,
            write('To get you started, please measure the radiation of a pitchblende sample with an electroscope. You find everything you need in the storage."'), nl,
            assertz(knowledge(met_marie))
    ).
talk_to_text(pierre_curie) :-
    (
        story_progress(secure_funding), knowledge(secure_funding) ->
            write('Pierre looks at you with a serious expression: "I am on edge, waiting to hear if Henri has an answer about our funding"'), nl
        ;
        story_progress(went_hospital), knowledge(went_hospital) -> 
            write('Pierre looks relieved: "Go talk to Marie, about the next steps."')
        ;
        story_progress(cleaned_lab_yourself), knowledge(cleaned_lab_yourself) ->
            write('Pierre looks at you with concern and compassion: "You did a great job, but now you have to take care of yourself.'), nl,
            write('Use this bandage and you should go to the hospital and get your hands treated right now! I have had some burns in the past,'), nl,
            write('but not to this extent. I am really worried about you."'), nl,
            assertz(knowledge(need_hospital))
        ;
        story_progress(evacuated_lab), knowledge(evacuated_lab) ->
            write('Pierre is smiling, but you see sadness in his eyes: "I am relieved to know you are safe,'), nl,
            write('but the laboratory is in a dreadful state and we cannot afford the time nor the means to clean it. Go talk to Henri, to talk about the funding!"'), nl,
            assertz(knowledge(need_money))
        ;
        write('Pierre Curie, Marie\'s husband and a brilliant physicist, is standing in front of you. He is currently busy with his experiments, you decide to better leave him alone.'), nl
    ).
talk_to_text(henri_becquerel) :-
    (
        story_progress(secure_funding), knowledge(secure_funding) ->
            write('Henri Becquerel is looking happy. "After countless hours of trying to get a funding for a women, I have finally convinced them."'), nl,
            write('He continues: "The expectations are high now, but I am sure you will do great work with Marie and Pierre."'), nl,
            assertz(knowledge(secured_funding))
        ;
        story_progress(evacuated_lab), knowledge(need_money) ->
            write('Henri Becquerel, the discoverer of radioactivity, is standing in front of you. "I might be able to get the funding for the cleanup,'), nl,
            write('but the odds are against us. The Académie des sciences does not like women working in science."'), nl,
            assertz(knowledge(cleanup_funding))
        ;
            write('Henri Becquerel, the discoverer of radioactivity, is standing in front of you. He seems happy: "I heard you are the new laborytory assistent of Marie!'), nl,
            write('Congratulations, she must have seen a bright future in you! I am sure you will learn a lot from her."'), nl
    ).

% Story progression checks
% Action measure radiation of pitchblende sample
story_check :-
    story_progress(beginning),
    knowledge(electroscope),
    knowledge(pitchblende_sample),
    at(player, laboratory),
    !,
    retract(story_progress(beginning)),
    assertz(story_progress(measured_radiation)),
    assertz(knowledge(measured_radiation)),
    nl,
    write('*** ACTION ***'), nl,
    write('You take the electroscope and measure the radiation of the pitchblende sample.'), nl,
    write('The electroscope reacts strongly, indicating that the sample is highly radioactive.'), nl.

% Decision point: Evacuate or clean the laboratory
story_check :-
    story_progress(measured_radiation),
    knowledge(heard_theory),
    !,
    retract(story_progress(measured_radiation)),
    assertz(story_progress(save_lab_decision)),
    nl,
    write('*** DECISION POINT ***'), nl,
    write('Suddenly, a glass jar with solved pitchblende shatters. It is running everywhere!'), nl,
    write('There is not much time to decide, you have to act fast!'), nl,
    write('Use "choose(evacuate)" to evacuate the laboratory or "choose(clean)" to clean it yourself, before it can make more damage.'), nl.

% Action go to hospital
story_check :-
    story_progress(cleaned_lab_yourself),
    knowledge(need_hospital),
    !,
    retract(story_progress(cleaned_lab_yourself)),
    assertz(story_progress(went_hospital)),
    assertz(knowledge(went_hospital)),
    nl,
    write('*** ACTION ***'), nl,
    write('You leave the laboratory and make your way to the nearest hospital. Upon arrival, you are made to wait—several men are treated before you,'), nl,
    write(' though their injuries appear far less severe. The delay allows the remaining acid to eat deeper into your wounds. Eventually, however, '), nl,
    write('a doctor sees you. With calm efficiency, they cleanse the burns and apply fresh bandages. Once treated, you return to the laboratory.'), nl.

% Decision point: Continoue research decision
story_check :-
    story_progress(went_hospital),
    knowledge(continoue_research_decision),
    !,
    retract(story_progress(went_hospital)),
    assertz(story_progress(continoue_research_decision)),
    nl,
    write('*** DECISION POINT ***'), nl,
    write('Use "choose(keep_researching)" to keep researching, knowing the risks or "choose(stop_researching)" to end your journey as a scientist and continoue somewhere else.'), nl.

% Decision point: Cleanup funding
story_check :-
    story_progress(evacuated_lab),
    knowledge(cleanup_funding),
    !,
    retract(story_progress(evacuated_lab)),
    assertz(story_progress(cleanup_funding_decision)),
    nl,
    write('*** DECISION POINT ***'), nl,
    write('You have two remaining options to secure a funding for the cleanup of the laboratory. You can steal the money from the university or'), nl,
    write('you can let Henri Becquerel try to secure a funding from the Académie des sciences. However the odds of getting it are slim.'), nl,
    write('Use "choose(steal_money)" to steal the money, knowing the risks or "choose(secure_funding)" to let Henri Becquerel try to get the funding.'), nl.

% End-Action steal money
story_check :-
    story_progress(steal_money),
    knowledge(directors_office_money),
    at(player, university),
    !,
    write('*** ACTION ***'), nl,
    write('You dart across the lab, clutching the money, and head for the university’s back exit. Just as you’re almost free, your foot hits a tiny pebble on the threshold.'), nl, 
    write('Before you can steady yourself, you’re tumbling forward—face into a cold, muddy puddle. The impact knocks the wind out of you and darkness closes in.'), nl, 
    write('You never have a chance to call for help. Some say it was karma catching up to you.'), nl, nl,
    write('After the incident, Marie and Pierre lose their funding. Without support, they never get to unlock the real secrets hidden in the pitchblende.'), nl, nl,
    assertz(game_state(end)).

% Action secured funding
story_check :-
    story_progress(secure_funding),
    knowledge(secured_funding),
    !,
    retract(story_progress(secure_funding)),
    assertz(story_progress(return_to_research)),
    assertz(knowledge(return_to_research)),

    retract(at(player, _)),
    assertz(at(player, laboratory)),
    retract(at(marie_curie, _)),
    retract(at(pierre_curie, _)),
    assertz(at(marie_curie, laboratory)),
    assertz(at(pierre_curie, laboratory)),

    assertz(at(beakers, storage)),
    assertz(at(filter_paper, storage)),
    assertz(at(bunsen_burner, storage)),
    nl,
    write('*** ACTION ***'), nl,
    write('You can feel the relief in Marie and Pierre and luckily, the laboratory could be cleaned within the next day.'), nl,
    write('You return to a seemingly unchanged laboratory, but you have now become a accepted member of the team.'), nl,
    look.

% Decision point: Research one or both elements
story_check :-
    story_progress(return_to_research),
    knowledge(heard_knowledge_of_elements_in_pitchblende),
    !,
    retract(story_progress(return_to_research)),
    assertz(story_progress(heard_knowledge_of_elements_in_pitchblende)),
    nl,
    write('*** DECISION POINT ***'), nl,
    write('Marie continues: "However this leaves us with a choice: Either we focus on one element or we try to isolate both at the same time."'), nl,
    write('Use "choose(research_one)" to go the save route and isolate one element or "choose(research_both)" to try to isolate both elements'), nl.

% End-Action: Research one element
story_check :-
    story_progress(research_one_element),
    knowledge(research_one_element),
    knowledge(knows_to_get_chemistry_equipment),
    knowledge(beakers),
    knowledge(filter_paper),
    knowledge(bunsen_burner),
    at(player,laboratory),
    !,
    retract(story_progress(research_one_element)),
    assertz(story_progress(researched_one_element)),
    assertz(knowledge(researched_one_element)),
    nl,
    write('*** ACTION ***'), nl,
    write('Marie already prepared a lot of pitchblende and nitric acid. Containers are stacked everywhere around the laboratory.'), nl,
    write('She starts by crumbling a small portion of the pitchblende and then solving it with nitric acid over the bunsen burner.'), nl,
    write('Some parts however, remain unsolved. After filtering out the unsolved parts, she puts them in a beaker. Then she repeats that.'), nl,
    write('After filtering out enough unsolved parts, she pours fresh nitric acid over it to solve further and further.'), nl,
    write('After weeks of filtering, she finally has it in a good enough concentration to nearly proof it is a new element.'), nl,
    write('To honor her suppressed home country Poland, she names it "Polonium".'), nl, nl,
    write('Five days later Henri Becquerel presents the findings to the Académie des sciences and in 1903 Marie, Pierre and Henri receive '),nl,
    write('the nobel prize for physics for isolating the new element.'), nl,
    assertz(game_state(end)).

% Decision-Point: Make safety measures
story_check :-
    story_progress(research_both_elements),
    knowledge(research_both_elements),
    knowledge(knows_to_get_chemistry_equipment),
    knowledge(beakers),
    knowledge(filter_paper),
    knowledge(bunsen_burner),
    at(player,laboratory),
    !,
    retract(story_progress(research_both_elements)),
    assertz(story_progress(make_safety_measures_decision)),
    assertz(knowledge(make_safety_measures_decision)),
    nl,
    write('*** DECISION POINT ***'), nl,
    write('Use "choose(make_safety_measures)" to make the reaction slower but safer or "choose(make_fast)" to make the reaction faster,'), nl,
    write('but there is more risk to it.').

% Default story check
story_check.

% Options of story-progression
% Chose evacuate
choose(Option) :-
    story_progress(save_lab_decision),
    Option = evacuate,
    !,
    retract(story_progress(save_lab_decision)),
    assertz(story_progress(evacuated_lab)),
    assertz(knowledge(evacuated_lab)),
    
    % Move the player to the university
    retract(at(player, _)),
    assertz(at(player, university)),

    % Move Marie and Pierre to the university
    retract(at(marie_curie, _)),
    retract(at(pierre_curie, _)),
    assertz(at(marie_curie, university)),
    assertz(at(pierre_curie, university)),
    
    % Story-Fortschritt
    nl,
    write('*** ACTION ***'), nl,
    write('You chose to evacuate the laboratoy. Luckily nobody was harmed, but now the laboratory full of radioactive waste.'), nl,
    write('The university of sorbonne was so kind to give everyone shelter, while you decide, what should happen next.'), nl,
    nl,
    look.

% Chose clean
choose(Option) :-
    story_progress(save_lab_decision),
    Option = clean,
    !,
    retract(story_progress(save_lab_decision)),
    assertz(story_progress(cleaned_lab_yourself)),
    assertz(knowledge(cleaned_lab_yourself)),
    
    % Story-Fortschritt
    nl,
    write('*** ACTION ***'), nl,
    write('You chose to clean it yourself before more damage arises. You quickly take a towel and start to clean it.'), nl,
    write('But soon the concentrated nitric acid starts to burn your skin. You finish the cleanup successfully,'), nl,
    write('but at what cost? Your hands have severe burning marks and are radioactively contaminated.'), nl,
    nl.

% Steal or secure funding decision
% Choose steal_money
choose(Option) :-
    story_progress(cleanup_funding_decision),
    Option = steal_money,
    !,
    retract(story_progress(cleanup_funding_decision)),
    assertz(story_progress(steal_money)),
    assertz(knowledge(steal_money)),

    retract(at(player, _)),
    assertz(at(player, directors_office)),
    
    % Story-Fortschritt
    nl,
    write('*** ACTION ***'), nl,
    write('You chose to steal the money from the university. During the night, you sneak successfully into the directors office.'), nl,
    write('It was a hard time breaking in, but now you only have to take it.'), nl,
    nl.

% Chose secure_funding
choose(Option) :-
    story_progress(cleanup_funding_decision),
    Option = secure_funding,
    !,
    retract(story_progress(cleanup_funding_decision)),
    assertz(story_progress(secure_funding)),
    assertz(knowledge(secure_funding)),

    % Story-Fortschritt
    nl,
    write('*** ACTION ***'), nl,
    write('You chose to let Henri Becquerel try to secure the funding from the Académie des sciences.'), nl,
    write('He is a well-respected scientist, but the odds are against you.'), nl,
    write('Days go by and nothing seems to happen, but suddenly Henri invites you, to tell you an important message.'), nl, nl.

% Continoue research decision
% Choose keep_researching
choose(Option) :-
    story_progress(continoue_research_decision),
    Option = keep_researching,
    !,
    retract(story_progress(continoue_research_decision)),
    assertz(story_progress(return_to_research)),
    assertz(knowledge(return_to_research)),

    assertz(at(beakers, storage)),
    assertz(at(filter_paper, storage)),
    assertz(at(bunsen_burner, storage)),

    % Story-Fortschritt
    nl,
    write('*** ACTION ***'), nl,
    write('You chose to keep researching, knowing the risks. Marie Curie is happy about your decision and you start to work together.'), nl,
    write('You are now part of the team and you will help her to discover the secrets of pitchblende.'), nl, nl.

% Choose stop_researching
choose(Option) :-
    story_progress(continoue_research_decision),
    Option = stop_researching,
    !,
    retract(story_progress(continoue_research_decision)),
    assertz(story_progress(end_research)),
    assertz(knowledge(end_research)),
    assertz(game_state(end)),

    % Story-Fortschritt
    nl,
    write('*** ACTION ***'), nl,
    write('You chose not going to take the risk of destroying your body for science. Marie Curie helps you to get'), nl,
    write('a good job, but for the rest of your life, you feel like you missed something. Marie Curie continoues her research'), nl,
    write('and reaches the achivement of getting a nobel price in 1903 for extracting the new elements Polonium and Radium from pitchblende.'), nl, nl,
    assertz(game_state(end)).

% One or both elements decision
% Choose research_one
choose(Option) :-
    story_progress(heard_knowledge_of_elements_in_pitchblende),
    Option = research_one,
    !,
    retract(story_progress(heard_knowledge_of_elements_in_pitchblende)),
    assertz(story_progress(research_one_element)),
    assertz(knowledge(research_one_element)),

    % Story-Fortschritt
    nl,
    write('*** ACTION ***'), nl,
    write('You chose to focus on isolating one element. Marie Curie is happy about your decision and you start to work together.'), nl, nl.

% Choose research_both
choose(Option) :-
    story_progress(heard_knowledge_of_elements_in_pitchblende),
    Option = research_both,
    !,
    retract(story_progress(heard_knowledge_of_elements_in_pitchblende)),
    assertz(story_progress(research_both_elements)),
    assertz(knowledge(research_both_elements)),

    % Story-Fortschritt
    nl,
    write('*** ACTION ***'), nl,
    write('You chose to try to isolate both elements. Marie Curie is excited about your decision and you start to work together.'), nl, nl.

% Choose make safety measures
choose(Option) :-
    story_progress(make_safety_measures_decision),
    Option = make_safety_measures,
    !,
    retract(story_progress(make_safety_measures_decision)),
    assertz(story_progress(make_safety_measures)),
    assertz(knowledge(make_safety_measures)),

    nl,
    write('*** ACTION ***'), nl,
    write('Marie slips on her gloves, masks up and checks if every tube is leakproof.'), nl,
    write('Then she sparks the Bunsen burner beneath the fume hood. She dumps crushed pitchblende into a beaker,'),nl,
    write('pours in nitric acid, and stirs until the dark ore dissolves. Using filter paper, she separates the waste from the yellow solution and boils'),nl,
    write('it down until tiny Polonium crystals shimmer at the bottom. Finally, she adds barium salts to isolate the Radium. She repeats this'), nl,
    write('process for weeks, until she has enough of both elements, to nearly prove their existance.'), nl, nl,
    write('To honor her suppressed home country Poland, she names one of them "Polonium". The other one she calls "Radium", because it glows in the dark.'), nl,
    write('Merely five days later Henri Becquerel presents their findings in front of the Académie des sciences.'), nl,
    write('A few years later in 1903 she, Pierre and Henri receive the nobel prize for physics for isolating the new elements.'), nl,
    assertz(game_state(end)).

% Choose make fast and wothout safety measures
choose(Option) :-
    story_progress(make_safety_measures_decision),
    Option = make_fast,
    !,
    retract(story_progress(make_safety_measures_decision)),
    assertz(story_progress(make_fast)),
    assertz(knowledge(make_fast)),
    nl,
    write('*** ACTION ***'), nl,
    write('Marie sparks the Bunsen burner. She dumps crushed pitchblende into a beaker and pours in nitric acid. However a glass tube shatters'), nl,
    write('and the nitric acid fumes get blown directly into your face. You can not react fast enough and breath in a lot of it.'), nl,
    write('Your lungs start to feel like a fire is burning in them and you can not move, stunned by the pain. Marie grabs you and pulls you out'),nl,
    write('of the danger zone, but it is too late. You have already inhaled a lot of the fumes.'), nl,
    write('You are rushed to the hospital, but the damage is done. You have severe burns in your lungs and you will never be able to work as a physicist again.'), nl,
    write('Marie however continues her research and is successful in isolating the two elements. In 1903 she wins the nobel prize for physics,'), nl,
    write('together with Pierre and Henri.'), nl,
    assertz(game_state(end)).

choose(_) :- write('This is not a valid decision at the moment.'), nl.
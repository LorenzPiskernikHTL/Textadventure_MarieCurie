
# Marie Curie: The Text Adventure  
## A Prolog Text Adventure by Lorenz Piskernik and André Wildberger

### Instructions: Start the Game in GNU Prolog

1. **Install GNU Prolog**  
   Make sure GNU Prolog is installed on your system. You can download it from the official website: [GNU Prolog](http://www.gprolog.org/).

2. **Prepare the Game File**  
   Download the file `textadv_curie_test01.pl` and save it to your computer.

3. **Start GNU Prolog**  
   Open PowerShell and navigate to the directory where the file is saved. Use the command:  
   ```powershell
   cd "Path\to\directory"
   ```
  
4. **Load the Game File**

Load the file into GNU Prolog with following Command:

```prolog
[game.pl].
```

5. **Starting the Game**

Start the Game by typing the following command into your GNU Prolog Console:

```prolog
start.
```

6. **Using Game Commands**

Whilst playing the game you can use various command, e.g.

```prolog
go_to(place).       % Go to a location  
look.               % Look around  
take(object).       % Take an item  
examine(object).    % Examine an item  
inventory.          % Show your collected items  
talk_to(person).    % Talk to a person  
choose(option).     % Choose an option  
help.               % Show available commands  
exit_game.          % Exit the game  
```
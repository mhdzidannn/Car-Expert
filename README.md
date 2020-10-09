# Car Expert Mobile Application
<p align = "center">
    <img src = https://github.com/mhdzidannn/Car-Expert/blob/master/android/app/src/main/res/mipmap-hdpi/login.png?raw=true>
</p>

# Team Members
>>
```
Afnan bin Fader (Leader)
Mohamad Zaidan bin Mohamad Khalil

```

# App Description

•	It's like [carlist.my](https://www.carlist.my/) but the mobile app version

•	We did this app as a freelancing work during the quarantine, as well as a stepping stone for me to learn Flutter

•	Took the two of us from April 2020 until August 2020 to finish the project




# Explanation of Assigned Task
>>
```
•	Speed Accumulator
Each of the pokemon’s character have different HP. If both of the team have less than 100 of speed accumulator, no pokemon can attack. Any team can start to attack if and only if their speed accumulator is 100 or more. Once the pokemon is attack their speed accumulator will reduce by 100 and the opponent speed accumulator reduce by amount of damage multiplier. Previous Pokemon’s health points will retained. On the other hand, both team can casts skills randomly. 
•	Damage Multiplier
The damage multiplier are count in the speed accumulator which will reduce the pokemon HP. These damage are different based on their skill type. If the type skill is more skillful, the damage will affect 2 times to the opponent as example if grass type move hits water, then water damage will double meanwhile if grass type move hits fire, the damage will be halved. But if the type skill is same or normal so the damage will remain the same. As conclusion, fire skill type is the most skillful follow by grass and then water.
•	Skill Accuracy
The skill accuracy will be randomize for each pokemon type. If the random number is between 0 and 70 the skill accuracy will have 30% of missing attacks. If random number below 70 then it will attack.
•	Combat
Two team will play which are player versus computer. This team will divide into team A and team B. Each team have to select 3 characters of pokemon in total so that the battle can start. Different pokemon type have their own stat( Pokemon attack stat, Pokemon defense stat, Pokemon hp, Pokemon speed). Each pokemon will have different four type of skill moves. Battle will ends when one of the team with all six pokemons’ health points reach 0. 
•	GUI
This feature will display all types of pokemon and the player can choose 3 type of pokemon by move the cursor. Then the scene will show the battle between the two type of pokemon chosen. Hp for each pokemon also will display along the battle and automatically change to other type of pokemon when the hp is zero or pokemon fainted. At the different bottom of the scene, it will display what type of pokemon you choose, the skill type and also the result whether win or lose. 
•	Super Computer
Computer will choose pokemon that counter user pokemon. As example if player choose more skillful type than the computer player, when computer player hp become lower than 10, it will automatically change the pokemon skill type into more skillful type than the opponent. 
```
# The Requirement of the Task
>>
```
•	Speed Accumulator
It needs two variable for getting the speed of each specific pokemon. Two variable are made for each team for speed accumulator. When speed accumulator reaches 100 and above, it will proceed to getting the pokemon’s hp and subtract it with the damage from Damage Multiplier. If the pokemon ran out of hp, it would faint and another pokemon is input by user. If all pokemon fainted, the opponent would display as the winner.
•	Damage Multiplier
In this method, there is a variable damage which would count for the damage for the pokemon. In damage, it would get attack and skill power of the pokemon and the defence of the opponent pokemon. It would then proceed on getting type of each pokemon for effective of damage using accessor method. If it is effective, the damage would multiply by 2, and if not effective, would be divided by 2, though if neither damage remains the same. 
•	Skill Accuracy
A variable ‘miss’ is used to generate random integer number from 0 to 100. If miss variable contains integer that is lesser or equal to skill accumulator of the pokemon, the attack would either be very effective or not very effective and an instruction of it would be displayed. Else, the attack would be missed and the pokemon’s HP won’t be affected.
•	Combat
6 chosen pokemon by the user are placed in string array. Then, using accessor method, the stats (Pokemon attack stat, Pokemon defense stat, Pokemon hp, Pokemon speed) of the pokemon are obtained which would be used for other methods in the code. When all pokemon of a team are detected all fainted in the method, the opponent would be the winner.
•	GUI
In the game the keyboard button ‘Z’ is used for choosing aided by cursor as well as going to the next scene. A few classes are used. The first class are for positioning of x and y and its velocity of x and y for GUI. In the class as well, height and width are set for rendering.
The next class, contains the inventory of all each pokemon with the methods to get and set it depending on what pokemon are used from the user and the computer. Media Players are included as well in the game, audio file are input and play during scenes assigned.
•	Super Computer
In this method it is used to get type of user’s pokemon. In the method, for method is used to loop through computer’s inventory to check if computer’s pokemon has fainted and choosing the type of next computer’s pokemon to put into combat. The chosen pokemon is then assigned to a variable and then returned.
```


# The Project Timeline
>>
```
2/11 = Formation of group through github.
17/11 = Task assigned to members given by leader.
18/11 - 5/12 = Each members proceed with coding their own task.
6/12 = Compiling of all coding into github.
7/12 - 8/12 = Combining all codes.
9/12 - 10/11 = Test run the codes and fixing problems that arise.
11/12 = Finalization of GUI
12/12 - 13/12 = Confirming that all codes are running fine and double checking of report.
14/12 = Submission of assignment.
21/12 = Presentation of assignment.
```
# The problems faced in accomplishing this project
>>
```
Problem 1: Difficulty on doing a meeting as everyone is from different college and projects to attend.
Solution: Discuss on Internet platform (Github and Whatsapp) and meeting only when needed.
Problem 2: Could not detect an error in the code.
Solution: Approach and seek help from seniors and friends.
```







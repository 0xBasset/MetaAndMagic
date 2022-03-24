The mechanics of the fight calculator is described in this document.


================================================== Relevant submechanics ==================================================


1. Modifiers

Modifiers modify the effect of attacks on the subject. E.g. modifier of 0.7 = 0.7 x atk dealt to subject

Modifiers are relevant to penetration/resistance interaction, and elements.

---
Pen/Resis Interaction:
If and only if subject has resistance and opponent has no penetration, the pen/resis modifier = 0.5.

Elements:
Elements are arranged in a circular sequence with the preceding element having advantage over the next.

element_chart = ['Water', 'Fire', 'Air', 'Lightning', 'Earth']

The element rule tells that advantageous elements give a modifier of 0.5; disadvantageous elements modifier of 2; same elements modifier of 0

element_rule = {1:2, 4:0.5, 0:0}
---

2. Multiplicative Stacking

For decks with multiple items, modifiers are stacked to avoid the need for item ordering by reducing a deck of modifiers into one stacked modifier; they are also stacked to prevent overpowering of the deck with linear item stacking.

Multiplicative stacking follows the DotA formula of 1 - (1 - resistance_1) * (1 - resistance_2) * ...  (1 - resistance_n) to give an overall resistance

e.g. 70% overall resistance = dmg * 30%

Configuring the formula to M&M context, the stacked modifier is the cumulative multiplication of the modifiers in the deck i.e. mod_1 * mod_2 * mod_3 * ... mod_n = stacked mod. e.g. mod_stacked * dmg = dmg dealt


================================================== End of relevant submechanics ==================================================





========================================================= Fight mechanics =========================================================


1. Retrieval of boss stats and player stats

The player stats are gathered from the initial information of the player's deck. The player's deck includes all tokens put up for fight.

The boss and player stats in their final format should include the attributes:

health
[element]             ----- removed as a separate table for player
physical_damage
physical_penetration
physical_resistance
magical_damage
magical_penetration
magical_resistance

The element information for the players is presented as a separate table

2. Evaluation of boss and player element stats

Elements are arranged in a circular sequence with the preceding element having advantage over the next.

element_chart = ['Water', 'Fire', 'Air', 'Lightning', 'Earth']

The boss's element type is compared against the elements of all tokens in the player's deck.

The comparison tells if the respective player tokens have an elemental advantage, disadvantage, or if same as the boss's. Based on this comparison, the boss and player each yields an element modifier list of equal length, which is the number of tokens in the player deck. The list comprises modifier values that affect the extent of damage dealt to the boss and player deck respectively.

The element modifier affects only magical attacks from the opponent, and not physical attacks.


e.g.

Boss element stats:

| Level  | Name             | element  |
| :----- | :--------------- | :------- |
| 4.0    | Axieom Asmodeus  | Water    |

Player element stats:

| trait_value  | element   |
| :----------- | :-------- |
| TOKEN1       | Fire      |
| TOKEN2       | Air       |
| TOKEN3       | None      |
| TOKEN4       | Water     |
| TOKEN5       | Earth     |


Output:

[Boss modifier applied to all attributes per TOKEN]

(simplified table)
| element_modifier  |
| :---------------- |
| 0.5               |
| 1                 |
| 1                 |
| 0                 |
| 2                 |

(representation of element_modifier flattened to attributes level)
[[0.5, 0.5, 0.5, 0.5, 0.5], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [0, 0, 0, 0, 0], [2, 2, 2, 2, 2, 2]]

[Player modifier applied to all attributes per TOKEN]

| element_modifier  |
| :---------------- |
| 2                 |
| 1                 |
| 1                 |
| 0                 |
| 0.5               |

(representation of element_modifier flattened to attributes level)
[[2, 2, 2, 2, 2], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [0, 0, 0, 0, 0], [0.5, 0.5, 0.5, 0.5, 0.5, 0.5]]


3. Evaluation of boss and player pen/res stats

The boss's pen/res is compared against the pen/res of all tokens in the player's deck.

The comparison is made between a subject's res against the opponent's pen to yield the pen/res modifiers for the subject. The pen/res modifier affects the extent of damage dealt to the boss and player deck respectively.

i.e.

pen/res modifier for boss:

- check boss res
- check pen of tokens in player deck
- for each token, if res == 1 && pen == 0 => modifier = 0.5

pen/res modifier for player deck:

- check res of tokens in player deck
- check boss pen
- for each token, if res == 1 && pen == 0 => modifier = 0.5

The output from this step yields a pen/res modifier for boss and player respectively, of equal lengths, which is the number of tokens in the player deck.

e.g.

Boss pen/res stats:

| Level  | Name         | physical_penetration  | physical_resistance  | magical_penetration  | magical_resistance  |
| :----- | :----------- | :-------------------- | :------------------- | :------------------- | :------------------ |
| 1.0    | Inu Dogemon  | N                     | N                    | N                    | N                   |


Player single token pen/res stats:

| trait_value  | physical_penetration  | physical_resistance  | magical_penetration  | magical_resistance  |
| :----------- | :-------------------- | :------------------- | :------------------- | :------------------ |
| V            | N                     | N                    | N                    | N                   |
| Assassin     | N                     | Y                    | Y                    | N                   |
| Elixir       | N                     | Y                    | N                    | N                   |
| Epic         | Y                     | Y                    | N                    | Y                   |
| Fair         | N                     | N                    | N                    | N                   |


Output:

[Boss modifier]

| physical_modifier  | magical_modifier  |
| :----------------- | :---------------- |
| 1                  | 1                 |
| 1                  | 1                 |
| 1                  | 1                 |
| 1                  | 1                 |
| 1                  | 1                 |

[Player single token modifier]

| physical_modifier  | magical_modifier  |
| :----------------- | :---------------- |
| 1                  | 1                 |
| 0.5                | 1                 |
| 0.5                | 1                 |
| 0.5                | 0.5               |
| 1                  | 1                 |


4. Multiplicative stacking of modifiers (player deck)

For the evaluation of damage dealt to the player deck from boss, the element modifier and pen/res modifier are reduced to a single modifier value through multiplicative stacking.

The modifiers are stacked to avoid the need for item ordering by reducing a deck of modifiers into one stacked modifier; they are also stacked to prevent overpowering of the deck with linear item stacking.

Multiplicative stacking of the modifiers for players deck happens on two levels:

- stacking of modifiers for attributes within each token (output: list of stacked token modifiers, length = size of deck)
- stacking of modifiers for tokens in player deck (output: single num value of stacked deck modifier; used in calculation of player fight outcome)

e.g.

[Stacking of modifiers for attributes within single token]

| trait_value  | physical_modifier  | magical_modifier  |
| :----------- | :----------------- | :---------------- |
| V            | 1                  | 1                 |
| Assassin     | 0.5                | 1                 |
| Elixir       | 0.5                | 1                 |
| Epic         | 0.5                | 0.5               |
| Fair         | 1                  | 1                 |
| :----------- | :----------------- | :---------------- |
| RESULT       | stacked = 0.125    | stacked = 0.5     |

(element stacking example based on L4 boss Axie Asmodeus)
| trait_value  | element_modifier  |
| :----------- | :---------------- |
| V            | 2                 |
| Assassin     | 2                 |
| Elixir       | 2                 |
| Epic         | 2                 |
| Fair         | 2                 |
| :----------- | :---------------- |
| RESULT       | stacked = 32      |


[Subsequent stacking of modifier for deck of 5 tokens]

| trait_value  | physical_modifier  | magical_modifier  |
| :----------- | :----------------- | :---------------- |
| TOKEN1       | stacked = 0.125    | stacked = 0.5     |
| TOKEN2       | stacked = ?        | stacked = ?       |
| TOKEN3       | stacked = ?        | stacked = ?       |
| TOKEN4       | stacked = ?        | stacked = ?       |
| TOKEN5       | stacked = ?        | stacked = ?       |
| :----------- | :----------------- | :---------------- |
| FINAL RESULT | final stacked = _  | final stacked = _ |

(element stacking example based on L4 boss Axie Asmodeus)
| trait_value  | element_modifier   |
| :----------- | :----------------- |
| TOKEN1       | stacked = 32       |
| TOKEN2       | stacked = 1        |
| TOKEN3       | stacked = 1        |
| TOKEN4       | stacked = 0        |
| TOKEN5       | stacked = 0.015625 |
| :----------- | :----------------- |
| FINAL RESULT | final stacked = 0  |


5. Final calculation of fight outcome

Boss outcome:

- dmg to boss (list) = player phy dmg (list) * boss phy modifier (list) + player mag dmg (list) * boss mag modifier (list) * boss element modifier (list)
- total dmg to boss = sum(dmg to boss)
- Leftover boss hp = boss hp - total dmg to boss

Player outcome:

- total dmg to player (num) = boss phy dmg (num) * stacked player phy modifier (num) + boss mag dmg (num) * stacked player mag modifier (num) * stacked player element modifier (num)
- Leftover player hp = sum(player hp) - total dmg to player

e.g.

Assumptions:

- final stacked phy_mod for player = 0.001953125
- final stacked mag_mod for player = 0.007812
- final stacked ele_mod for player = 1

- boss hp = 1000.0
- player total hp = 11800.0

Boss outcome (no stacking involved):

Referencing: dmg to boss (list) = player phy dmg (list) * boss phy modifier (list) + player mag dmg (list) * boss mag modifier (list) * boss element modifier (list)

[PER TOKEN --- player phy dmg (list) * boss phy modifier (list)]

| player_physical_damage  |           | physical_modifier  |            | physical_dmg_dealt  |
| :---------------------- |           | :----------------- |            | :------------------ |
| 0                       |           | 1                  |            | 0                   |
| 1000                    |     *     | 1                  |      =     | 1000                |
| 0                       |           | 1                  |            | 0                   |
| 500                     |           | 1                  |            | 500                 |
| 1000                    |           | 1                  |            | 1000                |
                                                                        | :------------------ |
                                                                        | 2500                |

[PER TOKEN --- player mag dmg (list) * boss mag modifier (list) * boss element modifier (list)]

| player_magical_damage  |             | magical_modifier  |           | element_modifier  |           | magical_dmg_dealt  |
| :--------------------- |             | :---------------- |           | :---------------- |           | :----------------- |
| 0                      |             | 1                 |           | 1                 |           | 0                  |
| 500                    |      *      | 1                 |     *     | 1                 |     =     | 500                |
| 0                      |             | 1                 |           | 1                 |           | 0                  |
| 0                      |             | 1                 |           | 1                 |           | 0                  |
| 1000                   |             | 1                 |           | 1                 |           | 1000               |
                                                                                                       | :----------------- |
                                                                                                       | 1500               |

Leftover boss hp = boss hp - total dmg to boss
                 = 1000.0 - [TOKEN1 DMG] - [TOKEN2 DMG] - ... - [TOKEN_N_DMG]
                 = 1000.0 - [2500 + 1500] - ... - [TOKEN_N_DMG]


Player outcome (stacking is involved):

dmg_to_player = final_stacked_phy_mod * boss_phy_dmg + final_stacked_mag_mod * final_stacked_ele_mod * boss_mag_dmg
              = 0.001953125 * boss_phy_dmg + 0.0078125 * 1 * boss_mag_dmg
              = 001953125 * 2000.0 + 0.0078125 * 1 * 0.0
              = 3.90625

Leftover player hp = sum(player_hp) - dmg_to_player
                   = 11800.0 - 3.90625
                   = 11796.09375


========================================================= End of fight mechanics =========================================================

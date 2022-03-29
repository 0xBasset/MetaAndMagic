// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract HeroesDeck {

    function getTraitsNames(uint256[6] calldata atts) public pure returns(string[6] memory names) {
        names[0] = level(atts[0]);
        names[1] = class(atts[1]);
        names[2] = rank(atts[2]);
        names[3] = rarity(atts[3]);
        names[4] = pet(atts[4]);
        names[5] = item(atts[5]);
    }

    function getTrait(uint256 traitIndex, uint256 traitId) public pure returns(string memory) {
        if (traitIndex == 0) return level(traitId);
        if (traitIndex == 1) return class(traitId);
        if (traitIndex == 2) return rank(traitId);
        if (traitIndex == 3) return rarity(traitId);
        if (traitIndex == 4) return pet(traitId);
        if (traitIndex == 5) return item(traitId);
    }

    function level(uint256 id) public pure returns (string memory) {
        if (id == 1) return "I";
        if (id == 2) return "II";
        if (id == 3) return "III";
        if (id == 4) return "IV";
        if (id == 5) return "V";
        if (id == 6) return "X"; 
    }

    function class(uint256 id) public pure returns (string memory) {
        if (id == 1) return "Warrior";
        if (id == 2) return "Marksman";
        if (id == 3) return "Assassin"; 
        if (id == 4) return "Monk";
        if (id == 5) return "Mage";
        if (id == 6) return "Zombie";
        if (id == 7) return "God";
    }

    function rank(uint256 id) public pure returns (string memory) {
        if (id == 1) return "novice";
        if (id == 2) return "beginner";
        if (id == 3) return "intermediate";
        if (id == 4) return "advanced";
        if (id == 5) return "expert";
        if (id == 6) return "master";
    }

    function rarity(uint256 id) public pure returns (string memory) {
        if (id == 1) return "Common";
        if (id == 2) return "Uncommon";
        if (id == 3) return "Rare";
        if (id == 4) return "Epic";
        if (id == 5) return "Legendary";
        if (id == 6) return "Mythic";
    }

    function pet(uint256 id) public pure returns (string memory) {
        if (id == 1) return  "Fairy";
        if (id == 2) return  "Kitsune";
        if (id == 3) return  "Unicorn";
        if (id == 4) return  "Sphinx";
        if (id == 5) return  "Dragon";
    }

    function item(uint256 id) public pure returns (string memory) {
        if (id == 1)  return "dagger";
        if (id == 2)  return "sword";
        if (id == 3)  return "hammer";
        if (id == 4)  return "spear";
        if (id == 5)  return "mace";
        if (id == 6)  return "staff";
        if (id == 7)  return "force";
        if (id == 8)  return "implosion";
        if (id == 9)  return "explosion";
        if (id == 10) return "antimatter";
        if (id == 11) return "supernova";
        if (id == 12) return "ultimatum";
        if (id == 13) return "potion";
        if (id == 14) return "ether";
        if (id == 15) return "elixir";
        if (id == 16) return "nectar";
        if (id == 17) return "ambrosia";
        if (id == 18) return "cornucopia";
    }

}


contract ItemsDeck {

    function getTraitsNames(uint256[6] calldata atts) public pure returns(string[6] memory names) {
        names[0] = level(atts[0]);
        names[1] = kind(atts[1]);
        names[2] = material(atts[2]);
        names[3] = rarity(atts[3]);
        names[4] = quality(atts[4]);
        names[5] = element(atts[5]);
    }
    
    function level(uint256 id) public pure returns (string memory) {
        if (id == 1) return "I";
        if (id == 2) return "II";
        if (id == 3) return "III";
        if (id == 4) return "IV";
        if (id == 5) return "V";
        if (id == 6) return "X"; 
    }

    function kind(uint256 id) public pure returns (string memory) {
        uint256 class = id % 4;
        if (class == 0) {
            if (id == 1) return "Dagger";
            if (id == 2) return "Sword";
            if (id == 3) return "Hammer";
            if (id == 4) return "Spear";
            if (id == 5) return "Mace";
            if (id == 6) return "Staff"; 
        }

        if (class == 1) {
            if (id == 1) return "Leather";
            if (id == 2) return "Split Mail";
            if (id == 3) return "Chain Mali";
            if (id == 4) return "Sccale Mail";
            if (id == 5) return "Half Plate";
            if (id == 6) return "Full Plate"; 
        }

        if (class == 2) {
            if (id == 1) return "Force";
            if (id == 2) return "Implosion";
            if (id == 3) return "Explosion";
            if (id == 4) return "Antimatter";
            if (id == 5) return "Supernova";
            if (id == 6) return "Ultimatum"; 
        }

        if (class == 3) {
            if (id == 1) return "Potion";
            if (id == 2) return "Ether";
            if (id == 3) return "Elixir";
            if (id == 4) return "Nectar";
            if (id == 5) return "Ambrosia";
            if (id == 6) return "Cornucopia"; 
        }
    }

    function material(uint256 id) public pure returns(string memory) {
        uint256 class = id % 4;

        if (class == 2) {
            if (id == 1) return "Kinectic";
            if (id == 2) return "Potential";
            if (id == 3) return "Electrical";
            if (id == 4) return "Nuclear";
            if (id == 5) return "Gravitational";
            if (id == 6) return "Cosmic"; 
        }

        if (class == 3) {
            if (id == 1) return "New";
            if (id == 2) return "Annum";
            if (id == 3) return "Decade";
            if (id == 4) return "Century";
            if (id == 5) return "Millenium";
            if (id == 6) return "Beginning of Time"; 
        }

        if (id == 1)return "Wood";
        if (id == 2)return "Iron";
        if (id == 3)return "Bronze";
        if (id == 4)return "Silver";
        if (id == 5)return "Gold";
        if (id == 6)return "Mythril";
    }

    function rarity(uint256 id) public pure returns (string memory) {
        if (id == 1) return "Common";
        if (id == 2) return "Uncommon";
        if (id == 3) return "Rare";
        if (id == 4) return "Epic";
        if (id == 5) return "Legendary";
        if (id == 6) return "Mythic";
    }

    function quality(uint256 id) public pure returns (string memory) {
        if (id == 1) return "Normal";
        if (id == 2) return "Good";
        if (id == 3) return "Very Good";
        if (id == 4) return "Fine";
        if (id == 5) return "Superfime";
        if (id == 6) return "Excellent";
    }

    function element(uint256 id) public pure returns (string memory) {
        uint256 class = id % 4;

        if (class == 3) {
            if (id == 1) return "None";
            if (id == 2) return "Weak";
            if (id == 3) return "Mild";
            if (id == 4) return "Regular";
            if (id == 5) return "Strong";
            if (id == 6) return "Potent"; 
        }

        if (id == 0) return "None";
        if (id == 1) return "Water";
        if (id == 2) return "Fire";
        if (id == 3) return "Air";
        if (id == 4) return "Lightining";
        if (id == 5) return "Earth";
    }
}

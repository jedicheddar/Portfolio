function battle(myArmy, opposingArmy) {
  const myArmyLength = myArmy.length;
  const opposingArmyLength = opposingArmy.length;

  // if my army wins
  if (myArmyLength > opposingArmyLength) {
    myArmy = "Opponent retreated";
  }
  else if (myArmyLength < opposingArmyLength) {
    myArmy = "We retreated"
  }
  else {
    const strength = "abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    let myArmyStrength = 0;
    let opposingArmyStrength = 0;
    let myArmyBattles = 0;
    let opposingArmyBattles = 0;
    for (let i=0; i<myArmy.length; i++) {
      myArmyStrength = Number.isNaN(myArmy[i]) ? strength.indexOf(myArmy[i]) : myArmy[i];
      opposingArmyStrength = Number.isNaN(opposingArmy[i]) ? strength.indexOf(opposingArmy[i]) : opposingArmy[i];
      if (myArmyStrength > opposingArmyStrength) {
        myArmyBattles += 1;
      }
      else if (myArmyStrength < opposingArmyStrength) { 
        opposingArmyBattles += 1;
      }
    }
    if (myArmyBattles > opposingArmyBattles) {
      myArmy = "We won";
    }
    else if (myArmyBattles < opposingArmyBattles) {
      myArmy = "We lost";
    }
    else {
      myArmy = "It was a tie";
    }
  }

  return myArmy;
}

console.log(battle("Wizards", "Dragons"));

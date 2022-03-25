// Let's build a smart contract that lets us send a 👋
// to our contract and keep track of the total # of waves.
// This is going to be useful because on your site, you
// might want to keep track of this #! Feel free to change
// this to fit your use case.

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    address owner;

    /*
     * We will be using this below to help generate a random number
     */
    uint256 private seed;

    mapping(address => bool) public Wallets;

    function setWallet(address _wallet, bool b) public {
        Wallets[_wallet] = b;
    }

    function contains(address _wallet) private view returns (bool) {
        // since your function doesn't change the state, you can mark it as view
        return Wallets[_wallet];
    }

    /*
     * A little magic, Google what events are in Solidity!
     */
    event NewWave(address indexed from, uint256 timestamp, string message);

    /*
     * I created a struct here named Wave.
     * A struct is basically a custom datatype where we can customize what we want to hold inside it.
     */
    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

     /*
     * I declare a variable waves that lets me store an array of structs.
     * This is what lets me hold all the waves anyone ever sends to me!
     */
    Wave[] waves;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;


    /*
     * Advantages:
     * If you make your function pure or view, you can call it for
     * example through web3.js without needing a transaction, without
     * any gas cost and without confirmation delay.
     */

    // we also added a totalWaves variable that automatically is
    // initialized to 0. But, this variable is special because it's
    // called a "state variable" and it's cool because it's stored
    // permanently in contract storage.

    constructor() payable {
        owner = msg.sender;
        console.log("Yo yo, I am a contract and I am smart");
        /*
         * Set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function addFriend() public {
        if (msg.sender == owner) {
            return;
        }
        setWallet(msg.sender, true);
    }

    function removeFriend() public {
        if (msg.sender == owner) {
            return;
        }
        setWallet(msg.sender, false);
    }

    function wave(string memory _message) public {
        if (msg.sender == owner || contains(msg.sender)) {
            totalWaves += 1;
            if (msg.sender == owner) {
                console.log("I waved at myself!");
            }
            else {
                console.log("%s is my friend and they have waved!", msg.sender);
            }
            console.log("%s waved w/ message %s", msg.sender, _message);

            /*
            * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
            */
            require(
                lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
                "Wait 15m"
            );

            /*
            * Update the current timestamp we have for the user
            */
            lastWavedAt[msg.sender] = block.timestamp;

            /*
            * This is where I actually store the wave data in the array.
            */
            waves.push(Wave(msg.sender, _message, block.timestamp));

            /*
            * I added some fanciness here, Google it and try to figure out what it is!
            * Let me know what you learn in #general-chill-chat
            */
            emit NewWave(msg.sender, block.timestamp, _message);

            /*
            * Generate a new seed for the next user that sends a wave
            */
            seed = (block.difficulty + block.timestamp + seed) % 100;

            console.log("Random # generated: %d", seed);

            /*
            * Give a 50% chance that the user wins the prize.
            */
            if (seed <= 50) {
                console.log("%s won!", msg.sender);

                /*
                * The same code we had before to send the prize.
                */
                uint256 prizeAmount = 0.0001 ether;
                require(
                    prizeAmount <= address(this).balance,
                    "Trying to withdraw more money than the contract has."
                );
                (bool success, ) = (msg.sender).call{value: prizeAmount}("");
                require(success, "Failed to withdraw money from contract.");
            }
        } else {
            console.log("%s is not a friend!", msg.sender);
        }
        // This is the wallet address of the person who called the function.
    }

     /*
     * I added a function getAllWaves which will return the struct array, waves, to us.
     * This will make it easy to retrieve the waves from our website!
     */
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}

// In the future, we can write functions that only certain
// wallet addresses can hit. For example, we can change this
// function so that only our address is allowed to send a
// wave. Or, maybe have it where only your friends can wave
// at you!

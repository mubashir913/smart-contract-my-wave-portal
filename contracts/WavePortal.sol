// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {

    uint256 totalWaves;
    event NewWave(address indexed from, uint256 timestamp, string message);

    uint256 private seed; // Will be used to generate a random number
    mapping(address => uint256) public lastWavedAt;

    struct Wave {
        address waver;      // The address of the user who waved.
        string message;     // The message the user sent.
        uint256 timestamp;  // The timestamp when the user waved.
    }

    Wave[] waves;

    constructor() payable {
        console.log("WAVE PORTAL SMART CONTRACT");
    }

    function wave(string memory _message) public {
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Wait 15 minutes"
        );

         /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        waves.push(Wave(msg.sender, _message, block.timestamp));

        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %d", seed);

        if (seed <= 20) {
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }

}
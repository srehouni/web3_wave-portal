// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract WavePortal {
    Wave[] waves;
    uint256 totalWaves;
    mapping(address => uint256) wavers;
    address maxWaver;
    uint256 maxWaverWavesCount;
    mapping(address => uint256) public lastWavedAt;

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    event NewWave(address indexed from, uint256 timestamp, string message);

    uint256 private seed;

    constructor() payable {
        console.log("Yo yo, gm y'all");

        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {

        require(lastWavedAt[msg.sender] + 60 seconds < block.timestamp, "Wait 15m");

        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);
        wavers[msg.sender] += 1;

        if (wavers[msg.sender] > maxWaverWavesCount) {
            maxWaver = msg.sender;
            maxWaverWavesCount = wavers[msg.sender];
        }

        waves.push(Wave(msg.sender, _message, block.timestamp));

        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %d", seed);

        if (seed <= 50) {
            uint256 prizeAmount = 0.0001 ether;
            require(prizeAmount <= address(this).balance, "Trying to withdraw more money than the contract has.");

            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getMaxWaverAddress() public view returns (address) {
        console.log("%s waved the most, a total of %d!", maxWaver, maxWaverWavesCount);
        return maxWaver;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import {Game} from "@ds/Game.sol";
import {Actions} from "@ds/actions/Actions.sol";
import {Node, Schema, State} from "@ds/schema/Schema.sol";
import {ItemUtils, ItemConfig} from "@ds/utils/ItemUtils.sol";
import {BuildingUtils, BuildingConfig, Material, Input, Output} from "@ds/utils/BuildingUtils.sol";
import {GoblinsCave} from "../src/GoblinsCave.sol";

using Schema for State;

contract Deployer is Script {
    function setUp() public {}

    function run() public {
        // configure our deployment by fetch environment variables...

        // PLAYER_DEPLOYMENT_KEY is the private key of a ds player
        // session to execute the commands as.
        //
        // When deploying to local testnet instances of the game (localhost)
        // you can leave this as the default well-known-and-totally-insecure
        // development key DO NOT ACTUALLY SET THIS TO A _REAL_ KEY UNLESS YOU
        // KNOW WHAT YOU ARE DOING.
        Game ds = Game(gameAddr);

        // BUILDING_KIND_EXTENSION_ID is the unique identifier for your building
        // kind. Pick any number you like, use a random number generate or
        // choose your favourite number.
        //
        // The only rules for selecting a number are:
        //
        // * it must be between 1 and 9223372036854775807
        // * if someone else has already registered the number, then you can't have it
        //
        // When deploying to local testnet instances of the game (localhost)
        // you can probably leave this as the default of 45342312 as you are
        // unlikely to clash with yourself
        uint64 extensionID = uint64(vm.envUint("BUILDING_KIND_EXTENSION_ID"));

        // connect as the player...
        vm.startBroadcast(playerDeploymentKey);

        // deploy the hammer and hammer factory
        // bytes24 hammerItem = registerHammerItem(ds, extensionID);
        bytes24 goblinCaveFactory = registerGoblinsCave(ds, extensionID);

        // dump deployed ids
        // console2.log("ItemKind", uint256(bytes32(hammerItem)));
        console2.log("BuildingKind", uint256(bytes32(goblinCaveFactory)));

        vm.stopBroadcast();
    }

    // register a new item id
    // function registerHammerItem(Game ds, uint64 extensionID) public returns (bytes24 itemKind) {
    //     return ItemUtils.register(
    //         ds,
    //         ItemConfig({
    //             id: extensionID,
    //             name: "Hammer",
    //             icon: "15-38",
    //             greenGoo: 10, //In combat, Green Goo increases life
    //             blueGoo: 0, //In combat, Blue Goo increases defense
    //             redGoo: 6, //In combat, Red Goo increases attack
    //             stackable: false,
    //             implementation: address(0),
    //             plugin: ""
    //         })
    //     );
    // }

    // register a new
    function registerGoblinsCave(Game ds, uint64 extensionID) public returns (bytes24 buildingKind) {
        // find the base item ids we will use as inputs for our hammer factory
        bytes24 none = 0x0;
        bytes24 glassGreenGoo = ItemUtils.GlassGreenGoo();
        bytes24 beakerBlueGoo = ItemUtils.BeakerBlueGoo();
        bytes24 flaskRedGoo = ItemUtils.FlaskRedGoo();

        // register a new building kind
        return BuildingUtils.register(
            ds,
            BuildingConfig({
                id: extensionID,
                name: "Goblins Cave",
                materials: [
                    Material({quantity: 10, item: glassGreenGoo}), // these are what it costs to construct the factory
                    Material({quantity: 10, item: beakerBlueGoo}),
                    Material({quantity: 10, item: flaskRedGoo}),
                    Material({quantity: 0, item: none})
                ],
                inputs: [
                    Input({quantity: 10, item: glassGreenGoo }), // these are required inputs to get the output
                    Input({quantity: 0, item: none}),
                    Input({quantity: 0, item: none}),
                    Input({quantity: 0, item: none})
                ],
                outputs: [
                    Output({quantity: 0, item: none}) // this is the output that can be crafted given the inputs
                ],
                implementation: address(new GoblinsCave()),
                plugin: vm.readFile("src/GoblinsCave.js")
            })
        );
    }
}

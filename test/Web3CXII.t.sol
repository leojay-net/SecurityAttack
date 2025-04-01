// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {W3CXII} from "../src/Web3CXII.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {Attack} from "./helpers/attack.sol";

contract WEB3CXIITEST is Test {
    W3CXII public w3cxii;

    address user = makeAddr("user");

    function setUp() public {
        deal(msg.sender, 50 ether);
        deal(user, 50 ether);
        vm.prank(msg.sender);
        w3cxii = new W3CXII{value: 1 ether}();
    }

    function test_Deposit() public {
        vm.prank(user);
        w3cxii.deposit{value: 0.5 ether}();

        assertEq(w3cxii.balanceOf(user), 0.5 ether);
        assertEq(address(w3cxii).balance, 1.5 ether);
    }

    function test_DepositRevertWithMax() public {
        deal(address(w3cxii), 0 ether);
        vm.startPrank(user);
        w3cxii.deposit{value: 0.5 ether}();
        w3cxii.deposit{value: 0.5 ether}();
        
        vm.expectRevert("Max deposit exceeded");
        w3cxii.deposit{value: 0.5 ether}();
        vm.stopPrank();
    }

    function test_forceEther() public {
        vm.startPrank(msg.sender);
        Attack attack = new Attack{value: 20 ether}(address(w3cxii));
        vm.stopPrank();   

        assertGe(address(w3cxii).balance, 20 ether);   
    }



    function test_attack() public {
        test_Deposit();
        test_forceEther();

        vm.prank(user);

        w3cxii.withdraw();

        w3cxii.dest();
    }

    function test_attackRevert() public {
        test_Deposit();
        test_forceEther();

        vm.expectRevert("Not dosed");
        vm.prank(user);
        w3cxii.dest();
    }



    function test_DepositRevertWithInvalidAmount() public {
        vm.expectRevert("InvalidAmount");
        vm.prank(user);
        w3cxii.deposit{value: 1 ether}();

    }

    function test_LockedDeposit() public {
        test_forceEther();
        vm.expectRevert("deposit locked");
        vm.prank(user);
        w3cxii.deposit{value: 0.5 ether}();

    }

    function test_WithdrawRevertNoDeposit() public {
        vm.prank(user);
        vm.expectRevert("No deposit");
        w3cxii.withdraw();
    }


    function test_WithdrawWithoutSettingDosed() public {
        vm.startPrank(user);
        w3cxii.deposit{value: 0.5 ether}();
        w3cxii.withdraw();
        assertEq(w3cxii.dosed(), false);
        
        vm.stopPrank();
    }

    function test_WithdrawRevertWithTransferFailed() public {
        deal(address(this), 50 ether);
        vm.startPrank(address(this));
        w3cxii.deposit{value: 0.5 ether}();

        vm.expectRevert("Transfer failed");
        w3cxii.withdraw();
        
        vm.stopPrank();
    }

    

}

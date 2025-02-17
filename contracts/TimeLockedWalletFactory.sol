// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

import "./TimeLockedWallet.sol";

contract TimeLockedWalletFactory {

    mapping(address => address[]) wallets;

    function getWallets(address _user)
        public
        view
        returns(address[] memory)
    {
        return wallets[_user];
    }

    function newTimeLockedWallet(address _owner, uint256 _unlockDate)
        payable
        public
        returns(address payable walletAddress)
    {
        // Create new wallet.
        walletAddress = address(new TimeLockedWallet(msg.sender, _owner, _unlockDate));

        // Add wallet to sender's wallets.
        wallets[msg.sender].push(walletAddress);

        // If owner is the same as sender then add wallet to sender's wallets too.
        if(msg.sender != _owner){
            wallets[_owner].push(walletAddress);
        }

        // Send ether from this transaction to the created contract.
        walletAddress.transfer(msg.value);

        // Emit event.
        emit Created(walletAddress, msg.sender, _owner, now, _unlockDate, msg.value);
    }

    // Prevents accidental sending of ether to the factory
    function () external {
        revert();
    }

    event Created(address walletAddress, address from, address to, uint256 createdAt, uint256 unlockDate, uint256 amount);
}

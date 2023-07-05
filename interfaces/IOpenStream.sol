//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IOpenStream {
    function getTokenBanance() external view returns (uint256);

    function getTokenAddress() external view returns (address);

    function setClaimable(bool _isClaimable) external;

    function calculate(uint256 claimedAt) external view returns (uint256);

    function claim() external;

    function terminate() external;

    function accumulation() external view returns (uint256);

}

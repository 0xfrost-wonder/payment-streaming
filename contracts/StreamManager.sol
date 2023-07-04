//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IStreamManager.sol";
import "../interfaces/IOpenStream.sol";
import "./OpenStream.sol";

contract StreamManager is IStreamManager {
    using SafeERC20 for IERC20;
    
    /**
     * @dev New open stream event
     * @param _payer payer address
     * @param _itself open steam instance address
     */
    event OpenStreamCreated(address _payer, address _itself);
    /**
     * @dev Cancel open stream event
     * @param _payer payer address
     * @param _amount amount of the tokens
     */
    event CancelStream(address _payer, uint256 _amount);

    error InvalidAddress();
    error InvalidValue();

    /// @dev Mapping for addresses of streams instance 
    mapping(address => address) public streams;

    constructor() {}

    /**
     * @dev Payer can create open stream instance with the params paying amounts of USDT or USDC
     * @param _payee payee address
     * @param _token token address; USDC or USDT
     * @param _amount USDC or USDT amount
     * @param _rate monthly rate
     * @param _terminationPeriod termination period
     * @param _cliffPeriod cliff period
     */
    function createOpenStream(
        address _payee,
        address _token,
        uint256 _amount,
        uint256 _rate,
        uint256 _terminationPeriod,
        uint256 _cliffPeriod
    ) external {
        if (_payee == address(0) || _token == address(0)) revert InvalidAddress();
        if (_rate == 0 || _amount == 0 || _terminationPeriod == 0 || _cliffPeriod == 0)
            revert InvalidValue();

        /// @dev create a new open stream instance
        OpenStream openStreamInstance = new OpenStream(
            msg.sender,
            _payee,
            _token,
            _rate,
            _terminationPeriod,
            _cliffPeriod,
            true
        );
        address streamInstance = address(openStreamInstance);
        /// @dev stores the address of the payee, and the address of his flow instance
        streams[_payee] = streamInstance;
        /// @dev when creating an instance, it deposits stable coins(USDC or USDT)
        IERC20(_token).safeTransferFrom(msg.sender, streamInstance, _amount);

        emit OpenStreamCreated(msg.sender, streamInstance);
    }

    /**
     * @dev Payer can cancel open stream instance
     * @param _payee payee address
     */
    function cancelOpenStream(address _payee) external {
        /// @dev address of the open stream instance
        address streamInstance = streams[_payee];
        /// @dev getting the balance of the token USDC or USDT
        uint256 amount = IOpenStream(streamInstance).getTokenBanance();

        if (_payee != address(0) || streamInstance != address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidValue();

        /// @dev change `isClaimable` in OpenStream contract to `false` in order to cancel a stream
        IOpenStream(streamInstance).setClaimable(false);
        /// @dev getting the address of the token USDC or USDT from open stream instance
        address tokenAddress = IOpenStream(streamInstance).getTokenAddress();
        IERC20(tokenAddress).safeTransferFrom(streamInstance, msg.sender, amount);

        emit CancelStream(msg.sender, amount);
    }
}

pragma ever-solidity >= 0.62.0;

/// @title LiquidityTokenRootDeployed-callback Interface
/// @notice Interface for liquidityTokenRootDeployed-callback implementation
interface ILiquidityTokenRootDeployedCallback {
    /// @notice Callback for DEX vault after successful LP token deploy
    /// @dev Only the DEX vault can perform
    /// @param _lpRoot Address of the LP root for pair
    /// @param _sendGasTo Receiver of the remaining gas
    function liquidityTokenRootDeployed(
        address _lpRoot,
        address _sendGasTo
    ) external;
}

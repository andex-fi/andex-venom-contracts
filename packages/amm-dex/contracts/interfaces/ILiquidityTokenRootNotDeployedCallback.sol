pragma ever-solidity >= 0.62.0;

/// @title LiquidityTokenRootNotDeployed-callback Interface
/// @notice Interface for liquidityTokenRootNotDeployed-callback implementation
interface ILiquidityTokenRootNotDeployedCallback {
    /// @notice Callback for DEX vault after failed LP token deploy
    /// @dev Only the DEX vault can perform
    /// @param _lpRoot Address of the LP root for pair
    /// @param _sendGasTo Receiver of the remaining gas
    function liquidityTokenRootNotDeployed(
        address _lpRoot,
        address _sendGasTo
    ) external;
}

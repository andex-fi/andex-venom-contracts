pragma ever-solidity >= 0.62.0;

/// @title Reserve Types
/// @notice Utility reserve types to use
library ReserveType {
    /// @dev Pool's reserves
    uint8 constant POOL = 1;

    /// @dev Accumulated fees
    uint8 constant FEE = 2;

    /// @dev LP token reserves
    uint8 constant LP = 3;
}

pragma ever-solidity >= 0.62.0;

/// @title ReferralProgram-callbacks Interface
/// @notice Interface for ReferralProgram-callbacks implementation
interface IReferralProgramCallbacks {
    function onRefLastUpdate(
        address referred,
        address referrer,
        address remainingGasTo
    ) external;
}

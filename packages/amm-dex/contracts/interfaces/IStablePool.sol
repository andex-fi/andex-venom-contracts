pragma ever-solidity >= 0.62.0;

import "./INPool.sol";
import "../structures/IAmplificationCoefficient.sol";

interface IStablePool is INPool, IAmplificationCoefficient {

    event AmplificationCoefficientUpdated(AmplificationCoefficient A);

    function getAmplificationCoefficient() external view responsible returns (AmplificationCoefficient);

    function setAmplificationCoefficient(AmplificationCoefficient _A, address send_gas_to) external;

    function getVirtualPrice() external view responsible returns (optional(uint256));
}

pragma ever-solidity >= 0.62.0;

import "./IPair.sol";
import "../structures/IAmplificationCoefficient.sol";
import "../structures/IDepositLiquidityResultV2.sol";

interface IStablePair is IPair, IAmplificationCoefficient, IDepositLiquidityResultV2 {

    event AmplificationCoefficientUpdated(AmplificationCoefficient A);

    function expectedDepositLiquidityV2(uint128[] amounts) external view responsible returns (DepositLiquidityResultV2);

    function getAmplificationCoefficient() external view responsible returns (AmplificationCoefficient);

    function setAmplificationCoefficient(AmplificationCoefficient _A, address send_gas_to) external;

    function getVirtualPrice() external view responsible returns (optional(uint256));
}

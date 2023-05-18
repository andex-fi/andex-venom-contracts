pragma ever-solidity >= 0.62.0;

import "../structures/ITokenOperationStructure.sol";

interface IOperation is ITokenOperationStructure {
    struct Operation {
        TokenOperation[] token_operations;
        address send_gas_to;
        address expected_callback_sender;
    }
}

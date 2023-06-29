import { Contract } from "locklift";
import { abiContract, signerNone } from "@eversdk/core";
import { client } from "..";

/**
 * Encode message body
 * @param {Object} encodeMessageBodyParameters
 * @param {Contract} encodeMessageBodyParameters.contract 
 * @param {String} encodeMessageBodyParameters.functionName 
 * @param {JSON} encodeMessageBodyParameters.input 
 * @returns 
 */

async function encodeMessageBody(
    contract: any,
    functionName: string,
    input: any
) {
    return (await client.abi.encode_message_body({
        abi: abiContract(contract.abi),
        call_set: {
            function_name: functionName,
            input: input
        },
        is_internal: true,
        signer: signerNone()
    })).body;
}

export default encodeMessageBody;
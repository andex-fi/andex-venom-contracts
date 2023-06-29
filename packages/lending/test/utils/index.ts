import { TonClient } from "@eversdk/core"

export const client = new TonClient({
    network: { 
        endpoints: [
            'https://gql-devnet.venom.network/graphql'
        ] 
    } 
})
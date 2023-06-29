export function describeTransaction(tx: any) {
    let description = '';
    description += `Tx ${tx.compute.success == true ? 'success':'fail'}\n`;
    description += `Fees: ${tx.fees.total_account_fees}`;
    return description
}

export function fraction(nom: any, denom: any) {
    return {
        nom, denom
    }
}

export function pp(obj: any) {
    return JSON.stringify(obj, null, '\t');
}

export const stringToBytesArrray = (dataString: string) => {
    return Buffer.from(dataString).toString('hex')
}


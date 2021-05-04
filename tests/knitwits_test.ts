
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.6.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that minting works",
    async fn(chain: Chain, accounts: Array<Account>) {
        let block = chain.mineBlock([
            // Tx.contractCall("knitwits", "mint", [], wallet_1.address),
        ]);
        assertEquals(block.receipts.length, 1);
    },
});

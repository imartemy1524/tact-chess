import { toNano } from '@ton/core';
import { TactChess } from '../wrappers/TactChess';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const tactChess = provider.open(await TactChess.fromInit());

    await tactChess.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(tactChess.address);

    // run methods on `tactChess`
}

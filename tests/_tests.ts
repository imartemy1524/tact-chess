import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { TactChess } from '../build/TactChess/tact_TactChess';
import { toNano } from '@ton/core';


export async function deployChess(): Promise<[Blockchain, SandboxContract<TreasuryContract>, SandboxContract<TactChess>]> {
    const blockchain = await Blockchain.create();

    const chess = blockchain.openContract(await TactChess.fromInit());

    const deployer = await blockchain.treasury('deployer');

    const deployResult = await chess.send(
        deployer.getSender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        },
    );

    expect(deployResult.transactions).toHaveTransaction({
        from: deployer.address,
        to: chess.address,
        deploy: true,
        success: true,
    });

    return [blockchain, deployer, chess];
}
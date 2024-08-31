import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { TactChess } from '../wrappers/TactChess';
import '@ton/test-utils';

describe('TactChess', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let chess: SandboxContract<TactChess>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        chess = blockchain.openContract(await TactChess.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await chess.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: chess.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        const {game, moves} = await chess.getGame();
        const
    });
});

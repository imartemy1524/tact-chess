import { Blockchain, printTransactionFees, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Move, TactChess } from '../wrappers/TactChess';
import '@ton/test-utils';
import {
    buildChessBoardFromGame,
    checkGame,
    chessMoveToBlockchain,
    defaultChess,
    expectEqualsChess,
    expectSuccessMove,
    toGame,
} from './_chess';
import { Chess } from 'chess.js';
import { deployChess } from './_tests';

describe('CheckCustomVariants', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let chess: SandboxContract<TactChess>;

    beforeEach(async () => {
        [blockchain, deployer, chess] = await deployChess();
    });

    it('check en passant', () => checkGame(chess, deployer.getSender(), toGame(`1. a3 d5 2. a4 d4 3. e4 dxe3`)));
    it('check castling', () =>
        checkGame(chess, deployer.getSender(), toGame(`1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. O-O axb5`)));
    it('check queen castling', () =>
        checkGame(chess, deployer.getSender(), toGame(`1. d4 d5 2. Be3 Be6 3. Qd3 Qd6 3. Nc3 Nc6 4. O-O-O O-O-O`)));
    for (const figure of ['N', 'B', 'R', 'Q']) {
        it(`check pawn promotion ${figure}`, async () =>{
            await checkGame(
                chess,
                deployer.getSender(),
                toGame(`1. e4 d5 2. exd5 Nf6 3. Bb5+ c6 4. dxc6 Qb6 5. cxb7+ Qxb5 6. bxc8=${figure}`),
            );
        })
    }
    it('check king under attack', async () => {
        await checkGame(
            chess,
            deployer.getSender(),
            toGame(`1. e4 d5 2. exd5 Nf6 3. Bb5+ c6 4. dxc6 Qb6 5. cxb7+ Qxb5 6. bxc8=R`),
        );
        // try to move invalid
        const { transactions: tr } = await chess.send(
            deployer.getSender(),
            {
                value: toNano(1),
            },
            {
                $$type: 'MoveMsg',
                move: {
                    fromX: 4n,
                    fromY: 7n,
                    toX: 3n,
                    toY: 7n,
                    $$type: 'Move',
                },
                promotion: 0n,
            },
        );
        expect(tr).toHaveTransaction({
            from: deployer.address,
            to: chess.address,
            success: false,
        });
        //now lets try to make success move
        expectSuccessMove(
            chess,
            await chess.send(
                deployer.getSender(),
                { value: toNano(1) },
                {
                    $$type: 'MoveMsg',
                    promotion: 0n,
                    move: {
                        fromX: 4n,
                        fromY: 7n,
                        toX: 3n,
                        toY: 6n,
                        $$type: 'Move',
                    },
                },
            ),
        );
    });
});

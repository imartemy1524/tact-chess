import { Blockchain, printTransactionFees, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Move, TactChess } from '../wrappers/TactChess';
import '@ton/test-utils';
import {
    buildChessBoardFromGame,
    chessMoveToBlockchain,
    defaultChess,
    expectEqualsChess,
    expectSuccessMove
} from './_chess';
import { Chess } from 'chess.js';
import { deployChess } from './_tests';

declare global {
    interface Array<T>{
        shuffle<T>(): Array<T>;
    }
}
Array.prototype.shuffle = function<T>(this: T[]) {
    let currentIndex = this.length;

    // While there remain elements to shuffle...
    while (currentIndex != 0) {

        // Pick a remaining element...
        let randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex--;

        // And swap it with the current element.
        [this[currentIndex], this[randomIndex]] = [this[randomIndex], this[currentIndex]];
    }
    return this;
}
const StartMovesOld: string[] = [
    'e4', 'd4', 'a4', 'h4', 'b4', 'g4', 'c4', 'f4',
    'a3', 'b3', 'c3', 'd3', 'e3', 'f3', 'g3', 'h3',
    'Nc3', 'Nf3', 'Na3', 'Nh3',
];
const BlackStartMovesOld: string[] = [
    'a6', 'b6', 'c6', 'd6', 'e6', 'f6', 'g6', 'h6',
    'a5', 'b5', 'c5', 'd5', 'e5', 'f5', 'g5', 'h5',
    'Nc6', 'Nf6', 'Na6', 'Nh6',
];
const StartMovesInvalid: Move[] = [
    {fromX: 0n, fromY: 0n, toX: 1n, toY: 0n, $$type: 'Move'},
    {fromX: 0n, fromY: 0n, toX: 0n, toY: 1n, $$type: 'Move'},
    {fromX: 3n, toX: 0n, fromY: 0n, toY: 3n, $$type: 'Move'},
    {fromX: 0n, toX: 3n, fromY: 0n, toY: 3n, $$type: 'Move'},
    {fromX: 2n, toX: 0n, fromY: 0n, toY: 2n, $$type: 'Move'},
]
describe('TactChessStart', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let chess: SandboxContract<TactChess>;

    beforeEach(async () => {
        [blockchain, deployer, chess] = await deployChess();
    });

    it('should deploy', async () => {
        const g = await chess.getGame();
        const game = buildChessBoardFromGame(g);
        expectEqualsChess(game, defaultChess());
    });

    for(let number=0;number<3;number++) {
        const StartMoves = (StartMovesOld).shuffle() as string[];
        const BlackStartMoves = (BlackStartMovesOld).shuffle() as string[];
        for (const WhiteMove of StartMoves) {
            const BlackMove = BlackStartMoves[StartMoves.indexOf(WhiteMove)];
            const def = defaultChess();
            it(`check move ${WhiteMove}-${BlackMove} ${number}`, async () => {
                let MoveBlockchain = chessMoveToBlockchain(def.move(WhiteMove));
                expectSuccessMove(chess, await chess.send(
                    deployer.getSender(),
                    { value: toNano('0.05') },
                    {
                        $$type: 'MoveMsg',
                        ...MoveBlockchain,
                    },
                ));
                expectEqualsChess(buildChessBoardFromGame(await chess.getGame()), def);
                MoveBlockchain = chessMoveToBlockchain(def.move(BlackMove));
                expectSuccessMove(chess, await chess.send(
                    deployer.getSender(),
                    { value: toNano('0.05') },
                    {
                        $$type: 'MoveMsg',
                        ...MoveBlockchain
                    },
                ));
                expectEqualsChess(buildChessBoardFromGame(await chess.getGame()), def);
            })
        }
    }
    for(const Move of StartMovesInvalid) {
        it(`check invalid move ${Move.fromX}-${Move.toX} ${Move.fromY}-${Move.toY}`, async () => {
            const { transactions } = await chess.send(
                deployer.getSender(),
                { value: toNano('0.05') },
                {
                    $$type: 'MoveMsg',
                    move: Move,
                    promotion: 0n,
                },
            );
            expect(transactions).toHaveTransaction({
                from: deployer.address,
                to: chess.address,
                success: false,
            });
        })
    }
});


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
    it('check castling', () => checkGame(chess, deployer.getSender(), toGame(`1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. O-O axb5`)));
    it('check queen castling', () => checkGame(chess, deployer.getSender(), toGame(`1. d4 d5 2. Be3 Be6 3. Qd3 Qd6 3. Nc3 Nc6 4. O-O-O O-O-O`)));
});

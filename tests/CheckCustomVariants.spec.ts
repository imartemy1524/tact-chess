import '@ton/test-utils';
import { describe } from 'node:test';
import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { TactChess } from '../build/TactChess/tact_TactChess';
import { deployChess } from './_tests';
import { checkGame, toGame } from './_chess';

describe('CheckCustomVariants', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let chess: SandboxContract<TactChess>;

    beforeEach(async () => {
        [blockchain, deployer, chess] = await deployChess();
    });

    it('check en passant', () => checkGame(chess, deployer.getSender(), toGame(`1. a3 d5 2. a4 d4 3. e4 dxe3`)));
});

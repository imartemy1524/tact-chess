import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { TactChess } from '../wrappers/TactChess';
import '@ton/test-utils';
import {
    checkGame,
    toGame,
} from './_chess';
import { deployChess, loadDatabase } from './_tests';


describe('FromDatabase', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let chess: SandboxContract<TactChess>;

    beforeEach(async () => {
        [blockchain, deployer, chess] = await deployChess();
    });

    const DB= loadDatabase();
    for(let i=0;i<DB.length;i++){
        it(`database ${i}`, () => checkGame(chess, deployer.getSender(), DB[i]));
    }
});



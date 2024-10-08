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

const Games = [
    `1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3
O-O 9. h3 Re8 10. d4 Bb7 11. Nbd2 Bf8 12. d5 Nb8 13. Nf1 Nbd7 14. N3h2 Nc5 15.
Bc2 c6 16. b4 Ncd7 17. dxc6 Bxc6 18. Bg5 h6 19. Bxf6 Nxf6 20. Ng4 Nxg4 21. Qxg4
d5 22. exd5 Qxd5 23. Bb3 Qd8 24. Qh5 Ra7 25. Rxe5 Rxe5 26. Qxe5 Qg5 27. Qxg5
hxg5 28. Ne3 g6 29. Rd1 Rc7 30. Kf1 Kg7 31. Ke2 Be7 32. Bd5 Bd7 33. Rd3 Bf6 34.
c4 bxc4 35. Bxc4 Bc8 36. a3 Bb2 37. Kd2 f5 38. Kc2 Bxa3 39. Rxa3 f4 40. Kb3 fxe3
41. fxe3 Re7 42. Ka4 Re5 43. Rd3 Bf5 44. Rd2 Rxe3 45. Bxa6 Be4 46. Rf2 Kh6 47.
Bf1 g4 48. hxg4 Re1 49. Be2 Ra1+ 50. Kb3 Rb1+ 51. Kc3 Rc1+ 52. Kd4 Bb7 53. Bf3
Ba6 54. Rb2 Bb5 55. Be2 Bc6 56. Bf3 Bb5 57. Be2 Bc6 58. Ba6 Rg1 59. b5 Bxg2 60.
b6 Kg5 61. Bc8 Kf4 62. Kc5 Be4 63. Rb4 Ke5 64. b7 Rc1+ 65. Kb5 Bxb7 66. Bxb7 Kf6
67. Rc4 Rb1+ 68. Kc6 Kg5 69. Bc8 Rd1 70. Bd7 Kh4 71. Kc7 Rd2 72. Kd8 Re2 73. Rc6
g5 74. Bf5 Re3 75. Re6 Rg3 76. Rh6#`
].map(toGame);

describe('CheckMates', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let chess: SandboxContract<TactChess>;

    beforeEach(async () => {
        [blockchain, deployer, chess] = await deployChess();
    });

    for (const i of Games) {
        it(`should play popular game 2.${Games.indexOf(i)}`, () => checkGame(chess, deployer.getSender(), i));
    }
});

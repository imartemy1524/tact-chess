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
    `1. e4 d6 2. d4 Nf6 3. Nc3 g6 4. Be3 Bg7 5. Qd2 c6 6. f3 b5 7. Nge2 Nbd7 8. Bh6
Bxh6 9. Qxh6 Bb7 10. a3 e5 11. O-O-O Qe7 12. Kb1 a6 13. Nc1 O-O-O 14. Nb3 exd4
15. Rxd4 c5 16. Rd1 Nb6 17. g3 Kb8 18. Na5 Ba8 19. Bh3 d5 20. Qf4+ Ka7 21. Rhe1
d4 22. Nd5 Nbxd5 23. exd5 Qd6 24. Rxd4 cxd4 25. Re7+ Kb6 26. Qxd4+ Kxa5 27. b4+
Ka4 28. Qc3 Qxd5 29. Ra7 Bb7 30. Rxb7 Qc4 31. Qxf6 Kxa3 32. Qxa6+ Kxb4 33. c3+
Kxc3 34. Qa1+ Kd2 35. Qb2+ Kd1 36. Bf1 Rd2 37. Rd7 Rxd7 38. Bxc4 bxc4 39. Qxh8
Rd3 40. Qa8 c3 41. Qa4+ Ke1 42. f4 f5 43. Kc1 Rd2 44. Qa7`,
    `1. e4 e5 2. Nf3 d6 3. d4 Bg4 4. dxe5 Bxf3 5. Qxf3 dxe5 6. Bc4 Nf6 7. Qb3 Qe7 8.
Nc3 c6 9. Bg5 b5 10. Nxb5 cxb5 11. Bxb5+ Nbd7 12. O-O-O Rd8 13. Rxd7 Rxd7 14.
Rd1 Qe6 15. Bxd7+ Nxd7 16. Qb8+ Nxb8 17. Rd8`,
    `1. e4 c5 2. Nf3 e6 3. d4 cxd4 4. Nxd4 Nc6 5. Nb5 d6 6. c4 Nf6 7. N1c3 a6 8. Na3
d5 9. cxd5 exd5 10. exd5 Nb4 11. Be2 Bc5 12. O-O O-O 13. Bf3 Bf5 14. Bg5 Re8 15.
Qd2 b5 16. Rad1 Nd3 17. Nab1 h6 18. Bh4 b4 19. Na4 Bd6 20. Bg3 Rc8 21. b3 g5 22.
Bxd6 Qxd6 23. g3 Nd7 24. Bg2 Qf6 25. a3 a5 26. axb4 axb4 27. Qa2 Bg6 28. d6 g4
29. Qd2 Kg7 30. f3 Qxd6 31. fxg4 Qd4+ 32. Kh1 Nf6 33. Rf4 Ne4 34. Qxd3 Nf2+ 35.
Rxf2 Bxd3 36. Rfd2 Qe3 37. Rxd3 Rc1 38. Nb2 Qf2 39. Nd2 Rxd1+ 40. Nxd1 Re1+`,
    `1. c4 e5 2. g3 d6 3. Bg2 g6 4. d4 Nd7 5. Nc3 Bg7 6. Nf3 Ngf6 7. O-O O-O 8. Qc2
Re8 9. Rd1 c6 10. b3 Qe7 11. Ba3 e4 12. Ng5 e3 13. f4 Nf8 14. b4 Bf5 15. Qb3 h6
16. Nf3 Ng4 17. b5 g5 18. bxc6 bxc6 19. Ne5 gxf4 20. Nxc6 Qg5 21. Bxd6 Ng6 22.
Nd5 Qh5 23. h4 Nxh4 24. gxh4 Qxh4 25. Nde7+ Kh8 26. Nxf5 Qh2+ 27. Kf1 Re6 28.
Qb7 Rg6 29. Qxa8+ Kh7 30. Qg8+ Kxg8 31. Nce7+ Kh7 32. Nxg6 fxg6 33. Nxg7 Nf2 34.
Bxf4 Qxf4 35. Ne6 Qh2 36. Rdb1 Nh3 37. Rb7+ Kh8 38. Rb8+ Qxb8 39. Bxh3 Qg3`,
    `1. e4 Nf6 2. e5 Nd5 3. d4 d6 4. Nf3 g6 5. Bc4 Nb6 6. Bb3 Bg7 7. Qe2 Nc6 8. O-O
O-O 9. h3 a5 10. a4 dxe5 11. dxe5 Nd4 12. Nxd4 Qxd4 13. Re1 e6 14. Nd2 Nd5 15.
Nf3 Qc5 16. Qe4 Qb4 17. Bc4 Nb6 18. b3 Nxc4 19. bxc4 Re8 20. Rd1 Qc5 21. Qh4 b6
22. Be3 Qc6 23. Bh6 Bh8 24. Rd8 Bb7 25. Rad1 Bg7 26. R8d7 Rf8 27. Bxg7 Kxg7 28.
R1d4 Rae8 29. Qf6+ Kg8 30. h4 h5 31. Kh2 Rc8 32. Kg3 Rce8 33. Kf4 Bc8 34. Kg5`,
    `1. d4 d5 2. Nf3 e6 3. e3 c5 4. c4 Nc6 5. Nc3 Nf6 6. dxc5 Bxc5 7. a3 a6 8. b4 Bd6
9. Bb2 O-O 10. Qd2 Qe7 11. Bd3 dxc4 12. Bxc4 b5 13. Bd3 Rd8 14. Qe2 Bb7 15. O-O
Ne5 16. Nxe5 Bxe5 17. f4 Bc7 18. e4 Rac8 19. e5 Bb6+ 20. Kh1 Ng4 21. Be4 Qh4 22.
g3 Rxc3 23. gxh4 Rd2 24. Qxd2 Bxe4+ 25. Qg2 Rh3`,
    `1. d4 Nf6 2. c4 e6 3. Nc3 Bb4 4. e3 c5 5. a3 Bxc3+ 6. bxc3 b6 7. Bd3 Bb7 8. f3
Nc6 9. Ne2 O-O 10. O-O Na5 11. e4 Ne8 12. Ng3 cxd4 13. cxd4 Rc8 14. f4 Nxc4 15.
f5 f6 16. Rf4 b5 17. Rh4 Qb6 18. e5 Nxe5 19. fxe6 Nxd3 20. Qxd3 Qxe6 21. Qxh7+
Kf7 22. Bh6 Rh8 23. Qxh8 Rc2 24. Rc1 Rxg2+ 25. Kf1 Qb3 26. Ke1 Qf3`,
    `1. d4 d5 2. c4 c6 3. Nf3 Nf6 4. Nc3 e6 5. e3 Nbd7 6. Bd3 dxc4 7. Bxc4 b5 8. Bd3
Bd6 9. O-O O-O 10. Qc2 Bb7 11. a3 Rc8 12. Ng5 c5 13. Nxh7 Ng4 14. f4 cxd4 15.
exd4 Bc5 16. Be2 Nde5 17. Bxg4 Bxd4+ 18. Kh1 Nxg4 19. Nxf8 f5 20. Ng6 Qf6 21. h3
Qxg6 22. Qe2 Qh5 23. Qd3 Be3`,
    `1. d4 d5 2. c4 dxc4 3. e4 e6 4. Bxc4 Nf6 5. Nc3 Bb4 6. e5 Nfd7 7. Nf3 O-O 8. O-O
Bxc3 9. bxc3 Nc6 10. Bd3 b6 11. Re1 Bb7 12. Bxh7+ Kxh7 13. Ng5+ Kg6 14. Qd3+ f5
15. exf6+ Kxf6 16. Rxe6#`,
    // en passant
    `1. d4 d5 2. c4 c6 3. Nc3 e6 4. Nf3 Bb4 5. a3 Bxc3+ 6. bxc3 h6 7. Bf4 Nd7 8. e3
Ngf6 9. Bd3 Qe7 10. c5 a6 11. O-O g6 12. Rb1 g5 13. Bg3 Nh5 14. Bd6 Qd8 15. Ne5
Nxe5 16. Bxe5 Nf6 17. Qf3 Ne4 18. Bxh8 Nd2 19. Qh3 Nxf1 20. Kxf1 Bd7 21. Qxh6
Qe7 22. Bf6 Qf8 23. Qxg5 Bc8 24. c4 Kd7 25. cxd5 cxd5 26. Bc2 Kc7 27. Be5+ Kd7
28. Ba4+ b5 29. cxb6#`,
    `1. a4 c5 2. a5 e5 3. f4 exf4 4. h4 d6 5. c4 Bh3 6. Rxh3 Be7 7. Nf3 Na6 8. Ng5
Qb8 9. Nxh7 Bd8 10. Re3+ Ne7 11. Qa4+ b5 12. axb6`,
    `1. Nf3 Nc6 2. e4 e5 3. Bc4 h6 4. d4 exd4 5. c3 dxc3 6. Nxc3 Nf6 7. O-O Bd6 8.
Re1 Bb4 9. e5 Ng4 10. e6 dxe6 11. Bxe6 fxe6 12. Bd2 O-O 13. Ne4 Bxd2 14. Nfxd2
Qd4 15. Qxg4 Qxf2+ 16. Nxf2 e5 17. Qc4+ Kh8 18. Ng4 Na5 19. Qxc7 Bxg4 20. Qxa5
b6 21. Qxe5 Rfe8 22. Qf4 Rxe1+ 23. Rxe1 Be6 24. Rxe6 Rd8 25. Rg6 Kh7 26. Qf5
Rxd2 27. Kf1 Rd1+ 28. Ke2 Rd8 29. h4 Re8+ 30. Kf3 Kg8 31. h5 Rf8 32. Kg4 Rxf5
33. Kxf5 b5 34. Ke5 a5 35. Kd4 b4 36. Kc4 Kf7 37. Kb5 Ke7 38. Kxa5 Kf7 39. Kxb4
Kf8 40. a4 Kf7 41. a5 Kf8 42. a6 Kf7 43. a7 Kf8 44. a8=Q+ Kf7 45. Kc5 Ke7 46.
Kc6 Kf7 47. b3 Ke7 48. b4 Kf7 49. b5 Ke7 50. b6 Kf7 51. b7 Ke7 52. b8=Q Kf7 53.
Qh8 Ke7 54. Qab8 Kf7 55. g3 Ke7 56. Qd6+ Kf7 57. Re6 g5 58. hxg6#`,
    `1. Nf3 Nf6 2. g3 d5 3. Bg2 c6 4. O-O Bf5 5. c4 e6 6. d3 dxc4 7. dxc4 Qxd1 8.
Rxd1 Bc2 9. Rf1 Nbd7 10. Nc3 Bb4 11. Bd2 a5 12. a3 Bxc3 13. Bxc3 a4 14. Rac1 Be4
15. Rfd1 Ke7 16. Bf1 c5 17. Ne1 Bc6 18. f3 Rhd8 19. Nd3 b6 20. Kf2 Ne8 21. e4
Bb7 22. Ke3 Ba6 23. h4 Rac8 24. Nf4 f6 25. Rd2 Nd6 26. Nh5 Ne8 27. Rcd1 Ne5 28.
Rxd8 Rxd8 29. Rxd8 Kxd8 30. Bxe5 fxe5 31. g4 Ke7 32. Kd2 g6 33. Ng3 Nd6 34. Kc3
Nb7 35. Bd3 Na5 36. Nf1 Bc8 37. Nd2 Bd7 38. Bc2 h6 39. g5 hxg5 40. hxg5 Nb7 41.
Nf1 Nd6 42. Ne3 Nf7 43. Ng4 Bc6 44. Kd2 Kd6 45. Ke3 Nxg5 46. Nf2 Nh7 47. Nd1 Nf6
48. Nc3 Nh5 49. Bxa4 Bb7 50. Bd1 Nf4 51. Be2 Ng2+ 52. Kf2 Nf4 53. Bf1 Bc6 54. b4
cxb4 55. axb4 Be8 56. Ke3 g5 57. b5 Kc7 58. Na4 Bh5 59. Be2 Ng2+ 60. Kf2 Nf4 61.
Bf1 g4 62. fxg4 Bxg4 63. Ke3 Bd1 64. Nb2 Bc2 65. Bd3 Bb3 66. Kd2 Kd6 67. Kc3 Ba2
68. Nd1 Kc5 69. Nf2 Kd6 70. Kb4 Kc7 71. Bf1 Kd6 72. Nd1 Bb1 73. Nf2 Kc7 74. c5
bxc5+ 75. Kxc5 Bc2 76. b6+ Kb7 77. Bb5 Bb1 78. Bc6+ Ka6 79. b7 Ka7 80. Kd6 Kb8
81. Kxe5 Ne2 82. Kxe6 Kc7 83. Bd5 Nc3 84. Ke5 Nxd5 85. exd5 Kxb7 86. d6 Kc8 87.
d7+ Kxd7 88. Kd4 Ke6 89. Kc5 Kd7 90. Kb6 Ba2 91. Ka7 Bc4 92. Ka8 Ba6 93. Nd3 Kc7
94. Ne5 Kc8 95. Nc6 Kc7 96. Na7 Bb7#`,
    `1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. c3 Nf6 5. d4 exd4 6. cxd4 Bb4+ 7. Nc3 Nxe4 8.
O-O Bxc3 9. d5 Ne5 10. bxc3 Nxc4 11. Qd4 f5 12. Qxc4 d6 13. Nd4 O-O 14. f3 Nf6
15. Bg5 h6 16. Bh4 g5 17. Bf2 Kg7 18. Rfe1 Bd7 19. Qb3 c5 20. dxc6 bxc6 21. Ne6+
Bxe6 22. Rxe6 Qd7 23. Rd1 Nd5 24. Bd4+ Kh7 25. Rde1 Rae8 26. Rxe8 Rxe8 27. Rxe8
Qxe8 28. Qb7+ Kg6 29. Qg7+ Kh5 30. h3 Qe6 31. g4+ fxg4 32. hxg4+ Kh4 33. Qxh6+
Qxh6 34. Kh2 Nf6 35. Bf2#`,
    `1. d4 Nf6 2. c4 g6 3. Nf3 Bg7 4. g3 c6 5. Bg2 d5 6. cxd5 cxd5 7. Nc3 O-O 8. Ne5
e6 9. O-O Nfd7 10. f4 Nc6 11. Be3 Nb6 12. Bf2 Bd7 13. e4 Ne7 14. Nxd7 Qxd7 15.
e5 Rac8 16. Rc1 a6 17. b3 Rc7 18. Qd2 Rfc8 19. g4 Bf8 20. Qe3 Nc6 21. f5 Ba3 22.
Rcd1 Nb4 23. Qh6 Qe8 24. Nb1 Bb2 25. Qd2 Nc2 26. Kh1 Qe7 27. Bg1 Nd7 28. Rf3 Qb4
29. Qh6 Qf8 30. Qg5 Qg7 31. Qd2 b6 32. Rdf1 a5 33. h4 Nb4 34. a3 Rc2 35. Qf4 Nc6
36. Bh3 Nd8 37. Be3 b5 38. R3f2 b4 39. axb4 axb4 40. Rxc2 Rxc2 41. Rf2 Rxf2 42.
Qxf2 Ba3 43. Qc2 Nxe5 44. dxe5 Qxe5 45. Qc8 Qe4+ 46. Bg2 Qxb1+ 47. Kh2 Bb2 48.
Qxd8+ Kg7 49. f6+ Bxf6 50. Bh6+ Kxh6 51. Qxf6 Qc2 52. g5+ Kh5 53. Kg3 Qc7+ 54.
Kh3 Qc3+ 55. Qf3+ Qxf3+ 56. Bxf3#`,
    `1. e4 d5 2. exd5 Qxd5 3. Nc3 Qe6+ 4. Be2 Qc6 5. Nf3 f6 6. O-O e5 7. d4 e4 8.
Nxe4 Qxe4 9. Bb5+ Kd8 10. Re1 Qf5 $2 11. Re8#`,
    `1. e4 c5 2. Nf3 Nc6 3. Bb5 e6 4. Bxc6 bxc6 5. b3 Ne7 6. Bb2 Ng6 7. h4 h5 8. e5
d6 9. exd6 Qxd6 10. Qe2 f6 11. Qe4 Kf7 12. Nc3 e5 13. O-O-O Be7 14. d3 Be6 15.
g3 Rad8 16. Rhf1 Bh3 17. Rg1 Bg4 18. Rde1 Qe6 19. Nd2 Rd4 20. Qg2 Rhd8 21. f3
Bh3 22. Qf2 Bf5 23. Nce4 Qd7 24. Nc4 Be6 25. g4 hxg4 26. fxg4 Bxc4 27. dxc4 Nf4
28. Qf3 a5 29. a4 Qb7 30. g5 Rb8 31. gxf6 gxf6 32. Rg4 Nd3+ 33. cxd3 Qxb3 34.
Qg2 Bf8 35. Rg6 Qxd3 36. Rxf6+ Ke7 37. Bxd4 Rb1#`,
    `1. d4 d5 2. c4 {Queen's Gambit} 2... dxc4 3. Nf3 Nc6 4. e3 Bf5 5. Bxc4 e6 6. a3
a6 7. Nc3 Bd6 8. e4 Bg6 9. O-O b5 10. Bd3 h6 11. e5 Be7 12. Bxg6 {hurting
black's pawn structure.} 12... fxg6 13. Qd3 Kf7 14. d5 exd5 15. Qxd5+ Qxd5 16.
Nxd5 Bd8 17. Re1 Nge7 18. e6+ Kf8 19. Nxe7 {All of the following trade-offs
might not have been necessary, but honestly I thought that I would have a better
chance of protecting or promoting the pawn if black didn't have so many pieces
around it.} 19... Bxe7 20. Bd2 Bf6 21. Bc3 Ke7 22. Re4 Rhe8 23. Rae1 Rad8 24.
Ne5 Nxe5 25. Bxe5 Bxe5 26. Rxe5 Rd2 27. Rc5 Rc8 28. Rc6 Rxb2 29. Rxa6 {Probably
should have ended up a drawn game at this point, but black makes a fatal mistake
on the next move.} 29... c6 30. Ra7+ Kf6 (30... Kd6 31. Rd7+ Kc5 32. e7 Re8 33.
h3 (33. Rd8 Rxe7 34. Rxe7 Rb1+) 33... Kb6 34. Rd8 Rxe7 35. Rxe7) 31. Rf7+ Kg5
32. h4+ {creating an escape square for my king without wasting any time.} 32...
Kxh4 33. e7 Re8 34. Rf8 Rxe7 35. Rxe7 g5 36. Re6 h5 37. Rxc6 g4 38. Rf4 g5 39.
Re4 Rb1+ 40. Kh2 Rf1 41. g3#`
].map(toGame);

describe('CheckPopuluarGames', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let chess: SandboxContract<TactChess>;

    beforeEach(async () => {
        [blockchain, deployer, chess] = await deployChess();
    });

    for (const i of Games) {
        it(`should play popular game ${Games.indexOf(i)}`, () => checkGame(chess, deployer.getSender(), i));
    }
});

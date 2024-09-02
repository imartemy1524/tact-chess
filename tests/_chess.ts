import { Chess, Move as ChessMove } from 'chess.js';
import { Game, GameResponse, Move, TactChess } from '../build/TactChess/tact_TactChess';
import { BlockchainTransaction, SandboxContract } from '@ton/sandbox';
import { flattenTransaction } from '@ton/test-utils';
import { OpenedContract, Sender, toNano } from '@ton/core';

enum Spot {
    EMPTY = 0,
    PAWN_BLACK = 1,
    KNIGHT_BLACK = 2,
    BISHOP_BLACK = 3,
    ROOK_BLACK = 4,
    QUEEN_BLACK = 5,
    KING_BLACK = 6,
    PAWN_WHITE = 7,
    KNIGHT_WHITE = 8,
    BISHOP_WHITE = 9,
    ROOK_WHITE = 10,
    QUEEN_WHITE = 11,
    KING_WHITE = 12,
}

interface Castles {
    whiteKing: boolean;
    whiteQueen: boolean;
    blackKing: boolean;
    blackQueen: boolean;
}

function spotToChar(spot: Spot): string {
    switch (spot) {
        case Spot.EMPTY:
            return '.';
        case Spot.PAWN_BLACK:
            return 'p';
        case Spot.KNIGHT_BLACK:
            return 'n';
        case Spot.BISHOP_BLACK:
            return 'b';
        case Spot.ROOK_BLACK:
            return 'r';
        case Spot.QUEEN_BLACK:
            return 'q';
        case Spot.KING_BLACK:
            return 'k';
        case Spot.PAWN_WHITE:
            return 'P';
        case Spot.KNIGHT_WHITE:
            return 'N';
        case Spot.BISHOP_WHITE:
            return 'B';
        case Spot.ROOK_WHITE:
            return 'R';
        case Spot.QUEEN_WHITE:
            return 'Q';
        case Spot.KING_WHITE:
            return 'K';
        default:
            throw new Error('Invalid chess figure');
    }
}

function toCoordinate(x: number, y: number) {
    return ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'][x] + (y + 1);
}

export function buildChessBoardFromGame({
    game: {
        whiteTurn,
        board: { game: position },
        blackCanCastleQueen: blackQueen,
        blackCanCastleKing: blackKing,
        whiteCanCastleKing: whiteKing,
        whiteCanCastleQueen: whiteQueen,
        halfMoveClock,
    },
    moves,
    isCheckMate,
}: GameResponse) {
    const castles: Castles = { whiteKing, whiteQueen, blackKing, blackQueen };
    const enums = buildEnumArray(position);
    let enPassage = '';
    const lastMove = moves.size ? moves.get(moves.size - 1) : null;
    if (
        lastMove &&
        enums[Number(lastMove.toX)][Number(lastMove.toY)] === Spot.PAWN_BLACK &&
        whiteTurn &&
        lastMove.fromY - lastMove.toY === 2n &&
        lastMove.fromY === 6n
    ) {
        enPassage = toCoordinate(Number(lastMove.toX), Number(lastMove.toY) + 1);
    }
    if (
        lastMove &&
        enums[Number(lastMove.toX)][Number(lastMove.toY)] === Spot.PAWN_WHITE &&
        !whiteTurn &&
        lastMove.toY - lastMove.fromY === 2n &&
        lastMove.fromY === 1n
    ) {
        enPassage = toCoordinate(Number(lastMove.toX), Number(lastMove.toY) - 1);
    }
    const fen = buildFenBoard(enums);
    const ans = buildChessBoard(fen, whiteTurn, castles, ~~(moves.size / 2) + 1, Number(halfMoveClock), enPassage);
    expect(ans.isCheckmate()).toBe(isCheckMate);

    if(isCheckMate){
        console.log("Checkmate: \n", ans.ascii());
    }

    return ans;
}

export function defaultChess() {
    const chess = new Chess();
    chess.load('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
    return chess;
}

function buildChessBoard(
    fenStart: string,
    whiteMoves: boolean,
    castles: Castles,
    fullMoves: number,
    movesNoTake: number,
    enPassage: string,
) {
    return new Chess(
        `${fenStart} ${whiteMoves ? 'w' : 'b'} ${
            castles.whiteKing ? 'K' : ''
        }${castles.whiteQueen ? 'Q' : ''}${castles.blackKing ? 'k' : ''}${castles.blackQueen ? 'q' : ''}${
            !Object.values(castles).some((e) => e) ? '-' : ''
        } ${enPassage || '-'} ${movesNoTake} ${fullMoves}`,
    );
}

function buildEnumArray(number: bigint) {
    const data = [];
    for (let y = 0n; y < 8n; y++) {
        const row = [];
        for (let x = 0n; x < 8n; x++) {
            const offset = 4n * (8n * y + x);
            let shifted = number >> offset;
            const spot = Number(shifted & 0xfn) as Spot;
            if (spot < Spot.EMPTY || spot > Spot.KING_WHITE) {
                throw new Error('Invalid chess board');
            }
            row.push(spot);
        }
        data.push(row);
    }
    return data.reverse();
}

function buildFenBoard(enums: number[][]): string {
    const data = enums
        .map((el) => el.map(spotToChar).join(''))
        //replace many dots with a number
        .map((row) => row.replace(/\.+/g, (match) => match.length.toString()))
        .join('/');
    return data;
}

export function chessMoveToBlockchain(move: ChessMove): { move: Move; promotion: bigint } {
    const [symbol, number] = move.from.split('');
    const fromX = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].indexOf(symbol);
    const fromY = Number(number) - 1;
    const [symbol2, number2] = move.to.split('');
    const toX = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].indexOf(symbol2);
    const toY = Number(number2) - 1;
    return {
        move: {
            fromX: BigInt(fromX),
            fromY: BigInt(fromY),
            toX: BigInt(toX),
            toY: BigInt(toY),
            $$type: 'Move',
        },
        promotion: BigInt(
            move.promotion
                ? {
                      p: move.color === 'b' ? Spot.PAWN_BLACK : Spot.PAWN_WHITE,
                      n: move.color === 'b' ? Spot.KNIGHT_BLACK : Spot.KNIGHT_WHITE,
                      b: move.color === 'b' ? Spot.BISHOP_BLACK : Spot.BISHOP_WHITE,
                      r: move.color === 'b' ? Spot.ROOK_BLACK : Spot.ROOK_WHITE,
                      q: move.color === 'b' ? Spot.QUEEN_BLACK : Spot.QUEEN_WHITE,
                      k: move.color === 'b' ? Spot.KING_BLACK : Spot.KING_WHITE,
                  }[move.promotion]
                : 0,
        ),
    };
}

export function expectEqualsChess(from: Chess, to: Chess) {
    expect(from.ascii()).toEqual(to.ascii());
    expect(from.getCastlingRights('w')).toEqual(to.getCastlingRights('w'));
    expect(from.getCastlingRights('b')).toEqual(to.getCastlingRights('b'));
    expect(from.moveNumber()).toEqual(to.moveNumber());
}

export function expectSuccessMove(
    contract: SandboxContract<TactChess>,
    {
        transactions,
    }: {
        transactions: BlockchainTransaction[];
    },
) {
    for (const tr of transactions) {
        const transaction = flattenTransaction(tr);
        if (transaction.exitCode !== 0) {
            console.error(
                contract.abi!.errors![transaction.exitCode! as any]?.message ?? 'Unknown error',
                '\n',
                transaction.exitCode,
                '\n',
                transaction,
            );
        }
        expect(transaction.exitCode).toBe(0);
    }
    // expect(transactions).toHaveTransaction({
    //     success: true,
    // });
}

export function toGame(game: string): ([string, string])[] {
    return game
        .replace(/\n/g, ' ')
        .split(/\d+\. /)
        .slice(1)
        .map((e) => e.trim().split(' ') as [string, string]);
}

export async function checkGame(chess: SandboxContract<TactChess>, sender: Sender, i: ([string, string])[]) {
    const board = defaultChess();
    for (const move of i) {
        const [first, second] = move;
        const MoveFirst = chessMoveToBlockchain(board.move(first));
        // console.log("Trying move", j++, first);
        expectSuccessMove(
            chess,
            await chess.send(
                sender,
                { value: toNano('0.07') },
                {
                    $$type: 'MoveMsg',
                    ...MoveFirst,
                },
            ),
        );
        expectEqualsChess(board, buildChessBoardFromGame(await chess.getGame()));
        if (!second) break;
        const MoveSecond = chessMoveToBlockchain(board.move(second));
        // console.log("Trying move", j++, second);
        expectSuccessMove(
            chess,
            await chess.send(
                sender,
                { value: toNano('0.07') },
                {
                    $$type: 'MoveMsg',
                    ...MoveSecond,
                },
            ),
        );

        expectEqualsChess(board, buildChessBoardFromGame(await chess.getGame()));
    }
    return board;
}

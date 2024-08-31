import { Chess } from 'chess.js';
import { Game, GameResponse } from '../build/TactChess/tact_TactChess';

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

export function buildChessBoardFromGame({
    game: {
        whiteTurn,
        board: { game: position },
        blackCanCastleQueen: blackQueen,
        blackCanCastleKing: blackKing,
        whiteCanCastleKing: whiteKing,
        whiteCanCastleQueen: whiteQueen,
        lastMove,
        halfMoveClock,
    },
    moves,
}: GameResponse) {
    const castles: Castles = { whiteKing, whiteQueen, blackKing, blackQueen };
    const enums = buildEnumArray(position);
    let enPassage = '';
    if (lastMove && enums[Number(lastMove.toX)][Number(lastMove.toY)] === Spot.PAWN_BLACK && whiteTurn && lastMove.fromY - lastMove.toY === 2n) {
        enPassage = String.fromCharCode(97 + Number(lastMove.toX)) + (8 - Number(lastMove.toY) + 1);
    }
    if(lastMove && enums[Number(lastMove.toX)][Number(lastMove.toY)] === Spot.PAWN_WHITE && !whiteTurn && lastMove.fromY - lastMove.toY === -2n) {
        enPassage = String.fromCharCode(97 + Number(lastMove.toX)) + (8 - Number(lastMove.toY) - 1);
    }
    const fen = buildFenBoard(enums);
    return buildChessBoard(fen, whiteTurn, castles, ~~(moves.size / 2) + 1, Number(halfMoveClock), enPassage);
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
    for (let x = 0n; x < 8n; x++) {
        const row = [];
        for (let y = 0n; y < 8n; y++) {
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
    return data;
}

function buildFenBoard(enums: number[][]): string {
    const data = enums
        .map((el) => el.map(spotToChar).join(''))
        //replace many dots with a number
        .map((row) => row.replace(/\.+/g, (match) => match.length.toString()))
        .join('/');
    return data;
}

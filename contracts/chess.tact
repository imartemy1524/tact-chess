import "./moves.tact";
const SPOT_EMPTY: Int = 0;

const SPOT_PAWN_BLACK: Int = 1;
const SPOT_KNIGHT_BLACK: Int = 2;
const SPOT_BISHOP_BLACK: Int = 3;
const SPOT_ROOK_BLACK: Int = 4;
const SPOT_QUEEN_BLACK: Int = 5;
const SPOT_KING_BLACK: Int = 6;

const SPOT_PAWN_WHITE: Int = 7;
const SPOT_KNIGHT_WHITE: Int = 8;
const SPOT_BISHOP_WHITE: Int = 9;
const SPOT_ROOK_WHITE: Int = 10;
const SPOT_QUEEN_WHITE: Int = 11;
const SPOT_KING_WHITE: Int = 12;

extends inline fun isBlack(self: Int): Bool{
    return self >= SPOT_PAWN_BLACK && self <= SPOT_KING_BLACK;
}
extends inline fun isWhite(self: Int): Bool{
    return self >= SPOT_PAWN_WHITE && self <= SPOT_KING_WHITE;
}
extends inline fun isEmpty(self: Int): Bool{
    return self == SPOT_EMPTY;
}
extends inline fun isPawn(self: Int): Bool{
    return self == SPOT_PAWN_BLACK || self == SPOT_PAWN_WHITE;
}
extends inline fun isKnight(self: Int): Bool{
    return self == SPOT_KNIGHT_BLACK || self == SPOT_KNIGHT_WHITE;
}
extends inline fun isBishop(self: Int): Bool{
    return self == SPOT_BISHOP_BLACK || self == SPOT_BISHOP_WHITE;
}
extends inline fun isRook(self: Int): Bool{
    return self == SPOT_ROOK_BLACK || self == SPOT_ROOK_WHITE;
}
extends inline fun isQueen(self: Int): Bool{
    return self == SPOT_QUEEN_BLACK || self == SPOT_QUEEN_WHITE;
}
extends inline fun isKing(self: Int): Bool{
    return self == SPOT_KING_BLACK || self == SPOT_KING_WHITE;
}

struct Position{
    x: Int;
    y: Int;
}
struct Row{
    a: Int as uint8 = 0;
    b: Int as uint8 = 0;
    c: Int as uint8 = 0;
    d: Int as uint8 = 0;
    e: Int as uint8 = 0;
    f: Int as uint8 = 0;
    g: Int as uint8 = 0;
    h: Int as uint8 = 0;
}

struct Board{
    // y1, y2, ... - rows of the board at y = 0, 1, ...
    y1: Row;
    y2: Row;
    y3: Row;
    y4: Row;
    y5: Row;
    y6: Row;
    y7: Row;
    y8: Row;
}
struct Move{
    fromX: Int as uint8;
    fromY: Int as uint8;
    toX: Int as uint8;
    toY: Int as uint8;
}
extends inline fun deltaXABS(self: Move): Int{
    return abs(self.toX - self.fromX);
}
extends inline fun deltaYABS(self: Move): Int{
    return abs(self.toY - self.fromY);
}

struct Game {
    board: Board;
    whiteTurn: Bool = true;

    // Castling flags
    whiteKingMoved: Bool = false;
    blackKingMoved: Bool = false;
    lastMove: Move = Move{fromX: 0, fromY: 0, toX: 0, toY: 0};
}


extends fun lastMovePiece(self: Game): Int{
    return self.board.at(self.lastMove.toX, self.lastMove.toY);
}

extends fun move(self: Game, mv: Move): Game{
    let piece: Int = self.board.at(mv.fromX, mv.fromY);
    let target: Int = self.board.at(mv.toX, mv.toY);
    require(!piece.isEmpty(), "No piece at the source position");

    // check that this is even move
    require(mv.fromY != mv.toY || mv.fromX != mv.toX, "Not a move at all");

    // moving black
    if(piece.isBlack()) {
        require(!self.whiteTurn, "It's white's turn to move");
        //TODO: add castling logic
        require(!target.isBlack(), "Cannot capture a piece of the same color");
    }
    else {
        require(self.whiteTurn, "It's black's turn to move");
        require(!target.isWhite(), "Cannot capture a piece of the same color");
    }
    if(piece.isPawn()){
        requireCanMovePawn(self, mv, self.whiteTurn);
    }
    else if(piece.isKnight()){
        requireCanMoveKnight(self, mv);
    }
    else if(piece.isBishop()){
        requireCanMoveBishop(self, mv);
    }
    else if(piece.isRook()){
        requireCanMoveRook(self, mv);
    }
    else if(piece.isKing()){
        requireCanMoveKing(self, mv);
    }
    else if(piece.isQueen()){
        requireCanMoveQueen(self, mv);
    }
    else {
        require(false, "Uknown piece moved!");
    }

    requirePositionStillValid(self, self.whiteKingMoved);


    return self;
}



//This function returns SPOT_* constants at position x, y on the board (0-based)
extends fun at(self: Board, x: Int, y: Int): Int{
    require(x >= 0 && x <= 7, "x must be between 0 and 7");
    require(y >= 0 && y <= 7, "y must be between 0 and 7");
    let row: Row = self.y1;
    if y == 1 {
        row = self.y2;
    } else if y == 2{
        row = self.y3;
    } else if y == 3{
        row = self.y4;
    } else if y == 4{
        row = self.y5;
    } else if y == 5{
        row = self.y6;
    } else if y == 6{
        row = self.y7;
    } else {
        row = self.y8;
    }
    if x == 0{
        return row.a;
    } else if x == 1{
        return row.b;
    } else if x == 2{
        return row.c;
    } else if x == 3{
        return row.d;
    } else if x == 4{
        return row.e;
    } else if x == 5{
        return row.f;
    } else if x == 6{
        return row.g;
    }
    return row.h;
}

extends fun findFigure(self: Board, which: Int): Position{
    let y: Int = 0;
    let row: Row = self.y1;
    while(y < 8){
        if row.a == which{
            return Position{x: 0, y};
        }
        if row.b == which{
            return Position{x: 1, y};
        }
        if row.c == which{
            return Position{x: 2, y};
        }
        if row.d == which{
            return Position{x: 3, y};
        }
        if row.e == which{
            return Position{x: 4, y};
        }
        if row.f == which{
            return Position{x: 5, y};
        }
        if row.g == which{
            return Position{x: 6, y};
        }
        if row.h == which{
            return Position{x: 7, y};
        }
        if(y == 0){
            row = self.y2;
        } else if(y == 1){
            row = self.y3;
        } else if(y == 2){
            row = self.y4;
        } else if(y == 3){
            row = self.y5;
        } else if(y == 4){
            row = self.y6;
        } else if(y == 5){
            row = self.y7;
        } else if(y == 6){
            row = self.y8;
        }
        y += 1;
    }
    require(false, "Figure not found");
    return Position{x: 0, y: 0};
}

inline fun startBoard(): Board{
    return Board{
        y1: Row{
            a: SPOT_ROOK_WHITE,
            b: SPOT_KNIGHT_WHITE,
            c: SPOT_BISHOP_WHITE,
            d: SPOT_QUEEN_WHITE,
            e: SPOT_KING_WHITE,
            f: SPOT_BISHOP_WHITE,
            g: SPOT_KNIGHT_WHITE,
            h: SPOT_ROOK_WHITE
        },
        y2: Row{
            a: SPOT_PAWN_WHITE,
            b: SPOT_PAWN_WHITE,
            c: SPOT_PAWN_WHITE,
            d: SPOT_PAWN_WHITE,
            e: SPOT_PAWN_WHITE,
            f: SPOT_PAWN_WHITE,
            g: SPOT_PAWN_WHITE,
            h: SPOT_PAWN_WHITE
        },
        y3: emptyRow(),
        y4: emptyRow(),
        y5: emptyRow(),
        y6: emptyRow(),
        y7: Row{
            a: SPOT_PAWN_BLACK,
            b: SPOT_PAWN_BLACK,
            c: SPOT_PAWN_BLACK,
            d: SPOT_PAWN_BLACK,
            e: SPOT_PAWN_BLACK,
            f: SPOT_PAWN_BLACK,
            g: SPOT_PAWN_BLACK,
            h: SPOT_PAWN_BLACK
        },
        y8: Row{
            a: SPOT_ROOK_BLACK,
            b: SPOT_KNIGHT_BLACK,
            c: SPOT_BISHOP_BLACK,
            d: SPOT_QUEEN_BLACK,
            e: SPOT_KING_BLACK,
            f: SPOT_BISHOP_BLACK,
            g: SPOT_KNIGHT_BLACK,
            h: SPOT_ROOK_BLACK
        }
    };
}


inline fun emptyRow(): Row{
    return Row{a:0};
}






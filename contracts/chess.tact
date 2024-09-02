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
    x: Int as int8;
    y: Int as int8;
}
extends inline fun toInt(self: Position): Int{
    return (self.y << 3) + self.x;
}
extends inline fun positionFromInt(self: Int): Position{
    return Position{x: self & 0x7, y: self >>3};
}

struct Board{

    //lets store the board as 8 rows * 8 columns * 4 bits per cell
    game: Int as uint256;
}
struct Move{
    fromX: Int as uint8;
    fromY: Int as uint8;
    toX: Int as uint8;
    toY: Int as uint8;
}

extends inline fun from(self: Move): Position{
    return Position{x: self.fromX, y: self.fromY};
}
extends inline fun to(self: Move): Position{
    return Position{ x: self.toX, y: self.toY};
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
    whiteCanCastleKing: Bool = true;
    whiteCanCastleQueen: Bool = true;
    blackCanCastleKing: Bool = true;
    blackCanCastleQueen: Bool = true;
    halfMoveClock: Int as uint16 = 0;

}


extends fun move(self: Game, mv: Move, lastMove: Move, promotionTo: Int): Game{
    let piece: Int = self.board.at(mv.fromX, mv.fromY);
    let target: Int = self.board.at(mv.toX, mv.toY);
    require(!piece.isEmpty(), "No piece at the source position");

    // check that this is even move
    require(mv.fromY != mv.toY || mv.fromX != mv.toX, "Not a move at all");

    // moving black
    if(piece.isBlack()) {
        require(!self.whiteTurn, "It's white's turn to move");
        require(!target.isBlack(), "Cannot capture a piece of the same color");
    }
    else {
        require(self.whiteTurn, "It's black's turn to move");
        require(!target.isWhite(), "Cannot capture a piece of the same color");
    }
    if(piece.isPawn()){
        requireCanMovePawn(self, mv, lastMove, self.whiteTurn);
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
        requireCanMoveKing(self, mv, self.whiteTurn);
    }
    else if(piece.isQueen()){
        requireCanMoveQueen(self, mv);
    }
    else {
        require(false, "Uknown piece moved!");
    }

    //castling logic + moves set
    if piece.isKing(){
        if(self.whiteTurn){
            self.whiteCanCastleKing = false;
            self.whiteCanCastleQueen = false;
        }
        else{
            self.blackCanCastleKing = false;
            self.blackCanCastleQueen = false;
        }
        if(mv.deltaXABS() == 2){
            //TODO: add castling logic (move rock)
            if(mv.toX > mv.fromX){
                let rook = self.board.at(7, mv.fromY);
                self.board.set(7, mv.fromY, SPOT_EMPTY);
                self.board.set(5, mv.fromY, rook);
            }
            else{
                let rook = self.board.at(0, mv.fromY);
                self.board.set(0, mv.fromY, SPOT_EMPTY);
                self.board.set(3, mv.fromY, rook);
            }
        }

        self.board.set(mv.fromX, mv.fromY, SPOT_EMPTY);
        self.board.set(mv.toX, mv.toY, piece);
    }
    else if piece.isRook(){
        //Castling logic
        if(self.whiteTurn){
            if(mv.fromX == 0){
                self.whiteCanCastleQueen = false;
            }
            else if(mv.fromX == 7){
                self.whiteCanCastleKing = false;
            }
        }
        else{
            if(mv.fromX == 0){
                self.blackCanCastleQueen = false;
            }
            else if(mv.fromX == 7){
                self.blackCanCastleKing = false;
            }
        }
        self.board.set(mv.fromX, mv.fromY, SPOT_EMPTY);
        self.board.set(mv.toX, mv.toY, piece);
    }
    else if piece.isPawn() {
        if(mv.toY == 0 || mv.toY == 7){
            if self.whiteTurn {
                require(promotionTo == SPOT_ROOK_WHITE || promotionTo == SPOT_KNIGHT_WHITE || promotionTo == SPOT_BISHOP_WHITE || promotionTo == SPOT_QUEEN_WHITE, "Invalid promotion piece");
            }
            else {
                require(promotionTo == SPOT_ROOK_BLACK || promotionTo == SPOT_KNIGHT_BLACK || promotionTo == SPOT_BISHOP_BLACK || promotionTo == SPOT_QUEEN_BLACK, "Invalid promotion piece");
            }

            self.board.set(mv.fromX, mv.fromY, SPOT_EMPTY);
            self.board.set(mv.toX, mv.toY, promotionTo);
        }
        else{
            self.board.set(mv.fromX, mv.fromY, SPOT_EMPTY);
            self.board.set(mv.toX, mv.toY, piece);
            if(target.isEmpty() && mv.deltaXABS() == 1 && mv.deltaYABS() == 1){
                //en passant
                let enPassantY = self.whiteTurn ? mv.toY - 1 : mv.toY + 1;
                self.board.set(mv.toX, enPassantY, SPOT_EMPTY);
            }
        }
    }
    else {
        self.board.set(mv.fromX, mv.fromY, SPOT_EMPTY);
        self.board.set(mv.toX, mv.toY, piece);
    }
    // if someone ate rock, we need to update castling flags
    if target.isRook() {
        // white ate black rock at a8 or h8
        if (self.whiteTurn && mv.toY == 7 && (mv.toX == 7 || mv.toX == 0)){
            if mv.toX == 7{
                self.blackCanCastleKing = false;
            }
            else {
                self.blackCanCastleQueen = false;
            }

        }
        // black ate white rock at a1 or h1
        if (!self.whiteTurn && mv.toY == 0 && (mv.toX == 7 || mv.toX == 0)){
            if mv.toX == 7 {
                self.whiteCanCastleKing = false;
            }
            else {
                self.whiteCanCastleQueen = false;
            }
        }

    }
    // increase halfMoveClock if no pawn was moved and no piece was captured
    self.halfMoveClock = (!piece.isPawn() && target.isEmpty()) ? self.halfMoveClock + 1 : 0;
    // check if the move is valid after the move, i.e. the king is not under attack
    requirePositionStillValid(self, self.whiteTurn);
    self.whiteTurn = !self.whiteTurn;

    return self;
}



//This function returns SPOT_* constants at position x, y on the board (0-based)
extends fun at(self: Board, x: Int, y: Int): Int{
    require(x >= 0 && x <= 7, "x must be between 0 and 7");
    require(y >= 0 && y <= 7, "y must be between 0 and 7");
    let offset: Int = 4 * (8 * y + x);
    let shifted = self.game >> offset;
    return shifted & 0xF;
}

extends mutates fun set(self: Board, x: Int, y: Int, value: Int): Board{
    require(x >= 0 && x <= 7, "x must be between 0 and 7");
    require(y >= 0 && y <= 7, "y must be between 0 and 7");
    //clear the bits at the position
    let gameWithZeroAtBit = self.game & ~(0xF << (4 * (8 * y + x)));
    //set the bits at the position
    self.game = gameWithZeroAtBit | (value << (4 * (8 * y + x)));
    return self;
}
extends fun findFigure(self: Board, which: Int): Position{
    let gameOld = self.game;
    let y=0;

    while(y < 8){
        let x=0;
        while(x < 8){
            let figure = gameOld & 0xF;
            if(figure == which){
                return Position{
                x: x, y: y};
            }
            gameOld = gameOld >> 4;
            x = x + 1;
        }
        y = y + 1;
    }
    require(false, "Figure not found");
    return Position{
    x: 0, y: 0};
}

//inline fun startBoard(): Board{
//    let g = 0;
//    g = g | SPOT_ROOK_WHITE;
//    g = g | (SPOT_KNIGHT_WHITE << 4);
//    g = g | (SPOT_BISHOP_WHITE << 8);
//    g = g | (SPOT_QUEEN_WHITE << 12);
//    g = g | (SPOT_KING_WHITE << 16);
//    g = g | (SPOT_BISHOP_WHITE << 20);
//    g = g | (SPOT_KNIGHT_WHITE << 24);
//    g = g | (SPOT_ROOK_WHITE << 28);
//
//    g = g | (SPOT_PAWN_WHITE << 32);
//    g = g | (SPOT_PAWN_WHITE << 36);
//    g = g | (SPOT_PAWN_WHITE << 40);
//    g = g | (SPOT_PAWN_WHITE << 44);
//    g = g | (SPOT_PAWN_WHITE << 48);
//    g = g | (SPOT_PAWN_WHITE << 52);
//    g = g | (SPOT_PAWN_WHITE << 56);
//    g = g | (SPOT_PAWN_WHITE << 60);
//
//    g = g | (SPOT_ROOK_BLACK << (256 - 4));
//    g = g | (SPOT_KNIGHT_BLACK << (256 - 8));
//    g = g | (SPOT_BISHOP_BLACK << (256 - 12));
//    g = g | (SPOT_KING_BLACK << (256 - 16));
//    g = g | (SPOT_QUEEN_BLACK << (256 - 20));
//    g = g | (SPOT_BISHOP_BLACK << (256 - 24));
//    g = g | (SPOT_KNIGHT_BLACK << (256 - 28));
//    g = g | (SPOT_ROOK_BLACK << (256 - 32));
//
//    g = g | (SPOT_PAWN_BLACK << (256 - 36));
//    g = g | (SPOT_PAWN_BLACK << (256 - 40));
//    g = g | (SPOT_PAWN_BLACK << (256 - 44));
//    g = g | (SPOT_PAWN_BLACK << (256 - 48));
//    g = g | (SPOT_PAWN_BLACK << (256 - 52));
//    g = g | (SPOT_PAWN_BLACK << (256 - 56));
//    g = g | (SPOT_PAWN_BLACK << (256 - 60));
//    g = g | (SPOT_PAWN_BLACK << (256 - 64));
//    return Board{
//    game: g};
//}
inline fun startBoard(): Board{
    return Board{game: 0x42365324111111110000000000000000000000000000000077777777a89cb98a};
}







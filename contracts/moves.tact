inline fun canMoveRock(game: Game, move: Move): Bool{
    let deltaX: Int = move.toX - move.fromX;
    let deltaY: Int = move.toY - move.fromY;
    //if both are non-zero, then it is not a rook move
    if(deltaX != 0 && deltaY != 0 ){
        return false;
    }
    if(deltaX != 0 ){
        let i = (deltaX > 0 ? 1 : -1);
        repeat(abs(deltaX)-1){
            let x: Int = move.fromX + i;
            let y: Int = move.fromY;
            if !game.board.at(x, y).isEmpty(){
                return false;
            }

            i += (deltaX > 0 ? 1 : -1);
        }
    }
    else{
        let i = (deltaY > 0 ? 1 : -1);
        repeat(abs(deltaY)-1){
            let x: Int = move.fromX;
            let y: Int = move.fromY + i;
            if !game.board.at(x, y).isEmpty(){
                return false;
            }
            i += (deltaY > 0 ? 1 : -1);
        }
    }
    return true;
}
inline fun canMoveBishop(game: Game, move: Move): Bool{
    let countX = move.deltaXABS();
    if countX != move.deltaYABS() {
        return false;
    }
    let signX: Int = (move.toX - move.fromX)>0?1:-1;
    let signY: Int = (move.toY - move.fromY)>0?1:-1;
    let x =move.fromX;
    let y =move.fromY;
    repeat(abs(countX)-1){
        x += signX;
        y += signY;

        if !game.board.at(x, y).isEmpty(){
            return false;
        }
    }
    return true;

}
inline fun canMoveKnight(game: Game, move: Move): Bool{
    let deltaX: Int = move.deltaXABS();
    let deltaY: Int = move.deltaYABS();
    return deltaX + deltaY == 3 && deltaX != 0 && deltaY != 0;
}
inline fun canMovePawn(game: Game, move: Move, lastMove: Move, isWhite: Bool): Bool{
    if(move.fromX != move.toX){
        //moving horizontaly - only if eating someone
        if!(move.toY == move.fromY + (isWhite?1:-1)){
            return false;
        }
        if(abs(move.fromX - move.toX) != 1) {
            return false;
        }
        //checks that it actially eats the figure
        if !(
        //the target should be non-empty
        !game.board.at(move.toX, move.toY).isEmpty() ||
        // En passant
        (
        // on the destination space - 1 pawn exists
        game.board.at(move.toX, move.toY + (isWhite?-1:1)) == (isWhite?SPOT_PAWN_BLACK:SPOT_PAWN_WHITE) &&
        game.board.at(lastMove.toX, lastMove.toY).isPawn() &&

        lastMove.fromX == move.toX &&
        lastMove.toX == move.toX &&
        lastMove.fromY == move.toY + (isWhite?1:-1) &&
        lastMove.toY == move.toY + (isWhite?-1:1)
        )
        ){
            return false;
        }
    }
    else if(move.toY == move.fromY + (isWhite?2:-2)) {
        if!(
        move.fromY == (isWhite?1:6) && game.board.at(move.fromX, isWhite?2:5).isEmpty() && game.board.at(move.fromX, isWhite?3:4).isEmpty()
        ){
            return false;
        }
    }
    else {
        if !(move.toY == move.fromY + (isWhite?1:-1)){
            return false;
        }
        if!(game.board.at(move.toX, move.toY).isEmpty()){
            return false
        }
    }
    return true;

}

//checks that pawn can do a move
inline fun requireCanMovePawn(game: Game, move: Move, lastMove: Move, isWhite: Bool){
    require(canMovePawn(game, move, lastMove, isWhite), "Invalid pawn move");
}

//checks that knight can do a move
inline fun requireCanMoveKnight(game: Game, move: Move){
    require(canMoveKnight(game, move), "Invalid knight move");
}

//checks that bishop can do a move
inline fun requireCanMoveBishop(game: Game, move: Move){
    require(canMoveBishop(game, move), "Invalid bishop move");
}

//checks that rock can do a move
inline fun requireCanMoveRook(game: Game, move: Move){
    require(canMoveRock(game, move), "Invalid rook move");
}

//checks that king can do a move
inline fun requireCanMoveKing(game: Game, move: Move, isWhite: Bool){
    if(move.deltaXABS() <= 1 && move.deltaYABS() <= 1){
        //pass, everything is fine, move is valid
    }
    else {
        //check for castling
        require(move.deltaXABS() == 2 && move.deltaYABS() == 0, "Invalid castle move");
        require(game.board.isUnderAttack(move.from(), !isWhite) ==0, "Castling through check");

        if(move.toX > move.fromX){
            //king side castle
            require(isWhite?game.whiteCanCastleKing:game.blackCanCastleKing, "No rights for castling");
            require(game.board.at(move.fromX+1, move.fromY).isEmpty(), "Castling through figures");
            require(game.board.at(move.fromX+2, move.fromY).isEmpty(), "Castling through figures");
            require(game.board.isUnderAttack(Position{
            x: move.fromX+1, y: move.fromY }, !isWhite) == 0, "Castling through check");
        }
        else{
            //queen side castle
            require(isWhite?game.whiteCanCastleQueen:game.blackCanCastleQueen, "No rights for castling");
            require(game.board.at(move.fromX-1, move.fromY).isEmpty(), "Castling through figures");
            require(game.board.at(move.fromX-2, move.fromY).isEmpty(), "Castling through figures");
            require(game.board.isUnderAttack(Position{
            x: move.fromX-1, y: move.fromY }, !isWhite) == 0, "Castling through check");
        }

    }
}

//checks that queen can do a move
inline fun requireCanMoveQueen(game: Game, move: Move){
    require(canMoveRock(game, move) || canMoveBishop(game, move), "Invalid queen move");
}


//checks, that after move king is not under attack
inline fun requirePositionStillValid(game: Game, checkWhite: Bool){
    let king = game.board.findFigure(checkWhite? SPOT_KING_WHITE: SPOT_KING_BLACK);
    require(game.board.isUnderAttack(king, !checkWhite)==0, "King is under attack");
}


//checks, that the spot is under attack (true if it is)
//set isWhite to true, if you want to check if BLACK figure is under WHITE attack
extends inline fun isUnderAttack(self: Board, pos: Position, isWhite: Bool): Int{
    // Lets suppose, that there are NO situation, when there are more than 2 figures attacking the spot
    // Also we'll use assumption, that there are no 2 figures of the same type attacking the spot
    let i: Int = 0;
    //check that there are no knights nearby, that can attack the spot
    let position: Position? = isKnightNearby(self, pos, isWhite);
    let shift = 0;
    if position != null{
        i = (isWhite ? SPOT_KNIGHT_WHITE : SPOT_KNIGHT_BLACK) << (shift);
        i |= position!!.toInt() << (shift+8);
        shift += 16;
    }
    //check that there is no king nearby
    position=kingNearby(self, pos, isWhite);
    if position != null{
        i |= (isWhite?SPOT_KING_WHITE:SPOT_KING_BLACK) << shift;
        i |= position!!.toInt() << (shift+8);
        shift += 16;
    }
    //check that there is no pawn nearby
    position = isPawnNearby(self, pos, isWhite);
    if position != null {
        i |= (isWhite?SPOT_PAWN_WHITE:SPOT_PAWN_BLACK) << shift;
        i |= position!!.toInt() << (shift+8);
        shift += 16;
    }
    // check that there is no rock/queen, that can attack the spot
    // goes vertically and horizontally
    let maybeQueen: MaybeQueen= isRockOrQueenNearby(self, pos, isWhite);
    if maybeQueen.position != null{
        i |= (isWhite?(!maybeQueen.isQueen?SPOT_ROOK_WHITE:SPOT_QUEEN_WHITE):(!maybeQueen.isQueen?SPOT_ROOK_BLACK:SPOT_QUEEN_WHITE)) << shift;
        i |= maybeQueen.position!!.toInt() << (shift+8);
        shift += 16;
    }
    //check that there is no bishop/queen, that can attack the spot
    //goes diagonally
    maybeQueen = isBishopOrQueenNearby(self, pos, isWhite);
    if maybeQueen.position != null{
        i |= (isWhite?(!maybeQueen.isQueen?SPOT_BISHOP_WHITE:SPOT_QUEEN_WHITE):(!maybeQueen.isQueen?SPOT_BISHOP_BLACK:SPOT_QUEEN_WHITE)) << shift;
        i |= maybeQueen.position!!.toInt() << (shift+8);
        shift += 16;
    }

    return i;
}
struct MaybeQueen{
    position: Position?;
    isQueen: Bool;
}
inline fun isRockOrQueenNearby(board: Board, position: Position, isWhite: Bool): MaybeQueen{
    //TODO: add queen also here
    let ROCK = isWhite ? SPOT_ROOK_WHITE: SPOT_ROOK_BLACK;
    let QUEEN = isWhite ? SPOT_QUEEN_WHITE: SPOT_QUEEN_BLACK;
    let x: Int = position.x + 1;
    let y: Int = position.y;
    let valid: Bool = true;
    //check horizontal
    while (x < 8 && valid) {
        let spot = board.at(x, y);
        if spot == ROCK || spot == QUEEN {
            return MaybeQueen{
            position: Position{
            x, y}, isQueen: spot == QUEEN};
        }
        if !spot.isEmpty(){
            valid = false;
        }
        x += 1;
    }
    //chec other horizontal
    x = position.x - 1;
    valid = true;
    while (x >= 0 && valid) {
        let spot = board.at(x, y);
        if spot == ROCK || spot == QUEEN {
            return MaybeQueen{
            position: Position{
            x, y}, isQueen: spot == QUEEN};
        }
        if !spot.isEmpty(){
            valid = false;
        }
        x -= 1;
    }
    x = position.x;
    y = position.y + 1;
    valid = true;
    while (y < 8 && valid) {
        let spot = board.at(x, y);
        if spot == ROCK || spot == QUEEN {
            return MaybeQueen{
            position: Position{
            x, y}, isQueen: spot == QUEEN};
        }
        if !spot.isEmpty(){
            valid=false;
        }
        y += 1;
    }
    y = position.y - 1;
    valid = true;
    while (y >= 0 && valid) {
        let spot = board.at(x, y);
        if spot == ROCK || spot == QUEEN {
            return MaybeQueen{
            position: Position{
            x, y}, isQueen: spot == QUEEN};
        }
        if !board.at(x, y).isEmpty(){
            valid = false;
        }
        y -= 1;
    }
    return MaybeQueen{
    position: null, isQueen: false};
}
//checks, that there is a pawn at the any position on the board, that can attack the spot `position`
inline fun isPawnNearby(board: Board, position: Position, isWhite: Bool): Position?{
    if(isWhite){
        let x: Int = position.x - 1;
        let y: Int = position.y - 1;
        if x >= 0 && y >= 0 && board.at(x, y) == SPOT_PAWN_WHITE {
            return Position{
            x, y};
        }
        x = position.x + 1;
        if x < 8 && y >= 0 && board.at(x, y) == SPOT_PAWN_WHITE {
            return Position{
            x, y};
        }
    }
    else{
        let x: Int = position.x - 1;
        let y: Int = position.y + 1;
        if x >= 0 && y < 8 && board.at(x, y) == SPOT_PAWN_BLACK {
            return Position{
            x, y};
        }
        x = position.x + 1;
        if x < 8 && y < 8 && board.at(x, y) == SPOT_PAWN_BLACK {
            return Position{
            x, y};
        }
    }
    return null;
}

//checks, that there is a knight at the any position on the board, that can attack the spot `position`
inline fun isKnightNearby(board: Board, position: Position, isWhite: Bool): Position?{
    let KN = (isWhite ? SPOT_KNIGHT_WHITE: SPOT_KNIGHT_BLACK);
    let x: Int = position.x - 2;
    let y: Int = position.y - 1;
    if x>= 0 && y >= 0 && board.at(x, y) == KN  {
        return Position{
        x, y};
    }
    x = position.x + 2;
    if x<8 && y >= 0 && board.at(x, y) == KN {
        return Position{
        x, y};
    }
    y = position.y + 1;
    if x<8 && y<8 && board.at(x, y) == KN {
        return Position{
        x,y};
    }
    x = position.x - 2;
    if x>= 0 && y<8 && board.at(x, y) == KN {
        return Position{
        x,y};
    }
    x = position.x - 1;
    y = position.y - 2;
    if x>= 0 && y >= 0 && board.at(x, y) == KN {
        return Position{
        x,y};
    }
    y = position.y + 2;
    if x>= 0 && y<8 && board.at(x, y) == KN {
        return Position{
        x,y};
    }
    x = position.x + 1;
    if x<8 && y<8 && board.at(x, y) == KN {
        return Position{
        x,y};
    }
    y = position.y - 2;
    if x<8 && y >= 0 && board.at(x, y) == KN {
        return Position{
        x,y};
    }
    return null;

}

inline fun isBishopOrQueenNearby(board: Board, position: Position, isWhite: Bool): MaybeQueen{
    let BISHOP = isWhite ? SPOT_BISHOP_WHITE: SPOT_BISHOP_BLACK;
    let QUEEN = isWhite ? SPOT_QUEEN_WHITE: SPOT_QUEEN_BLACK;
    let x: Int = position.x + 1;
    let y: Int = position.y + 1;
    let valid: Bool = true;
    //check diagonal
    while (x < 8 && y < 8 && valid) {
        let spot = board.at(x, y);
        if spot == BISHOP || spot == QUEEN {
            return MaybeQueen{
            position: Position{
            x, y}, isQueen: spot == QUEEN};
        }
        if !spot.isEmpty(){
            valid = false;
        }
        x += 1;
        y += 1;
    }
    //check other diagonal
    x = position.x - 1;
    y = position.y - 1;
    valid = true;
    while (x >= 0 && y >= 0 && valid) {
        let spot = board.at(x, y);
        if spot == BISHOP || spot == QUEEN {
            return MaybeQueen{
            position: Position{
            x, y}, isQueen: spot == QUEEN};
        }
        if !spot.isEmpty(){
            valid = false;
        }
        x -= 1;
        y -= 1;
    }
    x = position.x + 1;
    y = position.y - 1;
    valid = true;
    while (x < 8 && y >= 0 && valid) {
        let spot = board.at(x, y);
        if spot == BISHOP || spot == QUEEN {
            return MaybeQueen{
            position: Position{
            x, y}, isQueen: spot == QUEEN};
        }
        if !spot.isEmpty(){
            valid = false;
        }
        x += 1;
        y -= 1;
    }
    x = position.x - 1;
    y = position.y + 1;
    valid = true;
    while (x >= 0 && y < 8 && valid) {
        let spot = board.at(x, y);
        if spot == BISHOP || spot == QUEEN {
            return MaybeQueen{
            position: Position{
            x, y}, isQueen: spot == QUEEN};
        }
        if !spot.isEmpty(){
            valid = false;
        }
        x -= 1;
        y += 1;
    }
    return MaybeQueen{
    position: null, isQueen: false};
}

//checks, that there is a king nearby
inline fun kingNearby(board: Board, position: Position, isWhite: Bool): Position?{
    let KNG = isWhite ? SPOT_KING_WHITE: SPOT_KING_BLACK;
    let x: Int = position.x - 1;
    let y: Int = position.y - 1;
    if x >= 0 && y >= 0 && board.at(x, y) == KNG{
        return Position{
        x, y};
    }
    x = position.x;
    if y >= 0 && board.at(x, y) == KNG {
        return Position{
        x, y};
    }
    x = position.x + 1;
    if y >= 0 && x < 8 && board.at(x, y) == KNG {
        return Position{
        x,y};
    }
    y = position.y;
    if x < 8 && board.at(x, y) == KNG {
        return Position{
        x,y};
    }
    y = position.y + 1;
    if x < 8 && y < 8 && board.at(x, y) == KNG {
        return Position{
        x,y};
    }
    x = position.x;
    if y < 8 && board.at(x, y) == KNG {
        return Position{
        x,y};
    }
    x = position.x - 1;
    if y < 8 && x >= 0 && board.at(x, y) == KNG {
        return Position{
        x,y};
    }
    y = position.y;
    if x >= 0 && board.at(x, y) == KNG {
        return Position{
        x,y};
    }
    return null;
}

//checks, that the king at position `king` can move and run away from the attack
inline fun canMoveKingAndNoCheckMate(board: Board, king: Position, isWhite: Bool): Bool{
    //check all possible moves of the king
    let x: Int = king.x - 1;
    repeat(3){
        if(x >= 0 && x <= 7){
            let y: Int = king.y - 1;
            repeat(3){
                if(y >= 0 && y <= 7){
                    let point = board.at(x, y);
                    //check that not the same spot  &&  (spot is empty || spot is of the opposite color)
                    if (y != king.y || x != king.x) && (point.isEmpty() || (isWhite?point.isBlack():point.isWhite())){
                        let newBoard = board;
                        newBoard.set(king.x, king.y, SPOT_EMPTY);
                        newBoard.set(x, y, isWhite?SPOT_KING_WHITE:SPOT_KING_BLACK);
                        //if king moved and noone can attack him, then it is not a checkmate
                        if newBoard.isUnderAttack(Position{
                        x, y}, !isWhite) == 0 {
                            return true;
                        }
                    }
                }
                y += 1;
            }
        }
        x += 1;
    }
    return false;
}

inline fun noCheckAfterMove(kingPosition: Position, board: Game, move: Move, isWhite: Bool): Bool{
    let newBoard = board.board;
    let figure = newBoard.at(move.fromX, move.fromY);
    newBoard.set(move.fromX, move.fromY, SPOT_EMPTY);
    newBoard.set(move.toX, move.toY, figure);
    return newBoard.isUnderAttack(kingPosition, !isWhite) == 0;
}
//checks, that there is a figure, that can go at the position `whom` without additional king checks
extends inline fun someoneCanEat(self: Game, kingPosition: Position, someoneWhite: Bool, whom: Position, lastMove: Move): Bool{
    //for each figure on the board, check if it can eat the figure at position `whom`
    let y = 0;
    repeat(8){
        let x = 0;
        repeat(8){
            let figure = self.board.at(x, y);
            if (someoneWhite?figure.isWhite():figure.isBlack()){
                if figure.isKing(){
                    //king can't eat anyone
                }
                else if figure.isKnight(){
                    let move = Move{ fromX: x, fromY: y, toX: whom.x, toY: whom.y};
                    if canMoveKnight(self, move) && noCheckAfterMove(kingPosition, self, move, someoneWhite) {
                        return true;
                    }
                }
                else if figure.isBishop(){
                    let move = Move{ fromX: x, fromY: y, toX: whom.x, toY: whom.y};
                    if canMoveBishop(self, move) && noCheckAfterMove(kingPosition, self, move, someoneWhite) {
                        return true;
                    }
                }
                else if figure.isRook(){
                    let move = Move{ fromX: x, fromY: y, toX: whom.x, toY: whom.y};
                    if canMoveRock(self, move) && noCheckAfterMove(kingPosition, self, move, someoneWhite) {
                        return true;
                    }
                }
                else if figure.isQueen(){
                    let move = Move{ fromX: x, fromY: y, toX: whom.x, toY: whom.y};
                    if (canMoveRock(self, move) || canMoveBishop(self, move)) && noCheckAfterMove(kingPosition, self, move, someoneWhite) {
                        return true;
                    }
                }
                else if figure.isPawn(){
                    let move = Move{ fromX: x, fromY: y, toX: whom.x, toY: whom.y};
                    if canMovePawn(self, move, lastMove, someoneWhite) && noCheckAfterMove(kingPosition, self, move, someoneWhite) {
                        return true;
                    }
                }

            }
            x += 1;
        }
        y += 1;
    }
    return false;
}

//check that isWhite king is under checkmate
extends inline fun isCheckMate(self: Game, isWhite: Bool, lastMove: Move): Bool{
    let board = self.board;
    let king = board.findFigure(isWhite?SPOT_KING_WHITE:SPOT_KING_BLACK);
    let attackFigures = board.isUnderAttack(king, !isWhite);
    if attackFigures == 0{
        return false;
    }
    //lets check, if one can move the king and get no checks
    if canMoveKingAndNoCheckMate(board, king, isWhite){
        return false;
    }
    let firstAttackFigure: Int = attackFigures & 0xFF;
    let firstAttackPosition: Position = ((attackFigures >> 8) & 0xFF).positionFromInt();

    let secondAttackFigure: Int = (attackFigures >> 16) & 0xFF;

    //if there are 2 figures, that attack the king, and king is not able to move away then it is defenetly a checkmate
    if(secondAttackFigure != 0){
        dump("Double check checkmate");
        return true;
    }
    // now there is only one figure that attacks the king
    // one should check, if it is possible either to eat this figure or to protect the king by setting a figure between the king and the attacker

    // check that someone can "eat" the attacker
    if self.someoneCanEat(king, isWhite, firstAttackPosition, lastMove){
        return false;
    }
    // El passant check - one can eat pawn by moving to the square behind the pawn
    if firstAttackFigure.isPawn(){
        if(
            firstAttackPosition.x >= 1 && board.at(firstAttackPosition.x - 1, firstAttackPosition.y).isPawn() &&
            (isWhite?board.at(firstAttackPosition.x - 1, firstAttackPosition.y).isWhite():board.at(firstAttackPosition.x - 1, firstAttackPosition.y).isBlack())
        ){
            if canMovePawn(self, Move{ fromX: firstAttackPosition.x - 1, fromY: firstAttackPosition.y, toX: firstAttackPosition.x, toY: firstAttackPosition.y +(isWhite?1:-1) }, lastMove, isWhite){
                return false;
            }
        }
        if(
            firstAttackPosition.x <= 6 && board.at(firstAttackPosition.x + 1, firstAttackPosition.y).isPawn() &&
            (isWhite?board.at(firstAttackPosition.x + 1, firstAttackPosition.y).isWhite():board.at(firstAttackPosition.x + 1, firstAttackPosition.y).isBlack())
        ){
            if canMovePawn(self, Move{ fromX: firstAttackPosition.x + 1, fromY: firstAttackPosition.y, toX: firstAttackPosition.x, toY: firstAttackPosition.y +(isWhite?1:-1) }, lastMove, isWhite){
                return false;
            }
        }
    }
    // check that the figure attacks the king "horiontally" or "vertically" and it is possible, protect the king by setting a figure between the attacker and the king
    if firstAttackFigure.isRook() || (firstAttackFigure.isQueen() && (firstAttackPosition.x == king.x || firstAttackPosition.y == king.y)){
        //vertically and non close
        if(firstAttackPosition.x == king.x){
            //vertical attack
            let delta = (firstAttackPosition.y > king.y ? 1 : -1);
            let y: Int = king.y;
            let x: Int = king.x;
            repeat(abs(firstAttackPosition.y - king.y) - 1){
                y += delta;
                if self.someoneCanEat(king, isWhite, Position{x, y}, lastMove){
                    return false;
                }
            }
        }
        //horizontally
        if(firstAttackPosition.y == king.y){
            //horizontal attack
            let delta = (firstAttackPosition.x > king.x ? 1 : -1);
            let y: Int = king.y;
            let x: Int = king.x;
            repeat(abs(firstAttackPosition.x - king.x) - 1){
                x += delta;
                if self.someoneCanEat(king, isWhite, Position{x, y}, lastMove){
                    return false;
                }
            }
        }
    }
    // check that the figure attacks the king "diagonally" and it is possible, protect the king by setting a figure between the attacker and the king
    if firstAttackFigure.isBishop() || (firstAttackFigure.isQueen() && (abs(firstAttackPosition.x - king.x) == abs(firstAttackPosition.y - king.y))){
        let deltaX = (firstAttackPosition.x > king.x ? 1 : -1);
        let deltaY = (firstAttackPosition.y > king.y ? 1 : -1);
        let x: Int = king.x;
        let y: Int = king.y;
        repeat(abs(firstAttackPosition.x - king.x) - 1){
            x += deltaX;
            y += deltaY;
            if self.someoneCanEat(king, isWhite, Position{x, y}, lastMove){
                return false;
            }
        }
    }

    //WOOF!!! It is a checkmate


    return true;
}
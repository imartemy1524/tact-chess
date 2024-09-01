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
//checks that pawn can do a move
inline fun requireCanMovePawn(game: Game, move: Move, lastMove: Move, isWhite: Bool){
    if(move.fromX != move.toX){
        //moving horizontaly - only if eating someone
        require(move.toY == move.fromY + (isWhite?1:-1), "To long move");
        require(abs(move.fromX - move.toX) == 1, "Invalid pawn move");
        //checks that it actially eats the figure
        require(
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
        ),
        "Invalid pawn move"
        );
    }
    else if(move.toY == move.fromY + (isWhite?2:-2)) {
        require(
        move.fromY == (isWhite?1:6) && game.board.at(move.fromX, isWhite?2:5).isEmpty() && game.board.at(move.fromX, isWhite?3:4).isEmpty(),
        "Invalid pawn move"
        );
    }
    else {
        require(move.toY == move.fromY + (isWhite?1:-1), "To long move");
        require(game.board.at(move.toX, move.toY).isEmpty(), "Invalid pawn move");
    }
}

//checks that knight can do a move
inline fun requireCanMoveKnight(game: Game, move: Move){
    let deltaX: Int = move.deltaXABS();
    let deltaY: Int = move.deltaYABS();
    require(deltaX + deltaY == 3 && deltaX != 0 && deltaY != 0, "Invalid knight move");
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
    else{
        //check for castling
        require(move.deltaXABS() == 2 && move.deltaYABS() == 0, "Invalid castle move");
        require(!game.board.isUnderAttack(move.from(), !isWhite), "Castling through check");

        if(move.toX > move.fromX){
            //king side castle
            require(isWhite?game.whiteCanCastleKing:game.blackCanCastleKing, "No rights for castling");
            require(game.board.at(move.fromX+1, move.fromY).isEmpty(), "Castling through figures");
            require(game.board.at(move.fromX+2, move.fromY).isEmpty(), "Castling through figures");
            require(!game.board.isUnderAttack(Position{ x: move.fromX+1, y: move.fromY }, !isWhite), "Castling through check");
        }
        else{
            //queen side castle
            require(isWhite?game.whiteCanCastleQueen:game.blackCanCastleQueen, "No rights for castling");
            require(game.board.at(move.fromX-1, move.fromY).isEmpty(), "Castling through figures");
            require(game.board.at(move.fromX-2, move.fromY).isEmpty(), "Castling through figures");
            require(!game.board.isUnderAttack(Position{x: move.fromX-1, y: move.fromY }, !isWhite), "Castling through check");
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
    require(!game.board.isUnderAttack(king, !checkWhite), "King is under attack");
}


//checks, that the spot is under attack (true if it is)
//set isWhite to true, if you want to check if BLACK figure is under WHITE attack
extends inline fun isUnderAttack(self: Board, position: Position, isWhite: Bool): Bool{
    //check that there are no knights nearby, that can attack the spot
    if isKnightNearby(self, position, isWhite){
        return true;
    }
    //check that there is no king nearby
    if kingNearby(self, position, isWhite){
        return true;
    }
    //check that there is no pawn nearby
    if isPawnNearby(self, position, isWhite){
        return true;
    }
    // check that there is no rock/queen, that can attack the spot
    // goes vertically and horizontally
    if isRockOrQueenNearby(self, position, isWhite){
        return true;
    }
    //check that there is no bishop/queen, that can attack the spot
    //goes diagonally
    if isBishopOrQueenNearby(self, position, isWhite){
        return true;
    }

    return false;
}
inline fun isRockOrQueenNearby(board: Board, position: Position, isWhite: Bool): Bool{
    //TODO: add queen also here
    let ROCK = isWhite ? SPOT_ROOK_WHITE: SPOT_ROOK_BLACK;
    let QUEEN = isWhite ? SPOT_QUEEN_WHITE: SPOT_QUEEN_BLACK;
    let x: Int = position.x + 1;
    let y: Int = position.y;
    let valid: Bool = true;
    //check horizontal
    while (x < 8 && valid) {
        if board.at(x, y) == ROCK || board.at(x, y) == QUEEN {
            return true;
        }
        if !board.at(x, y).isEmpty(){
            valid = false;
        }
        x += 1;
    }
    //chec other horizontal
    x = position.x - 1;
    valid = true;
    while (x >= 0 && valid) {
        if board.at(x, y) == ROCK || board.at(x, y) == QUEEN {
            return true;
        }
        if !board.at(x, y).isEmpty(){
            valid = false;
        }
        x -= 1;
    }
    x = position.x;
    y = position.y + 1;
    valid = true;
    while (y < 8 && valid) {
        if board.at(x, y) == ROCK || board.at(x, y) == QUEEN {
            return true;
        }
        if !board.at(x, y).isEmpty(){
            valid=false;
        }
        y += 1;
    }
    y = position.y - 1;
    valid = true;
    while (y >= 0 && valid) {
        if board.at(x, y) == ROCK || board.at(x, y) == QUEEN {
            return true;
        }
        if !board.at(x, y).isEmpty(){
            valid = false;
        }
        y -= 1;
    }
    return false;
}
//checks, that there is a pawn at the any position on the board, that can attack the spot `position`
inline fun isPawnNearby(board: Board, position: Position, isWhite: Bool): Bool{
    if(isWhite){
        let x: Int = position.x - 1;
        let y: Int = position.y - 1;
        if x >= 0 && y >= 0 && board.at(x, y) == SPOT_PAWN_WHITE {
            return true;
        }
        x = position.x + 1;
        if x < 8 && y >= 0 && board.at(x, y) == SPOT_PAWN_WHITE {
            return true;
        }
    }
    else{
        let x: Int = position.x - 1;
        let y: Int = position.y + 1;
        if x >= 0 && y < 8 && board.at(x, y) == SPOT_PAWN_BLACK {
            return true;
        }
        x = position.x + 1;
        if x < 8 && y < 8 && board.at(x, y) == SPOT_PAWN_BLACK {
            return true;
        }
    }
    return false;
}

//checks, that there is a knight at the any position on the board, that can attack the spot `position`
inline fun isKnightNearby(board: Board, position: Position, isWhite: Bool): Bool{
    let KN = (isWhite ? SPOT_KNIGHT_WHITE: SPOT_KNIGHT_BLACK);
    let x: Int = position.x - 2;
    let y: Int = position.y - 1;
    if x>= 0 && y >= 0 && board.at(x, y) == KN  {
        return true;
    }
    x = position.x + 2;
    if x<8 && y >= 0 && board.at(x, y) == KN {
        return true;
    }
    y = position.y + 1;
    if x<8 && y<8 && board.at(x, y) == KN {
        return true;
    }
    x = position.x - 2;
    if x>= 0 && y<8 && board.at(x, y) == KN {
        return true;
    }
    x = position.x - 1;
    y = position.y - 2;
    if x>= 0 && y >= 0 && board.at(x, y) == KN {
        return true;
    }
    y = position.y + 2;
    if x>= 0 && y<8 && board.at(x, y) == KN {
        return true;
    }
    x = position.x + 1;
    if x<8 && y<8 && board.at(x, y) == KN {
        return true;
    }
    y = position.y - 2;
    if x<8 && y >= 0 && board.at(x, y) == KN {
        return true;
    }
    return false;

}

inline fun isBishopOrQueenNearby(board: Board, position: Position, isWhite: Bool): Bool{
    let BISHOP = isWhite ? SPOT_BISHOP_WHITE: SPOT_BISHOP_BLACK;
    let QUEEN = isWhite ? SPOT_QUEEN_WHITE: SPOT_QUEEN_BLACK;
    let x: Int = position.x + 1;
    let y: Int = position.y + 1;
    let valid: Bool = true;
    //check diagonal
    while (x < 8 && y < 8 && valid) {
        if board.at(x, y) == BISHOP || board.at(x, y) == QUEEN {
            return true;
        }
        if !board.at(x, y).isEmpty(){
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
        if board.at(x, y) == BISHOP || board.at(x, y) == QUEEN {
            return true;
        }
        if !board.at(x, y).isEmpty(){
            valid = false;
        }
        x -= 1;
        y -= 1;
    }
    x = position.x + 1;
    y = position.y - 1;
    valid = true;
    while (x < 8 && y >= 0 && valid) {
        if board.at(x, y) == BISHOP || board.at(x, y) == QUEEN {
            return true;
        }
        if !board.at(x, y).isEmpty(){
            valid = false;
        }
        x += 1;
        y -= 1;
    }
    x = position.x - 1;
    y = position.y + 1;
    valid = true;
    while (x >= 0 && y < 8 && valid) {
        if board.at(x, y) == BISHOP || board.at(x, y) == QUEEN {
            return true;
        }
        if !board.at(x, y).isEmpty(){
            valid = false;
        }
        x -= 1;
        y += 1;
    }
    return false;
}

//checks, that there is a king nearby
inline fun kingNearby(board: Board, position: Position, isWhite: Bool): Bool{
    let KNG = isWhite ? SPOT_KING_WHITE: SPOT_KING_BLACK;
    let x: Int = position.x - 1;
    let y: Int = position.y - 1;
    if x >= 0 && y >= 0 && board.at(x, y) == KNG{
        return true;
    }
    x = position.x;
    if y >= 0 && board.at(x, y) == KNG {
        return true;
    }
    x = position.x + 1;
    if y >= 0 && x < 8 && board.at(x, y) == KNG {
        return true;
    }
    y = position.y;
    if x < 8 && board.at(x, y) == KNG {
        return true;
    }
    y = position.y + 1;
    if x < 8 && y < 8 && board.at(x, y) == KNG {
        return true;
    }
    x = position.x;
    if y < 8 && board.at(x, y) == KNG {
        return true;
    }
    x = position.x - 1;
    if y < 8 && x >= 0 && board.at(x, y) == KNG {
        return true;
    }
    y = position.y;
    if x >= 0 && board.at(x, y) == KNG {
        return true;
    }
    return false;
}
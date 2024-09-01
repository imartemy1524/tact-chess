import "@stdlib/deploy";

import "./chess.tact";
message MoveMsg{
    move: Move;
    promotion: Int as uint8 = 0;
}
struct GameResponse{
    game: Game;
    moves: map<Int as uint16, Move>;
    isCheckMate: Bool = false;
}

contract TactChess with Deployable {
    game: Game;
    moves: map<Int as uint16, Move> = emptyMap();
    movesLength: Int as uint16 = 0;
    init(){
        self.game = Game{
            board: startBoard()
        };
    }
    receive(move: MoveMsg){
        //TODO: check that sender is one of the players
        self.game = self.game.move(move.move, self.lastMove(), move.promotion);
        self.moves.set(self.movesLength, move.move);
        self.movesLength = self.movesLength + 1;
    }
    get fun game(): GameResponse{
        return GameResponse{
            game: self.game,
            moves: self.moves,
            isCheckMate: self.movesLength != 0 ? self.game.isCheckMate(self.game.whiteTurn, self.lastMove()): false
        };
    }

    inline fun lastMove(): Move{
        return self.movesLength != 0 ? self.moves.get(self.movesLength - 1)!!: Move{fromX: 0, fromY: 0, toX: 0, toY: 0};
    }

    // Empty init() function is present by default in all Tact contracts
    // since v1.3.0, so the following may be omitted:
    //
    // init() {}

    //TODO: add repeat moves checks
}





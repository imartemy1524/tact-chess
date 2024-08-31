import "@stdlib/deploy";

import "./chess.tact";
message MoveMsg{
    move: Move;
}
struct GameResponse{
    game: Game;
    moves: map<Int as uint16, Move>;
}

contract TactChess with Deployable {
    game: Game;
    moves: map<Int as uint16, Move> = emptyMap();
    lastMoveIndex: Int as uint16 = 0;
    init(){
        self.game = Game{
            board: startBoard()
        };
    }
    receive(move: MoveMsg){
        //TODO: check that sender is one of the players
        self.game = self.game.move(move.move, self.moves);
        self.moves.set(self.lastMoveIndex, move.move);
        self.lastMoveIndex = self.lastMoveIndex + 1;
    }
    get fun game(): GameResponse{
        return GameResponse{
            game: self.game,
            moves: self.moves
        };
    }

    // Empty init() function is present by default in all Tact contracts
    // since v1.3.0, so the following may be omitted:
    //
    // init() {}
}





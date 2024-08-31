import "@stdlib/deploy";

import "./chess.tact";
message MoveMsg{
    move: Move;
}

contract TactChess with Deployable {
    game: Game;

    init(){
        self.game = Game{
            board: startBoard()
        };
    }
    receive(move: MoveMsg){
        //TODO: check that sender is one of the players
        self.game = self.game.move(move.move);
    }
    // Empty init() function is present by default in all Tact contracts
    // since v1.3.0, so the following may be omitted:
    //
    // init() {}
}





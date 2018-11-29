import * as Server from "./server";
import * as MatchManager from "./match_manager";
import * as WaitRoom from "./wait_room";

love.load = function () {
    Server.init();
    MatchManager.init();
    WaitRoom.init();
};

love.update = function (dt: number) {
    Server.update();
};

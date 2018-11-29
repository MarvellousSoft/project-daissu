import * as sock from "../common/extra_libs/sock";

let server: sock.Socket;

export function init() {
    assert(server == null);

    server = sock.newServer("0.0.0.0", 47111);
    print("Starting server at port 47111");
    io.flush();
}

export function update() {
    server.update();
}

export function on(event: string, callback: (data: any, client: sock.Client) => void) {
    return server.on(event, callback);
}

export function removeCallback(callback: (data: any, client: sock.Client) => void) {
    server.removeCallback(callback);
}

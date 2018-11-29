declare class Socket {
    update(): void;
    on(event: string, callback: (...args: unknown[]) => void): void;
    removeCallback(callback: (...args: unknown[]) => void): void;
}
declare class Client {
    send(event: string, data: unknown): void;
    getConnectId(): number;
}

export function newServer(host: string, port: number): Socket;

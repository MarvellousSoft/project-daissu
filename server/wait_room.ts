import * as Server from './server';
import * as MatchManager from './match_manager';
import { Client } from 'common/extra_libs/sock';

class Room {
    name: string;
    clients: Set<Client>;
    constructor(name: string) {
        this.name = name;
        this.clients = new Set();
    }
}

const clients = new Map<Client, Room>();
const rooms = new Map<String, Room>();

function addClientToRoom(client: Client, room: string): void {
    if (!rooms.has(room))
        rooms.set(room, new Room(room));
    const r = rooms.get(room)!;
    clients.set(client, r);
    r.clients.add(client);
}

function remClientFromRoom(client: Client): void {
    const r = clients.get(client)!;
    clients.delete(client);
    r.clients.delete(client);
    if (r.name !== 'default' && r.clients.size === 0) {
        rooms.delete(r.name);
    }
}

function sendClientList(): void {
    const cl_list: Array<[Client, Room]> = [...clients.entries()];
    const list: Array<string> = [];
    for (const [client, room] of cl_list)
        list[client.getConnectId()] = room.name;
    for (const [client] of cl_list)
        client.send('client list', list);
}


export function init(): void {
    rooms['default'] = new Room('default');
    Server.on('connect', (data: never, client: Client) => {
        print('Client connected --', client);
        io.flush();
        addClientToRoom(client, 'default');
        sendClientList();
    });

    Server.on('change room', (room: string, client: Client) => {
        if (clients.get(client)!.name !== room) {
            print('Client', client, 'changing room to', room)
            remClientFromRoom(client);
            addClientToRoom(client, room);
            if (room !== 'default' && rooms.get(room)!.clients.size == 2) {
                const cls: [Client, Client][] = [...rooms.get(room)!.clients.entries()];
                const a = cls[0][0];
                const b = cls[1][0];
                remClientFromRoom(a);
                remClientFromRoom(b);
                MatchManager.startMatch(a, b);
            }
            sendClientList();
        }
    });
}
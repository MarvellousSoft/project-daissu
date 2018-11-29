import * as Server from "./server";
import { Client } from "common/extra_libs/sock";

class Match {
    cl_list: Client[];
    actions: string[][];
    lock_count: number;

    constructor(c1: Client, c2: Client) {
        this.cl_list = [c1, c2];
        this.cl_list.forEach((c, i) => c.send('start game', i))
        this.actions = [];
        this.lock_count = 0;
    }

    actionLocked(i: number, actions: string[]) {
        this.lock_count++;
        this.actions[i] = actions;
        if (this.lock_count == this.cl_list.length) {
            this.cl_list.forEach(c => c.send('turn ready', this.actions));
            this.lock_count = 0;
            this.actions = [];
        }
    }

    actionInput(data: unknown, client: Client) {
        this.cl_list.forEach(cl => {
            if (cl !== client)
                cl.send('action input', data);
        })
    }
}

const match_map = new Map<Client, Match>();

export function init() {
    Server.on('actions locked', (data: { i: number, actions: string[] }, client: Client) => {
        match_map.get(client)!.actionLocked(data.i, data.actions);
    })

    Server.on('action input', (data, client: Client) => {
        match_map.get(client)!.actionInput(data, client);
    })
}

export function startMatch(c1: Client, c2: Client) {
    const m = new Match(c1, c2);
    match_map.set(c1, m);
    match_map.set(c2, m);
}
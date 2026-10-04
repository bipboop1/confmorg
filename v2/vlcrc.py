#!/usr/bin/env python3
"""Sends the same command to several VLC players' remote control at once.
Usage: vlcrc.py "command" port1 [port2 ...]   (players listen on 127.0.0.1)
Prints one line per player: "port reply" ("port ERROR" if unreachable)."""
import socket, sys, time

cmd, ports = sys.argv[1], [int(p) for p in sys.argv[2:]]


def read_until_prompt(s, timeout):
    """Read until VLC's "> " prompt (or timeout); return the text before it."""
    s.settimeout(timeout)
    out = b""
    try:
        while not out.endswith(b"> "):
            chunk = s.recv(4096)
            if not chunk:
                break
            out += chunk
    except OSError:
        pass
    return out.decode(errors="replace")


socks = {}
for p in ports:
    try:
        s = socket.create_connection(("127.0.0.1", p), timeout=2)
        read_until_prompt(s, 1)          # skip the welcome banner
        socks[p] = s
    except OSError:
        socks[p] = None

# Send to all players back to back, so they act at (almost) the same moment
for s in socks.values():
    if s:
        s.sendall((cmd + "\n").encode())

for p, s in socks.items():
    if not s:
        print(p, "ERROR")
        continue
    reply = read_until_prompt(s, 2)
    reply = reply[:-2] if reply.endswith("> ") else reply
    print(p, reply.strip().replace("\r", "").replace("\n", " | "))
    s.close()

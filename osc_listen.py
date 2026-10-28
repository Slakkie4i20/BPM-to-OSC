"""Minimal OSC listener to check BPMtoOSC output without Resolume.

Usage: python osc_listen.py [ip] [port]   (defaults: 127.0.0.1 7000)
"""
import sys
from datetime import datetime

from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import BlockingOSCUDPServer

# must match the defaults in main_gui.py / lastsession.ini
BPM_ADRESS = "/composition/tempocontroller/tempo"


def print_message(address: str, *args) -> None:
    line = f"{datetime.now():%H:%M:%S.%f}"[:-3] + f"  {address}  {args}"

    # BPMtoOSC maps BPM 20..500 to 0..1 for Resolume (see OSCclient.send_osc)
    if address == BPM_ADRESS and len(args) == 1 and isinstance(args[0], float):
        line += f"  -> {args[0] * 480 + 20:.1f} BPM"

    print(line, flush=True)


if __name__ == "__main__":
    ip = sys.argv[1] if len(sys.argv) > 1 else "127.0.0.1"
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 7000

    dispatcher = Dispatcher()
    dispatcher.set_default_handler(print_message)

    server = BlockingOSCUDPServer((ip, port), dispatcher)
    print(f"Listening for OSC on {ip}:{port} (Ctrl+C to quit)")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass

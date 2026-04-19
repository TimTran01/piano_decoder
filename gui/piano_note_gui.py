import socket
import struct
import threading
import tkinter as tk
from tkinter import ttk

PACKET_STRUCT = struct.Struct("<IIIIBBBBIHh")
MAGIC = 0x50494E4F
UDP_PORT = 5005

NOTE_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


def midi_to_name(midi_note: int) -> str:
    if midi_note < 0:
        return "--"
    octave = midi_note // 12 - 1
    return f"{NOTE_NAMES[midi_note % 12]}{octave}"


class PianoGui:
    def __init__(self) -> None:
        self.root = tk.Tk()
        self.root.title("Zybo Piano Note Monitor")
        self.root.geometry("420x240")

        self.status_var = tk.StringVar(value="Waiting for UDP packets")
        self.key_var = tk.StringVar(value="--")
        self.note_var = tk.StringVar(value="--")
        self.freq_var = tk.StringVar(value="0.00 Hz")
        self.level_var = tk.StringVar(value="0.0 %")
        self.event_var = tk.StringVar(value="0")

        self._build()
        threading.Thread(target=self._listen, daemon=True).start()

    def _build(self) -> None:
        frame = ttk.Frame(self.root, padding=16)
        frame.pack(fill="both", expand=True)

        ttk.Label(frame, textvariable=self.status_var, font=("TkDefaultFont", 11)).pack(anchor="w", pady=(0, 12))
        ttk.Label(frame, text="Piano Key", font=("TkDefaultFont", 10, "bold")).pack(anchor="w")
        ttk.Label(frame, textvariable=self.key_var, font=("TkDefaultFont", 26)).pack(anchor="w", pady=(0, 8))
        ttk.Label(frame, text="Note Name", font=("TkDefaultFont", 10, "bold")).pack(anchor="w")
        ttk.Label(frame, textvariable=self.note_var, font=("TkDefaultFont", 20)).pack(anchor="w", pady=(0, 8))
        ttk.Label(frame, textvariable=self.freq_var).pack(anchor="w")
        ttk.Label(frame, textvariable=self.level_var).pack(anchor="w")
        ttk.Label(frame, textvariable=self.event_var).pack(anchor="w")

    def _listen(self) -> None:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind(("0.0.0.0", UDP_PORT))
        while True:
            data, addr = sock.recvfrom(1024)
            if len(data) != PACKET_STRUCT.size:
                continue
            fields = PACKET_STRUCT.unpack(data)
            if fields[0] != MAGIC:
                continue
            self.root.after(0, self._apply_packet, fields, addr)

    def _apply_packet(self, fields, addr) -> None:
        _, version, event_count, _, note_valid, piano_key, midi_note, _, freq_q16_16, level_q1_15, cents_q8_8 = fields
        freq_hz = freq_q16_16 / 65536.0
        level_pct = (level_q1_15 / 32767.0) * 100.0 if level_q1_15 else 0.0

        self.status_var.set(f"Listening on UDP {UDP_PORT} | source {addr[0]} | v{version}")
        self.event_var.set(f"Event Counter: {event_count}")
        self.freq_var.set(f"Frequency: {freq_hz:.2f} Hz | Cents error: {cents_q8_8 / 256.0:.2f}")
        self.level_var.set(f"Signal Level: {level_pct:.1f}%")
        if note_valid:
            self.key_var.set(str(piano_key))
            self.note_var.set(midi_to_name(midi_note))
        else:
            self.key_var.set("--")
            self.note_var.set("Note Off")

    def run(self) -> None:
        self.root.mainloop()


if __name__ == "__main__":
    PianoGui().run()

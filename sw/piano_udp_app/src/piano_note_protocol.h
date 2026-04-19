#ifndef PIANO_NOTE_PROTOCOL_H
#define PIANO_NOTE_PROTOCOL_H

#include <stdint.h>

#define PIANO_NOTE_MAGIC   0x50494E4FUL
#define PIANO_NOTE_VERSION 1UL

#pragma pack(push, 1)
typedef struct {
    uint32_t magic;
    uint32_t version;
    uint32_t event_counter;
    uint32_t timestamp_ms;
    uint8_t note_valid;
    uint8_t piano_key;
    uint8_t midi_note;
    uint8_t reserved;
    uint32_t freq_hz_q16_16;
    uint16_t signal_level_q1_15;
    int16_t cents_error_q8_8;
} piano_note_packet_t;
#pragma pack(pop)

#endif


#include <stdint.h>
#include <string.h>

#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "sleep.h"
#include "xiltimer.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xiic.h"

#if defined(__has_include) && __has_include("lwip/init.h")
#include "lwip/init.h"
#include "lwip/ip_addr.h"
#include "lwip/netif.h"
#include "lwip/pbuf.h"
#include "lwip/sys.h"
#include "lwip/udp.h"
#else
#include "include/lwip/init.h"
#include "include/lwip/ip_addr.h"
#include "include/lwip/netif.h"
#include "include/lwip/pbuf.h"
#include "include/lwip/sys.h"
#include "include/lwip/udp.h"
#endif
#include "netif/xadapter.h"

#include "piano_note_protocol.h"

#ifndef XPAR_PIANO_NOTE_DETECT_0_S_AXI_BASEADDR
#define XPAR_PIANO_NOTE_DETECT_0_S_AXI_BASEADDR 0x40000000U
#endif

#ifndef XPAR_AXI_IIC_0_BASEADDR
#define XPAR_AXI_IIC_0_BASEADDR 0x41600000U
#endif

#ifndef XPAR_AXI_IIC_0_DEVICE_ID
#define XPAR_AXI_IIC_0_DEVICE_ID 0U
#endif

#define REG_CONTROL      0x00U
#define REG_STATUS       0x04U
#define REG_PIANO_KEY    0x08U
#define REG_MIDI_NOTE    0x0CU
#define REG_FREQUENCY    0x10U
#define REG_SIGNAL_LEVEL 0x14U
#define REG_CENTS_ERROR  0x18U
#define REG_EVENT_COUNT  0x1CU

#define CONTROL_CLEAR_EVENT 0x00000001U
#define CONTROL_IRQ_ENABLE  0x00000002U

#define STATUS_NOTE_VALID   0x00000001U
#define STATUS_NEW_EVENT    0x00000002U

#define CODEC_ADDR 0x1AU

#define BOARD_IP_ADDR  "192.168.1.50"
#define BOARD_NETMASK  "255.255.255.0"
#define BOARD_GATEWAY  "192.168.1.1"
#define GUI_IP_ADDR    "192.168.1.100"
#define GUI_UDP_PORT   5005U

static struct netif server_netif;
static struct udp_pcb *udp_pcb_ptr;
static XIic codec_iic;

static void codec_write_reg(uint8_t reg_addr, uint16_t data)
{
    uint8_t buf[2];
    buf[0] = (uint8_t)((reg_addr << 1) | ((data >> 8) & 0x01U));
    buf[1] = (uint8_t)(data & 0xFFU);

    while (XIic_IsIicBusy(&codec_iic)) {
    }
    XIic_Send(XPAR_AXI_IIC_0_BASEADDR, CODEC_ADDR, buf, 2, XIIC_STOP);
    while (XIic_IsIicBusy(&codec_iic)) {
    }
}

static void codec_init(void)
{
    int status;

#ifdef SDT
    status = XIic_Initialize(&codec_iic, XPAR_AXI_IIC_0_BASEADDR);
#else
    status = XIic_Initialize(&codec_iic, XPAR_AXI_IIC_0_DEVICE_ID);
#endif
    if (status != XST_SUCCESS) {
        xil_printf("XIic_Initialize failed: %d\r\n", status);
        return;
    }

    status = XIic_Start(&codec_iic);
    if (status != XST_SUCCESS) {
        xil_printf("XIic_Start failed: %d\r\n", status);
        return;
    }

    codec_write_reg(0x0F, 0x000);
    codec_write_reg(0x06, 0x010);
    codec_write_reg(0x00, 0x017);
    codec_write_reg(0x01, 0x017);
    codec_write_reg(0x04, 0x012);
    codec_write_reg(0x05, 0x000);
    codec_write_reg(0x07, 0x042);
    codec_write_reg(0x08, 0x000);
    codec_write_reg(0x09, 0x001);
}

static uint32_t det_read(uint32_t offset)
{
    return Xil_In32(XPAR_PIANO_NOTE_DETECT_0_S_AXI_BASEADDR + offset);
}

static void det_write(uint32_t offset, uint32_t value)
{
    Xil_Out32(XPAR_PIANO_NOTE_DETECT_0_S_AXI_BASEADDR + offset, value);
}

static uint32_t timestamp_ms(void)
{
    XTime ticks;

    XTime_GetTime(&ticks);
    return (uint32_t)(ticks / (COUNTS_PER_SECOND / 1000U));
}

static void network_init(void)
{
    ip_addr_t ipaddr, netmask, gw, gui_ip;

    lwip_init();

    ipaddr_aton(BOARD_IP_ADDR, &ipaddr);
    ipaddr_aton(BOARD_NETMASK, &netmask);
    ipaddr_aton(BOARD_GATEWAY, &gw);
    ipaddr_aton(GUI_IP_ADDR, &gui_ip);

    if (!xemac_add(&server_netif, &ipaddr, &netmask, &gw, NULL, XPAR_XEMACPS_0_BASEADDR)) {
        xil_printf("xemac_add failed\r\n");
        return;
    }

    netif_set_default(&server_netif);
    netif_set_up(&server_netif);
    udp_pcb_ptr = udp_new_ip_type(IPADDR_TYPE_V4);
    udp_connect(udp_pcb_ptr, &gui_ip, GUI_UDP_PORT);
}

static void send_note_packet(void)
{
    piano_note_packet_t pkt;
    struct pbuf *pbuf_ptr;

    memset(&pkt, 0, sizeof(pkt));
    pkt.magic = PIANO_NOTE_MAGIC;
    pkt.version = PIANO_NOTE_VERSION;
    pkt.event_counter = det_read(REG_EVENT_COUNT);
    pkt.timestamp_ms = timestamp_ms();
    pkt.note_valid = (det_read(REG_STATUS) & STATUS_NOTE_VALID) ? 1U : 0U;
    pkt.piano_key = (uint8_t)det_read(REG_PIANO_KEY);
    pkt.midi_note = (uint8_t)det_read(REG_MIDI_NOTE);
    pkt.freq_hz_q16_16 = det_read(REG_FREQUENCY);
    pkt.signal_level_q1_15 = (uint16_t)det_read(REG_SIGNAL_LEVEL);
    pkt.cents_error_q8_8 = (int16_t)det_read(REG_CENTS_ERROR);

    pbuf_ptr = pbuf_alloc(PBUF_TRANSPORT, sizeof(pkt), PBUF_RAM);
    if (pbuf_ptr == NULL) {
        return;
    }

    memcpy(pbuf_ptr->payload, &pkt, sizeof(pkt));
    udp_send(udp_pcb_ptr, pbuf_ptr);
    pbuf_free(pbuf_ptr);

    det_write(REG_CONTROL, CONTROL_IRQ_ENABLE | CONTROL_CLEAR_EVENT);
    det_write(REG_CONTROL, CONTROL_IRQ_ENABLE);
}

int main(void)
{
    init_platform();
    xil_printf("Piano UDP app starting\r\n");

    network_init();
    codec_init();
    det_write(REG_CONTROL, CONTROL_IRQ_ENABLE);

    while (1) {
        xemacif_input(&server_netif);
        if (det_read(REG_STATUS) & STATUS_NEW_EVENT) {
            send_note_packet();
        }
        usleep(2000U);
    }

    cleanup_platform();
    return 0;
}

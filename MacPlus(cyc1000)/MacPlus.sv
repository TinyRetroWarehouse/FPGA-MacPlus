`default_nettype none
//============================================================================
//  Macintosh Plus
//
//  Port to MiSTer
//  Copyright (C) 2017-2019 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module MacPlus
(
	//Master input clock
	input         CLK_12M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET_IN,

	//Must be passed to hps_io module
//	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
//	output  [7:0] VIDEO_ARX,
//	output  [7:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output  [1:0] VGA_SL,

//	output [15:0] AUDIO_L,
//	output [15:0] AUDIO_R,
//	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
//	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
//	inout   [3:0] ADC_BUS,

	// SD-SPI
	output        SD_SCK,
	output        SD_CMD,  // MOSI,
	input         SD_DAT0, // MISO,
	output        SD_CS,
	//input         SD_CD,
	output [1:0]	SD_pup, // pull.up
/*
	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,
*/
	//SDRAM interface with lower latency
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,
	output        SDRAM_CLK,
	//output        SDRAM_CKE,

//	input         UART_CTS,
//	output        UART_RTS,
//	input         UART_RXD,
//	output        UART_TXD,
//	output        UART_DTR,
//	input         UART_DSR,

	inout				ps2_kbd_dat,
	inout				ps2_kbd_clk,
	inout				ps2_mouse_dat,
	inout				ps2_mouse_clk,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..5 - USR1..USR4
	// Set USER_OUT to 1 to read from USER_IN.
//	input   [5:0] USER_IN,
//	output  [5:0] USER_OUT,

//	input         OSD_STATUS
	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,
	output  [2:0] LED	
);

wire RESET;
assign RESET = cpurst;
assign buttons = 4'b0000; // ext.in
assign SD_pup = 2'b11; // pull.up
//assign ADC_BUS  = 'Z;
//assign USER_OUT = '1;
//assign {UART_RTS, UART_TXD, UART_DTR} = 0;
//assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = 0; 
//assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;

assign LED_DISK[1] = mmwrdt==8'h0 && sdsts==8'h0;
assign LED_DISK[0] = 0;
assign LED_POWER = 2'b00;
assign LED_USER  = dio_download || (disk_act ^ |diskMotor);
assign LED[2:0]  = { 1'b0,cpurst, sdrst};

//assign VIDEO_ARX = status[8] ? 8'd16 : 8'd4;
//assign VIDEO_ARY = status[8] ? 8'd9  : 8'd3; 

`include "build_id.v" 
localparam CONF_STR = {
	"MACPLUS;;",
	"-;",
	"F,DSK;",
	"F,DSK;",
	"S,VHD;",
	"-;",
	"O8,Aspect ratio,4:3,16:9;",
	"-;",
	"O9A,Memory,512KB,1MB,4MB;",
	"O5,Speed,Normal,Turbo;",
	"-;",
	"R6,Reset;",
	"V,v",`BUILD_DATE
};

////////////////////   CLOCKS   ///////////////////

wire clk_sys, clk_spi,clk_sysq;
wire pll_locked;
		
pll pll
(
	.inclk0(CLK_12M),
	.areset(0),
	.c0(clk_sys),
	.c1(SDRAM_CLK),
	.c2(clk_spi),
	.c3(clk_sysq),
	.locked(pll_locked)
);

wire cep   = (stage == 0);
wire cen   = (stage == 4);
wire cel   = (stage == 7);
wire cepix = !stage[1:0];

reg [2:0] stage;
always @(negedge clk_sys) stage <= stage + 1'd1;

///////////////////////////////////////////////////

// interconnects
// CPU
wire        _cpuReset, _cpuResetOut, _cpuUDS, _cpuLDS, _cpuRW;
wire  [2:0] _cpuIPL;
wire  [7:0] cpuAddrHi;
wire [23:0] cpuAddr;
wire [15:0] cpuDataOut;

// RAM/ROM
wire        _romOE;
wire        _ramOE, _ramWE;
wire        _memoryUDS, _memoryLDS;
wire        videoBusControl;
wire        dioBusControl;
wire        cpuBusControl;
wire [21:0] memoryAddr;
wire [15:0] memoryDataOut;

// peripherals
wire        memoryOverlayOn, selectSCSI, selectSCC, selectIWM, selectVIA;	 
wire [15:0] dataControllerDataOut;

// audio
wire snd_alt;
wire loadSound;

// floppy disk image interface
wire        dskReadAckInt;
wire [21:0] dskReadAddrInt;
wire        dskReadAckExt;
wire [21:0] dskReadAddrExt;
wire  [1:0] diskMotor, diskAct, diskEject;

// the status register is controlled by the on screen display (OSD)
wire [31:0] status; ////
wire  [1:0] buttons;
wire [31:0] sd_lba;
wire        sd_rd;
wire        sd_wr;
wire        sd_ack;
wire  [8:0] sd_buff_addr;
wire  [7:0] sd_buff_dout;
wire  [7:0] sd_buff_din;
wire        sd_buff_wr;

reg         ioctl_wr;
wire        ioctl_write;
reg         ioctl_wait = 0;

wire [10:0] ps2_key;
wire [24:0] ps2_mouse;
wire        capslock;

wire [24:0] ioctl_addr;
wire  [7:0] ioctl_data;

always @(posedge clk_sys) begin
	reg [7:0] temp;
	
	ioctl_wr <= 0;
	if(ioctl_write) begin
		if(~ioctl_addr[0]) temp <= ioctl_data;
		else begin
			dio_data <= {temp, ioctl_data};
			ioctl_wr <= 1;
		end
	end
end


/* ////
hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),

	.buttons(buttons),
	.status(status),

	.sd_lba(sd_lba),
	.sd_rd(sd_rd),
	.sd_wr(sd_wr),
	.sd_ack(sd_ack),

	.sd_conf(0),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr),
	
	.ioctl_download(dio_download),
	.ioctl_index(dio_index),
	.ioctl_wr(ioctl_write),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_data),

	.ioctl_wait(ioctl_wait),

	.ps2_key(ps2_key),
	.ps2_kbd_led_use(3'b001),
	.ps2_kbd_led_status({2'b00, capslock}),

	.ps2_mouse(ps2_mouse)
);
*/
// hps_io Dumy Opretion
reg [2:0] loadreq; // bit0:os bit1:disk bit2: 
reg rdd,wrd,fend;
reg [2:0]  iseq,wseq,aseq,aseqc,rseq,rmseq,wmseq;
reg  [7:0] wptn,wofs,dio_indexr;
(*keep*)reg  [15:0] sdbkcnt;
//reg  [10:0] mradr; 
reg 			dio_downloadr,sdmode;
assign dio_download = dio_downloadr;
assign dio_index = dio_indexr;
assign ioctl_addr = io_addr;
assign ioctl_data = sdrbrd;
assign ioctl_write = mrwes;
reg mrwer,mrwes,mrwef,mrwefd,mrwefdd;
reg [7:0] sdrbuf [0:511];
reg [8:0] sdrbwp,sdrbrp;
reg  [23:0] io_addr;
reg [7:0] sdrbrd;
reg [9:0] sdbbcnt;
always @(posedge clk_sys) begin
	mrwer <= mrwe;
	if(~dio_downloadr) begin 
		io_addr <= 24'h000000;  sdrbwp <= 0; sdrbrp <= 0;
	end else begin
		if(mrwe && ~mrwer) begin 
			sdrbuf[sdrbwp] <= mmwrdt; sdrbwp <= sdrbwp + 1;
		end
		if(sdrbwp!=sdrbrp && ~ioctl_wait && ~mrwefdd) begin
			sdrbrd <= sdrbuf[sdrbrp]; sdrbrp <= sdrbrp + 1; mrwes <= 1'b1;
			//io_addr <= io_addr + 1;
			mrwef <= 1'b1;
		end else mrwes <= 1'b0;
		mrwefd <= mrwef; mrwefdd <= mrwefd;
		if(mrwefdd && ~ioctl_wait) begin 
			io_addr <= io_addr + 1; mrwef <= 1'b0; mrwefd <= 1'b0; mrwefdd <= 1'b0;end
	end
end

reg sd_ackr,sd_rdd;
reg sd_run;
reg [1:0] sd_dbg;
assign sd_ack = sd_ackr;
assign sd_buff_addr = sdbbcnt;
assign sd_buff_dout = mmwrdt;
assign sd_buff_wr   = sd_run ? mrwe : 0;

always @(posedge clk_spi) begin
	if(~sdcopy) begin 
		iseq <= 3'h0; aseq <= 3'h0; rseq <= 3'h0; wseq <= 3'h0; sdmode <= 0;
		dio_downloadr <= 1'b0; sdwr_req <= 1'b0;
		loadreq <= 3'b111; sd_dbg <= 2'b11; //cpurst <= 1'b1;
	end else begin
		if(loadreq!=3'b000) begin
			if(~dio_downloadr) begin
				dio_downloadr <= 1'b1; sdmode <= 0;
				if(loadreq[0]) begin	loadreq[0] <= 1'b0; sdbadr <= 24'h000F00; sdbkcnt <= 16'h0100; dio_indexr <= 0;
				end else 
				if(loadreq[1]) begin	loadreq[1] <= 1'b0; sdbadr <= 24'h000800; sdbkcnt <= 16'h0640; dio_indexr <= 1;
				end else 
				if(loadreq[2]) begin	loadreq[2] <= 1'b0; sdbadr <= 24'h000000; sdbkcnt <= 16'h0640; dio_indexr <= 2;
				end
				iseq <= 3'h1; // Read.Seq Start
			end
		//end else if(~dio_downloadr && wseq==3'h0 && rseq==3'h0) begin 
		//	if(sd_dbg[0])      begin sd_dbg[0] <= 0; sdbadr <= 24'h000200; sdmode <= 1; dio_indexr <= 3; wseq <= 3'h1; end
		//	else if(sd_dbg[1]) begin sd_dbg[1] <= 0; sdbadr <= 24'h000200; sdmode <= 0; dio_indexr <= 4; rseq <= 3'h1; end
		end
			//cpurst <= dio_downloadr;
		if(~cpurst && ~sd_run) begin
			if(sd_rd || sd_wr) begin
				sd_run <= 1; sdbadr <= 24'h001000 + sd_lba[23:0]; //sdbkcnt <= 16'h0001; 
				sd_ackr <= 1; 
				if(sd_rd) begin sdmode <= 0; rseq <= 3'h1; end
				else      begin sdmode <= 1; wseq <= 3'h1; end
			end 
		end
		if(sd_run && rseq==3'h0 && wseq==3'h0) begin sd_ackr <= 0; sd_run <= 0; end 
		//end
		//
		case(iseq)
			3'h1: begin rseq <= 3'h1; iseq <= 3'h2; end  
			3'h2: if(rseq==3'h0) iseq <= 3'h3; 
			3'h3: if(~sdsts[4]) iseq <= 3'h4;
			3'h4: begin
					if(sdbkcnt==16'h0000) begin 
						if(sdrbrp==9'h000) begin dio_downloadr <= 1'b0; iseq <= 3'h0; end 
					end else begin 
						sdbadr <= sdbadr + 24'd1;  iseq <= 3'h1; 
					end
				end
			default: ;
		endcase;
		//
		//if(sdmode==0) begin
		case(rseq)
			3'h1: begin aseq <= 3'h1; rseq <= 3'h2; end
			3'h2: if(aseq==3'h0)	begin sdbbcnt <= 9'd0; rseq <= 3'h3; end
			3'h3: if(sdsts[6]) begin sdrd_req <= 1'b1; rseq <= 3'h4; end
			3'h4: begin	sdrd_req <= 1'b0; mmwrdt <= sdrddt; mrwe <= 1'b1; rseq <= 3'h5;	end
			3'h5: begin 
					mrwe <= 1'b0; 
					if(sdbbcnt!=511) begin 
						sdbbcnt <= sdbbcnt + 1; rseq <= 3'h3; 
					end else 
						if(~sdsts[5]) begin sdbkcnt <= sdbkcnt - 1; rseq <= 3'h0; end
				end
			default: ;
		endcase;
		//
		//end else begin
		case(wseq)
			3'h1: begin sdwrdt <= 8'h01; aseq <= 3'h1; wseq <= 3'h2; end
			3'h2: if(aseq==3'h0)	begin mrwe <= 1'b0; sdbbcnt <= 9'd0; wseq <= 3'h3;	end
			3'h3: if(sdsts[7]) begin wseq <= 3'h4; end 
			3'h4: begin sdwr_req <= 1'b1;  sdwrdt <= sd_buff_din; wseq <= 3'h5; end
			3'h5: begin	sdwr_req <= 1'b0;   wseq <= 3'h6;	end
			3'h6: begin wseq <= 3'h7;	end
			3'h7: begin 
					if(sdbbcnt!=9'd511) begin 
						sdbbcnt <= sdbbcnt + 9'd1; wseq <= 3'h3; // Loop 
					end else 
						if(~sdsts[5]) begin wseq <= 3'h0; end // Write.end
				end
			default: ;
		endcase;
		//end
		//
		case(aseq)
			3'h1: begin sdadreg <= 3'b010; sdwr_req <= 1'b1; aseqc <= 3'h0; aseq <= 3'h2; end
			3'h2: begin  
					case(aseqc)
						3'h0: begin sdadreg <= 3'b010; sdwrdt <= sdbadr[ 7: 0]; end
						3'h1: begin sdadreg <= 3'b011; sdwrdt <= sdbadr[15: 8]; end
						3'h2: begin sdadreg <= 3'b100; sdwrdt <= sdbadr[23:16]; end
						3'h3: begin if(sdmode) sdwrdt <= 8'h01;
										else       sdwrdt <= 8'h00;
										sdadreg <= 3'b001; 
								end
						default: ;
					endcase
					aseq <= 3'h3;
				end
			3'h3: begin sdwr_req <= 1'b0; aseq <= 3'h4; end 
			3'h4: begin 
					sdwr_req <= 1'b1; aseqc <= aseqc + 3'h1;
					if(aseqc<3'h3) aseq <= 3'h2;
					else     begin aseq <= 3'h0; sdadreg <= 3'b000; sdwr_req <= 1'b0; end // Address Set.End
				end
			3'h7: ;
			default: ;
		endcase
		//
	end
end
	// SPI.Clock = 60MHz
	reg  sdrd_req,sdwr_req,mrwe,rb_req,wb_req,fone,fmon;
	reg  [23:0] sdbadr;
	reg  [2:0]  sdadreg;
	(*keep*)reg  [7:0]  sdwrdt,mmwrdt;
	(*keep*)wire [7:0]  sdrd_reqt,sdrddt,sdled,sdsts;
	sd_controller sd_controller(
		.sdCS(SD_CS), .sdMOSI(SD_CMD), .sdMISO(SD_DAT0), .sdSCLK(SD_SCK),
		.clk(clk_spi), .n_reset(~sdrst), .n_rd(!sdrd_req), .n_wr(!sdwr_req),
		.dataIn(sdwrdt), .dataOut(sdrddt), .regAddr(sdadreg),
		.rb_req(), .wb_req(), .stsout(sdsts),
		.driveLED() 
		);
/* regAddr dataOut   n_rd(Rise)   n_wr(Rise)
	000    <= sdrddt  Data.Read    Data.Write              
	001    <= status              Start.Read(0)/Write(1)  0/1=DataIn                
                                   <SDSC><SDHC> 
	010                           Adr(16:9   7:0 )  
	011                           Adr(24:17 15:8 )
	100                           Adr(31:25 23:16)

	status(7) <= '1' when host_write_flag=sd_write_flag else '0'; -- tx byte empty when equal
	status(6) <= '0' when host_read_flag=sd_read_flag else '1'; -- rx byte ready when not equal
	status(5) <= block_busy;
	status(4) <= init_busy;
*/
reg [31:0] divcnt;
reg       cpurst,sdrst,sdcopy;
always @(posedge clk_sys) begin
	if(~pll_locked || ~RESET_IN ) begin 
		divcnt <= 0; sdrst <= 1'b1; sdcopy <= 1'b0; cpurst <= 1'b1;
	end else	begin
		divcnt <= divcnt + 1;
		if(divcnt[28:25]>4'b0001) sdrst  <= 1'b0;
		if(divcnt[28:25]>4'b0010) sdcopy <= 1'b1;
		if(divcnt[28:25]>4'b1000) cpurst <= 1'b0;
	end
end

wire  [1:0] cpu_busstate;
wire        cpu_clkena = cep && (cpuBusControl || (cpu_busstate == 2'b01));
reg  [15:0] cpuDataIn;
always @(posedge clk_sys) if(cel && cpuBusControl && ~cpu_busstate[0] && _cpuRW) cpuDataIn <= dataControllerDataOut;

TG68KdotC_Kernel #(0,0,0,0,0,0) m68k
(
	.clk            ( clk_sys        ),
	.nReset         ( _cpuReset      ),
	.clkena_in      ( cpu_clkena     ), 
	.data_in        ( cpuDataIn      ),
	.IPL            ( _cpuIPL        ),
	.IPL_autovector ( 1'b1           ),
	.berr           ( 1'b0           ),
	.clr_berr       ( 1'b0           ),
	.CPU            ( 2'b00          ),   // 00=68000
	.addr           ( {cpuAddrHi, cpuAddr} ),
	.data_write     ( cpuDataOut     ),
	.nUDS           ( _cpuUDS        ),
	.nLDS           ( _cpuLDS        ),
	.nWr            ( _cpuRW         ),
	.busstate       ( cpu_busstate   ), // 00-> fetch code 10->read data 11->write data 01->no memaccess
	.nResetOut      ( _cpuResetOut   ),
	.FC             (                )
);

assign VGA_R = {8{pixelOut}};
assign VGA_G = {8{pixelOut}};
assign VGA_B = {8{pixelOut}};
assign CLK_VIDEO = clk_sys;
assign CE_PIXEL  = cepix;
assign VGA_F1 = 0;
assign VGA_SL = 0;

wire screenWrite;
always @(*) begin
	case(configRAMSize)
		0:	screenWrite = ~_ramWE && &memoryAddr[16:15]; // 01A700 (018000)
		1:	screenWrite = ~_ramWE && &memoryAddr[18:15]; // 07A700 (078000)
		2:	screenWrite = ~_ramWE && &memoryAddr[19:15]; // 0FA700 (0F8000)
		3:	screenWrite = ~_ramWE && &memoryAddr[21:15]; // 3FA700 (3F8000)
	endcase
end

wire pixelOut, _hblank, _vblank;
video video
(
	.clk(clk_sys),
	.ce(cepix),

	.addr(cpuAddr[15:1]),
	.dataIn(cpuDataOut),
	.wr({~_cpuUDS & screenWrite, ~_cpuLDS & screenWrite}),

	._hblank(_hblank),
	._vblank(_vblank),

	.hsync(VGA_HS),
	.vsync(VGA_VS),
	.video_en(VGA_DE),
	.pixelOut(pixelOut)
);

wire [10:0] audio;
//assign AUDIO_L = {audio[10:0], 5'b00000};
//assign AUDIO_R = {audio[10:0], 5'b00000};
//assign AUDIO_S = 0;
//assign AUDIO_MIX = 0;

wire       status_turbo = 1; //// status[5];
wire       status_reset = 0; //// status[6];

wire [1:0] status_mem   = 2'b10; //// status[10:9]; // 128KB, 512KB, 1MB, 4MB
reg  [1:0] configRAMSize= 3;

reg n_reset = 0;
always @(posedge clk_sys) begin
	reg [15:0] rst_cnt;

	// various sources can reset the mac
	if(!pll_locked || status[0] || status_reset || buttons[1] || RESET || ~_cpuResetOut) begin
		rst_cnt <= '1;
		n_reset <= 0;
	end else if(rst_cnt) begin
		if(cen) rst_cnt <= rst_cnt - 1'd1;
		configRAMSize <= status_mem + 1'd1;
	end else n_reset <= 1;
end

addrController_top ac0
(
	.clk(clk_sys),
	.cep(cep),
	.cen(cen),

	.cpuAddr(cpuAddr),
	._cpuUDS(_cpuUDS),
	._cpuLDS(_cpuLDS),
	._cpuRW(_cpuRW),
	.turbo(real_turbo),
	.configROMSize(1), // 128KB
	.configRAMSize(configRAMSize),
	.memoryAddr(memoryAddr),
	._memoryUDS(_memoryUDS),
	._memoryLDS(_memoryLDS),
	._romOE(_romOE),
	._ramOE(_ramOE),
	._ramWE(_ramWE),
	.dioBusControl(dioBusControl),
	.cpuBusControl(cpuBusControl),
	.selectSCSI(selectSCSI),
	.selectSCC(selectSCC),
	.selectIWM(selectIWM),
	.selectVIA(selectVIA),
	._vblank(_vblank),
	._hblank(_hblank),
	.memoryOverlayOn(memoryOverlayOn),

	.snd_alt(snd_alt),
	.loadSound(loadSound),

	.dskReadAddrInt(dskReadAddrInt),
	.dskReadAckInt(dskReadAckInt),
	.dskReadAddrExt(dskReadAddrExt),
	.dskReadAckExt(dskReadAckExt)
);

dataController_top dc0
(
	.clk(clk_sys),
	.cep(cep),
	.cen(cen),
	
	._systemReset(n_reset),
	._cpuReset(_cpuReset), 
	._cpuIPL(_cpuIPL),
	._cpuUDS(_cpuUDS), 
	._cpuLDS(_cpuLDS), 
	._cpuRW(_cpuRW), 
	.cpuDataIn(cpuDataOut),
	.cpuDataOut(dataControllerDataOut), 	
	.cpuAddrRegHi(cpuAddr[12:9]),
	.cpuAddrRegMid(cpuAddr[6:4]),  // for SCSI
	.cpuAddrRegLo(cpuAddr[2:1]),		
	.selectSCSI(selectSCSI),
	.selectSCC(selectSCC),
	.selectIWM(selectIWM),
	.selectVIA(selectVIA),
	.cpuBusControl(cpuBusControl),
	.memoryDataOut(memoryDataOut),
	.memoryDataIn(sdram_do),

	// peripherals
	//.ps2_key(ps2_key),
	.capslock(capslock),
	//.ps2_mouse(ps2_mouse),
	.serialIn(0),
	
	.ps2_kbd_dat(ps2_kbd_dat),
	.ps2_kbd_clk(ps2_kbd_clk),
	.ps2_mouse_dat(ps2_mouse_dat),
	.ps2_mouse_clk(ps2_mouse_clk),

	// video
	._hblank(_hblank),
	._vblank(_vblank),

	.memoryOverlayOn(memoryOverlayOn),

	.audioOut(audio),
	.snd_alt(snd_alt),
	.loadSound(loadSound),
	
	// floppy disk interface
	.insertDisk({dsk_ext_ins, dsk_int_ins}),
	.diskSides({dsk_ext_ds, dsk_int_ds}),
	.diskEject(diskEject),
	.dskReadAddrInt(dskReadAddrInt),
	.dskReadAckInt(dskReadAckInt),
	.dskReadAddrExt(dskReadAddrExt),
	.dskReadAckExt(dskReadAckExt),

	.diskMotor(diskMotor),
	.diskAct(diskAct),

	// block device interface for scsi disk
	.io_lba(sd_lba),
	.io_rd(sd_rd),
	.io_wr(sd_wr),
	.io_ack(sd_ack),

	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr)
);

reg disk_act;
always @(posedge clk_sys) begin
	integer timeout = 0;

	if(timeout) begin
		timeout <= timeout - 1;
		disk_act <= 1;
	end else begin
		disk_act <= 0;
	end

	if(|diskAct) timeout <= 1000000;
end

//////////////////////// DOWNLOADING ///////////////////////////

// include ROM download helper
wire        dio_download;
reg         dio_write;
wire [23:0] dio_addr = ioctl_addr[24:1];
wire  [7:0] dio_index;
reg  [15:0] dio_data;

// good floppy image sizes are 819200 bytes and 409600 bytes
reg dsk_int_ds, dsk_ext_ds;  // double sided image inserted
reg dsk_int_ss, dsk_ext_ss;  // single sided image inserted

// any known type of disk image inserted?
wire dsk_int_ins = dsk_int_ds || dsk_int_ss;
wire dsk_ext_ins = dsk_ext_ds || dsk_ext_ss;

// at the end of a download latch file size
// diskEject is set by macos on eject
always @(posedge clk_sys) begin
	reg old_down;

	old_down <= dio_download;
	if(old_down && ~dio_download && dio_index == 1) begin
		dsk_int_ds <= (dio_addr == 409600);   // double sides disk, addr counts words, not bytes
		dsk_int_ss <= (dio_addr == 204800);   // single sided disk
	end

	if(diskEject[0]) begin
		dsk_int_ds <= 0;
		dsk_int_ss <= 0;
	end
end

always @(posedge clk_sys) begin
	reg old_down;

	old_down <= dio_download;
	if(old_down && ~dio_download && dio_index == 2) begin
		dsk_ext_ds <= (dio_addr == 409600);   // double sided disk, addr counts words, not bytes
		dsk_ext_ss <= (dio_addr == 204800);   // single sided disk
	end

	if(diskEject[1]) begin
		dsk_ext_ds <= 0;
		dsk_ext_ss <= 0;
	end
end

// disk images are being stored right after os rom at word offset 0x80000 and 0x100000 
wire [20:0] dio_a = 
	(dio_index == 0)?dio_addr[20:0]:                 // os rom
	(dio_index == 1)?{21'h80000 + dio_addr[20:0]}:   // first dsk image at 512k word addr
	{21'h100000 + dio_addr[20:0]};                   // second dsk image at 1M word addr

always @(posedge clk_sys) begin
	reg old_cyc = 0;
	
	old_cyc <= dioBusControl;
	if(ioctl_wr) ioctl_wait <= 1;

	if(~dioBusControl) dio_write <= ioctl_wait;
	if(old_cyc & ~dioBusControl & dio_write) ioctl_wait <= 0;
end

// sdram used for ram/rom maps directly into 68k address space
wire download_cycle = dio_download && dioBusControl;

////////////////////////// SDRAM // 4MW 0100 0000 0000 0000 0000 0000 (8MB) ///////////////////////////////

wire [24:0] sdram_addr = download_cycle ? { 4'b0001, dio_a[20:0] } : { 3'b000, ~_romOE, memoryAddr[21:1] };
wire [15:0] sdram_din  = download_cycle ? dio_data : memoryDataOut;
wire  [1:0] sdram_ds   = download_cycle ? 2'b11 : { !_memoryUDS, !_memoryLDS };
wire        sdram_we   = download_cycle ? dio_write : !_ramWE;
wire        sdram_oe   = download_cycle ? 1'b0 : (!_ramOE || !_romOE);
wire [15:0] sdram_do   = download_cycle ? 16'hffff : (dskReadAckInt || dskReadAckExt) ? extra_rom_data_demux : sdram_out;

// "extra rom" is used to hold the disk image. It's expected to be byte wide and
// we thus need to properly demultiplex the word returned from sdram in that case
wire [15:0] extra_rom_data_demux = memoryAddr[0]? {sdram_out[7:0],sdram_out[7:0]}:{sdram_out[15:8],sdram_out[15:8]};
wire [15:0] sdram_out;

//assign SDRAM_CKE = 1;

sdram sdram
(
	// system interface
	.init    ( !pll_locked ),
	.clk     ( clk_sys     ),
	.sync    ( cep         ),

	// interface to the MT48LC16M16 chip
	.sd_data ( SDRAM_DQ    ),
	.sd_addr ( SDRAM_A     ),
	.sd_dqm  ( {SDRAM_DQMH, SDRAM_DQML} ),
	.sd_cs   ( SDRAM_nCS   ),
	.sd_ba   ( SDRAM_BA    ),
	.sd_we   ( SDRAM_nWE   ),
	.sd_ras  ( SDRAM_nRAS  ),
	.sd_cas  ( SDRAM_nCAS  ),

	// cpu/chipset interface
	// map rom to sdram word address $200000 - $20ffff
	.din     ( sdram_din   ),
	.addr    ( sdram_addr  ),
	.ds      ( sdram_ds    ),
	.we      ( sdram_we    ),
	.oe      ( sdram_oe    ),
	.dout    ( sdram_out   )
);


//////////////////////// TURBO HANDLING //////////////////////////

// cannot boot from SCSI if turbo enabled
// delay the turbo.
reg real_turbo = 0;
always @(posedge clk_sys) begin
	reg old_ack;
	integer ack_cnt = 0;
	
	old_ack <= sd_ack;
	if(old_ack && ~sd_ack && ack_cnt) ack_cnt <= ack_cnt - 1'd1;

	//Cancel delay if FDD is accesed.
	if(diskMotor) ack_cnt <= 0;
	if(!ack_cnt && dioBusControl) real_turbo <= status_turbo;

	if(~n_reset) begin
		real_turbo <= 0;
		ack_cnt <= 20;
	end
end

endmodule
`default_nettype wire
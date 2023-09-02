module FIFO
#(bus_width = 8,
	addr_width = 8,
	device = "Cyclone V")
(input clock,
 input rdreq,
 input wrreq,
 input [bus_width-1:0] data,
 output	[bus_width-1:0] q,
 output	[addr_width-1:0] usedw);

	scfifo	scfifo_component (
				.clock (clock),
				.data (data),
				.rdreq (rdreq),
				.wrreq (wrreq),
				.q (q),
				.usedw (usedw),
				.aclr (),
				.almost_empty (),
				.almost_full (),
				.eccstatus (),
				.empty (),
				.full (),
				.sclr ());
	defparam
		scfifo_component.add_ram_output_register = "OFF",
		scfifo_component.intended_device_family = device,
		scfifo_component.lpm_numwords = 2 ** addr_width,
		scfifo_component.lpm_showahead = "OFF",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = bus_width,
		scfifo_component.lpm_widthu = bus_width,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";


endmodule

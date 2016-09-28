// i2c_master.sv
//
// avalon bus based i2c master
//
// registers are 32 bits wide:
//	data register at address = 0
//		bits 31-18: reserved, read as 0
//		bit 17: i2c_error read only 1 = error (usually no device ack), cleared on start of i2c transaction
//		bit 16: i2c_busy read only 1 = busy
//		bits 15-0: i2c read or write data
// 	address register at address = 1 (byte address = 4)
//		bits 31-26: reserved, read as 0
//		bit 25: sub address size, 0 = 1 byte, 1 = 2 bytes
//		bit 24: data size, 0 = 1 byte, 1 = 2 bytes
//		bits 23-16: device address, lsb 0 = write, lsb 1 = read
//		bits 15-0: sub address
//
// to perform a write:
//	read the data register until the i2c_busy bit is zero
//	write the data register with the i2c data
//	write to the address register with device address even
//
// to perform a read:
//	read the data register until the i2c_busy bit is zero
//	write to the address register with device address odd
//	read the data register until the i2c_busy bit is zero, the data is in the low 16 bits

module i2c_master
#( parameter
	AVALON_CLOCK_PERIOD_IN_PICOSECONDS	= 10000,
	I2C_CLOCK_PERIOD_IN_PICOSECONDS 	= 2500000	// 400 KHz
) (	
    input   logic			clk,                	// avalon bus clock
    input   logic           reset_n,            	// avalon active low reset
    input  	logic           register_read,			// avalon register read
    input  	logic           register_write,     	// avalon register write
    input  	logic   [0:0]  	register_address,   	// avalon register address                
	input	logic	[31:0]	register_writedata,		// avalon register write data
	output	logic	[31:0]	register_readdata,		// avalon register read data
	output	logic			scl_out,				// i2c clock
	inout	logic			sda_inout				// i2c data
);

logic			lreset;
int unsigned	clock_count;
logic			clock_count_enable;
logic			scl_rising_edge;
logic			scl_falling_edge;
logic 	[7:0]	device_address;
logic 	[15:0]	sub_address;
logic 	[15:0]	write_data;
logic	[15:0]	read_data;
logic			start_i2c_transaction;
logic			i2c_busy;
logic			i2c_done;
logic			i2c_error;
logic			data_is_2_bytes;
logic			sub_address_is_2_bytes;
logic			scl;
logic			sda;
logic			sda_in;
logic			sda_out;	

localparam	SYSTEM_CLOCKS_PER_I2C_CLOCK =  I2C_CLOCK_PERIOD_IN_PICOSECONDS / AVALON_CLOCK_PERIOD_IN_PICOSECONDS;
localparam	I2C_SDA_DELAY_IN_SYSTEM_CLOCKS =  SYSTEM_CLOCKS_PER_I2C_CLOCK / 20;

assign scl_out = (scl == 0)? 0 : 'bz;
assign sda_inout = (sda_out == 0)? 0 : 'bz;
assign sda_in = sda_inout;

always @(posedge clk) begin : gen_lreset
	reg tmp;
	tmp <= ~reset_n;
	lreset <= tmp;
end

always @(posedge clk) begin : gen_sda_out
	int unsigned delay_count;
	logic old_sda;
	if (lreset) begin
		delay_count <= 0;
		sda_out <= 1;
		old_sda <= 1;
	end else if (old_sda != sda) begin
		delay_count <= 0;
		old_sda <= sda;
	end else if (delay_count == I2C_SDA_DELAY_IN_SYSTEM_CLOCKS) begin
		delay_count <= 0;
		sda_out <= old_sda;
	end else begin
		delay_count <= delay_count + 1;
	end
end					

always @(posedge clk) begin
	start_i2c_transaction <= 0;
	if (lreset) begin
		device_address <= 0;
		sub_address <= 0;
		write_data <= 0;
		i2c_busy <= 0;
		data_is_2_bytes <= 0;
		sub_address_is_2_bytes <= 0;
	end else if (register_write && !i2c_busy) begin
		if (register_address[0] == 1) begin				// address register
			device_address <= register_writedata[23:16];
			sub_address <= register_writedata[15:0];
			data_is_2_bytes <= register_writedata[24];
			sub_address_is_2_bytes <= register_writedata[25];
			start_i2c_transaction <= 1;
			i2c_busy <= 1;
		end else begin
			write_data <= register_writedata[15:0];
		end	
	end else if (i2c_done) begin
		i2c_busy <= 0;	
	end
end

always @(posedge clk) begin
	register_readdata <= 'b1;
	if (register_read) begin
		if (register_address[0] == 1) begin
			register_readdata[25] <= sub_address_is_2_bytes;
			register_readdata[24] <= data_is_2_bytes;			
			register_readdata[23:16] <= device_address;
			register_readdata[15:0] <= sub_address;
		end else begin	
			register_readdata[17] <= i2c_error;
			register_readdata[16] <= i2c_busy;
			if (i2c_busy) begin
				register_readdata[15:0] <= write_data;
			end else begin
				register_readdata[15:0] <= read_data;
			end
		end	
	end
end		


always @(posedge clk) begin
	scl_rising_edge <= 0;
	scl_falling_edge <= 0;
	if (lreset) begin
		clock_count <= 0;
	end else if (clock_count_enable == 0) begin
		clock_count <= 0;	
	end else if (clock_count == (SYSTEM_CLOCKS_PER_I2C_CLOCK - 1)) begin
		scl_rising_edge <= 1;
		clock_count <= 0;
	end else begin
		clock_count <= clock_count + 1;
	end
	if (clock_count == (SYSTEM_CLOCKS_PER_I2C_CLOCK / 2)) begin
		scl_falling_edge <= 1;
	end
end

always @(posedge clk) begin : i2c_transaction_state_machine
	logic [3:0] count;
	logic is_read;
	enum {idle, start, send_device_address, sub_address_high, sub_address_low, read_data_high, read_data_low, write_data_high, write_data_low, stop, recover} i2c_state;
	i2c_done <= 0;
	if (lreset) begin
		count <= 0;
		i2c_state <= idle;
		sda <= 1;
		scl <= 1;
		clock_count_enable <= 0;
		i2c_error <= 0;
		is_read <= 0;
		read_data <= 0;
	end else if ((i2c_state == idle) && (start_i2c_transaction)) begin
		count <= 1;
		i2c_state <= start;
		sda <= 1;
		scl <= 1;
		clock_count_enable <= 1;
		i2c_error <= 0;
		is_read <= 0;
		read_data <= 0;
	end else if (i2c_state == start) begin
		if (scl_rising_edge) begin
			scl <= 1;
			if (count == 1) begin
				count <= 0;
				i2c_state <= send_device_address;
			end else begin
				count <= count + 1;
			end;			
		end else if (scl_falling_edge) begin
			if (count == 0) begin
				sda <= 1;
				scl <= 0;	
			end else begin
				sda <= 0;
			end
		end					
	end else if (i2c_state == send_device_address) begin
		if (scl_rising_edge) begin
			scl <= 1;
			if (count == 8) begin		// check for ack
				count <= 0;
				if (sda_in == 0) begin			// got ack
					if (is_read) begin
						if (data_is_2_bytes) begin
							i2c_state <= read_data_high;
						end else begin
							i2c_state <= read_data_low;
						end		
					end else begin
						if (sub_address_is_2_bytes) begin	
							i2c_state <= sub_address_high;
						end else begin
							i2c_state <= sub_address_low;
						end		
					end	
				end else begin
					i2c_state <= stop;		// no ack...abort
					i2c_error <= 1;	
				end
			end else begin
				count <= count + 1;	
			end						
		end							
		if (scl_falling_edge) begin
			scl <= 0;
			if (count < 8) begin
				if (count == 7) begin
					if (is_read) begin
						sda <= 1;
					end else begin								
						sda <= 0;
					end
				end else begin		
					sda <= device_address[7 - count];
				end	
			end else begin
				sda <= 1;
			end
		end	
	end else if (i2c_state == sub_address_high) begin
		if (scl_rising_edge) begin
			scl <= 1;
			if (count == 8) begin		// check for ack
				count <= 0;
				if (sda_in == 0) begin	// got ack
					i2c_state <= sub_address_low;
				end else begin
					i2c_state <= stop;
					i2c_error <= 1;	
				end
			end	else begin
				count <= count + 1;
			end
		end	
		if (scl_falling_edge) begin
			scl <= 0;
			if (count < 8) begin
				sda <= sub_address[15 - count];
			end else begin
				sda <= 1;
			end
		end	
	end else if (i2c_state == sub_address_low) begin
		if (scl_rising_edge) begin
			scl <= 1;
			if (count == 8) begin		// check for ack
				count <= 0;
				if (sda_in != 0) begin	// got ack
					i2c_state <= stop;
					i2c_error <= 1;
				end else begin
					if (device_address[0] == 0) begin
						if (data_is_2_bytes) begin
							i2c_state <= write_data_high;
						end else begin
							i2c_state <= write_data_low;
						end		
					end else begin
						is_read <= 1;
						i2c_state <= start;
					end			
				end
			end	else begin
				count <= count + 1;
			end
		end	
		if (scl_falling_edge) begin
			scl <= 0;
			if (count < 8) begin
				sda <= sub_address[7 - count];
			end else begin
				sda <= 1;
			end
		end
	end else if (i2c_state == write_data_high) begin
		if (scl_rising_edge) begin
			scl <= 1;
			if (count == 8) begin
				count <= 0;
				if (sda_in != 0) begin		// check for ack
					i2c_error <= 1;
					i2c_state <= stop;
				end else begin
					i2c_state <= write_data_low;	
				end	
			end	else begin
				count <= count + 1;
			end
		end
		if (scl_falling_edge) begin
			scl <= 0;
			if (count < 8) begin
				sda <= write_data[15 - count];
			end else begin
				sda <= 1;
			end
		end
	end else if (i2c_state == write_data_low) begin
		if (scl_rising_edge) begin
			scl <= 1;
			if (count == 8) begin
				count <= 0;
				i2c_state <= stop;
				if (sda_in != 0) begin		// check for ack
					i2c_error <= 1;
				end	
			end	else begin
				count <= count + 1;
			end
		end
		if (scl_falling_edge) begin
			scl <= 0;
			if (count < 8) begin
				sda <= write_data[7 - count];
			end else begin
				sda <= 1;
			end
		end
	end else if (i2c_state == read_data_high) begin
		if (scl_rising_edge) begin
			scl <= 1;
			if (count == 8) begin
				count <= 0;
				i2c_state <= read_data_low;
			end else begin
				read_data[15 - count] <= sda_in;
				count <= count + 1;
			end
		end
		if (scl_falling_edge) begin
			scl <= 0;
			if (count < 8) begin
				sda <= 1;
			end else begin
				sda <= 0;
			end	
		end								
	end else if (i2c_state == read_data_low) begin
		if (scl_rising_edge) begin
			scl <= 1;
			if (count == 8) begin
				count <= 0;
				i2c_state <= stop;
			end else begin
				read_data[7 - count] <= sda_in;
				count <= count + 1;
			end
		end
		if (scl_falling_edge) begin
			scl <= 0;
			if (count < 8) begin
				sda <= 1;
			end else begin
				sda <= 1;
			end	
		end								
	end else if (i2c_state == stop) begin
		if (scl_rising_edge) begin
			scl <= 1;
			count <= count + 1;		
		end
		if (scl_falling_edge) begin
			if (count == 0) begin
				sda <= 0;
				scl <= 0;
			end else begin
				sda <= 1;
				scl <= 1;
				count <= 0;
				i2c_state <= recover;
			end
		end						
	end else if (i2c_state == recover) begin
		if (scl_falling_edge) begin
			i2c_state <= idle;
			clock_count_enable <= 0;
			i2c_done <= 1;			
		end
	end			
end						
					
endmodule
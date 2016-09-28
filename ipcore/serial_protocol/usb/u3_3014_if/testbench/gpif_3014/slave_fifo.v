`timescale 1ns / 1ps
module slave_fifo  #(
	parameter	SLAVE_DPTH_WD	= 14                        ,
	parameter	SLAVE_DPTH		= 16'h1fff      			,
	parameter	BUFFER_NUM		= 8                         ,
	parameter	U3_DATWD		= 32
)
(
	input						reset_n				,
	input						i_usb_rd			,//usb read signal
	input		[ 1			:0]	iv_usb_addr			,//usb address 0 1
	input						i_usb_wr			,//usb write signal
	input		[U3_DATWD-1:0]	iv_usb_data			,//usb data signal
	input						i_usb_pclk			,//usb clock signal
	input						i_usb_pkt			,//usb pkt signal
	input						i_usb_cs			,//usb select signal
	input						i_usb_oe			,//usb port enable signal
	input						i_pc_busy			,//pc busy flag
	output		reg				o_flaga				,
	output						o_flagb
    );


	reg			[ SLAVE_DPTH_WD-1:0]	count_full	;
	reg			[ 1			     :0]	usb_addr_r	;
	reg			[ 7			     :0]	shpkt_cnt	;	//用于模拟短包信号后的满标志的状态
	reg									pc_busy		;
	reg			[ 3			     :0]	buffer_cnt	;
	reg			[ 23			 :0]	packet_size	;
	reg			[ 3			     :0]	flagb_shift	;


	always @ ( posedge i_usb_pclk or negedge reset_n  )
		begin
			if ( !reset_n )
				buffer_cnt	<=	4'h0;
			else if ( buffer_cnt >= BUFFER_NUM -1 )
				buffer_cnt <= BUFFER_NUM -1;
			else if ( usb_addr_r != iv_usb_addr)
				buffer_cnt	<=	buffer_cnt + 4'h1;
		end

	always @ ( posedge i_usb_pclk or negedge reset_n  )
		begin
			if ( !reset_n )
				pc_busy	<=	1'b0;
			else if ( !o_flagb )
				pc_busy	<=	i_pc_busy;
		end
//	always @ ( posedge i_usb_pclk or negedge reset_n  )
//		begin
//			if ( !reset_n )
//				pc_busy	<=	1'b1;
//			else
//				pc_busy	<=	1'b1;
//		end


	always @ ( posedge i_usb_pclk or negedge reset_n  )
		begin
			if ( !reset_n )
				usb_addr_r	<=	2'b00;
			else
				usb_addr_r	<=	iv_usb_addr;
		end

	always @ ( posedge i_usb_pclk or negedge reset_n  )
		begin
			if ( !reset_n )
				count_full	<=	0;
			else if ( usb_addr_r != iv_usb_addr )
				count_full	<=	0;
			else if ( ~i_usb_wr )
				count_full	<=	count_full + 1;
		end

	always @ ( posedge i_usb_pclk or negedge reset_n  )
		begin
			if ( !reset_n )
				o_flaga	<=	1'b1;
			else if ( pc_busy )
				o_flaga	<=	1'b0;
			else if ( count_full >= SLAVE_DPTH-5 )
				o_flaga	<=	1'b0;
			else
				o_flaga	<=	1'b1;
		end


	always @ ( posedge i_usb_pclk or negedge reset_n  )
		begin
			if ( !reset_n )
				packet_size	<=	24'h0;
			else if( !i_usb_pkt )
				packet_size	<=	24'h0;
			else if( ~i_usb_wr )
				packet_size	<=	packet_size + 24'h01;
		end


	always @ ( posedge i_usb_pclk or negedge reset_n  )
		begin
			if ( !reset_n )
				shpkt_cnt	<=	8'hff;
			else if( !i_usb_pkt )
				shpkt_cnt	<=	8'h00;
			else if( shpkt_cnt	>=	8'hff )
				shpkt_cnt	<=	8'hff;
			else
				shpkt_cnt	<=	shpkt_cnt + 8'h01;
		end

	always @ ( posedge i_usb_pclk or negedge reset_n  )
		begin
			if ( !reset_n )
				flagb_shift[0]	<=	1'b1;
			else if ( pc_busy )
				flagb_shift[0]	<=	1'b0;
			else if ( ( shpkt_cnt >8'h03 ) &&( shpkt_cnt <8'h15 ) )
				flagb_shift[0]	<=	1'b0;
			else if ( count_full >= SLAVE_DPTH-1 )
				flagb_shift[0]	<=	1'b0;
			else
				flagb_shift[0]	<=	1'b1;
		end

	always @ ( posedge i_usb_pclk or negedge reset_n  )
		begin
			flagb_shift[3:1]<= flagb_shift[2:0];
		end

	assign	o_flagb = flagb_shift[3];	//满标志延时3个时钟

endmodule

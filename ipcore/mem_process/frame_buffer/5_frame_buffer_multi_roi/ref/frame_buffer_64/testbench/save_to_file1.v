
module  save_to_file1
	#(
	parameter	DATA_WD		= 32
	)
	(
	input					clk			,
	input					reset		,
	input	[DATA_WD-1:0]	iv_data		,
	input					i_data_en
	);

	integer	fp;


	initial
	begin
	    fp =$fopen("../testbench/file1.txt","w");
	end



	always@(posedge clk )
		begin
			if (i_data_en)
				begin
					$fwrite (fp,"%x ",iv_data);
					$fwrite (fp,"\n ");
				end
	    end
endmodule
//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : frame_buffer_def
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/5/27 13:12:02	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	�궨��ģ��
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------

//  **************************************************************************************************************
//	ref 1 �û��������� *******************************************************************************************
//  **************************************************************************************************************

//  ===============================================================================================
//	-- ref 1.1 DDR3 оƬ����
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	---- ref 1.1.1 DDR3 �����߸���
//  -------------------------------------------------------------------------------------
`define	DDR3_16_DQ
//`define	DDR3_8_DQ

//  -------------------------------------------------------------------------------------
//	---- ref 1.1.2 DDR3 ��С
//  -------------------------------------------------------------------------------------
//`define	DDR3_MEM_DENSITY_512Mb
`define	DDR3_MEM_DENSITY_1Gb

//  -------------------------------------------------------------------------------------
//	---- ref 1.1.3 DDR3 ʱ����С����
//  -------------------------------------------------------------------------------------
//`define	DDR3_TCK_187E
`define	DDR3_TCK_15E
//`define	DDR3_TCK_125


//  ===============================================================================================
//	-- ref 1.2 MCB ����
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	---- ref 1.2.1 DDR3 ʵ��Ƶ��
//  -------------------------------------------------------------------------------------
//`define	DDR3_800
//`define	DDR3_720
`define	DDR3_660
//`define	DDR3_640

//  -------------------------------------------------------------------------------------
//	-- ref 1.2.2 MCB ��ַ�Ų�
//  -------------------------------------------------------------------------------------
`define	MEM_ADDR_ORDER   			"ROW_BANK_COLUMN"
//`define	MEM_ADDR_ORDER   			"BANK_ROW_COLUMN"


//  ===============================================================================================
//	-- ref 1.3 �������
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	---- ref 1.3.1 MCBΪ8bit��ddr3оƬΪ16bit����ʱddr3��������Ϊ1Gb��MCB��ʵ��Ϊ��512Mb��
//  -------------------------------------------------------------------------------------
//`define	DDR3_16_DQ_MCB_8_DQ

//  -------------------------------------------------------------------------------------
//	---- ref 1.3.2 ��д�����Ƿ�����Զ�Ԥ���Ĺ���
//	ʵ�ʹ����У���д������Ԥ���Ĺ��ܣ�ÿ�ζ�д������precharge������ɹ��ļӴ�
//  -------------------------------------------------------------------------------------
//`define	RD_WR_WITH_PRE

//  -------------------------------------------------------------------------------------
//	---- ref 1.3.3 ������������ָ�벻�ܽ���дָ�룬�Ҷ�дͬʱ��ʼ��
//	ʵ�ʹ���ʱ��ȡ������궨��
//  -------------------------------------------------------------------------------------
//`define	TERRIBLE_TRAFFIC

//  -------------------------------------------------------------------------------------
//	---- ref 1.3.3 ���濪��
//	�����ʱ�򣬶��� SIMULATION ���Լӿ������ٶ�
//  -------------------------------------------------------------------------------------
//`define	SIMULATION

`ifdef SIMULATION
	//����ʱ��ĺ궨��
	`define	DDR3_CALIB_SOFT_IP			"FALSE"		//��ʹ��calibrationģ��
	`define	DDR3_SIMULATION				"TRUE"		//����ģʽ������MCB�����ٶ�
//	`define	DDR3_HW_TESTING				"FALSE"		//���Ե�ַ��խ
	`define	DDR3_HW_TESTING				"TRUE"		//���Ե�ַ�ܿ���ַȫ����
	
`else
	//�ۺ�ʱ��ĺ궨��
	`define	DDR3_CALIB_SOFT_IP			"TRUE"		//ʹ��calibrationģ��
	`define	DDR3_SIMULATION				"FALSE"		//���ֲ���ģʽ
	`define	DDR3_HW_TESTING				"TRUE"		//���Ե�ַ�ܿ���ַȫ����
	
`endif

//  ===============================================================================================
//	-- ref 1.3 Traffic������
//  ===============================================================================================
//`define	TRAFFIC_TYPE_ADDR_AS_DATA
`define	TRAFFIC_TYPE_HAMMER
//`define	TRAFFIC_TYPE_NEIGHBOR
//`define	TRAFFIC_TYPE_WALKING_1S
//`define	TRAFFIC_TYPE_WALKING_0S
//`define	TRAFFIC_TYPE_PRBS

`ifdef	TRAFFIC_TYPE_ADDR_AS_DATA
	`define	TRAFFIC_DATA_MODE	4'b0010
`elsif	TRAFFIC_TYPE_HAMMER
	`define	TRAFFIC_DATA_MODE	4'b0011
`elsif	TRAFFIC_TYPE_NEIGHBOR
	`define	TRAFFIC_DATA_MODE	4'b0100
`elsif	TRAFFIC_TYPE_WALKING_1S
	`define	TRAFFIC_DATA_MODE	4'b0101	
`elsif	TRAFFIC_TYPE_WALKING_0S
	`define	TRAFFIC_DATA_MODE	4'b0110	
`elsif	TRAFFIC_TYPE_PRBS
	`define	TRAFFIC_DATA_MODE	4'b0111
`endif
	

//  **************************************************************************************************************
//	ref 2 �û����������� *****************************************************************************************
//  **************************************************************************************************************

//  ===============================================================================================
//	-- ref 2.1 �궨�����õ�MCB��
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	---- ref 2.1.1 DDR3 �����ߺ궨��
//  -------------------------------------------------------------------------------------
`ifdef	DDR3_16_DQ
	`define	NUM_DQ_PINS				16					//External memory data width
`elsif	DDR3_8_DQ
	`define	NUM_DQ_PINS				8					//External memory data width
`endif

//  -------------------------------------------------------------------------------------
//	---- ref 2.1.2 DDR3 ��С�궨��
//  -------------------------------------------------------------------------------------
`ifdef	DDR3_MEM_DENSITY_1Gb
	`define	DDR3_MEM_DENSITY		"1Gb"				//"1Gb" "512Mb"
`elsif	DDR3_MEM_DENSITY_512Mb
	`define	DDR3_MEM_DENSITY		"512Mb"				//"1Gb" "512Mb"
`endif

//  -------------------------------------------------------------------------------------
//	---- ref 2.1.3 DDR3 ��ַ�߿�Ⱥ궨��
//  -------------------------------------------------------------------------------------
`ifdef	DDR3_MEM_DENSITY_512Mb
	`ifdef	DDR3_8_DQ
		`define	MEM_ADDR_WIDTH		13					//External memory address width
	`elsif	DDR3_16_DQ
		`define	MEM_ADDR_WIDTH		12					//External memory address width
	`endif
`elsif	DDR3_MEM_DENSITY_1Gb
	`ifdef	DDR3_8_DQ
		`define	MEM_ADDR_WIDTH		14					//External memory address width
	`elsif	DDR3_16_DQ
		`define	MEM_ADDR_WIDTH		13					//External memory address width
	`endif
`endif

//  -------------------------------------------------------------------------------------
//	---- ref 2.1.4 DDR3 BANK ��ַ�߿�Ⱥ궨��
//  -------------------------------------------------------------------------------------
`define	MEM_BANKADDR_WIDTH   		3					//External memory bank address width

//  -------------------------------------------------------------------------------------
//	---- ref 2.1.5 DDR3 ʱ������궨��
//  -------------------------------------------------------------------------------------
`ifdef	DDR3_TCK_187E
	`define	DDR3_MEM_TRAS		37500
	`define	DDR3_MEM_TRCD		13130
	`define	DDR3_MEM_TREFI		7800000
	`define	DDR3_MEM_TRFC		160000
	`define	DDR3_MEM_TRP		13130
	`define	DDR3_MEM_TWR		15000
	`define	DDR3_MEM_TRTP		7500
	`define	DDR3_MEM_TWTR		7500

`elsif	DDR3_TCK_15E
	`define	DDR3_MEM_TRAS		36000
	`define	DDR3_MEM_TRCD		13500
	`define	DDR3_MEM_TREFI		7800000
	`define	DDR3_MEM_TRFC		160000
	`define	DDR3_MEM_TRP		13500
	`define	DDR3_MEM_TWR		15000
	`define	DDR3_MEM_TRTP		7500
	`define	DDR3_MEM_TWTR		7500

`elsif	DDR3_TCK_125
	`define	DDR3_MEM_TRAS		35000
	`define	DDR3_MEM_TRCD		13750
	`define	DDR3_MEM_TREFI		7800000
	`define	DDR3_MEM_TRFC		160000
	`define	DDR3_MEM_TRP		13750
	`define	DDR3_MEM_TWR		15000
	`define	DDR3_MEM_TRTP		7500
	`define	DDR3_MEM_TWTR		7500

`endif


//  ===============================================================================================
//	-- ref 2.2 �궨�����õ�����ģ����
//  ===============================================================================================

//  -------------------------------------------------------------------------------------
//	---- ref 2.2.1 PLL �궨��
//  -------------------------------------------------------------------------------------
`ifdef DDR3_800
	`define	DDR3_MEMCLK_PERIOD			2500			//DDR3-800 �Ĺ���ʱ��Ƶ����400MHz��������2500ps.����ʵ��Ƶ����д
	//PLL����
	`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL����Ƶ�ʣ���λ��ps
	`define	DDR3_PLL_CLKOUT0_DIVIDE		1				//ddr3 2��Ƶ 800MHz
	`define	DDR3_PLL_CLKOUT1_DIVIDE		1				//ddr3 2��Ƶ 800MHz ��λ�෴
	`define	DDR3_PLL_CLKOUT2_DIVIDE		8				//mcb drp ʱ�� 100MHz
	`define	DDR3_PLL_CLKOUT3_DIVIDE		5				//֡���湤��ʱ�� 160
	`define	DDR3_PLL_CLKOUT4_DIVIDE		5
	`define	DDR3_PLL_CLKOUT5_DIVIDE		5
	`define	DDR3_PLL_CLKFBOUT_MULT		20
	`define	DDR3_PLL_DIVCLK_DIVIDE		1

`elsif DDR3_720
	`define	DDR3_MEMCLK_PERIOD			2778			//DDR3-720 �Ĺ���ʱ��Ƶ����360MHz��������2778ps.����ʵ��Ƶ����д
	//PLL����
	`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL����Ƶ�ʣ���λ��ps
	`define	DDR3_PLL_CLKOUT0_DIVIDE		1
	`define	DDR3_PLL_CLKOUT1_DIVIDE		1
	`define	DDR3_PLL_CLKOUT2_DIVIDE		8
	`define	DDR3_PLL_CLKOUT3_DIVIDE		4
	`define	DDR3_PLL_CLKOUT4_DIVIDE		5
	`define	DDR3_PLL_CLKOUT5_DIVIDE		5
	`define	DDR3_PLL_CLKFBOUT_MULT		18
	`define	DDR3_PLL_DIVCLK_DIVIDE		1

`elsif DDR3_660
	`define	DDR3_MEMCLK_PERIOD			3030			//DDR3-660 �Ĺ���ʱ��Ƶ����330MHz��������3125ps.����ʵ��Ƶ����д
	//PLL����
	`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL����Ƶ�ʣ���λ��ps
	`define	DDR3_PLL_CLKOUT0_DIVIDE		1				//ddr3 2��Ƶ 6600MHz
	`define	DDR3_PLL_CLKOUT1_DIVIDE		1				//ddr3 2��Ƶ 660MHz ��λ�෴
	`define	DDR3_PLL_CLKOUT2_DIVIDE		8				//mcb drp ʱ�� 82.5MHz
	`define	DDR3_PLL_CLKOUT3_DIVIDE		7				//֡���湤��ʱ�� 94.286MHz
	//	`define	DDR3_PLL_CLKOUT3_DIVIDE		6			//֡���湤��ʱ�� 110MHz
	`define	DDR3_PLL_CLKOUT4_DIVIDE		8
	`define	DDR3_PLL_CLKOUT5_DIVIDE		8
	`define	DDR3_PLL_CLKFBOUT_MULT		33
	`define	DDR3_PLL_DIVCLK_DIVIDE		2

`elsif DDR3_640
	`define	DDR3_MEMCLK_PERIOD			3125			//DDR3-640 �Ĺ���ʱ��Ƶ����320MHz��������3125ps.����ʵ��Ƶ����д
	//PLL����
	`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL����Ƶ�ʣ���λ��ps
	`define	DDR3_PLL_CLKOUT0_DIVIDE		1
	`define	DDR3_PLL_CLKOUT1_DIVIDE		1
	`define	DDR3_PLL_CLKOUT2_DIVIDE		8
	`define	DDR3_PLL_CLKOUT3_DIVIDE		4
	`define	DDR3_PLL_CLKOUT4_DIVIDE		5
	`define	DDR3_PLL_CLKOUT5_DIVIDE		5
	`define	DDR3_PLL_CLKFBOUT_MULT		16
	`define	DDR3_PLL_DIVCLK_DIVIDE		1


`endif



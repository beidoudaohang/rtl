//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : testbench_def
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
//  -- ģ������     :����testbench�ĸ����������������ʹ��
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------







//Ӱ��֡�����������Ҫ�������¼���
//(1)ͼ���С
//(2)֡�����
//(3)������ʱ�������Чʱ��
//(4)ͼ������ʱ��
//(5)֡���湤��ʱ��
//(6)ͣ�����ź�
//(7)ddr3����
//  ===============================================================================================
//	ref ����֡����Ĺ���
//  ===============================================================================================

//  ===============================================================================================
//	--ref 1.����֡��������
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	��������1.1
////	4֡���� �ва�
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			100
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	��������1.2
////	2֡���� �ва�
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			100
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b010		//2 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	��������1.3
////	1֡���� �ва�
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			100
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b001		//1 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	��������1.4
////	4֡���� �޲а�
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			128
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	��������1.5
////	2֡���� �޲а�
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			128
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b010		//2 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	��������1.6
////	1֡���� �޲а�
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			128
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b001		//1 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10


//  ===============================================================================================
//	--ref 2.����ͼ���С
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	��������2.1
////	�ва���ͼ���СΪ 80 byte С�� 256 byte��ͼ���С��һ֡ͼ�񲻹�һ��дburst����������
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			2
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10
//

////  -------------------------------------------------------------------------------------
////	��������2.2
////	�޲а���ͼ���С���� 256 byte��һ֡ͼ�����һ��дburst����������
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			16
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	��������2.3
////	�ва���ͼ���С�е� 8016 byte��
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			501
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				5

////  -------------------------------------------------------------------------------------
////	��������2.4
////	�޲а���ͼ���С�е� 8192 byte��
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			512
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				5
//
////  -------------------------------------------------------------------------------------
////	��������2.5
////	�ва���ͼ��Ƚϴ� 229360 byte��
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			14335
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
//
//
////  -------------------------------------------------------------------------------------
////	��������2.6
////	�޲а���ͼ��Ƚϴ� 229360 byte��
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			14336
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
//


//  ===============================================================================================
//	--ref 3.����ͣ�����ź�
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	��������3.1
////	��д3֮֡��ͣ�ɣ�ֹͣһ��ʱ��֮���ٿ���
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM				100
//`define			LINE_HIDE_PIX_NUM				200
//`define			LINE_ACTIVE_NUMBER				3
//`define			FRAME_HIDE_PIX_NUM				200
//`define			FRAME_TO_LINE_PIX_NUM			100
//
//`define			FRAME_DEPTH						3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD					20	//50MHz
//`define			CLK_OUT_PERIOD					10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD			10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM					10
//
//`define			SIM_CHANGE_FRAME_EN


////  -------------------------------------------------------------------------------------
////	��������3.2
////	��д3֮֡��ͣ�ɣ�ֹͣһ��ʱ��֮�󣬸ı�֡����ȣ��ٿ���
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			200
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//

//`define			FRAME_DEPTH0				3'b100		//4 frame
//`define			FRAME_DEPTH1				3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_CHANGE_FRAME_EN
//`define			SIM_CHANGE_FRAME_DEPTH


////  -------------------------------------------------------------------------------------
////	��������3.3
////	��д3֮֡��ͣ�ɣ�ֹͣһ��ʱ��֮�󣬸ı�ͼ���С���ٿ���
////  -------------------------------------------------------------------------------------
//pattern model
//`define			LINE_ACTIVE_PIX_NUM0			65
//`define			LINE_HIDE_PIX_NUM0				50
//`define			LINE_ACTIVE_NUMBER0				5
//`define			FRAME_HIDE_PIX_NUM0				100
//`define			FRAME_TO_LINE_PIX_NUM0			50
//
////test
//`define			LINE_ACTIVE_PIX_NUM1			100
//`define			LINE_HIDE_PIX_NUM1				200
//`define			LINE_ACTIVE_NUMBER1				3
//`define			FRAME_HIDE_PIX_NUM1				200
//`define			FRAME_TO_LINE_PIX_NUM1			100
//
//`define			FRAME_DEPTH						3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
//������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_CHANGE_FRAME_EN
//`define			SIM_CHANGE_FRAME_SIZE

//  ===============================================================================================
//	--ref 4.���Ը�λ�ź�
//  ===============================================================================================

////  -------------------------------------------------------------------------------------
////	��������4.1
////	��д3֮֡�󣬸�λһ��ʱ�䣬��ȡ����λ
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			200
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH						3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_CHANGE_RST


//  ===============================================================================================
//	--ref 5.���Ժ�ӵ������
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	��������5.1
////	4֡����
////	�ڶ��ڶ�֡��ʱ��ֹͣ��һ��ʱ�䣬�ٶ�
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			200
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH						3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_BACKEND_BLOCK

////  -------------------------------------------------------------------------------------
////	��������5.2
////	2֡����
////	�ڶ��ڶ�֡��ʱ��ֹͣ��һ��ʱ�䣬�ٶ�
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			200
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH						3'b010		//2 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_BACKEND_BLOCK

////  -------------------------------------------------------------------------------------
////	��������5.3
////	1֡����
////	�ڶ��ڶ�֡��ʱ��ֹͣ��һ��ʱ�䣬�ٶ�
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			200
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH						3'b001		//1 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_BACKEND_BLOCK


//  ===============================================================================================
//	ref ����֡����Ĵ�������
//  ===============================================================================================
//  ===============================================================================================
//	--ref 6.����֡����Ĵ�������
//	һ֡��ֻ��һ�У�û��������ʱ�䡣Fvin <= Fframe_buf * 0.85��
//  ===============================================================================================

////  -------------------------------------------------------------------------------------
////	��������6.1
////	ͼ���С��256byte����������һ֡��ֻ��һ�У�ǰ������ʱ��=֡����ʱ��*85%
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				11.76	//85MHz
//`define			CLK_OUT_PERIOD				10		//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				1
//`define			SIM_DELAY_TIME_NUM			6000

////  -------------------------------------------------------------------------------------
////	��������6.2
////	ͼ���С����256byte����������ͼ���ва���һ֡��ֻ��һ�У�ǰ������8.16Gbps���Ѿ�ʮ�ֽӽ�֡����ģ���������
////	֡���湤��ʱ��155MHz����Ϊֻ�д���150MHz��ʱ��֡����ģ����ܴﵽ������
////	��Ҫ֡���湤����170MHz��Ƶ�ʣ�PLL��Ƶһ��ֻ�ܵ�200MHz ���� 160MHz������170MHz��Ƶ��Ҳ̫����Щ
////	ǰ�˵�ʱ��Ƶ����127.5MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*127.5MHz=510Mbye/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				7.84	//127.5MHz
//`define			CLK_OUT_PERIOD				7.84	//127.5MHz
//`define			CLK_FRAME_BUF_PERIOD		5.88	//170MHz
//
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000



////  -------------------------------------------------------------------------------------
////	��������6.3
////	ǰ�˵�ʱ��Ƶ����150MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*150MHz=600Mbye/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				6.667	//150MHz
//`define			CLK_OUT_PERIOD				6.667	//150MHz
//`define			CLK_FRAME_BUF_PERIOD		5		//200MHz
//
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000
//
////  -------------------------------------------------------------------------------------
////	��������6.4
////	ǰ�˵�ʱ��Ƶ����160MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*160MHz=640Mbye/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				6.25	//150MHz
//`define			CLK_OUT_PERIOD				6.25	//150MHz
//`define			CLK_FRAME_BUF_PERIOD		5		//200MHz
//
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000



////  -------------------------------------------------------------------------------------
////	��������6.4
////	ͼ���С��256byte����������ͼ��û�ва���һ֡��ֻ��һ�У�ǰ������Ƚ�С��Fvin = Fframe_buf * 0.85
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				23.53	//42.5MHz
//`define			CLK_OUT_PERIOD				20		//50MHz
//`define			CLK_FRAME_BUF_PERIOD		20		//50MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				1
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000


//  ===============================================================================================
//	--ref 7.����֡����Ĵ������ܡ�
//	һ֡���ж��У���Ҫ����������ʱ�䡣Fvin > Fframe_buf ��
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	��������7.1
//	ͼ���С��256byte����������һ֡��ֻ��һ�У�ǰ������ʱ��=֡����ʱ��*85%
//  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				10		//100MHz
//`define			CLK_OUT_PERIOD				20		//50MHz
//`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				1
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000

//  ===============================================================================================
//	--ref 8.MCB λ��Ϊ8bit 800Mbps ���Դ�������
//	8bit�����۴���Ϊ 8pin * 800Mbps = 6.4Gbps = 800Mbyte/s�����ܴ����ǰ�˴������Ϊ400Mbyte/s
//	��������ʱ��Ϊ150MHzʱ��32bit*150MHz=4.8Gbps=600Mbyte�����������ϵĴ���
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	��������8.1
////	ǰ�˵�ʱ��Ƶ����80MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*80MHz=320Mbye/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
////`define			CLK_IN_PERIOD				7.84	//127.5MHz
////`define			CLK_OUT_PERIOD				5.88	//170MHz
////`define			CLK_FRAME_BUF_PERIOD		5.88	//170MHz
//
//////UNIT ns
////`define			CLK_IN_PERIOD				7.84	//127.5MHz
////`define			CLK_OUT_PERIOD				6.25	//160MHz
////`define			CLK_FRAME_BUF_PERIOD		6.25	//160MHz
////
////UNIT ns
//`define			CLK_IN_PERIOD				12.5	//80MHz
//`define			CLK_OUT_PERIOD				6.45	//155MHz
//`define			CLK_FRAME_BUF_PERIOD		6.45	//155MHz
//
////UNIT ns
////`define			CLK_IN_PERIOD				7.84	//127.5MHz
////`define			CLK_OUT_PERIOD				6.667	//150MHz
////`define			CLK_FRAME_BUF_PERIOD		6.667	//150MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				1
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000


////  -------------------------------------------------------------------------------------
////	��������8.2
////	ǰ�˵�ʱ��Ƶ����85MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*85MHz=340Mbye/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				11.764	//85MHz
//`define			CLK_OUT_PERIOD				11.764	//85MHz
//`define			CLK_FRAME_BUF_PERIOD		8.334	//120MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000



////  -------------------------------------------------------------------------------------
////	��������8.3
////	ǰ�˵�ʱ��Ƶ����90MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*90MHz=360Mbye/s ����̫��
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			3000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				11.111	//90MHz
//`define			CLK_OUT_PERIOD				11.111	//90MHz
//`define			CLK_FRAME_BUF_PERIOD		6.25	//160MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
////`define			SIM_READ_DELAY


////  -------------------------------------------------------------------------------------
////	��������8.4
////	ǰ�˵�ʱ��Ƶ����100MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*100MHz=400Mbye/s.
////	DDR3�ļ��ޣ����治��ͨ��
////  -------------------------------------------------------------------------------------
//pattern model
`define			LINE_ACTIVE_PIX_NUM			10005
`define			LINE_HIDE_PIX_NUM			0
`define			LINE_ACTIVE_NUMBER			1
`define			FRAME_HIDE_PIX_NUM			200
`define			FRAME_TO_LINE_PIX_NUM		100

`define			FRAME_DEPTH					3'b100	//4 frame

//UNIT ns
`define			CLK_IN_PERIOD				10	//100MHz
`define			CLK_OUT_PERIOD				6.45	//155MHz
`define			CLK_FRAME_BUF_PERIOD		6.45	//155MHz

//������ٷ�ͼ��
`define			SIM_FRAME_NUM				1



//  ===============================================================================================
//	--ref 9.MCB λ��Ϊ8bit 660Mbps ���Դ�������
//	8bit�����۴���Ϊ 8pin * 660Mbps = 5.28Gbps = 660Mbyte/s�����ܴ����ǰ�˴������Ϊ330Mbyte/s
//	�۳�ddr3��Э�鿪�����������㣬�ܴ�����Դﵽ569Mbyte/s
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	��������9.1
//	ǰ�˵�ʱ��Ƶ����70MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*70MHz=280Mbye/s
//  -------------------------------------------------------------------------------------
////pattern model
////`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_ACTIVE_PIX_NUM			100
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				14.285	//70MHz
//`define			CLK_OUT_PERIOD				14.285	//70MHz
//`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000

////  -------------------------------------------------------------------------------------
////	��������9.2
////	ǰ�˵�ʱ��Ƶ����71MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*71MHz=284Mbye/s
////	ddr3�Ĵ����ܹ����㵱ǰ��ǰ���������
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				14.084	//71MHz
//`define			CLK_OUT_PERIOD				14.084	//71MHz
////`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
////`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
//`define			CLK_FRAME_BUF_PERIOD		10.638	//94MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM	8000

////  -------------------------------------------------------------------------------------
////	��������9.3
////	ǰ�˵�ʱ��Ƶ����71.25MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*71.25MHz=285Mbye/s
////	ddr3�Ĵ����ܹ����㵱ǰ��ǰ���������
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			20000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		300
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				14.034	//71.25MHz
//`define			CLK_OUT_PERIOD				14.034	//71.25MHz
////`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
////`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
////`define			CLK_FRAME_BUF_PERIOD		10.638	//94MHz
//`define			CLK_FRAME_BUF_PERIOD		11.9	//84MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				6
//////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000

////  -------------------------------------------------------------------------------------
////	��������9.4
////	ǰ�˵�ʱ��Ƶ����71.5MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*71.5MHz=286Mbye/s
////////	������ddr3�Ĵ���
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			3000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.986	//71.5MHz
//`define			CLK_OUT_PERIOD				13.986	//71.5MHz
//`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
////`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
////`define			CLK_FRAME_BUF_PERIOD		10.638	//94MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	0

////  -------------------------------------------------------------------------------------
////	��������9.4
////	ǰ�˵�ʱ��Ƶ����71.75MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*71.75MHz=287Mbye/s
//////	������ddr3�Ĵ���
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			20000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.936	//71.75MHz
//`define			CLK_OUT_PERIOD				13.936	//71.75MHz
//`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
////`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
////`define			CLK_FRAME_BUF_PERIOD		10.638	//94MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000

////  -------------------------------------------------------------------------------------
////	��������9.4
////	ǰ�˵�ʱ��Ƶ����72MHz��һ֡��ֻ��һ�У�ǰ�˴���Ϊ 32bit*72MHz=288Mbye/s
////	������ddr3�Ĵ���
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.888	//72MHz
//`define			CLK_OUT_PERIOD				13.888	//72MHz
//`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM	8000




//  ===============================================================================================
//	--ref 10.����ddr3 660Mbps ��python1300�ϵ����ܣ�
//	python1300��ʱ��Ϊ72MHz������Ч320��clk��������4��clk��
//	��zero-rot�£��ܴ���Ϊ 1280*1024*210fps=275.251Mbyte/s����284Mbyte/s���ٶȻ����в�࣬�����Ͽ���ͨ��
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	��������10.1 һ֡��ʱ��̫������˷����ʱ��Ҫ����һЩ��
////	ǰ�˵�ʱ��Ƶ����72MHz��һ֡����30�У��ܵ�������Ϊ30��*320������*4byte=38400byte
////	38400byte/(275.251Mbyte/s) = 139.5us = 10044clk .������Чʱ��Ϊ 30*320+29*4=9716.����֡����ʱ���ܹ���328��
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			320
//`define			LINE_HIDE_PIX_NUM			4
////`define			LINE_ACTIVE_NUMBER			30
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			300
//`define			FRAME_TO_LINE_PIX_NUM		28
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.888	//72MHz
//`define			CLK_OUT_PERIOD				13.888	//72MHz
//
////`define			CLK_IN_PERIOD				100	//10MHz
////`define			CLK_OUT_PERIOD				100	//10MHz
//
////`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10.638	//94MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000
//

////  -------------------------------------------------------------------------------------
////	��������10.2 ʵ�ʵ�python���� ���ڰ��ϲ���
////	python1300�ֱ���Ϊ1280*1024��֡��Ϊ210fps���ܵĴ���ԼΪ274Mbyte/s.����Ч320clk��������4clk
////	ǰ�˵�ʱ��Ƶ����72MHz��һ֡����1024�У��ܵ�������Ϊ1024��*320������*4byte = 1310720 byte
////	1310720byte/(275.251Mbyte/s) = 4762us = 342857 clk .������Чʱ��Ϊ 1024*320+1023*4=331772.����֡����ʱ���ܹ���11085��clk
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			320
//`define			LINE_HIDE_PIX_NUM			4
//`define			LINE_ACTIVE_NUMBER			1024
//`define			FRAME_HIDE_PIX_NUM			11060
//`define			FRAME_TO_LINE_PIX_NUM		25
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.888	//72MHz
//`define			CLK_OUT_PERIOD				13.888	//72MHz
////`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
//`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
//////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000

////  -------------------------------------------------------------------------------------
////	��������10.3 ��python1300����������һ��CLK
////	����Ч320CLK��������3CLK������=72*4*320/323=285.325MByte/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			320
//`define			LINE_HIDE_PIX_NUM			3
//`define			LINE_ACTIVE_NUMBER			1024
////`define			FRAME_HIDE_PIX_NUM			11060
//`define			FRAME_HIDE_PIX_NUM			10
//`define			FRAME_TO_LINE_PIX_NUM		25
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.888	//72MHz
//`define			CLK_OUT_PERIOD				13.888	//72MHz
////`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
////`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
//`define			CLK_FRAME_BUF_PERIOD		10.868	//92MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				2
//////д��һ֮֡��Ż������д��ͬ֡��ddr3��Ч�ʻ����
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000

//  ===============================================================================================
//	ref ����������
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	����֡����Ĵ������ܣ�����������İ汾
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			120
//`define			LINE_HIDE_PIX_NUM			1
//`define			LINE_ACTIVE_NUMBER			1024
//`define			FRAME_HIDE_PIX_NUM			120
//`define			FRAME_TO_LINE_PIX_NUM		10
//
//`define			FRAME_DEPTH						3'b010		//2 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				10	//100MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		7.5	//133MHz
//
////������ٷ�ͼ��
//`define			SIM_FRAME_NUM				10






//  ===============================================================================================
//	*** do not modify ***
//  ===============================================================================================
`define			FRAME_SIZE					(`LINE_ACTIVE_PIX_NUM * `LINE_ACTIVE_NUMBER) - 1


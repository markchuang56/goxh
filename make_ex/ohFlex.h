
#ifndef		_OHFLEX_H_
#define		_OHFLEX_H_

#define ST			0x02
#define EOT			0x03
#define ST_OFFSET			0
#define LEN_OFFSET			1
#define MEM_OFFSET			3
#define DATA_OFFSET			5

#define	MEM_ADDR			0x0406

// CRC
#define           poly     0x1021          /* crc-ccitt mask */


#define LEN_TX				14
#define LEN_TOTAL			32
#define FLEX_DIV			19

void flexDataProcess(unsigned char* srcData, unsigned short dataLen, unsigned short memAddr);
unsigned char transfer(char ch);
unsigned char ohToAscii(char ch);

void update_good_crc(unsigned short); 
void augment_message_for_good_crc(); 
void update_bad_crc(unsigned short);
void goFlex(unsigned char *dataSrc, int srcLen);

#endif

/*

unsigned char flexDate[] =
{
	0x03, 
	0x02, 0x2a, 0x00 , 0x04, 0x06, 0x36, 0x00 , 
	0x38, 0x00, 0x41, 0x00 , 0x46, 0x00, 0x31, 0x00 , 
	0x36, 0x00, 0x45, 0x00 ,
	0x41, 0x30, 0x00, 0x44 , 0x00, 0x32, 0x00, 0x32 , 
	0x00, 0x43, 0x00, 0x32 , 0x00, 0x46, 0x00, 0x34 ,
	0x00, 0x42, 0x00, 0x00 ,
	0x42, 0x00, 0x03, 0x80 , 0x39
};

unsigned char flexDate1[] =
{
	0x03, 0x02, 0x2a, 0x00 , 0x04, 0x06, 0x39, 0x00 ,
	0x41, 0x00, 0x38, 0x00 , 0x36, 0x00, 0x31, 0x00 ,
	0x43, 0x00, 0x31, 0x00 ,
	
	0x41, 0x41, 0x00, 0x32 , 0x00, 0x31, 0x00, 0x42 , 
	0x00, 0x46, 0x00, 0x30 , 0x00, 0x31, 0x00, 0x45 ,
	0x00, 0x34, 0x00, 0x00 ,
		
	0x42, 0x00, 0x03, 0x6f , 0x98
		
	
									
		
	
};

unsigned char flexDate2[] =
{
	0x03, 0x02, 0x2a, 0x00 , 0x04, 0x06, 0x37, 0x00 ,
	0x38, 0x00, 0x39, 0x00 , 0x39, 0x00, 0x43, 0x00 ,
	0x34, 0x00, 0x37, 0x00 ,
	0x41, 0x46, 0x00, 0x43 , 0x00, 0x35, 0x00, 0x39 ,
	0x00, 0x30, 0x00, 0x30 , 0x00, 0x37, 0x00, 0x46 ,
	0x00, 0x37, 0x00, 0x00 ,
	0x42, 0x00, 0x03, 0x58 , 0xeb
};

// 68 24 53
//0x6d, 0x01, 0x02, 0x00 , 0x8e, 0x2c, 0x82, 0xd8 , 
//0x5a, 0xce, 0xe4, 0xc4 , 0xbd, 0xe9, 0xaf, 0x13 , 
//0x2a, 0x45, 0x33, 0x99
unsigned char flexDate3[] =
{
0x03, 0x02, 0x2a, 0x00 , 0x04, 0x06, 0x43, 0x00 , 
0x45, 0x00, 0x41, 0x00 , 0x43, 0x00, 0x45, 0x00 ,
0x34, 0x00, 0x37, 0x00 ,
0x41, 0x36, 0x00, 0x44 , 0x00, 0x39, 0x00, 0x34 , 
0x00, 0x37, 0x00, 0x39 , 0x00, 0x44, 0x00, 0x37 , 
0x00, 0x43, 0x00, 0x00 ,
0x42, 0x00, 0x03, 0x64 , 0x69
};

*/
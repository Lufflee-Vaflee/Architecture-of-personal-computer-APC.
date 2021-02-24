#include <stdio.h>
#include <dos.h>

void playSound();
void printStateWords();
void divRatio();

int main()
{
	printf("Start values:\n");
	printStateWords();
	divRatio();

	char choice;
	unsigned int limit = 65536 - 1, numberLow, numberHigh, number;

	while(1) {
		printf("\n\n1. Play sound.\n2. Print state words.\n3. Division ratio.\n4. Set a limit.\n5. Get a number.\n0. Exit\n");
		fflush(stdin);
		printf("\nYour choise: ");
		scanf("%c", &choice);

		switch (choice) {
		case '1':
			playSound();

			outp(0x43, 0xB4);			 //   43 - ������� ������,   �4 - 10110100
			//  [0] - 2ss, [1-3] - ����� ���������� ���������, [4-5] - ������/������ ��������, ����� �������� �����, [7-6]- ����� 3 ������
			outp(0x42, limit % 256);     //   limit % 256 = 255
			outp(0x42, limit / 256);	 //   limit / 256 = 255
			outp(0x61, inp(0x61) | 1);	 // ��������� ��� 1 � ���������� �� inp  (������������� 0 ��� 61 ����� � 1)

			break;

		case '2':
			printStateWords();

			outp(0x43, 0xB4);				// ��������������� ��������� ���������
			outp(0x42, limit % 256);
			outp(0x42, limit / 256);
			outp(0x61, inp(0x61) | 1);		

			break;

		case '3':
			divRatio();					// ���������� ���� �������

			outp(0x43, 0xB4);					
			outp(0x42, limit % 256);
			outp(0x42, limit / 256);
			outp(0x61, inp(0x61) | 1);

			break;

		case '4':														// ������������� ����� ������������ ����� ��� �������
			do {
				printf("\nEnter a limit in range [1...65635]: ");
				fflush(stdin);
			} while (!scanf("%d", &limit) || limit < 1);

			outp(0x43, 0xB4);
			outp(0x42, limit % 256);
			outp(0x42, limit / 256);
			outp(0x61, inp(0x61) | 1);

			break;

		case '5':

			outp(0x43, 128);			// 128 - 10000000
			//  [0] - 2ss, [1-3] - ��������� ���������� ��� �������� � 0, [4-5] - ���������� �������� [7-6]- ����� 3 ������
			numberLow = inp(0x42);						// ��������� ������� �����
			numberHigh = inp(0x42);						// ��������� ������� �����
			number = numberHigh * 256 + numberLow;		// ���������� ��� �������

			printf("\nRandom number: %u\n", number);

			break;

		case '0':
		       return 0;	;
		}
	}
}

void printStateWords() {
	unsigned char controlBytes[3] = { 0xE2, 0xE4, 0xE8 };   // 11100010, 11100100, 11101000
	// ����� ��������� ��� [7-6] = 1
	//  [0] - ������ 0, [1-3] - ����� ������(������ � 1), [4] - 0 ��������� �������� ��������� ������, [5] - 0 ��������� �������� ��������, [7-6]- ���������� �������� �� ��������� �������
	unsigned char state;
	unsigned char ports[3] = { 0x40, 0x41, 0x42 };


	for (int i = 0; i < 3; ++i)
	{
		outp(0x43, controlBytes[i]);   

		state = inp(ports[i]);			

		printf("Channel %d: ", i);
		for (int j = 7; j >= 0; --j)
		{
			printf("%d", (state >> j) & 1);
		}
		printf("\n");
	}
}

void divRatio()
{
	int ports[3] = { 0x40, 0x41, 0x42 };
	int controlBytes[3] = { 0, 64, 128 };
	unsigned int iValue, iHigh, iLow, temp;

	printf("Division ratio:\n");

	for (int i = 0; i < 3; ++i)
	{
		if (i == 2)														// �������� ��������� ��� ������ ��������
		{
			outp(0x61, inp(0x61) | 3); //  SPEAKER - ON
		}
		iValue = 0;
		for (int j = 0; j < 30000; j++)
		{
			outp(0x43, controlBytes[i]);
			iLow = inp(ports[i]);				// ��������� ������� �����
			iHigh = inp(ports[i]);				// ��������� ������� �����
			temp = iHigh * 256 + iLow;			// ���������� ��� ������� 
			if (temp > iValue)					// ���� ��� ������������, ����������
				iValue = temp;
		}

		if (i == 2)
		{
			outp(0x61, inp(0x61) & 0xFC); //  SPEAKER - OFF
		}
		printf("Channel %d: %X\n", i, iValue);
	}
}

void playSound() {
	int frequency[9] = { 659,622,659,622,659,493,622,523,440};	//������� �������		//  �������������, 
	int durability[9] = { 200,200,200,200,200,200,200,200,200};	//������������ �.		//  ��� ���� ������

	long unsigned base = 1193180;			//  ������� ����������
	int kd;

	for (int i = 0; i < 9; i++) {
		outp(0x43, 0xB6);	// 10110110 		   
		//  [0] - 2ss, [1-3] - ����� � ������������� ���������, [4-5] - ������/������ ��������, ����� �������� �����, [7-6]- ����� 3 ������
		kd = base / frequency[i];
		outp(0x42, kd % 256);
		kd /= 256;
		outp(0x42, kd);

		outp(0x61, inp(0x61) | 3);    // ������������� 0 � 1 ���� 61 ����� � 1, �������� �������
		delay(durability[i]);		  // ���������������� ���������� ��������� 
		outp(0x61, inp(0x61) & 0xFC); // ������������� 0 � 1 ���� 61 ����� � 0, ��������� �������
	}
}
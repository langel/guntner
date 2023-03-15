#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>


int main(int argc, char* args[]) {
	FILE * fp = fopen("guntest.nes", "r");
	fseek(fp, 0, SEEK_END);
	int size = ftell(fp);
	rewind(fp);
	uint8_t * data = (uint8_t*) malloc(size * sizeof(uint8_t));;
	fread(data, size, 1, fp);
	fclose(fp);
	char out[256];
	for (int hi = 0; hi < 8; hi++) {
		for (int lo = 0; lo < 16; lo++) {
			data[0x02b4] = (uint8_t) 0x60 + hi;
			data[0x02b5] = (uint8_t) 0x60 + lo;
			data[0x42b4] = (uint8_t) 0x60 + hi;
			data[0x42b5] = (uint8_t) 0x60 + lo;
			data[0x82b4] = (uint8_t) 0x60 + hi;
			data[0x82b5] = (uint8_t) 0x60 + lo;
			data[0xc2b4] = (uint8_t) 0x60 + hi;
			data[0xc2b5] = (uint8_t) 0x60 + lo;
			printf("Writing %X%X\n", hi, lo);
			sprintf(out, "guntout_%03d.nes", hi * 16 + lo);
			fp = fopen(out, "w");
			fwrite(data, size, 1, fp);
			fclose(fp);
		}
	}
	return 0;
}

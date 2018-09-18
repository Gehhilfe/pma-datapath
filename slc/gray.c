#include <stdio.h>

sl_def(gray, ,sl_glparam(uint8_t*, img),sl_glparam(uint8_t*, res))
{
	sl_index(i);
	int *img = sl_getp(img);
	int *res = sl_getp(res);
	uint16_t r = img[i*3];
	uint16_t g = img[i*3];
	uint16_t b = img[i*3];

	r = (r*19)>>6;
	g = (g*75)>>7;
	b = (b*3)>>5;

	uint16_t sum = r+g+b;

	if(sum > 255)
		sum = 255;

	res[i] = sum;
}
sl_enddef

int main(void) {
	uint8_t result[15*15];
	sl_create(,,0,15*15,1,0,,gray,
		sl_glarg(img*, cimage), sl_glarg(int*, cresult));

	sl_seta(cimage, image);
	sl_seta(cres, result);

	sl_sync();

	for(int x = 0; x < 15; x++) {
		for(int y = 0; y < 15; y++) {
			printf("%d ", res[x+y*15]);
		}
		printf("/n");
	}
}
/*	Program to test speed improvement going from Matlab to C for 
	phase correlation in frequency domain for image registration

	by Kenneth Laws
	Here technologies
	11/28/2017

*/

#include <stdio.h>
#include <stdint.h>
#include <cblas.h>




/* cast bytes into 32 bit integer, lowest order byte first */
uint32_t int32cast(unsigned char *bp, int n)
{
	uint32_t val=0;

	val |= *(bp+n++) ;
	val |= *(bp+n++) << 8;
	val |= *(bp+n++) << 16 ;
	val |= *(bp+n) << 24 ;
	return val;
}

/* cast bytes into 16 bit integer, lowest order byte first */
uint16_t int16cast(unsigned char *bp, int n)
{
	uint16_t val=0;
	val |= *(bp+n++) ;
	val |= *(bp+n++) << 8;
	return val;
}








FILE *fp;

// typedef struct {
//     char        sigB;
//     char        sigM;
//     int32_t     fileSize;
//     int16_t     resv1;
//     int16_t     resv2;
//     int32_t     pixelOffset;
// } headerInfo;


unsigned char basicHeader[14];
unsigned char infoHeader[40];
uint32_t fileSize=0;
uint32_t imageWidth=0,imageHeight=0,imageOffset=0,compression=0,imageSize=0,fz;
uint16_t ncolors=0,pixDepth=0;


int main(void){


	fp = fopen("./sample_image/Image__2017-11-28__10-16-16.bmp", "rb");
	if (fp == NULL) {
	     perror("Error opening file: ");
	     return 1;
	}

	// read in the basic information header (14 bytes)
	// The file size starts at element 2 and is stored from low byte to high byte
	// the offset to beginning of image data is stored in bytes 10 - 13
	fread( basicHeader, 1, sizeof(basicHeader), fp );

	fileSize = int32cast(basicHeader,2);
	imageOffset = int32cast(basicHeader,10);

	printf("%c%c ",basicHeader[0],basicHeader[1]);
	printf("file size: %i \n",fileSize);
	printf("image offset: %i \n",imageOffset);

	// read in the image information header
	fread( infoHeader, 1, sizeof(infoHeader), fp );

	imageWidth = int32cast(infoHeader,4);
	imageHeight = int32cast(infoHeader,8);
	ncolors = int16cast(infoHeader,12);
	pixDepth = int16cast(infoHeader,14);
	compression = int32cast(infoHeader,16);
	imageSize = int32cast(infoHeader,20);

	printf("info header size: %d \n",infoHeader[0]);
	printf("image width: %d \n",imageWidth);
	printf("image height: %i \n",imageHeight);
	printf("number of colors: %i \n",ncolors);
	printf("pixel depth: %i bytes\n",pixDepth);
	printf("compression: %i \n",compression);
	printf("image size: %i \n",imageSize);

	fclose(fp);
	return 0;	


}
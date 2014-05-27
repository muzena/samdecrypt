// DRMDecrypt_w32.cpp : Definiert den Einstiegspunkt für die Konsolenanwendung.
//

//#defines to switch on large file support
//http://publib.boulder.ibm.com/infocenter/aix/v7r1/index.jsp?topic=%2Fcom.ibm.aix.genprogc%2Fdoc%2Fgenprogc%2Fprg_lrg_files.htm
//off_t now 64bits, fopen will be redefined as fopen64, fseeko as fseeko64, ftello as ftello64 etc

//#define _LARGEFILE_SOURCE
//#define _LARGEFILE64_SOURCE
//#define _FILE_OFFSET_BITS 64

//windows stuff
#ifndef __MSVCRT__
#define __MSVCRT__
#endif

#ifndef _LARGEFILE64_H
#define _LARGEFILE64_H
#endif

#ifndef _LARGEFILE64_SOURCE
#define _LARGEFILE64_SOURCE 1
#endif

void aes_decrypt_128(unsigned char *plainText, unsigned char *cipherText, unsigned char *key);

//http://lists.mplayerhq.hu/pipermail/mplayer-dev-eng/2007-January/048904.html
//#define fseeko _fseeki64
//#define ftello _ftelli64

#include <stdio.h>
#include <string.h>
#include <errno.h>

//#include <dirent.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
//#include <sys/param.h>
//#include <sys/mman.h>
//#include <fcntl.h>

//typedef __int64 off64_t;
typedef off_t off64_t;
unsigned char	drm_key[0x10];
#define TS_FRAME_SIZE 188

//sync byte							8		0x47
//Transport Error Indicator (TEI)	1		Set by demodulator if can't correct errors in the stream, to tell the demultiplexer that the packet has an uncorrectable error [11]
//Payload Unit Start Indicator		1		1 means start of PES data or PSI otherwise zero only.
//Transport Priority				1		1 means higher priority than other packets with the same PID.
//PID								13		Packet ID
//Scrambling control				2		'00' = Not scrambled.   The following per DVB spec:[12]   
//											'01' = Reserved for future use,   
//											'10' = Scrambled with even key,   
//											'11' = Scrambled with odd key
//Adaptation field exist			2		01 = no adaptation fields, payload only
//											10 = adaptation field only
//											11 = adaptation field and payload
//Continuity counter				4		Incremented only when a payload is present (i.e., adaptation field exist is 01 or 11)[13]
//Note: the total number of bits above is 32 and is called the transport stream 4-byte prefix or Transport Stream Header.

unsigned char process_section (unsigned char *data , unsigned char *outdata, const off64_t dec_count) {
	
	unsigned char iv[0x10];
	unsigned char *inbuf;
	unsigned int i, n;
	unsigned char *outbuf;
	int rounds;
	int offset = 4;	
	int skipAF = 1;

	memcpy(outdata, data, TS_FRAME_SIZE);

	if((data[3]&0xC0)==0xC0)
	{
		//printf ("Odd Key...\n");
	}
	else if((data[3]&0xC0)==0x80)
	{
		//printf ("EvenKey...\n");
	}
    else if((data[3] & 0xC0) == 0x40)
    {
        //printf ("samsung encrypted adaption field...\n");
        skipAF = 0;
    }
	else
	{
		return 0;
	}
    if((data[3] & 0x20) && skipAF)
        offset += data[4] + 1 ;      // skip adaption field
    outdata[3] &= 0x3f;       	

	if(offset > TS_FRAME_SIZE)//application will crash withotu this check when file is corrupted
	{
		printf ("\nInvalid data @ %llu\n", dec_count);
		offset = TS_FRAME_SIZE;
	}
	inbuf  = data + offset;
	outbuf = outdata + offset;
		
	rounds = (TS_FRAME_SIZE - offset) / 0x10;
	// AES CBC / ECB
	//     // CBC used at 2011 models
	//         // ECB used at 2010 models
	memset(iv, 0, 16);

	for (i =  0; i <rounds; i++) {
		unsigned char *out = outbuf + i* 0x10;

		//for(n = 0; n < 16; n++) out[n] ^= iv[n];
		aes_decrypt_128(inbuf + i* 0x10, outbuf + i * 0x10, drm_key);
		//memcpy(iv, inbuf + i * 0x10, 16);
	}
	return 1;		
}

int main( int argc, char *argv[] )
{
	FILE *inputfp,*outputfp;
	int sync_find=0, j;
//FIX - type off_t is switched 32/64 bits by lfs-specific #defines
	off64_t filesize = 0, i, dec_count = 0;
	int print_count = 0;
//	struct _stati64 filestat;
//FIX
	unsigned char buf[1024];
	unsigned char outdata[1024];
	char split_file_name[1024];
	int split_file_count = 0;
	char outfile[256];



	printf("===============================================================================\n");
	printf("    SamyGO - Samsung LED TV PVR Recording Decrypt		  \n");

	switch (argc) {
	case 2:
		if((inputfp = fopen(argv[1], "rb")) == NULL){
			printf("Cannot open %s file\n", argv[1]);
			return 0;
		}

		// try .mdb
		sprintf(outfile,"%s",argv[1]);
		sprintf(&outfile[strlen(outfile)-3],"mdb");
		if((outputfp = fopen(outfile, "rb"))){
			fseek(outputfp, 8, SEEK_SET);
			for (j = 0; j<0x10; j++) 
				// read each byte separately because of different byte order
				fread(&drm_key[(j&0xc)+(3-(j&3))], sizeof(unsigned char), 1, outputfp);
			fclose(outputfp);
		} else {
			sprintf(outfile,"%s",argv[1]);
			sprintf(&outfile[strlen(outfile)-3],"key");
			if((outputfp = fopen(outfile, "rb"))){
				fread(drm_key, sizeof(unsigned char), 0x10, outputfp);
				fclose(outputfp);
			} else {
				printf("Cannot open %s key file\n", outfile);
				return 0;
			}
		}

		sprintf(outfile,"%s",argv[1]);
		sprintf(&outfile[strlen(outfile)-3],"ts");

		if((outputfp = fopen(outfile, "wb")) == NULL){
			printf("Cannot open %s file for write\n",outfile );
			return 0;
		}

		break;
	case 3:
		if((inputfp = fopen(argv[2], "rb")) == NULL){
			printf("Cannot open %s file\n", argv[2]);
			return 0;
		}
		fread(drm_key, sizeof(unsigned char), 0x10, inputfp);
		fclose(inputfp);
		
		if((inputfp = fopen(argv[1], "rb")) == NULL){
			printf("Cannot open %s file\n", argv[1]);
			return 0;
		}
		sprintf(outfile,"%s",argv[1]);
		sprintf(&outfile[strlen(outfile)-3],"ts");
		if((outputfp = fopen(outfile, "wb")) == NULL){
			printf("Cannot open %s file for write\n",outfile );
			return 0;
		}
		break;
	case 4:
		if((inputfp = fopen(argv[3], "rb")) == NULL){
			printf("Cannot open argv[3] key file\n");
			return 0;
		}
		if(strcmp((char *)&argv[3][strlen(argv[3])-3],"key")!=0) {
			printf("3rd parameter is keyfile, %s must end in '.key'\n", argv[3]);
			return 0;
		}
		fread(drm_key, sizeof(unsigned char), 0x10, inputfp);
		fclose(inputfp);
		
		
		if((inputfp = fopen(argv[1], "rb")) == NULL){
			printf("Cannot open %s file\n", argv[1]);
			return 0;
		}
		if((outputfp = fopen(argv[2], "wb")) == NULL){
			printf("Cannot open %s file for write\n", argv[2]);
			return 0;
		}
		break;
	default:
		
		printf("===============================================================================\n");
		printf("    1. Execute SamyGO\n");
		printf("    2. Enable DRM with SamyGO DRM Switcher\n");
		printf("    3. Start Playing your Recorded content on TV\n");
		printf("    4. Obtain DRM Key from TV using drmget & copy .srf and .key file to PC\n");
		printf("    4. Run in command line:\n");
		printf("    decrypt inputfile.srf outputfile.ts drm.key\n");
		printf("-or-\n");
		printf("    decrypt inputfile.srf drm.key (prog creates inputfile.ts)\n");
		printf("-or-\n");
		printf("    decrypt inputfile.srf prog will use inputfile.mdb and inputfile.ts\n");
		printf("-or-\n");
		printf("                                               inputfile.key and inputfile.ts\n");
		printf("===============================================================================\n");
		printf("Repeat process from Step 3 for all encrypted recordings\n");
		printf("ignore steps 2-4 if you have inputfile.mdb ;)\n");
		return 0;	
	}

//FIX (change not needed now - original code ok if u include all lfs #defines
//	if(_stati64(argv[1],&filestat) < 0) {printf("Cannot obtain file size\n");return;}
//	filesize = filestat.st_size;
//FIX

	fseeko(inputfp,0,2); 
	filesize=ftello (inputfp); 
	rewind(inputfp);

//	printf("sizeof(off_t) %d\n", sizeof(off64_t));

//	printf("%13lld bytes to decrypt\n", filesize);
//http://archives.seul.org/or/cvs/Feb-2007/msg00220.html
	printf("%llu bytes to decrypt\n", filesize);

	fread(buf, sizeof(unsigned char), 1024, inputfp);

	for(i=0; i<(1024 - TS_FRAME_SIZE); i++){
		if (buf[i] == 0x47 && buf[i+TS_FRAME_SIZE] == 0x47 && buf[i+TS_FRAME_SIZE+TS_FRAME_SIZE] == 0x47){
			sync_find = 1;
			fseeko(inputfp,i,SEEK_SET); 
			break;
		}
	}
	if (sync_find) {
		for(i=0;i<filesize;i+=TS_FRAME_SIZE) {
			fread(buf, sizeof(unsigned char), TS_FRAME_SIZE, inputfp);
			if (buf[0] != 0x47)  {
				printf("lost synk %llx\n", i);
				fseeko(inputfp,i,SEEK_SET); 
				sync_find = 0;
				while (sync_find == 0) {
					if(fread(buf, sizeof(unsigned char), 1024, inputfp) < 1024)
					{//prevent infinite loop at end of file
						break;
					}
					for(j=0; j<(1024 - TS_FRAME_SIZE); j++){
						if (buf[j] == 0x47 && buf[j+TS_FRAME_SIZE] == 0x47 && buf[j+TS_FRAME_SIZE+TS_FRAME_SIZE] == 0x47){
							sync_find = 1;
							fseeko(inputfp,i+j,SEEK_SET); 
							break;
						}
					}
					i+=1024;
				}
			}else{
				dec_count += TS_FRAME_SIZE;
				if (--print_count < 0){	//print every iteration takes a lot of time
					print_count +=5000;
					printf("\r%llu/%llu - %lld%%", dec_count,filesize,dec_count*100/filesize);
					fflush(stdout);
				}
				process_section (buf , outdata, dec_count);
				fwrite(outdata,sizeof(unsigned char), TS_FRAME_SIZE, outputfp);
			}
		}
		printf("\r%llu - 100%%", dec_count);
	}

	fclose(inputfp);
	fclose(outputfp);
//	printf("\ndrmdecrypt success: %I64u bytes decrypted from original %I64u!\n", dec_count, filesize);
	printf(" decrypted OK!\n");


	return 1;
}


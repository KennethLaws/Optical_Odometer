/*
   ImageRecord.c
   By: Kenneth Laws
       Bassler 
       Here Technologies
   Date: 12/6/2017
   

   Record images from camera at maximum frame rate over a fixed time interval.

   grab and process images asynchronously, i.e.,
   while the application is processing a buffer, the acquistion of the next buffer is done
   in parallel.
   The sample uses a pool of buffers that are passed to a stream grabber to be filled with
   image data. Once a buffer is filled and ready for processing, the buffer is retrieved from
   the stream grabber, processed, and passed back to the stream grabber to be filled again.
   Buffers retrieved from the stream grabber are not overwritten as long as
   they are not passed back to the stream grabber.
*/


#include <stdlib.h>
#include <stdio.h>
#include <malloc.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <pylonc/PylonC.h>

#define CHECK( errc ) if ( GENAPI_E_OK != errc ) printErrorAndExit( errc )

/* This function can be used to wait for user input at the end of the sample program. */
void pressEnterToExit(void);

/* This method demonstrates how to retrieve the error message for the last failed function call. */
void printErrorAndExit( GENAPIC_RESULT errc );

/* Calculating the minimum and maximum gray value */
void getMinMax( const unsigned char* pImg, int32_t width, int32_t height,
               unsigned char* pMin, unsigned char* pMax);

//#define NUM_GRABS 40000         /* Number of images to grab. */
#define NUM_BUFFERS 5         /* Number of buffers used for grabbing. */
// #define recordTime 10          // record time interval (sec)

int main(int argc, char *argv[])
{
    GENAPIC_RESULT              res;                      /* Return value of pylon methods. */
    size_t                      numDevices;               /* Number of available devices. */
    PYLON_DEVICE_HANDLE         hDev;                     /* Handle for the pylon device. */
    PYLON_STREAMGRABBER_HANDLE  hGrabber;                 /* Handle for the pylon stream grabber. */
    PYLON_WAITOBJECT_HANDLE     hWait;                    /* Handle used for waiting for a grab to be finished. */
    int32_t                     payloadSize;              /* Size of an image frame in bytes. */
    unsigned char              *buffers[NUM_BUFFERS];     /* Buffers used for grabbing. */
    PYLON_STREAMBUFFER_HANDLE   bufHandles[NUM_BUFFERS];  /* Handles for the buffers. */
    PylonGrabResult_t           grabResult;               /* Stores the result of a grab operation. */
    int                         nImg;                   /* Counts the number of buffers grabbed. */
    size_t                      nStreams;                 /* The number of streams the device provides. */
    _Bool                       isAvail;                  /* Used for checking feature availability. */
    _Bool                       isReady;                  /* Used as an output parameter. */
    size_t                      i;                        /* Counter. */
    int                         recordTime=0;

    if(argc == 1){
        printf("usage: grabframes <nSeconds>\n");
        printf("include number of seconds to collect images (nSeconds)\n");
        exit(0);
    }
    recordTime = atoi(argv[1]);

    /* Before using any pylon methods, the pylon runtime must be initialized. */
    PylonInitialize();

    /* Enumerate all camera devices. You must call
    PylonEnumerateDevices() before creating a device. */
    res = PylonEnumerateDevices( &numDevices );
    CHECK(res);
    if ( 0 == numDevices )
    {
        fprintf( stderr, "No devices found.\n" );
        PylonTerminate();
        pressEnterToExit();
        exit(EXIT_FAILURE);
    }

    /* Get a handle for the first device found.  */
    res = PylonCreateDeviceByIndex( 0, &hDev );
    CHECK(res);

    /* Before using the device, it must be opened. Open it for configuring
    parameters and for grabbing images. */
    res = PylonDeviceOpen( hDev, PYLONC_ACCESS_MODE_CONTROL | PYLONC_ACCESS_MODE_STREAM );
    CHECK(res);

    /* Print out the name of the camera we are using. */
    {
        char buf[256];
        size_t siz = sizeof(buf);
        _Bool isReadable;

        isReadable = PylonDeviceFeatureIsReadable( hDev, "DeviceModelName");
        if ( isReadable )
        {
            res = PylonDeviceFeatureToString( hDev, "DeviceModelName", buf, &siz );
            CHECK(res);
            printf("Using camera %s\n", buf);
        }
    }

    /* Set the pixel format to Mono8 if available, where gray values will be output as 8 bit values for each pixel. */
    isAvail = PylonDeviceFeatureIsAvailable(hDev, "EnumEntry_PixelFormat_Mono8");
    if (isAvail)
    {
        res = PylonDeviceFeatureFromString( hDev, "PixelFormat", "Mono8" );
        CHECK(res);
    }

    /* Disable acquisition start trigger if available. */
    isAvail = PylonDeviceFeatureIsAvailable( hDev, "EnumEntry_TriggerSelector_AcquisitionStart");
    if (isAvail)
    {
        res = PylonDeviceFeatureFromString( hDev, "TriggerSelector", "AcquisitionStart");
        CHECK(res);
        res = PylonDeviceFeatureFromString( hDev, "TriggerMode", "Off");
        CHECK(res);
    }

    /* Disable frame burst start trigger if available. */
    isAvail = PylonDeviceFeatureIsAvailable( hDev, "EnumEntry_TriggerSelector_FrameBurstStart");
    if (isAvail)
    {
        res = PylonDeviceFeatureFromString( hDev, "TriggerSelector", "FrameBurstStart");
        CHECK(res);
        res = PylonDeviceFeatureFromString( hDev, "TriggerMode", "Off");
        CHECK(res);
    }

    /* Disable frame start trigger if available. */
    isAvail = PylonDeviceFeatureIsAvailable( hDev, "EnumEntry_TriggerSelector_FrameStart");
    if (isAvail)
    {
        res = PylonDeviceFeatureFromString( hDev, "TriggerSelector", "FrameStart");
        CHECK(res);
        res = PylonDeviceFeatureFromString( hDev, "TriggerMode", "Off");
        CHECK(res);
    }

    /* We will use the Continuous frame acquisition mode, i.e., the camera delivers
    images continuously. */
    res = PylonDeviceFeatureFromString( hDev, "AcquisitionMode", "Continuous" );
    CHECK(res);


    /* For GigE cameras, we recommend increasing the packet size for better
       performance. When the network adapter supports jumbo frames, set the packet
       size to a value > 1500, e.g., to 8192. In this sample, we only set the packet size
       to 1500. */
    /* ... Check first to see if the GigE camera packet size parameter is supported and if it is writable. */
    isAvail = PylonDeviceFeatureIsWritable(hDev, "GevSCPSPacketSize");
    if ( isAvail )
    {
        /* ... The device supports the packet size feature, set a value. */
        res = PylonDeviceSetIntegerFeature( hDev, "GevSCPSPacketSize", 1500 );
        CHECK(res);
    }


    /* Image grabbing is done using a stream grabber.
      A device may be able to provide different streams. A separate stream grabber must
      be used for each stream. In this sample, we create a stream grabber for the default
      stream, i.e., the first stream ( index == 0 ).
      */

    /* Get the number of streams supported by the device and the transport layer. */
    res = PylonDeviceGetNumStreamGrabberChannels( hDev, &nStreams );
    CHECK(res);
    if ( nStreams < 1 )
    {
        fprintf( stderr, "The transport layer doesn't support image streams\n");
        PylonTerminate();
        pressEnterToExit();
        exit(EXIT_FAILURE);
    }

    /* Create and open a stream grabber for the first channel. */
    res = PylonDeviceGetStreamGrabber( hDev, 0, &hGrabber );
    CHECK(res);
    res = PylonStreamGrabberOpen( hGrabber );
    CHECK(res);

    /* Get a handle for the stream grabber's wait object. The wait object
       allows waiting for buffers to be filled with grabbed data. */
    res = PylonStreamGrabberGetWaitObject( hGrabber, &hWait );
    CHECK(res);

    /* Determine the required size of the grab buffer. */
    if ( PylonDeviceFeatureIsReadable(hDev, "PayloadSize") )
    {
        res = PylonDeviceGetIntegerFeatureInt32( hDev, "PayloadSize", &payloadSize );
        CHECK(res);
    }
    else
    {
        /* Note: Some camera devices, e.g Camera Link or BCON, don't have a payload size node.
                 In this case we'll look in the stream grabber node map for the PayloadSize node
                 The stream grabber, this can be a frame grabber, needs to be open to compute the
                 required payload size.
        */
        NODEMAP_HANDLE hStreamNodeMap;
        NODE_HANDLE hNode;
        int64_t i64payloadSize;

        res = PylonStreamGrabberGetNodeMap(hGrabber, &hStreamNodeMap);
        CHECK(res);
        res = GenApiNodeMapGetNode( hStreamNodeMap, "PayloadSize", &hNode );
        CHECK(res);
        if ( GENAPIC_INVALID_HANDLE == hNode )
        {
            fprintf( stderr, "There is no PayloadSize parameter.\n");
            PylonTerminate();
            pressEnterToExit();
            return EXIT_FAILURE;
        }
        res = GenApiIntegerGetValue(hNode, &i64payloadSize);
        CHECK(res);
        payloadSize = (int32_t) i64payloadSize;
    }

    /* Allocate memory for grabbing.  */
    for ( i = 0; i < NUM_BUFFERS; ++i )
    {
        buffers[i] = (unsigned char*) malloc ( payloadSize );
        if ( NULL == buffers[i] )
        {
            fprintf( stderr, "Out of memory!\n" );
            PylonTerminate();
            pressEnterToExit();
            exit(EXIT_FAILURE);
        }
    }

    /* We must tell the stream grabber the number and size of the buffers
        we are using. */
    /* .. We will not use more than NUM_BUFFERS for grabbing. */
    res = PylonStreamGrabberSetMaxNumBuffer( hGrabber, NUM_BUFFERS );
    CHECK(res);
    /* .. We will not use buffers bigger than payloadSize bytes. */
    res = PylonStreamGrabberSetMaxBufferSize( hGrabber, payloadSize );
    CHECK(res);


    /*  Allocate the resources required for grabbing. After this, critical parameters
        that impact the payload size must not be changed until FinishGrab() is called. */
    res = PylonStreamGrabberPrepareGrab( hGrabber );
    CHECK(res);


    /* Before using the buffers for grabbing, they must be registered at
       the stream grabber. For each registered buffer, a buffer handle
       is returned. After registering, these handles are used instead of the
       raw pointers. */
    for ( i = 0; i < NUM_BUFFERS; ++i )
    {
        res = PylonStreamGrabberRegisterBuffer( hGrabber, buffers[i], payloadSize,  &bufHandles[i] );
        CHECK(res);
    }



    /* Feed the buffers into the stream grabber's input queue. For each buffer, the API
       allows passing in a pointer to additional context information. This pointer
       will be returned unchanged when the grab is finished. In our example, we use the index of the
       buffer as context information. */
    for ( i = 0; i < NUM_BUFFERS; ++i )
    {
        res = PylonStreamGrabberQueueBuffer( hGrabber, bufHandles[i], (void*) i );
        CHECK(res);
    }

    /* Now the stream grabber is prepared. As soon as the camera starts to acquire images,
       the image data will be grabbed into the buffers provided.  */

    /* Let the camera acquire images. */
    res = PylonDeviceExecuteCommandFeature( hDev, "AcquisitionStart");
    CHECK(res);

    FILE *fp;
    #define LEN 24
    #define DIRLEN 48
    char fName[LEN];
    char dirName[DIRLEN];
    char fullName[DIRLEN+LEN];
    char timeTag[15];
    time_t now;
    struct tm * time_info;
    struct timeval start, end, check;
    long secs_used,micros_used;
    double elTime;
    double time_in_mill;
    double time_in_sec;
    int remain,lock;
    struct stat st = {0};

    /* Grab NUM_GRABS images */
    nImg = 0;                         /* Counts the number of images grabbed since in current second*/

    printf("Starting timed recording for %d seconds\n", recordTime);
    printf("capturing images from camera at maximum frame rate...\n");
    gettimeofday(&start, NULL);
    check = start;
    remain = start.tv_sec - check.tv_sec + recordTime;
    lock = 0;
    printf("\ttime remaining: %d\r",remain);
    fflush( stdout );
    while ( remain > 0 )
    {
        size_t bufferIndex;              /* Index of the buffer */
        unsigned char min, max;

        gettimeofday(&check, NULL);         // check the time elapsed since start
        remain = start.tv_sec - check.tv_sec + recordTime;

        // print the progress - this does not work, looks like buffer is not being sent to screen
        // printf("remain: %d   lock: %d\n",remain,lock);
        if(remain % 5 == 0 && remain != lock){
            printf("\ttime remaining: %d sec     \r",remain);
            lock = remain;
            fflush( stdout );
        }


        // generate a new folder name for each second
        fName[0] = 0;
        dirName[0] = 0;
        time(&now);
        time_info = localtime(&now);
        strftime(dirName, DIRLEN, "/media/kip/960Pro/images/%Y%m%d%H%M%S", time_info);
        //printf("checking folder: %s \n",dirName);
        if (stat(dirName, &st) == -1) {
            //printf("creating folder\n");
            mkdir(dirName, 0700);
        }else{
            //printf("folder exists\n");
        }

        // build the file name with path
        //printf("dirName: %s\n",dirName);

        // when image data has arrived from the camera give it a time tag in ms
        gettimeofday(&check, NULL);
        time_in_mill = check.tv_usec/1E3;
        time_in_sec = check.tv_sec;
        sprintf(timeTag,"%0.0f",time_in_sec*1000 + time_in_mill);
        // printf("time in ms: %f\n",time_in_sec*1000);
        //printf("time in ms: %s\n",timeTag);

        //sprintf(fName,"");
        //printf("fName: %s \n",fName);
        sprintf(fullName,"%s/%s.bin",dirName,timeTag);
        //printf("path+file: %s\n",fullName);

        // open the image output file
        fp = fopen (fullName,"wb");
        if (fp!=NULL)
        {
        
            /* Wait for the next buffer to be filled. Wait up to 1000 ms. */
            res = PylonWaitObjectWait( hWait, 1000, &isReady );
            CHECK(res);
            if ( ! isReady )
            {
                /* Timeout occurred. */
                fprintf(stderr, "Grab timeout occurred\n");
                break; /* Stop grabbing. */
            }

            /* Since the wait operation was successful, the result of at least one grab
               operation is available. Retrieve it. */

            res = PylonStreamGrabberRetrieveResult( hGrabber, &grabResult, &isReady );
            CHECK(res);
            if ( ! isReady )
            {
                /* Oops. No grab result available? We should never have reached this point.
                   Since the wait operation above returned without a timeout, a grab result
                   should be available. */
                fprintf(stderr, "Failed to retrieve a grab result\n");
                break;
            }


            /* Get the buffer index from the context information. */
            bufferIndex = (size_t) grabResult.Context;

            /* Check to see if the image was grabbed successfully. */
            if ( grabResult.Status == Grabbed ){
                /*  Success. Perform image processing. Since we passed more than one buffer
                to the stream grabber, the remaining buffers are filled while
                we do the image processing. The processed buffer won't be touched by
                the stream grabber until we pass it back to the stream grabber. */

                unsigned char* buffer;        /* Pointer to the buffer attached to the grab result. */

                /* Get the buffer pointer from the result structure. Since we also got the buffer index,
                   we could alternatively use buffers[bufferIndex]. */
                buffer = (unsigned char*) grabResult.pBuffer;

                // printf("size = %i\n",grabResult.SizeX*grabResult.SizeY);
                // printf("size = %lu\n",grabResult.PayloadSize);
                
                /* Perform processing. */
                // getMinMax( buffer, grabResult.SizeX, grabResult.SizeY, &min, &max );
                // printf("Grabbed frame %2d into buffer %2d. Min. gray value = %3u, Max. gray value = %3u\n",
                    // nImg, (int) bufferIndex, min, max);

                // write out the buffer to disk
                fwrite(buffer, 1, grabResult.PayloadSize, fp);


    #ifdef GENAPIC_WIN_BUILD
                /* Display image */
                res = PylonImageWindowDisplayImageGrabResult(0, &grabResult);
                CHECK(res);
    #endif

            }
            else if ( grabResult.Status == Failed )
            {
                fprintf( stderr,  "Frame %d wasn't grabbed successfully.  Error code = 0x%08X\n",
                    nImg, grabResult.ErrorCode );
            }

            /* Once finished with the processing, requeue the buffer to be filled again. */
            res = PylonStreamGrabberQueueBuffer( hGrabber, grabResult.hBuffer, (void*) bufferIndex );
            CHECK(res);
            fclose (fp);
        }
        else{
            printf("Failed to open output file\n");
        }
        // increment step number
        nImg++;
    }

    gettimeofday(&end, NULL);
    secs_used=(end.tv_sec - start.tv_sec); //avoid overflow by subtracting first
    elTime = secs_used + (double)(end.tv_usec - start.tv_usec)/1E6;

    // printf("grabbed %d frames\n",nframe);
    // printf("Total time taken by CPU: %f\n", (float) total_t  );
    printf("\ttime remaining: %d\r",remain);
    printf("\n");
    printf("Recording completed\n");
    printf("Captured %d images over %f seconds\n",nImg,elTime);
    printf("frame rate: %f fps\n",nImg/elTime);
    printf("\n");

    /* Clean up. */

    /*  ... Stop the camera. */
    res = PylonDeviceExecuteCommandFeature( hDev, "AcquisitionStop");
    CHECK(res);

    /* ... We must issue a cancel call to ensure that all pending buffers are put into the
       stream grabber's output queue. */
    res = PylonStreamGrabberCancelGrab( hGrabber );
    CHECK(res);

    /* ... The buffers can now be retrieved from the stream grabber. */
    do
    {
        res = PylonStreamGrabberRetrieveResult( hGrabber, &grabResult, &isReady );
        CHECK(res);
    } while ( isReady );

    /* ... When all buffers have been retrieved from the stream grabber, they can be deregistered.
           After that, it is safe to free the memory. */

    for ( i = 0; i < NUM_BUFFERS; ++i )
    {
        res = PylonStreamGrabberDeregisterBuffer( hGrabber, bufHandles[i] );
        CHECK(res);
        free( buffers[i] );
    }

    /* ... Release grabbing related resources. */
    res = PylonStreamGrabberFinishGrab( hGrabber );
    CHECK(res);

    /* After calling PylonStreamGrabberFinishGrab(), parameters that impact the payload size (e.g.,
    the AOI width and height parameters) are unlocked and can be modified again. */

    /* ... Close the stream grabber. */
    res = PylonStreamGrabberClose( hGrabber );
    CHECK(res);


    /* ... Close and release the pylon device. The stream grabber becomes invalid
       after closing the pylon device. Don't call stream grabber related methods after
       closing or releasing the device. */
    res = PylonDeviceClose( hDev );
    CHECK(res);

    /* ...The device is no longer used, destroy it. */
    res = PylonDestroyDevice ( hDev );
    CHECK(res);

    //pressEnterToExit();

    /* ... Shut down the pylon runtime system. Don't call any pylon method after
       calling PylonTerminate(). */
    PylonTerminate();


    return EXIT_SUCCESS;
}

/* This function demonstrates how to retrieve the error message for the last failed
   function call. */
void printErrorAndExit( GENAPIC_RESULT errc )
{
    char *errMsg;
    size_t length;

    /* Retrieve the error message.
    ... First find out how big the buffer must be, */
    GenApiGetLastErrorMessage( NULL, &length );
    errMsg = (char*) malloc( length );
    /* ... and retrieve the message. */
    GenApiGetLastErrorMessage( errMsg, &length );

    fprintf( stderr, "%s (%#08x).\n", errMsg, (unsigned int) errc);
    free( errMsg);

    /* Retrieve more details about the error.
    ... First find out how big the buffer must be, */
    GenApiGetLastErrorDetail( NULL, &length );
    errMsg = (char*) malloc( length );
    /* ... and retrieve the message. */
    GenApiGetLastErrorDetail( errMsg, &length );

    fprintf( stderr, "%s\n", errMsg);
    free( errMsg);

    PylonTerminate();  /* Releases all pylon resources */
    pressEnterToExit();

    exit(EXIT_FAILURE);
}



/* Simple "image processing" function returning the minimum and maximum gray
   value of an 8 bit gray value image. */
void getMinMax( const unsigned char* pImg, int32_t width, int32_t height,
               unsigned char* pMin, unsigned char* pMax)
{
    unsigned char min = 255;
    unsigned char max = 0;
    unsigned char val;
    const unsigned char *p;

    for ( p = pImg; p < pImg + width * height; p++ )
    {
        val = *p;
        if ( val > max )
           max = val;
        if ( val < min )
           min = val;
    }
    *pMin = min;
    *pMax = max;
}

/* This function can be used to wait for user input at the end of the sample program. */
void pressEnterToExit(void)
{
    fprintf( stderr, "\nPress enter to exit.\n");
    while( getchar() != '\n');
}


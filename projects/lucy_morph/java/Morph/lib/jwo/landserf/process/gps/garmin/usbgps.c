// This file contains sample code to help application developers
// interface with Garmin USB units. This should not be viewed as a
// full implementation of PC to unit communication. It does not include
// error checking and other elements of a full implementation.
// Also, there are notes in the code suggesting other elements that
// might be necessary.

#include <stdio.h>
#include <tchar.h>

#include <jni.h>
#include "jwo_landserf_process_gps_garmin_GarminUSB.h"

#include <windows.h>
#include <initguid.h>
#include <setupapi.h> // You may need to explicitly link with setupapi.lib
#include <winioctl.h>

DEFINE_GUID(GUID_DEVINTERFACE_GRMNUSB, 0x2c9c45c2L, 0x8e7d, 0x4c08, 0xa1, 0x2d, 0x81, 0x6b, 0xba, 0xe7, 0x22, 0xc0);

#define IOCTL_ASYNC_IN        CTL_CODE (FILE_DEVICE_UNKNOWN, 0x850, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_USB_PACKET_SIZE CTL_CODE (FILE_DEVICE_UNKNOWN, 0x851, METHOD_BUFFERED, FILE_ANY_ACCESS)

#define MAX_BUFFER_SIZE 4096
#define ASYNC_DATA_SIZE 64

//-----------------------------------------------------------------------------
HANDLE gHandle;
DWORD gUSBPacketSize;

//-----------------------------------------------------------------------------
#pragma pack(push, 1)
typedef struct
{
    unsigned char  mPacketType;
    unsigned char  mReserved1;
    unsigned short mReserved2;
    unsigned short mPacketId;
    unsigned short mReserved3;
    unsigned long  mDataSize;
    BYTE           mData[1];
} Packet_t;
#pragma pack(pop)

//-----------------------------------------------------------------------------
void SendPacket(Packet_t aPacket)
{
	DWORD theBytesToWrite = sizeof(aPacket)-1+aPacket.mDataSize;
	DWORD theBytesReturned = 0;

	WriteFile(gHandle, &aPacket, theBytesToWrite, &theBytesReturned, NULL);

	// If the packet size was an exact multiple of the USB packet
	// size, we must make a final write call with no data
	if (theBytesToWrite%gUSBPacketSize==0)
    {
		WriteFile(gHandle, 0, 0, &theBytesReturned, NULL);
    }
}

//-----------------------------------------------------------------------------
// Gets a single packet. Since packets may come simultaneously through
// asynchrous reads and normal (ReadFile) reads, a full implementation
// may require a packet queue and multiple threads.
Packet_t* GetPacket()
{
	Packet_t* thePacket = 0;
	DWORD theBufferSize = 0;
	BYTE* theBuffer = 0;


	for( ; ; )
    {
		// Read async data until the driver returns less than the
		// max async data size, which signifies the end of a packet
		BYTE theTempBuffer[ASYNC_DATA_SIZE];
		BYTE* theNewBuffer = 0;
		DWORD theBytesReturned = 0;

		DeviceIoControl(gHandle, IOCTL_ASYNC_IN, 0, 0, theTempBuffer, sizeof(theTempBuffer), &theBytesReturned, NULL);


		theBufferSize += ASYNC_DATA_SIZE;
		theNewBuffer = (BYTE*)malloc(theBufferSize);
		memcpy(theNewBuffer, theBuffer, theBufferSize - ASYNC_DATA_SIZE);
		memcpy(theNewBuffer + theBufferSize - ASYNC_DATA_SIZE, theTempBuffer, ASYNC_DATA_SIZE);

		free(theBuffer);
		theBuffer = theNewBuffer;

		if (theBytesReturned != ASYNC_DATA_SIZE)
        {
			thePacket = (Packet_t*)theBuffer;
			break;
        }

    }

	// If this was a small "signal" packet, read a real
	// packet using ReadFile
	if ((thePacket->mPacketType==0) && (thePacket->mPacketId==2))
    {
		BYTE* theNewBuffer = (BYTE*) malloc(MAX_BUFFER_SIZE);
		DWORD theBytesReturned = 0;
		free(thePacket);

		// A full implementation would keep reading (and queueing)
		// packets until the driver returns a 0 size buffer.
		ReadFile(gHandle, theNewBuffer, MAX_BUFFER_SIZE, &theBytesReturned, NULL);
	printf("Bytes returned: %i\n",theBytesReturned);

		return (Packet_t*) theNewBuffer;
	}
	else
    {
		return thePacket;
    }
}

//-----------------------------------------------------------------------------
void Initialize()
{
	// Make all the necessary Windows calls to get a handle
	// to our USB device
	DWORD theBytesReturned = 0;

	PSP_INTERFACE_DEVICE_DETAIL_DATA theDevDetailData = 0;
	SP_DEVINFO_DATA theDevInfoData = { sizeof(SP_DEVINFO_DATA) };

	Packet_t theStartSessionPacket = { 0, 0, 0, 5, 0 , 0 };
	Packet_t* thePacket = 0;

	HDEVINFO theDevInfo = SetupDiGetClassDevs((GUID*)&GUID_DEVINTERFACE_GRMNUSB, NULL, NULL, DIGCF_PRESENT|DIGCF_INTERFACEDEVICE);
	SP_DEVICE_INTERFACE_DATA theInterfaceData;
	theInterfaceData.cbSize = sizeof(theInterfaceData);

	if ((!SetupDiEnumDeviceInterfaces(theDevInfo, NULL, (GUID*)&GUID_DEVINTERFACE_GRMNUSB, 0, &theInterfaceData)) &&
        (GetLastError() == ERROR_NO_MORE_ITEMS))
    {
		gHandle = 0;
		return;
    }

	SetupDiGetDeviceInterfaceDetail(theDevInfo, &theInterfaceData, NULL, 0, &theBytesReturned, NULL);

	theDevDetailData = (PSP_INTERFACE_DEVICE_DETAIL_DATA) malloc(theBytesReturned);
	theDevDetailData->cbSize = sizeof(SP_INTERFACE_DEVICE_DETAIL_DATA);

	SetupDiGetDeviceInterfaceDetail(theDevInfo, &theInterfaceData, theDevDetailData, theBytesReturned, NULL, &theDevInfoData);
	gHandle = CreateFile(theDevDetailData->DevicePath, GENERIC_READ|GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	free(theDevDetailData);

	// Get the USB packet size, which we need for sending packets
	DeviceIoControl(gHandle, IOCTL_USB_PACKET_SIZE, 0, 0, &gUSBPacketSize, sizeof(gUSBPacketSize), &theBytesReturned, NULL);

	// Tell the device that we are starting a session.
	SendPacket(theStartSessionPacket);

	// Wait until the device is ready to the start the session
	for( ; ; )
    {
		thePacket = GetPacket();

		if ((thePacket->mPacketType==0) && (thePacket->mPacketId == 6))
        {
			break;
        }

		free(thePacket);
    }

	free(thePacket);
}

//-----------------------------------------------------------------------------
int _tmain(int argc, _TCHAR* argv[])
{
	Packet_t theProductDataPacket = { 20, 0, 0, 254, 0 , 0 };
	Packet_t* thePacket = 0;

	Initialize();

	if (gHandle==0)
    {
		printf( "%s", "No device" );
		return 0;
    }

	// Tell the device to send product data
	SendPacket(theProductDataPacket);

	// Get the product data packet
	for( ; ; )
    {
		thePacket = GetPacket();

		if ((thePacket->mPacketType==20) && (thePacket->mPacketId==255))
        {
			break;
        }

		free(thePacket);
    }

	// Print out the product description
	printf( "%s", (char*)&thePacket->mData[4]);
	free(thePacket);
	return 0;
}


// -------------------------- Java entries to the C functions ---------------

/* Sets up a GPS connection. Will report status of connection after
 * attempting to connect.
 */
JNIEXPORT jint JNICALL Java_jwo_landserf_process_gps_garmin_GarminUSB_initGPS (JNIEnv *env, jobject obj)
{
	Initialize();

	if (gHandle==0)
	{
		//printf( "%s", "No GPS device found.");
		return -1;
    }
    else
    {
		//printf("%s", "GPS device found.");
		return 0;
	}
}

/* Attempts to retrieve GPS info from device found during initialisation.
 * Returns a string containing GPS info or error message.
 */
JNIEXPORT jstring JNICALL Java_jwo_landserf_process_gps_garmin_GarminUSB_getGPSInfo (JNIEnv * env, jobject obj)
{

	char message[1024];
	Packet_t theProductDataPacket = { 20, 0, 0, 254, 0 , 0 };
	Packet_t* thePacket = 0;


	if (gHandle != 0)
	{
		// Tell the device to send product data
		SendPacket(theProductDataPacket);

		// Get the product data packet
		for( ; ; )
	    {
			thePacket = GetPacket();

			if ((thePacket->mPacketType==20) && (thePacket->mPacketId==255))
	        {
				break;
	        }

			free(thePacket);
	    }

		// Return the product description
		sprintf_s(message,1024, "%s",(char*)&thePacket->mData[4]);
		free(thePacket);

	}
	else
	{
		sprintf_s(message,1024,"%s","Cannot report info since no GPS device found.");
	}


	return (*env)->NewStringUTF(env, message);

}


/* Sends the given packet to the GPS device.
 */
JNIEXPORT jint JNICALL Java_jwo_landserf_process_gps_garmin_GarminUSB_sendPacket (JNIEnv * env, jobject obj, jbyte type , jshort id, jbyteArray jbytes)
{

	char message[1024];
	jsize dataSize;
	DWORD theBytesToWrite,theBytesReturned;
	Packet_t packet;
	int i;
	BYTE *dataPos;


	jbyte *packetData;
	packetData = (*env)->GetByteArrayElements(env, jbytes, NULL);

	if (packetData == NULL)
	{
	    return -1;
	}

	dataSize = (*env)->GetArrayLength(env,jbytes);

	// Create the packet.
    packet.mPacketType = type;
    packet.mReserved1  = 0;
    packet.mReserved2  = 0;
	packet.mPacketId   = id;
	packet.mReserved3  = 0;
	packet.mDataSize   = dataSize;

	dataPos = &(packet.mData);

	for (i=0; i<dataSize; i++)
	{
		*(dataPos+i) = packetData[i];
	}


	SendPacket(packet);

	return 0;

}

/* Retrieves a packet from the GPS device or NULL if no packet to retrieve.
 * jPacketInfo should be an array of two integers. This method will place the packet
 * type in the first element, and the packet ID in the second.
 * This method will return the packet data as a separate byte array.
 */
JNIEXPORT jbyteArray JNICALL Java_jwo_landserf_process_gps_garmin_GarminUSB_getPacket (JNIEnv * env, jobject obj, jintArray jPacketInfo)
{
	jint *cPacketInfo;
	Packet_t* thePacket = 0;

	jbyteArray jArray;
	char *jBytes;
	int i;


	if (gHandle != 0)
	{
	    thePacket = GetPacket();

		// Transfer the two items of metadata needed by Java.
		cPacketInfo = (*env)->GetIntArrayElements(env, jPacketInfo, NULL);
		if (cPacketInfo != NULL)
		{
			//printf("Packet Type (Native): %i  Packet ID (Native): %i\n",receivedPacket->mPacketType,receivedPacket->mPacketId);
			cPacketInfo[0] = thePacket->mPacketType;
			cPacketInfo[1] = thePacket->mPacketId;

		    (*env)->ReleaseIntArrayElements(env, jPacketInfo, cPacketInfo, 0);
		}


		// Pass the data array back to Java.

		jArray = (*env)->NewByteArray(env,thePacket->mDataSize);
		jBytes = (*env)->GetByteArrayElements(env,jArray, NULL);

		for(i=0; i<thePacket->mDataSize; i++)
		{
			jBytes[i] = thePacket->mData[i];
		}
		(*env)->ReleaseByteArrayElements(env, jArray, jBytes, 0);

		free(thePacket);

		return jArray;

	}
	else
	{
		return NULL;
	}
}
//
//  NSData+Formatter.m
//  Joyple
//
//  Created by Professional on 2014. 6. 17..
//  Copyright (c) 2014년 Joycity. All rights reserved.
//

#import "NSData+Formatter.h"

@implementation NSData (Formatter)

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)stringByBase64Encoding
{ // From: http://stackoverflow.com/a/4727124/143378
    const unsigned char * objRawData = self.bytes;
    char * objPointer;
    char * strResult;
    
    // Get the Raw Data length and ensure we actually have data
    NSInteger intLength = self.length;
    if (intLength == 0) return nil;
    
    // Setup the String-based Result placeholder and pointer within that placeholder
    strResult = (char *)calloc((((intLength + 2) / 3) * 4) + 1, sizeof(char));
    objPointer = strResult;
    
    // Iterate through everything
    while (intLength > 2) { // keep going until we have less than 24 bits
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
        *objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
        *objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
        
        // we just handled 3 octets (24 bits) of data
        objRawData += 3;
        intLength -= 3;
    }
    
    // now deal with the tail end of things
    if (intLength != 0) {
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        if (intLength > 1) {
            *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
            *objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
            *objPointer++ = '=';
        } else {
            *objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
            *objPointer++ = '=';
            *objPointer++ = '=';
        }
    }
    
    // Terminate the string-based result
    *objPointer = '\0';
    
    // Create result NSString object
    NSString *base64String = @(strResult);
    
    // Free memory
    free(strResult);
    
    return base64String;
}

- (NSString *)dataXORWithData:(NSString *)key
{
    NSMutableData *result = self.mutableCopy;
    
    // Get pointer to data to obfuscate
    char *dataPtr = (char *)result.mutableBytes;
    
    // Get pointer to key data
    char *keyData = (char *)[[key dataUsingEncoding:NSUTF8StringEncoding] bytes];
    
    // Points to each char in sequence in the key
    char *keyPtr = keyData;
    int keyIndex = 0;
    
    // For each character in data, xor with current value in key
    for (int x = 0; x < self.length; x++)
    {
        // Replace current character in data with
        // current character xor'd with current key value.
        // Bump each pointer to the next character
        *dataPtr = *dataPtr ^ *keyPtr;
        dataPtr++;
        keyPtr++;
        
        // If at end of key data, reset count and
        // set key pointer back to start of key value

        if (++keyIndex == [key length])
		{
            keyIndex = 0;
			keyPtr = keyData;
		}
	}
    
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}
@end

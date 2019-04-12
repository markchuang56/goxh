//
//  RocheSetInfo.m
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/8/23.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#import "H2Config.h"
#import "h2BrandModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "H2BleService.h"
//#import "OneTouchPlusFlex.h"

#import "LSOneTouchUltraMini.h"
#import "H2BleTimer.h"
#import "H2BleCentralManager.h"
#import "H2Records.h"
#import "H2LastDateTime.h"
#import "H2DebugHeader.h"

#import "RocheSetInfo.h"

@interface RocheSetInfo()
{
    UInt8 guideFlowSel;
    UInt8 guideCmdBuffer[32];
    UInt8 guideCmdLen;
}

@end


@implementation RocheSetInfo

- (id)init
{
    if (self = [super init]) {
        _guideElseServiceID = [CBUUID UUIDWithString:GUIDE_ELSE_SERVICE_UUID];
        
        _guideCharacteristicA0_UUID = [CBUUID UUIDWithString:GUIDE_ELSE_CHAR0_UUID];
        _guideCharacteristicA1_UUID = [CBUUID UUIDWithString:GUIDE_ELSE_CHAR1_UUID];
        
        _guideElseFlexService = nil;
        
        _guideCharacteristicWrite = nil;
        
        guideFlowSel = 0;
        guideCmdLen = 0;
    }
    return self;
}



UInt8 guideInit[] = {
    0x01, 0x01, 0x83, 0x01,  0x00, 0x01, 0x00, 0x06,
    0x00, 0x03, 0x00, 0x02,  0x00, 0x03, 0x6C, 0x41
};

unsigned char guideCmdSecond[] =
{
    0x01, 0x0F, 0x83, 0x02 ,  0x00, 0x01, 0x01, 0x04,
    0x00, 0x11, 0x01, 0x00 ,  0x98, 0x06, 0x16, 0x44,
    0x2F, 0x50, 0xF2, 0x2F ,
    
    0x02, 0x0F, 0xE0, 0x43 , 0x45, 0xD3, 0xE8, 0x08 ,
    0x26, 0x4A, 0x4A, 0xF6 , 0x12, 0x15, 0xA5, 0xE1 ,
    0x7E, 0xFD, 0x99, 0xA9 ,
    
    0x03, 0x0F, 0x0A, 0xA0 , 0xE3, 0xE5, 0x8F, 0x71 ,
    0x28, 0xB1, 0xA4, 0x7C , 0xA0, 0x90, 0xA1, 0x6A ,
    0x40, 0x0B, 0xAF, 0x7F ,
    
    0x04, 0x0F, 0xF8, 0x80 , 0x13, 0x4E, 0x15, 0x98 ,
    0xA4, 0x22, 0x36, 0x28 , 0x66, 0x6E, 0x27, 0xA5 ,
    0x1D, 0x9D, 0x0D, 0xF7 ,
    
    0x05, 0x0F, 0xB0, 0x0E , 0x4D, 0xA8, 0xB9, 0x71 ,
    0x30, 0xD8, 0xDD, 0x96 , 0x29, 0xA8, 0x6D, 0xC6 ,
    0xCB, 0x25, 0xCC, 0x9B ,
    
    0x06, 0x0F, 0x0F, 0x30 , 0xB0, 0x4E, 0x34, 0x67 ,
    0x7B, 0x71, 0x70, 0x8D , 0x37, 0xA6, 0xDB, 0x40 ,
    0xBC, 0x7D, 0x29, 0x00 ,
    
    0x07, 0x0F, 0x5F, 0xA2 , 0xF4, 0xF6, 0x68, 0x20 ,
    0x7E, 0x81, 0x5F, 0x4A , 0xB9, 0x9A, 0xC0, 0xDC ,
    0x7D, 0xF4, 0xD2, 0x86 ,
    
    0x08, 0x0F, 0x17, 0xC8 , 0x08, 0xFC, 0x25, 0x1F ,
    0x48, 0xFE, 0x63, 0x9E , 0x07, 0xAA, 0x07, 0x85 ,
    0x2C, 0x67, 0x22, 0xA2 ,
    
    0x09, 0x0F, 0x8B, 0x3C , 0x02, 0xDF, 0x77, 0x1F ,
    0x28, 0x8A, 0xD5, 0xF8 , 0xBF, 0x37, 0x6E, 0x2B ,
    0xFE, 0xA2, 0x55, 0x08 ,
    
    0x0A, 0x0F, 0x42, 0xD4 , 0x89, 0x2A, 0x33, 0x10 ,
    0x29, 0x17, 0xF0, 0xD9 , 0xC2, 0xD5, 0xA2, 0x90 ,
    0x43, 0xA5, 0x28, 0x28 ,
    
    0x0B, 0x0F, 0xC9, 0xB1 , 0xFF, 0xDB, 0x6F, 0xE5 ,
    0xB3, 0x29, 0xDA, 0xE9 , 0x40, 0x51, 0x46, 0x0B ,
    0x23, 0x4B, 0xF4, 0x60 ,
    
    0x0C, 0x0F, 0x34, 0x6A , 0xAE, 0x22, 0xA7, 0xA4 ,
    0x30, 0x83, 0xDD, 0x85 , 0x4C, 0xB3, 0xD8, 0xB6 ,
    0x33, 0x1F, 0xF8, 0x49 ,
    
    0x0D, 0x0F, 0x01, 0x20 , 0x8F, 0x76, 0x04, 0x27 ,
    0x5F, 0x20, 0x47, 0x35 , 0x44, 0x5E, 0x13, 0x58 ,
    0x8F, 0x4F, 0x32, 0x30 ,
    
    0x0E, 0x0F, 0xE9, 0x14 , 0x3A, 0x22, 0x69, 0xC9 ,
    0x32, 0x72, 0x8F, 0xA0 , 0xC0, 0x3F, 0x9E, 0x06 ,
    0xA2, 0xC1, 0xEA, 0x54 //,
};

unsigned char guideCmd_F[] =
{
    0x0F, 0x0F, 0x05, 0x63 , 0x72, 0x04, 0xB4, 0xF5 ,
    0x8F, 0xAB, 0x92, 0x32 , 0xC4, 0x7B, 0xF2, 0x34 ,
    0xE4, 0x17
    
};

unsigned char guideCmdGetCT[] =
{
      0x01, 0x01, 0x88, 0x8F , 0x00, 0x01, 0x00, 0x06
    , 0x00, 0x01, 0x00, 0x02 , 0x00, 0x00, 0x1E, 0x96
};

unsigned char guideCmdGetCTX[] =
{
      0x01, 0x01, 0x53, 0x33 , 0x00, 0x01, 0x00, 0x06
    , 0x00, 0x01, 0x00, 0x02 , 0x00, 0x00, 0x9C, 0xC7
};

unsigned char guideCmdSetCTA[] =
{
      0x01, 0x02, 0x88,0x92 , 0x00, 0x04, 0x00, 0x0C
    , 0x0c, 0x17, 0x00, 0x08, 0x20, 0x15 , 0x03, 0x08
    , 0x12, 0x13, 0x12, 0x00
};

unsigned char guideCmdSetCTB[] =
{
      0x02, 0x02
    , 0xE8, 0x43
};

unsigned char guideCmdSetCTX[] =
{
    
};

unsigned char configCmdBuffer[20] = {0};

unsigned char configX[] = {
    //  0xf0, 0x00,
    //0x01, 0x1a ,
    /*
     0x01, 0x16, 0x00, 0x02
     , 0x01, 0x06, 0x01, 0x10 , 0x00, 0x00, 0xf0, 0x02
     ,
     0x01, 0x0a,
     */
    0x83, 0x02 , 0x00, 0x01, 0x01, 0x04
    , 0x00, 0x11, 0x01, 0x00 , 0x19, 0x79, 0x9d, 0xcc
    , 0x70, 0x86, 0x44, 0x3c , 0xc7, 0x92, 0x2b, 0x01
    , 0x0a, 0xd3, 0xd6, 0x69 , 0x63, 0xa5, 0x94, 0xad
    , 0x19, 0xbe, 0x3e, 0x14 , 0x2e, 0x27, 0x30, 0x82
    , 0xbf, 0x26, 0xba, 0x2b , 0x75, 0xd3, 0x28, 0x44
    , 0xb7, 0x8f, 0x49, 0x32 , 0xe4, 0xce, 0x80, 0x67
    , 0x10, 0x9a, 0xe1, 0x6c , 0xb2, 0xd7, 0x3a, 0x44
    , 0x44, 0xea, 0xb7, 0x1e , 0xed, 0x28, 0xc7, 0x36
    , 0xc0, 0xa6, 0x71, 0xbd , 0x1c, 0x5c, 0x28, 0xe4
    , 0xb7, 0xa9, 0x94, 0x27 , 0xbe, 0x2b, 0xbf, 0xdc
    , 0xd7, 0xdc, 0xdb, 0xa9 , 0xe2, 0x1d, 0xcd, 0xe6
    , 0x3b, 0x91, 0xd9, 0x8a , 0x1b, 0xdf, 0x83, 0xa4
    , 0x60, 0xb8, 0x4b, 0x29 , 0x38, 0xc9, 0xe7, 0xef
    , 0xc4, 0xd7, 0xf7, 0x7b , 0x66, 0xdf, 0xe1, 0x7d
    , 0x08, 0x2d, 0xdd, 0x7d , 0xf7, 0x1f, 0xfe, 0xbb
    , 0x67, 0x1e, 0x70, 0x2d , 0x5f, 0x0b, 0x53, 0xd0
    , 0x85, 0x88, 0x2c, 0x6e , 0xaf, 0xf2, 0x5d, 0x6a
    , 0x73, 0x7b, 0x6d, 0xf1 , 0x41, 0x2b, 0x1e, 0x87
    , 0xe5, 0x5c, 0x0d, 0xb0 , 0x6e, 0x53, 0x68, 0x8a
    , 0xe3, 0x32, 0xc1, 0x88 , 0xbc, 0xa0, 0x4a, 0x29
    , 0xaf, 0x43, 0xb6, 0x93 , 0xbf, 0x8e, 0xf6, 0xbc
    , 0x15, 0x4b, 0xf1, 0x86 , 0x9e, 0x82, 0x77, 0x9f
    , 0x22, 0xd6, 0x78, 0xb2 , 0xf3, 0xbf, 0xc2, 0xad
    , 0xae, 0x69, 0x70, 0xb8 , 0xf7, 0x83, 0x91, 0x1d
    , 0xbd, 0x21, 0xa6, 0xd4 , 0xf1, 0xdb, 0x8c, 0x97
    , 0xb0, 0x5e, 0x92, 0xa3 , 0x14, 0x6c, 0x5b, 0xe5
    , 0x13, 0x23, 0x0b, 0xe6 , 0x73, 0x0d, 0x0d, 0x97
    , 0x51, 0xb9, 0x80, 0x95 , 0x50, 0x93, 0x79, 0xda
    , 0x4a, 0xbf, 0xd9, 0x06 , 0x65, 0xa6, 0x46, 0x10
    , 0x23, 0x26, 0xc8, 0x44 , 0xba, 0x76, 0x05, 0xc4
    , 0xe2, 0x29, 0x63, 0xcb , 0x7a, 0xe0, 0x59, 0x11
    , 0xb4, 0xde, 0xee, 0x96 , 0x67, 0x74, 0x50, 0xd8
    , 0xa9, 0xba, 0xe8, 0x30 //, 0xf3, 0xd0
    , 0x0F, 0x67
};


#pragma mark - ========= GUIDE ==========
- (void)guideValueUpdate:(CBCharacteristic *)characteristic
{
#ifdef DEBUG_ONETOUCH
    NSLog(@"ROCHE VALUE UPDATE ....");
#endif
    if (![characteristic.UUID isEqual:_guideCharacteristicA0_UUID]) {
        //NSLog(@"GUIDE Others !!");
        return;
    }
    Byte *guideTmpBuffer = (Byte *)malloc(20);
    memcpy(guideTmpBuffer, [characteristic.value bytes], characteristic.value.length);
#ifdef DEBUG_ONETOUCH
    NSLog(@"ROCHE VALUE UPDATE .... ELSE BACK");
#endif
    if([H2BleService sharedInstance].blePairingStage){
        if(guideTmpBuffer[0] == 0x03 && guideTmpBuffer[1] == 0x03){
            //[[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
            [self guideCommandFlow];
        }
        
        if (guideFlowSel == ROCHE_CMD_FLOW_MAX) {
        //if(guideTmpBuffer[0] == 0x0F && guideTmpBuffer[1] == 0x0F){
            [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
            //[self guideCommandFlow];
        }
        return;
    }
}

- (void)rocheCmdInit
{
    guideFlowSel = 0;
    guideCmdLen = 0;
    [self guideCommandFlow];
#if 0
    NSData *dataToWrite = [[NSData alloc]init];
    guideCmdLen = sizeof(guideInit);
    memcpy(guideCmdBuffer, guideInit, guideCmdLen);
    
    //if(guideSend){
        dataToWrite = [NSData dataWithBytes:guideCmdBuffer length:guideCmdLen];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_guideCharacteristicWrite type:CBCharacteristicWriteWithResponse];
#ifdef DEBUG_ONETOUCH
        NSLog(@"GUIDE CT CMD = %@", dataToWrite);
#endif
    //}
    
    guideFlowSel++;
#ifdef DEBUG_ONETOUCH
    if(guideFlowSel < ROCHE_CMD_FLOW_MAX){
        NSLog(@"GUIDE NEXT CMD ...");
        //[NSTimer scheduledTimerWithTimeInterval:1.8f target:self selector:@selector(guideCommandFlow) userInfo:nil repeats:NO];
    }
#endif
#endif
}

- (void)guideCommandFlow
{
    BOOL guideSend = YES;
    NSData *dataToWrite = [[NSData alloc]init];
#ifdef DEBUG_ONETOUCH
    NSLog(@"GUIDE COMMAND ... %02X", guideFlowSel);
#endif
    switch (guideFlowSel) {
        case 0:
            guideCmdLen = sizeof(guideInit);
            memcpy(guideCmdBuffer, guideInit, guideCmdLen);
            break;
            
        case 1:case 2:case 3:case 4:
        case 5:case 6:case 7:case 8:
        case 9:case 0xA:case 0xB:
        case 0xC:case 0xD:case 0xE:
            guideCmdLen = 20;
#if 1
            memcpy(guideCmdBuffer, &guideCmdSecond[(guideFlowSel-1)*20], guideCmdLen);
#else
            memcpy(&guideCmdBuffer[2], &configX[(guideFlowSel-1)*18], 18);
#endif
            guideCmdBuffer[0] = guideFlowSel;
            guideCmdBuffer[1] = 0x0F;
            break;
            
        case 0xF:
            guideCmdLen = 18;
#if 1
            memcpy(guideCmdBuffer, guideCmd_F, guideCmdLen);
#else
            memcpy(&guideCmdBuffer[2], &configX[(guideFlowSel-1)*18], 16);
#endif
            guideCmdBuffer[0] = 0x0F;
            guideCmdBuffer[1] = 0x0F;
            break;
#if 1
        case 0x10: // GET CURRENT TIME
            guideCmdLen = sizeof(guideCmdGetCT);
            memcpy(guideCmdBuffer, guideCmdGetCT, guideCmdLen);
            break;
            
        case 0x11: // GET CT AFTER
            guideCmdLen = sizeof(guideCmdGetCTX);
            memcpy(guideCmdBuffer, guideCmdGetCTX, guideCmdLen);
            break;
#endif
        default:
            guideSend = NO;
            break;
    }
    
    if(guideSend){
        dataToWrite = [NSData dataWithBytes:guideCmdBuffer length:guideCmdLen];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_guideCharacteristicWrite type:CBCharacteristicWriteWithResponse];
#ifdef DEBUG_ONETOUCH
        NSLog(@"GUIDE CT CMD = %@", dataToWrite);
#endif
    }
    
    guideFlowSel++;
    if(guideFlowSel < ROCHE_CMD_FLOW_MAX){
#ifdef DEBUG_ONETOUCH
        NSLog(@"GUIDE NEXT CMD ...");
#endif
        [NSTimer scheduledTimerWithTimeInterval:0.6f target:self selector:@selector(guideCommandFlow) userInfo:nil repeats:NO];
    }
}


- (void)rocheMeterTimeParser:(CBCharacteristic *)characteristic
{
    
    //if (![characteristic.UUID isEqual:_guideCharacteristicA0_UUID]) {
    //return;
    //}
    
    Byte *timeBuffer = (Byte *)malloc(20);
    memcpy(timeBuffer, [characteristic.value bytes], characteristic.value.length);
    
    UInt16 rocheYear = 0;
    memcpy(&rocheYear, timeBuffer, 2);
    
    UInt8 rocheMonth = timeBuffer[2];
    UInt8 rocheDay = timeBuffer[3];
    
    UInt8 rocheHour = timeBuffer[4];
    UInt8 rocheMinute = timeBuffer[5];
    //UInt8 rocheSecond = timeBuffer[6];
    
#ifdef DEBUG_BW
    //DLog(@"254C == 年 : %d, 月 : %d, 日 : %d", rocheYear, rocheMonth, rocheDay);
    //DLog(@"254C == 時 : %d, 分 : %d, 秒 : %d", rocheHour, rocheMinute, rocheSecond);
#endif
    [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000", rocheYear, rocheMonth, rocheDay, rocheHour, rocheMinute];
}

/*
 - (void)guideWriteCurrentTime
 {
 
 
 NSData *dataToWrite = [[NSData alloc]init];
 
 dataToWrite = [NSData dataWithBytes:dataCmd length:sizeof(dataCmd)];
 
 [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_guideCharacteristicWrite type:CBCharacteristicWriteWithResponse];
 NSLog(@"GUIDE CT CMD = %@", dataToWrite);
 }
 */

+ (RocheSetInfo *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred = 0;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}


@end

/*
 * Copyright (c) 2015, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "BPMViewController.h"
//#import "ScannerViewController.h"
#import "Constants.h"
//#import "AppUtilities.h"
#import "CharacteristicReader.h"
//#import "HelpViewController.h"
#import "H2Records.h"

@interface BPMViewController () {
    CBUUID *bpmServiceUUID;
    CBUUID *bpmBloodPressureMeasurementCharacteristicUUID;
    CBUUID *bpmIntermediateCuffPressureCharacteristicUUID;
    CBUUID *batteryServiceUUID;
    CBUUID *batteryLevelCharacteristicUUID;
}

@end

@implementation BPMViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    //self = [super initWithCoder:aDecoder];
    self = [super init];
    if (self) {
        // Custom initialization
        bpmServiceUUID = [CBUUID UUIDWithString:bpmServiceUUIDString];
        bpmBloodPressureMeasurementCharacteristicUUID = [CBUUID UUIDWithString:bpmBloodPressureMeasurementCharacteristicUUIDString];
        bpmIntermediateCuffPressureCharacteristicUUID = [CBUUID UUIDWithString:bpmIntermediateCuffPressureCharacteristicUUIDString];
        batteryServiceUUID = [CBUUID UUIDWithString:batteryServiceUUIDString];
        batteryLevelCharacteristicUUID = [CBUUID UUIDWithString:batteryLevelCharacteristicUUIDString];
    }
    return self;
}

- (H2BpRecord *)BPMDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
{
#ifdef DEBUG_BP
    DLog(@"BLE BP - DECODE");
#endif
    H2BpRecord *recordTmp = [[H2BpRecord alloc] init];
    
    // Scanner uses other queue to send events. We must edit UI in the main queue
//jj    dispatch_async(dispatch_get_main_queue(), ^{
        // Decode the characteristic data
    NSData *data = characteristic.value;
    uint8_t *array = (uint8_t *) data.bytes;

    UInt8 flags = [CharacteristicReader readUInt8Value:&array];
    BOOL kPa = (flags & 0x01) > 0;
    BOOL timestampPresent = (flags & 0x02) > 0;
    BOOL pulseRatePresent = (flags & 0x04) > 0;
    BOOL StatusFlag = (flags & 0x10) > 0;
#ifdef DEBUG_BP
    DLog(@"DID COME TO BPM - PARSER ...");
#endif
            
            // Update units
    if (kPa)
    {
        _systolicUnit = BP_UNIT_KPA;
        _diastolicUnit = BP_UNIT_KPA;
        _meanApUnit = BP_UNIT_KPA;
    }else{
        _systolicUnit = BP_UNIT;
        _diastolicUnit = BP_UNIT;
        _meanApUnit = BP_UNIT;
    }
    
    UInt16 ua651Value = [CharacteristicReader readSFloatValueUA651Ble:&array];
    
    float systolicValue = [CharacteristicReader readSFloatValue:&array];
    float diastolicValue = [CharacteristicReader readSFloatValue:&array];
    float meanApValue = [CharacteristicReader readSFloatValue:&array];
    
    recordTmp.bpSystolic = [NSString stringWithFormat:@"%.2f", systolicValue];
    recordTmp.bpDiastolic = [NSString stringWithFormat:@"%.2f", diastolicValue];
        
    _systolic = [NSString stringWithFormat:@"%.1f", systolicValue];
    _diastolic = [NSString stringWithFormat:@"%.1f", diastolicValue];
    _meanAp = [NSString stringWithFormat:@"%.1f", meanApValue];
    
    // Read timestamp
    if (timestampPresent)
    {
        NSDate* date = [CharacteristicReader readDateTime:&array];
                
        if (date == nil) {
#ifdef DEBUG_BP
            DLog(@"BP DATE is NIL");
#endif
            recordTmp.bpDateTime = @"";
        }else{
                    //DLog(@"2. BP-DATE-TIME is %@", date);
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    //[dateFormat setDateFormat:@"dd.MM.yyyy, hh:mm"];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
            NSString* dateFormattedString = [dateFormat stringFromDate:date];

            _timestamp = dateFormattedString;
            recordTmp.bpDateTime = [NSString stringWithFormat:@"%@ +0000", [_timestamp substringWithRange:NSMakeRange(0, 19)]];
        }
                
    }else{
        _timestamp = @"n/a";
        recordTmp.bpDateTime = _timestamp;
    }
    
    if (ua651Value >= 0x7FF) {
        _timestamp = @"n/a";
        recordTmp.bpDateTime = _timestamp;
    }
            
            // Read pulse
    if (pulseRatePresent)
    {
        float pulseValue = [CharacteristicReader readSFloatValue:&array];
        recordTmp.bpHeartRate_pulmin = [NSString stringWithFormat:@"%.2f", pulseValue];
        _pulse = [NSString stringWithFormat:@"%.1f", pulseValue];
    }else{
        _pulse = @"-";
    }
#ifdef DEBUG_BP
    DLog(@"BPM SYS - %@ %@", _systolic, _systolicUnit);
    DLog(@"BPM DIA - %@ %@", _diastolic, _diastolicUnit);
    DLog(@"BPM MEAN - %@ %@", _meanAp, _meanApUnit);
#endif
    recordTmp.bpUnit = _systolicUnit;
            
            
            
#ifdef DEBUG_BP
    DLog(@"BPM TIME - %@ ", _timestamp);
    DLog(@"BPM PULSE - %@", _pulse);
            //
    DLog(@"H2BP TIME - %@ ", recordTmp.bpDateTime);
    DLog(@"H2BP UNIT - %@ ", recordTmp.bpUnit);

    DLog(@"H2BP SYS - %@ ", recordTmp.bpSystolic);
    DLog(@"H2BP DIA - %@", recordTmp.bpDiastolic);
    DLog(@"H2BP PULSE - %@ ", recordTmp.bpHeartRate_pulmin);
#endif
    if (StatusFlag) {
        UInt16 measureStatus = [CharacteristicReader readSFloatValueApex:&array];
#ifdef DEBUG_BP
        NSLog(@"VALUE = %04X", measureStatus);
#endif
        if ((measureStatus & 0x04) > 0) {
            recordTmp.bpIsArrhythmia = YES;
#ifdef DEBUG_BP
            NSLog(@"心房𤉿");
#endif
        }
    }
    
    recordTmp.recordType = RECORD_TYPE_BP;
        
    return recordTmp;
}

+ (BPMViewController *)sharedBpInstance
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

#if 0
/*!
 * This property is set when the device successfully connects to the peripheral. It is used to cancel the connection
 * after user press Disconnect button.
 */
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;

@property (weak, nonatomic) IBOutlet UILabel *systolic;
@property (weak, nonatomic) IBOutlet UILabel *systolicUnit;
@property (weak, nonatomic) IBOutlet UILabel *diastolic;
@property (weak, nonatomic) IBOutlet UILabel *diastolicUnit;
@property (weak, nonatomic) IBOutlet UILabel *meanAp;
@property (weak, nonatomic) IBOutlet UILabel *meanApUnit;
@property (weak, nonatomic) IBOutlet UILabel *pulse;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;

@end

@implementation BPMViewController
@synthesize bluetoothManager;
@synthesize backgroundImage;
@synthesize verticalLabel;
@synthesize battery;
@synthesize deviceName;
@synthesize connectButton;
@synthesize connectedPeripheral;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        bpmServiceUUID = [CBUUID UUIDWithString:bpmServiceUUIDString];
        bpmBloodPressureMeasurementCharacteristicUUID = [CBUUID UUIDWithString:bpmBloodPressureMeasurementCharacteristicUUIDString];
        bpmIntermediateCuffPressureCharacteristicUUID = [CBUUID UUIDWithString:bpmIntermediateCuffPressureCharacteristicUUIDString];
        batteryServiceUUID = [CBUUID UUIDWithString:batteryServiceUUIDString];
        batteryLevelCharacteristicUUID = [CBUUID UUIDWithString:batteryLevelCharacteristicUUIDString];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (is4InchesIPhone)
    {
        // 4 inches iPhone
        UIImage *image = [UIImage imageNamed:@"Background4.png"];
        [backgroundImage setImage:image];
    }
    else
    {
        // 3.5 inches iPhone
        UIImage *image = [UIImage imageNamed:@"Background35.png"];
        [backgroundImage setImage:image];
    }
    
    // Rotate the vertical label
    self.verticalLabel.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(-150.0f, 0.0f), (float)(-M_PI / 2));
}

-(void)appDidEnterBackground:(NSNotification *)_notification
{
    [AppUtilities showBackgroundNotification:[NSString stringWithFormat:@"You are still connected to %@ peripheral. It will collect data also in background.",connectedPeripheral.name]];
}

-(void)appDidBecomeActiveBackground:(NSNotification *)_notification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (IBAction)connectOrDisconnectClicked {
    if (connectedPeripheral != nil)
    {
        [bluetoothManager cancelPeripheralConnection:connectedPeripheral];
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // The 'scan' seque will be performed only if connectedPeripheral == nil (if we are not connected already).
    return ![identifier isEqualToString:@"scan"] || connectedPeripheral == nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"scan"])
    {
        // Set this contoller as scanner delegate
        ScannerViewController *controller = (ScannerViewController *)segue.destinationViewController;
        controller.filterUUID = bpmServiceUUID;
        controller.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"help"]) {
        HelpViewController *helpVC = [segue destinationViewController];
        helpVC.helpText = [AppUtilities getBPMHelpText];
    }
}

#pragma mark Scanner Delegate methods

-(void)centralManager:(CBCentralManager *)manager didPeripheralSelected:(CBPeripheral *)peripheral
{
    // Some devices disconnects just after finishing measurement so we have to clear the UI before new connection, not after previous.
    [self clearUI];
    
    // We may not use more than one Central Manager instance. Let's just take the one returned from Scanner View Controller
    bluetoothManager = manager;
    bluetoothManager.delegate = self;
    
    // The sensor has been selected, connect to it
    peripheral.delegate = self;
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnNotificationKey];
    [bluetoothManager connectPeripheral:peripheral options:options];
}

#pragma mark Central Manager delegate methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        // TODO
    }
    else
    {
        // TODO
        DLog(@"Bluetooth not ON");
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [deviceName setText:peripheral.name];
        [connectButton setTitle:@"DISCONNECT" forState:UIControlStateNormal];
    });
    //Following if condition display user permission alert for background notification
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActiveBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // Peripheral has connected. Discover required services
    connectedPeripheral = peripheral;
    [peripheral discoverServices:@[bpmServiceUUID, batteryServiceUUID]];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppUtilities showAlert:@"Error" alertMessage:@"Connecting to the peripheral failed. Try again"];
        [connectButton setTitle:@"CONNECT" forState:UIControlStateNormal];
        connectedPeripheral = nil;
        
        [self clearUI];
    });
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [connectButton setTitle:@"CONNECT" forState:UIControlStateNormal];
        if ([AppUtilities isApplicationStateInactiveORBackground]) {
            [AppUtilities showBackgroundNotification:[NSString stringWithFormat:@"%@ peripheral is disconnected",peripheral.name]];
        }
        connectedPeripheral = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    });
}

- (void) clearUI
{
    [deviceName setText:@"DEFAULT BPM"];
    battery.tag = 0;
    [battery setTitle:@"n/a" forState:UIControlStateDisabled];
    
    self.systolicUnit.hidden = YES;
    self.diastolicUnit.hidden = YES;
    self.meanApUnit.hidden = YES;
    
    self.systolic.text = @"-";
    self.diastolic.text = @"-";
    self.meanAp.text = @"-";
    self.pulse.text = @"-";
    self.timestamp.text = @"n/a";
}

#pragma mark Peripheral delegate methods

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        DLog(@"Error discovering service: %@", [error localizedDescription]);
        [bluetoothManager cancelPeripheralConnection:connectedPeripheral];
        return;
    }
    
    for (CBService *service in peripheral.services)
    {
        // Discovers the characteristics for a given service
        if ([service.UUID isEqual:bpmServiceUUID])
        {
            [connectedPeripheral discoverCharacteristics:@[bpmBloodPressureMeasurementCharacteristicUUID, bpmIntermediateCuffPressureCharacteristicUUID] forService:service];
        }
        else if ([service.UUID isEqual:batteryServiceUUID])
        {
            [connectedPeripheral discoverCharacteristics:@[batteryLevelCharacteristicUUID] forService:service];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Characteristics for one of those services has been found
    if ([service.UUID isEqual:bpmServiceUUID])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            if ([characteristic.UUID isEqual:bpmBloodPressureMeasurementCharacteristicUUID] ||
                [characteristic.UUID isEqual:bpmIntermediateCuffPressureCharacteristicUUID])
            {
                // Enable notifications and indications on data characteristics
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    } else if ([service.UUID isEqual:batteryServiceUUID])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            if ([characteristic.UUID isEqual:batteryLevelCharacteristicUUID])
            {
                // Read the current battery value
                [peripheral readValueForCharacteristic:characteristic];
                break;
            }
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        // Decode the characteristic data
        NSData *data = characteristic.value;
        uint8_t *array = (uint8_t*) data.bytes;
        
        if ([characteristic.UUID isEqual:batteryLevelCharacteristicUUID])
        {
            UInt8 batteryLevel = [CharacteristicReader readUInt8Value:&array];
            NSString* text = [[NSString alloc] initWithFormat:@"%d%%", batteryLevel];
            [battery setTitle:text forState:UIControlStateDisabled];
            
            if (battery.tag == 0)
            {
                // If battery level notifications are available, enable them
                if (([characteristic properties] & CBCharacteristicPropertyNotify) > 0)
                {
                    battery.tag = 1; // mark that we have enabled notifications
                    
                    // Enable notification on data characteristic
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
        else if ([characteristic.UUID isEqual:bpmBloodPressureMeasurementCharacteristicUUID] ||
                 [characteristic.UUID isEqual:bpmIntermediateCuffPressureCharacteristicUUID])
        {
            UInt8 flags = [CharacteristicReader readUInt8Value:&array];
            BOOL kPa = (flags & 0x01) > 0;
            BOOL timestampPresent = (flags & 0x02) > 0;
            BOOL pulseRatePresent = (flags & 0x04) > 0;
            
            // Update units
            if (kPa)
            {
                self.systolicUnit.text = BP_UNIT_KPA;
                self.diastolicUnit.text = BP_UNIT_KPA;
                self.meanApUnit.text = BP_UNIT_KPA;
            }
            else
            {
                self.systolicUnit.text = BP_UNIT;
                self.diastolicUnit.text = BP_UNIT;
                self.meanApUnit.text = BP_UNIT;
            }
            
            // Read main values
            if ([characteristic.UUID isEqual:bpmBloodPressureMeasurementCharacteristicUUID])
            {
                float systolicValue = [CharacteristicReader readSFloatValue:&array];
                float diastolicValue = [CharacteristicReader readSFloatValue:&array];
                float meanApValue = [CharacteristicReader readSFloatValue:&array];
                
                self.systolic.text = [NSString stringWithFormat:@"%.1f", systolicValue];
                self.diastolic.text = [NSString stringWithFormat:@"%.1f", diastolicValue];
                self.meanAp.text = [NSString stringWithFormat:@"%.1f", meanApValue];
                
                self.systolicUnit.hidden = NO;
                self.diastolicUnit.hidden = NO;
                self.meanApUnit.hidden = NO;
            }
            else
            {
                float systolicValue = [CharacteristicReader readSFloatValue:&array];
                array += 4;
                
                self.systolic.text = [NSString stringWithFormat:@"%.1f", systolicValue];
                self.diastolic.text = @"n/a";
                self.meanAp.text = @"n/a";
                
                self.systolicUnit.hidden = NO;
                self.diastolicUnit.hidden = YES;
                self.meanApUnit.hidden = YES;
            }
            
            // Read timestamp
            if (timestampPresent)
            {
                NSDate* date = [CharacteristicReader readDateTime:&array];
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"dd.MM.yyyy, hh:mm"];
                NSString* dateFormattedString = [dateFormat stringFromDate:date];
                
                self.timestamp.text = dateFormattedString;
            }
            else
            {
                self.timestamp.text = @"n/a";
            }
            
            // Read pulse
            if (pulseRatePresent)
            {
                float pulseValue = [CharacteristicReader readSFloatValue:&array];
                self.pulse.text = [NSString stringWithFormat:@"%.1f", pulseValue];
            }
            else
            {
                self.pulse.text = @"-";
            }
        }
    });
}

@end
#endif

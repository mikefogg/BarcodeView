#import "ComMfoggBarcodeView.h"
#import "ComMfoggBarcodeViewProxy.h"
#import <AVFoundation/AVFoundation.h>

@implementation ComMfoggBarcodeView

@synthesize barcodes;
@synthesize minQuality;
@synthesize flashEnabled;
@synthesize scanCropPreview;
@synthesize scanCrop;
@synthesize barcodeDict;
@synthesize barcodeStrings;

static const enum zbar_symbol_type_e symbolValues[] =
{
    ZBAR_NONE,
    ZBAR_PARTIAL,
    ZBAR_EAN2,
    ZBAR_EAN5,
    ZBAR_EAN8,
    ZBAR_UPCE,
    ZBAR_ISBN10,
    ZBAR_UPCA,
    ZBAR_EAN13,
    ZBAR_ISBN13,
    ZBAR_COMPOSITE,
    ZBAR_I25,
    ZBAR_DATABAR,
    ZBAR_DATABAR_EXP,
    ZBAR_CODE39,
    ZBAR_PDF417,
    ZBAR_QRCODE,
    ZBAR_CODE93,
    ZBAR_CODE128,
    ZBAR_CODABAR,
};

static const enum zbar_symbol_type_e allSymbols[] =
{
    ZBAR_EAN2,
    ZBAR_EAN5,
    ZBAR_EAN8,
    ZBAR_UPCE,
    ZBAR_ISBN10,
    ZBAR_UPCA,
    ZBAR_EAN13,
    ZBAR_ISBN13,
    ZBAR_COMPOSITE,
    ZBAR_I25,
    ZBAR_DATABAR,
    ZBAR_DATABAR_EXP,
    ZBAR_CODE39,
    ZBAR_PDF417,
    ZBAR_CODE93,
    ZBAR_CODE128,
    ZBAR_CODABAR,
};

-(void)dealloc
{
	RELEASE_TO_NIL(square);
    
	[super dealloc];
}

-(void)initializeState
{
	[super initializeState];
    
    barcodeDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                   [NSNumber numberWithInt: ZBAR_EAN2], @"EAN2",
                   [NSNumber numberWithInt: ZBAR_EAN5], @"EAN5",
                   [NSNumber numberWithInt: ZBAR_EAN8], @"EAN8",
                   [NSNumber numberWithInt: ZBAR_UPCE], @"UPCE",
                   [NSNumber numberWithInt: ZBAR_ISBN10], @"ISBN10",
                   [NSNumber numberWithInt: ZBAR_UPCA], @"UPCA",
                   [NSNumber numberWithInt: ZBAR_EAN13], @"EAN13",
                   [NSNumber numberWithInt: ZBAR_ISBN13], @"ISBN13",
                   [NSNumber numberWithInt: ZBAR_COMPOSITE], @"COMPOSITE",
                   [NSNumber numberWithInt: ZBAR_I25], @"I25",
                   [NSNumber numberWithInt: ZBAR_DATABAR], @"DATABAR",
                   [NSNumber numberWithInt: ZBAR_DATABAR_EXP], @"DATABAR_EXP",
                   [NSNumber numberWithInt: ZBAR_CODE39], @"CODE39",
                   [NSNumber numberWithInt: ZBAR_PDF417], @"PDF417",
                   [NSNumber numberWithInt: ZBAR_CODE93], @"CODE93",
                   [NSNumber numberWithInt: ZBAR_CODE128], @"CODE128",
                   [NSNumber numberWithInt: ZBAR_CODABAR], @"CODABAR",
                   nil];

    barcodeStrings = [NSArray arrayWithObjects:
                   @"EAN2",
                   @"EAN5",
                   @"EAN8",
                   @"UPCE",
                   @"ISBN10",
                   @"UPCA",
                   @"EAN13",
                   @"ISBN13",
                   @"COMPOSITE",
                   @"I25",
                   @"DATABAR",
                   @"DATABAR_EXP",
                   @"CODE39",
                   @"PDF417",
                   @"CODE93",
                   @"CODE128",
                   @"CODABAR",
                   nil];
    
    // Set the barcodes
    barcodes = [self.proxy valueForKey:@"barcodes"];
    
    // Set the minQuality (not setting it will default to 0)
    minQuality = ([self.proxy valueForKey:@"minQuality"] != nil) ? [[self.proxy valueForKey:@"minQuality"] intValue] : 0;
    
    // Set the value of flashEnabled (true or false, defaults to false)
    flashEnabled = ([self.proxy valueForKey:@"flashEnabled"] != nil) ? [[self.proxy valueForKey:@"flashEnabled"] boolValue] : false;

    // Set the value of flashEnabled (true or false, defaults to false)
    scanCropPreview = ([self.proxy valueForKey:@"scanCropPreview"] != nil) ? [[self.proxy valueForKey:@"scanCropPreview"] boolValue] : false;

    // Set the value of flashEnabled (true or false, defaults to false)
    scanCrop = ([self.proxy valueForKey:@"scanCrop"] != nil) ? [self.proxy valueForKey:@"scanCrop"] : nil;
}

-(ZBarReaderView*)square
{
    if(square == nil){
        // initialize the reader
        square = [[ZBarReaderView alloc] initWithFrame:[self frame]];
        ZBarImageScanner * scanner = [ZBarImageScanner new];
        [square initWithImageScanner:scanner];
        [scanner release];
        
        square.readerDelegate = self;
        
        NSArray* barcodes = nil;
        
        if(self.barcodes != nil)
        {
            for(NSString * barcode in self.barcodes)
            {
                if(barcode != nil)
                {
                    if([barcodeDict objectForKey:[barcode uppercaseString]] != nil)
                    {
                        NSLog([NSString stringWithFormat:@"Listening for barcode type: %@", barcode]);
                        [square.scanner setSymbology:[[barcodeDict objectForKey:[barcode uppercaseString]] intValue] config:ZBAR_CFG_ENABLE to:true];
                    }
                    else
                    {
                        NSLog([NSString stringWithFormat:@"Unknown barcode type: %@", barcode]);
                    }
                }
                else
                {
                    NSLog([NSString stringWithFormat:@"barcode is nil :("]);
                }
            }
        }
        else
        {
            for (int k = 0, l = (sizeof allSymbols); l > k; k++) {
                [square.scanner setSymbology: allSymbols[k]
                                      config: ZBAR_CFG_ENABLE
                                          to: true];
            }
        }
        
        square.device = [self backFacingCameraIfAvailable];
        
        [square setTracksSymbols: NO];
        
        // Set the flash mode
        if(flashEnabled){
            square.torchMode = AVCaptureTorchModeOn;
        } else {
            square.torchMode = AVCaptureTorchModeOff;
        }
        
        // Set the scanCrop area
        
        
        if(scanCrop != nil){
            square.scanCrop = [self formatScanCrop:[self frame]];
        }
        
        
        // Start it up!
        [square start];

        [self addSubview:square];
        
        // Add a scancrop preview if we want it

        if(scanCropPreview && scanCrop != nil){
            CGFloat prev_x,prev_y,prev_width,prev_height;
            
            prev_x = [[scanCrop objectForKey:@"x"] floatValue];
            prev_y = [[scanCrop objectForKey:@"y"] floatValue];
            prev_width = [[scanCrop objectForKey:@"width"] floatValue];
            prev_height = [[scanCrop objectForKey:@"height"] floatValue];
            
            UIView* scan_overlay_view = [[UIView alloc]initWithFrame:CGRectMake(prev_x, prev_y, prev_width, prev_height)];
            scan_overlay_view.backgroundColor = [UIColor redColor];
            scan_overlay_view.alpha = 0.35;
            
            [self addSubview:scan_overlay_view];
        }
    }
    
    return square;
}

-(CGRect)formatScanCrop:(CGRect)frame
{
    CGFloat x,y,width,height,frame_width,frame_height;
    
    frame_width = frame.size.width > 0 ? frame.size.width : [UIScreen mainScreen].bounds.size.width;
    frame_height = frame.size.height > 0 ? frame.size.height : [UIScreen mainScreen].bounds.size.height;
    
    x = [[scanCrop objectForKey:@"y"] floatValue] / frame_height;
    y = (frame_width - [[scanCrop objectForKey:@"width"] floatValue] - [[scanCrop objectForKey:@"x"] floatValue]) / frame_width;
    width = [[scanCrop objectForKey:@"height"] floatValue] / frame_height;
    height = [[scanCrop objectForKey:@"width"] floatValue] / frame_width;
    
    return CGRectMake(x, y, width, height);
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
	[TiUtils setView:self.square positionRect:bounds];
}

-(AVCaptureDevice *)backFacingCameraIfAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
            break;
        }
    }
    
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

// ZBarReaderDelegate Methods

- (void) readerView: (ZBarReaderView*) view didReadSymbols: (ZBarSymbolSet*) syms fromImage: (UIImage*) img
{
    for(ZBarSymbol *sym in syms) {
        if(sym.quality > minQuality)
        {
            NSLog(@"Data= %@",sym.data);
            NSLog(@"Type= %@",sym.typeName);
            NSLog(@"Quality of Scan (minimum of %d): %d", minQuality, sym.quality);
            
            NSMutableDictionary *event = [NSMutableDictionary dictionary];
            
            [event setObject:sym.data forKey:@"data"];
            [event setObject:sym.typeName forKey:@"type"];
            [event setObject:[NSNumber numberWithInt:sym.quality] forKey:@"quality"];
            
            [self.proxy fireEvent:@"success" withObject:event];
        }
        break;
    };
}

# pragma public api

- (void)enableFlash:(id)args
{
    [self square].torchMode = AVCaptureTorchModeOn;
    flashEnabled = true;
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    
    [event setObject:[NSNumber numberWithBool:flashEnabled] forKey:@"flashEnabled"];
    
    [self.proxy fireEvent:@"flashChange" withObject:event];
}

- (void)disableFlash:(id)args
{
    [self square].torchMode = AVCaptureTorchModeOff;
    flashEnabled = false;
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    
    [event setObject:[NSNumber numberWithBool:flashEnabled] forKey:@"flashEnabled"];
    
    [self.proxy fireEvent:@"flashChange" withObject:event];

}

- (void)toggleFlash:(id)args
{
    if(flashEnabled)
    {
        [self disableFlash:args];
    }
    else
    {
        [self enableFlash:args];
    }
}

@end

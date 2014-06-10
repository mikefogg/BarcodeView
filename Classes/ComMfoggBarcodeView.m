#import "ComMfoggBarcodeView.h"
#import "ComMfoggBarcodeViewProxy.h"
#import <AVFoundation/AVFoundation.h>

@implementation ComMfoggBarcodeView

NSDictionary *barcodeDict = nil;
NSArray *barcodeStrings = nil;

@synthesize barcodes;

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
    
    barcodes = [self.proxy valueForKey:@"barcodes"];
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
        
        // Start it up!
        [square start];

        [self addSubview:square];
    }
    
    return square;
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
        NSLog(@"Data= %@",sym.data);
        NSLog(@"Data= %@",sym.typeName);
        
        NSMutableDictionary *event = [NSMutableDictionary dictionary];
        
        [event setObject:sym.data forKey:@"data"];
        [event setObject:sym.typeName forKey:@"type"];
        
        [self.proxy fireEvent:@"success" withObject:event];

        break;
    };
}

@end

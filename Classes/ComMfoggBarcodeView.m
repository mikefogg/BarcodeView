#import "ComMfoggBarcodeView.h"
#import "ComMfoggBarcodeViewProxy.h"
#import <AVFoundation/AVFoundation.h>

@implementation ComMfoggBarcodeView

NSDictionary *barcodeDict = nil;
NSArray *allBarcodes = nil;

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
	NSLog(@"[VIEW LIFECYCLE EVENT] dealloc");
    
	// Release objects and memory allocated by the view
	RELEASE_TO_NIL(square);
    
	[super dealloc];
}

-(void)initializeState
{
	// This method is called right after allocating the view and
	// is useful for initializing anything specific to the view
    
	[super initializeState];
    
	NSLog(@"[VIEW LIFECYCLE EVENT] initializeState");
    
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

    allBarcodes = [NSArray arrayWithObjects:
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
    
    NSLog([NSString stringWithFormat:@"[VIEW INFO EVENT] BARCODES: %@", barcodes]);
}

-(ZBarReaderView*)square
{
    NSLog(@"[VIEW LIFECYCLE EVENT] square hit");
    if(square == nil){
        NSLog(@"[VIEW LIFECYCLE EVENT] square initialized");
        // init reader
        square = [[ZBarReaderView alloc] initWithFrame:[self frame]];
        ZBarImageScanner * scanner = [ZBarImageScanner new];
        [square initWithImageScanner:scanner];
        [scanner release];
        
        square.readerDelegate = self;
        
        NSArray* barcodes = nil;
        
        if(self.barcodes != nil)
        {
            NSLog(@"barcodes != nil");
            
            NSLog([NSString stringWithFormat:@"barcodes: %@", self.barcodes]);
            for(NSString * barcode in self.barcodes)
            {
                if(barcode != nil)
                {
                    if([barcodeDict objectForKey:[barcode uppercaseString]] != nil)
                    {
                        NSLog([NSString stringWithFormat:@"Barcode type: %@", barcode]);
                        [square.scanner setSymbology:[[barcodeDict objectForKey:[barcode uppercaseString]] intValue] config:ZBAR_CFG_ENABLE to:true];
                    }
                    else
                    {
                        NSLog([NSString stringWithFormat:@"Unknown barcode type: %@", barcode]);
                    }
                }
                else
                {
                    NSLog([NSString stringWithFormat:@"barcode is nil"]);
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
        
        [square start];

        [self addSubview:square];
    } else {
        // scanner already initialized
    }
    
    return square;
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
	// You must implement this method for your view to be sized correctly.
	// This method is called each time the frame / bounds / center changes
	// within Titanium.
    
	NSLog(@"[VIEW LIFECYCLE EVENT] frameSizeChanged");
    
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
    
    //  couldn't find one on the front, so just get the default video device.
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

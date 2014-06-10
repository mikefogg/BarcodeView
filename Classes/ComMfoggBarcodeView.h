#import "TiUIView.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "ZBarSDK.h"

@interface ComMfoggBarcodeView : TiUIView <ZBarReaderViewDelegate>
{
    
    ZBarReaderView *square;
}

@property (nonatomic, retain) NSArray *barcodes;

@end


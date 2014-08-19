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
@property (nonatomic, retain) NSDictionary *barcodeDict;
@property (nonatomic, retain) NSDictionary *scanCrop;
@property (nonatomic, retain) NSArray *barcodeStrings;
@property (nonatomic) BOOL flashEnabled;
@property (nonatomic) BOOL scanCropPreview;
@property (nonatomic) int minQuality;

@end


#import "ComMfoggBarcodeView.h"
#import "ComMfoggBarcodeViewProxy.h"

@implementation ComMfoggBarcodeView

- (void) dealloc
{
    RELEASE_TO_NIL(square);

	[super dealloc];
}

-(void)initializeState
{
	[super initializeState];
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    if (square!=nil)
    {
        [TiUtils setView:square positionRect:bounds];
    }
}

-(UIView*)square
{
    if(square == nil){
        square = [[UIView alloc] initWithFrame:[self frame]];
		[self addSubview:square];
    }
    
    return square;
}

@end

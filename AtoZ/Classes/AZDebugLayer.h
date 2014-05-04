//
//  AZDebugLayer.h
//  AtoZ
//
//  Created by Alex Gray on 10/11/12.
//  Copyright (c) 2012 mrgray.com, inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AtoZ.h"


@interface AZDebugLayer : CAL
@property NSC* color;
//@property (strong) CAShapeLayer *anchorPointLayer, *positionLayer;
@end

@interface AZDebugLayerView : NSView
@property (nonatomic) AZDebugLayer *dLayer;
@property (nonatomic) CAL *root;
@end


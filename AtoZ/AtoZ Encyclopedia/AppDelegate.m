//
//  AppDelegate.m
//  AtoZ Encyclopedia
//
//  Created by Alex Gray on 8/2/12.
//  Copyright (c) 2012 mrgray.com, inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
	//@synthesize pIndi;
	//@synthesize orientButton;
	//@synthesize scaleSlider;
@synthesize window = _window, root;

-(void)awakeFromNib;
{
	
    [[_window contentView] setWantsLayer:YES];
	root = [CALayer layer];
	[[[_window contentView] layer] addSublayer: root ];
    [root setBackgroundColor:cgRANDOMCOLOR];
	//	root.layoutManager =
	int i = 4;
	while (i != 0) {
		CALayer *layer = [[AZBoxLayer alloc] initWithImage:[[NSImage systemImages]randomElement] title:$(@"vageen.%i",i)];
		[layer setFrame:CGRectMake(kMargin, 0.0, kIconWidth, kCompositeIconHeight)];
	    [root insertSublayer:layer atIndex:i];
		i--;
	}
		//		:iconPath1 title:@"Desktop"] retain];
		//		[layer1 setFrame:CGRectMake(kMargin, 0.0, kIconWidth, kCompositeIconHeight)];
		//	}	
		//    
		//    layer1 = [[[IconLayer alloc] initWithImagePath:iconPath1 title:@"Desktop"] retain];
		//    [layer1 setFrame:CGRectMake(kMargin, 0.0, kIconWidth, kCompositeIconHeight)];
		//    
		//    layer2 = [[[IconLayer alloc] initWithImagePath:iconPath2 title:@"Firewire Drive"] retain];
		//    [layer2 setFrame:CGRectMake(kMargin, kIconWidth + kMargin, kIconWidth, kCompositeIconHeight)];
		//    
		//    layer3 = [[[IconLayer alloc] initWithImagePath:iconPath3 title:@"Pictures"] retain];
		//    [layer3 setFrame:CGRectMake(kCompositeIconHeight + kMargin, 0.0, 128, kCompositeIconHeight)];
		//    
		//    layer4 = [[[IconLayer alloc] initWithImagePath:iconPath4 title:@"Computer"] retain];
		//    [layer4 setFrame:CGRectMake(kCompositeIconHeight + kMargin, kIconWidth + kMargin, kIconWidth, kCompositeIconHeight)];
		//	
		//    [root insertSublayer:layer1 atIndex:0];
		//    [root insertSublayer:layer2 atIndex:0];
		//    [root insertSublayer:layer3 atIndex:0];
		//    [root insertSublayer:layer4 atIndex:0];
    
}

-(IBAction)toggleShake:(id)sender;
{
	for (AZBoxLayer *obj in [root sublayers] )
		[obj toggleShake];
	
		//    [layer1 toggleShake];
		//    [layer2 toggleShake];
		//    [layer3 toggleShake];
		//    [layer4 toggleShake];
}


@end


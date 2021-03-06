//
//  AZGrid.h
//  Lumumba Framework
//
//  Created by Benjamin Schüttler on 28.09.09.
//  Copyright 2011 Rogue Coding. All rights reserved.
//


//#import "AZPoint.h"
//#import "AZSize.h"
//#import "AZRect.h"
//#import "AZMatrix.h"

/* NOTES note to self this is a bastard conglomeration two separate classes one is from pixen, one from lumumba?

  View Init.....
  	_grid = [AZGrid.alloc initWithUnitSize:NSMakeSize(1.0f, 1.0f)  color:GRAY2 shouldDraw:YES];

		In view's   ..  - (void) drawRect:(NSRect)rect
 	[_grid drawRect:rect];
*/

_EnumKind( AZGridStyle, AZGridStyleCompact, AZGridStyleHorizontal, AZGridStyleVertical );
_EnumKind( AZGridOrder, AZGridOrderRowMajor, AZGridOrderColumnMajor);

@class AZPoint, AZSize, AZRect, AZMatrix;

@interface AZGrid : NSObject <NSCopying, NSCoding >
{
	NSMA *array;
	NSUI parallels;
	NSUI style, order;
	BOOL rowMajorOrder;
	
  @private
	NSSize _unitSize;
	NSColor *_color;
	BOOL _shouldDraw;
}

@property (nonatomic) NSSize unitSize;
@property (nonatomic) NSColor *color;
@property (nonatomic) BOOL shouldDraw;
-   (id) initWithFrame:(NSR)frame;
-   (id) initWithUnitSize:(NSSize)unitSize color:(NSColor *)color shouldDraw:(BOOL)shouldDraw;
- (void) drawRect:(NSRect)drawingRect;
- (void) setDefaultParameters;
-    (id) initWithCapacity:(NSUInteger)numItems;

@property (UNSF,RO) AZSize* size;
_RO NSUI count;
_RO CGF width, height, min, max;

@property (ASS) NSUI parallels, order, style;

- (NSMA*) elements;
- (NSNumber*) indexAtPoint:(NSP)point;
- (id) objectAtIndex:(NSUInteger)index;
- (id) objectAtPoint:(NSP)point;
- (NSP) pointAtIndex:(NSUInteger)index; // was AZPoint*

- (void) addObject:(id) anObject;
- (void) insertObject:(id) anObject atIndex:(NSUInteger)index;
- (void) removeObjectAtIndex:(NSUInteger)index;
- (void) removeAllObjects;

@end


#define CRNR OSCornerType

_EnumKind(NSWindowResize, NSWindowResizeTopLeftCorner     = 1,
													NSWindowResizeTopRightCorner    = 2,
													NSWindowResizeBottomRightCorner = 3,
													NSWindowResizeBottomLeftCorner  = 4);


@interface NSAnimationContext (Blocks)

+ (void) groupWithDuration:(NSTI)d
    timingFunctionWithName __Text_ tF
         completionHandler:(VBlk)blk
            animationBlock:(VBlk)aniB;

+ (void) groupWithDuration:(NSTI)d
         completionHandler:(VBlk)cH
            animationBlock:(VBlk)ani;

+ (void)groupWithDuration:(NSTI)d
           animationBlock:(VBlk)an;
@end

@Xtra(NSResponder,AtoZ)

_VD        overrideResponder __Meth_ sel
										withBool __IsIt_ accepts ___
_VD setAcceptsFirstResponder __IsIt_ a ___
_VD  setPerformKeyEquivalent __IsIt_ p ___


/*! [win animateWithDuration:2 block:^(id w){ 
      [w setFrame:AZScreenFrameUnderMenu()]; 
    }]
*/
- (void) animateWithDuration:(NSTI)d block ＾ObjC_ stuff;
@end


@interface NSWindow (SBSWindowAdditions)
+ (void) setLiveFrameTracking:(BOOL) bol;
+ (BOOL) isLiveFrameTracking;
@end

@interface NSWindow (Resize)
- (void) resizeToWidth:(CGF)w height:(CGF)h;
- (void) resizeToWidth:(CGF)w height:(CGF)h origin:(NSWindowResize)theOrigin;
- (void) resizeToWidth:(CGF)w height:(CGF)h origin:(NSWindowResize)theOrigin duration:(NSTI)dur;
@end

@interface NSWindow		(AtoZ)  <RectLike> 

- (void) activate;

+ (INST) withFrame:(NSR)r mask:(NSUI)m;
#pragma mark - THE MISSING ACCESSORS

_NA _List childWindows;
_RO _View frameView;
_PR _View view;
_RO _Layr windowLayer, contentLayer;
_RO _Rect contentRect;
_RO _Flot  heightOfTitleBar, toolbarHeight;

_VD toggleVisibility;

_VD overrideCanBecomeMainWindow:(BOOL)canBecomeMain;
- (void)  overrideCanBecomeKeyWindow:(BOOL)canBecomeKey;
- (void)               setIgnoresEventsButAcceptsMoved;

#pragma mark - FACTORIES

+ (INST) windowWithFrame:(NSR)r view:(NSView*)v mask:(NSUI)m;
+ (INST) windowWithFrame:(NSR)r mask:(NSUI)m;

+ (NSW*) borderlessWindowWithContentRect:(NSR)aRect;
+   (id) hitTest:			(NSE*) event;
+   (id) hitTestPoint:(NSP)location;
+ (NSA*) appWindows;

- (NSA*) windowAndChildren;
+ (NSA*) allWindows;

+ desktopWindow;

_RO CAL* veilLayer;
- (CAL*) veilLayerForView:(NSV*)view;

- (void) addViewToTitleBar:	(NSV*)viewToAdd atXPosition:(CGFloat)x;

- (void) setContentSize:		(NSSZ)z display:(BOOL)f animate:(BOOL)a;
- (void) betterCenter;
- (void) fadeIn;
- (void) fadeOut;
- (void) slideUp;
- (void) slideDown;
- (void) extendVerticallyBy: (CGF) amount;
- (void) animateInsetTo:(CGF)f anchored:(AZA)edge;
- (void) delegateBlock: (void(^)(NSNOT*))block;

@end

//@property (readonly, nonatomic) BOOL isBorderless;
//-  (NSP) midpoint; //get the midpoint of the window
//- (void) setMidpoint:		(NSPoint) midpoint; //set the midpoint of the window
/* - (void) fadeInYesOrOutNo: (BOOL)fade andResizeTo: (NSRect)frame;	*/
//- (void) setDefaultFirstResponder;

#define kNTSetDefaultFirstResponderNotification @"NTSetDefaultFirstResponderNotification"  // object is the window, must check


#define NSBorderlessWindowMaskSet(bitMask) (bitMask == 0)  // NSBorderlessWindowMask == 0
#define NSTexturedBackgroundWindowMaskSet(bitMask) ((bitMask & NSTexturedBackgroundWindowMask) != 0)

@interface  NSWindow (UKFade)

-(void)       fadeInOneStep:(NSTimer*)timer;
-(void)      fadeOutOneStep:(NSTimer*)timer;
-(void)  fadeInWithDuration:(NSTimeInterval)duration;
-(void) fadeOutWithDuration:(NSTimeInterval)duration;
-(void)	        fadeToLevel:(int)lev
               withDuration:(NSTimeInterval)duration;
@end

@interface NSWindow (SDResizableWindow)

- (void) setContentViewSize:(NSSize)x
                    display:(BOOL)d
                    animate:(BOOL)a;

-  (NSR) windowFrameForNewContentViewSize:(NSSize)newSize;

@end

/*@interface NSWindow (Utilities)
- (void) eil:(NSView*)view;
+ (void) cascadeWindow:(NSWindow*)inWindow;
+ (NSA*) visibleWindows:(BOOL)ordered;
+ (NSA*)visibleWindows:(BOOL)ordered delegateClass:(Class)delegateClass;
- (NSWindow*)topWindowWithDelegateClass:(Class)klass;
+ (BOOL)isAnyWindowVisibleWithDelegateClass:(Class)klass;

+ (BOOL) isAnyWindowVisible;
+ (NSA*) miniaturizedWindows;

- (void) setFloating:(BOOL)set;
- _IsIt_ isFloating;

- _IsIt_ isMetallic;
- _IsIt_ isBorderless;

// returns parentWindow if an NSDrawerWindow, returns self if not a drawerWindow
- (NSWindow*) parentWindowIfDrawerWindow;

- _IsIt_ dimControls;
- _IsIt_ dimControlsKey;
- _IsIt_ keyWindowIsMenu;

- (void) flushActiveTextFields;

 (NSRect) setContentViewAndResizeWindow: (NSView*)view 		display:(BOOL)display;
- (NSRect) resizeWindowToContentSize: (NSSize)contentSize 	display:(BOOL)display;
- (NSRect) windowFrameForContentSize: (NSSize)contentSize;
+ (BOOL) windowRectIsOnScreen: (NSRect)windowRect;
@end

@interface NSWindow (UndocumentedRoutines)
- (void) setBottomCornerRounded:(BOOL)set;
- (BOOL)bottomCornerRounded;
@end
*/
/*
 Provides a "zoom" animation for windows when ordering on and off screen.
 For more details, check out the related blog posts at http://www.noodlesoft.com/blog/2007/06/30/animation-in-the-time-of-tiger-part-1/ and http://www.noodlesoft.com/blog/2007/09/20/animation-in-the-time-of-tiger-part-3/	*/
/*
@interface NSWindow (NoodleEffects)

- (void) animateToFrame: (NSRect) frameRect duration:(NSTimeInterval)duration;
- (void) zoomOnFromRect: (NSRect) startRect;
- (void) zoomOffToRect:  (NSRect) endRect;

@end
//- (void) setFrame:(NSR)frame;
//_RONSR   bounds;
//_ROCGF   originX, originY;
// Size
//@property (nonatomic) CGF width;
//@property (nonatomic) CGF height;
//@property (nonatomic) NSSZ frameSize;

//- (void) setWidth: (CGF) t;
//- (void) setHeight: (CGF) t;
//- (void) setFrameSize: (NSSZ) size;

*/

@interface NSWindow (Transforms)

- (NSPoint) windowToScreenCoordinates:(NSPoint)point;
- (NSPoint) screenToWindowCoordinates:(NSPoint)point;

- (void) rotate:(double)radians;
- (void) rotate:(double)radians about:(NSPoint)point;

- (void) scaleBy:(double)scaleFactor;
- (void) scaleX:(double)x Y:(double)y;
- (void) setScaleX:(double)x Y:(double)y;
- (void) scaleX:(double)x Y:(double)y about:(NSPoint)point concat:(BOOL)concat;

- (void) reset;

- (void) setSticky:(BOOL)flag;
@end




@interface NSColorPanel (AtoZ)
@property (CP) void(^actionBlock)(id);
@end


@protocol NSActionBlock <NSObject>
@concrete
_CP ＾ObjC actionBlock;
_CP ＾ voidActionBlock;
@end

@interface NSControl (AtoZEvent)
- (void) setAction:(SEL)method withTarget: object;
- (void) setActionString:(NSS*)methodasString withTarget: object;
@property (copy) void(^eventActionBlock)(AZEvent e,id sender);
@end

//typedef void (^whileDragging)(void);
//typedef void (^insideDrag)(NSE*, NSP, whileDragging);

@interface NSEvent (AtoZ)

//+ (void) monitorDragRect:(BOOL)

// deltasizeAZ has deltaY negated so it maessense to me.
@property (readonly) NSSZ deltaSize,  deltaSizeAZ;
@property (readonly) NSP delta;

//+ (void) dragBlock:(void(^)(NSP click, NSP delta))block;

/*	- (void) scrollWheel:(NSEvent *)theEvent	{	self.offset = [theEvent scrollOffsetInView:self];	
																						    [self setNeedsDisplay:YES];	} */
- (NSSZ) scrollOffsetInView:(NSV*)view;
/*	- (void) agnifyWithEvent:(NSEvent *)event {	[self setFrame:[event magnifyRect:self.frame]]; */
- (NSR) magnifyRect:(NSR)rect;
//- (whileDragging)dragBlock:(NSE*)e;
+ (void)whileDragging:(void(^)(NSE* click, NSE*drag,id context))block;
+ (void) shiftClick:(void(^)(void))block;
//+ (NSE*) whileDragging:(whileDragging)whileDraggingBlock;
#ifdef UNIMPLEMENTED
- (id) dragHandlerForClickWithBlock:(void(^)(NSE*click, NSE*drag, id context)) block;
#endif
@end


@interface NSTV (TargetAction)
@property (readwrite, nonatomic, copy) NSControlVoidActionBlock doubleActionBlock;
- (void) setDoubleAction:(SEL)method withTarget: object;
- (void) setDoubleActionString:(NSS*)methodasString withTarget: object;
//- (void) setDoubleActionBlock:(NSControlVoidActionBlock)block;

@end

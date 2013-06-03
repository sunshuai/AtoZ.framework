
#import "AtoZ.h"
#import "NSObject+AtoZ.h"


@implementation NSObject (GCD)
- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)shouldWait {
    shouldWait ?        // Synchronous
        dispatch_sync(dispatch_get_main_queue(), block) :
    dispatch_async(dispatch_get_main_queue(), block);  // Asynchronous
}
- (void)performAsynchronous:(void(^)(void))block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}
- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_current_queue(), block);
}
@end

@implementation NSObject (ClassAssociatedReferences)
+ (void)setValue:(id)value forKey:(NSS*)key {
	
	[self setAssociatedValue:value forKey:key policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}
+ (id)valueForKey:(NSS*)key  {
	return [(NSO*)self associatedValueForKey:(__bridge const void *)(key)];
}
@end

@implementation NSObject (HidingAssocitively)
- (BOOL) folded 						{ return [[self associatedValueForKey:@"AtoZhidden" orSetTo:@(NO) policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC]boolValue ]; 	}
- (void) setFolded:(BOOL)hidden 	{ 	[self setAssociatedValue:@(hidden) forKey:@"AtoZhidden" policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC]; }
@end


//#import "AutoCoding.h"

//#import "Nu.h"
//
//@implementation NSObject (AMAssociatedObjects)
//
//- (void)associate: (id)value with: (void*)key {			objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN); }
//
//- (void)weaklyAssociate: (id)value with: (void*)key {	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN); }
//
//- (id)associatedValueFor: (void*)key {			 return va;(self, key);								 }
//
//@end

IMP impOfCallingMethod(id lookupObject, SEL selector)
{
    NSUInteger returnAddress = (NSUInteger)__builtin_return_address(0);
    NSUInteger closest = 0;
    // Iterate over the class and all superclasses
    Class currentClass = object_getClass(lookupObject);
    while (currentClass)
    {
        // Iterate over all instance methods for this class
        unsigned int methodCount;
        Method *methodList = class_copyMethodList(currentClass, &methodCount);
        unsigned int i;
        for (i = 0; i < methodCount; i++)
        {
            // Ignore methods with different selectors
            if (method_getName(methodList[i]) != selector)  continue;
            // If this address is closer, use it instead
            NSUInteger address = (NSUInteger)method_getImplementation(methodList[i]);
            if (address < returnAddress && address > closest)
                closest = address;
    
        }
        free(methodList);
        currentClass = class_getSuperclass(currentClass);
    }
	 return (IMP)closest;
}
@implementation NSObject (SupersequentImplementation)
- (IMP)getImplementationOf:(SEL)lookup after:(IMP)skip
{
	BOOL found = NO;
	Class currentClass = object_getClass(self);
	while (currentClass)
	{
		// Get the list of methods for this class
		unsigned int methodCount;
		Method *methodList = class_copyMethodList(currentClass, &methodCount);
		// Iterate over all methods
		unsigned int i;
		for (i = 0; i < methodCount; i++)
		{
			// Look for the selector
			if (method_getName(methodList[i]) != lookup)				continue;
			IMP implementation = method_getImplementation(methodList[i]);
			// Check if this is the "skip" implementation
			if (implementation == skip)
				found = YES;
			else if (found)
			{
				// Return the match.
				free(methodList);
				return implementation;
			}
		}
		// No match found. Traverse up through super class' methods.
		free(methodList);
		currentClass = class_getSuperclass(currentClass);
	}
	return nil;
}

@end


static id addMethodTrampoline(id self, SEL _cmd) {
	id(^block)(id, SEL) = objc_getAssociatedObject([self class], _cmd);
	return block(self, _cmd);
}

@implementation NSObject (AddMethod)

+ (BOOL) addMethodFromString:(NSS*)s withArgs:(NSA*)a{
	
	// get an Objective-C selector variable for the method
	SEL mySelector;
	mySelector = NSSelectorFromString(s);
	// create a singature from the selector
	NSMethodSignature * sig = nil;
	sig = [self instanceMethodSignatureForSelector:mySelector];
	// create an actual invocation object and set the target to self
	NSInvocation * myInvocation = nil;
	myInvocation = [NSInvocation invocationWithMethodSignature:sig];
	[myInvocation setTarget:self];
	[myInvocation setSelector:mySelector];
	
	for (id arg in a ) {
		// add first argument  // add second argument
		id var = [[arg class] new];
		[myInvocation setArgument:&var atIndex:[a indexOfObject:arg] + 2 ];
	}
//	class_addMethod(__unsafe_unretained Class cls, SEL name, IMP imp, const char *types)
//	class_addMethod(self, mySelector, (IMP)addMethodTrampoline, types);


//	IMP myIMP = imp_implementationWithBlock(^(id _self, NSString *string) {		NSLog(@"Hello %@", string);
//	});
//	class_addMethod([self class], NSSelectorFromString(s), myIMP, "v@:@");
}

+ (BOOL)addMethodForSelector:(SEL)sel typed:(const char*)types implementation:(id)blkPtr {

	objc_setAssociatedObject(self, sel, blkPtr, OBJC_ASSOCIATION_COPY_NONATOMIC);
	class_addMethod(self, sel, (IMP)addMethodTrampoline, types);
	return YES;
}

- (NSA*) methodSignatureArray:(SEL)selector 	{

	NSMethodSignature *s =	[self methodSignatureForSelector:selector];
	return [[@0 to:@([s numberOfArguments] - 1)] nmap:^(id ob, NSUI ud){ return $UTF8([s getArgumentTypeAtIndex:ud]);	}];
}

+ (NSA*) methodSignatureArray:(SEL)selector 	{
	NSMethodSignature *s =	[self methodSignatureForSelector:selector];
	return  [[@0 to: @([s numberOfArguments] - 1)] nmap:^(id ob, NSUI ud){ return $UTF8([s getArgumentTypeAtIndex:ud]);	}];
}
- (NSS*) methodSignatureString:(SEL)selector {	return [NSS stringFromArray:[self methodSignatureArray:selector]];	}
+ (NSS*) methodSignatureString:(SEL)selector {return [NSS stringFromArray:[self methodSignatureArray:selector]]; }

@end


@implementation NSObject (AssociatedValues)

- (void)setAssociatedValue:(id)value forKey:(NSS *)key {
	[self setAssociatedValue:value forKey:key policy:OBJC_ASSOCIATION_ASSIGN];
}

- (void)setAssociatedValue:(id)value forKey:(NSS *)key policy:(objc_AssociationPolicy)policy {
	objc_setAssociatedObject(self, (__bridge const void *)(key), value, policy);
}

- (id)associatedValueForKey:(NSS *)key {
	return objc_getAssociatedObject(self, (__bridge const void *)(key));
}

- (void)removeAssociatedValueForKey:(NSS *)key {
	objc_setAssociatedObject(self, (__bridge const void *)(key), nil, OBJC_ASSOCIATION_ASSIGN);
}

- (void)removeAllAssociatedValues {
	objc_removeAssociatedObjects(self);
}

- (BOOL)hasAssociatedValueForKey:(NSS *)string {
	return [self associatedValueForKey:(__bridge const void *)string] != nil;
}

- (id)associatedValueForKey:(NSS *)key orSetTo:(id)anObject policy:(objc_AssociationPolicy)policy {
	return [self hasAssociatedValueForKey:key]
	? [self associatedValueForKey:(__bridge const void *)(key)]
	: ^{    [self setAssociatedValue:anObject forKey:key policy:policy];
		return [self associatedValueForKey:(__bridge const void *)(key)];        } ();
}

@end

@interface AZObserverTrampoline : NSObject
{
	__weak id observee;             NSS *keyPath;   AZBlockTask task;       NSOQ *queue;    dispatch_once_t cancellationPredicate;
}

- (AZObserverTrampoline *)initObservingObject:(id)obj keyPath:(NSS *)keyPath onQueue:(NSOQ *)queue task:(AZBlockTask)task;
- (void)cancelObservation;
@end

@implementation AZObserverTrampoline

static NSS *AZObserverTrampolineContext = @"AZObserverTrampolineContext";

- (AZObserverTrampoline *)initObservingObject:(id)obj keyPath:(NSS *)newKeyPath onQueue:(NSOQ *)newQueue task:(AZBlockTask)newTask {
	if (!(self = [super init])) return nil;
	task = [newTask copy];
	keyPath = [newKeyPath copy];
	queue = newQueue;        // retain];
	observee = obj;
	cancellationPredicate = 0;
	[observee addObserver:self forKeyPath:keyPath options:0 context:(__bridge void *)AZObserverTrampolineContext];
	return self;
}

- (void)observeValueForKeyPath:(NSS *)aKeyPath ofObject:(id)object change:(NSD*)change context:(void *)context {
	if (context == (__bridge const void *)AZObserverTrampolineContext) queue ? [queue addOperationWithBlock:^{ task(object, change); }] : task(object, change);
}

- (void)cancelObservation {
	dispatch_once(&cancellationPredicate, ^{
		[observee removeObserver:self forKeyPath:keyPath];
		observee = nil;
	});
}

//- (void)dealloc {	[self cancelObservation]; [task release]; [keyPath release]; [queue release]; [super dealloc]; }

@end

static NSS *AZObserverMapKey = @"com.github.mralexgray.observerMap";
static dispatch_queue_t AZObserverMutationQueue = NULL;
static dispatch_queue_t AZObserverMutationQueueCreatingIfNecessary(void) {
	static dispatch_once_t queueCreationPredicate = 0;
	dispatch_once(&queueCreationPredicate, ^{
		AZObserverMutationQueue = dispatch_queue_create("com.github.mralexgray.observerMutationQueue", 0);
	});
	return AZObserverMutationQueue;
}

@implementation NSObject (AZBlockObservation)

- (NSA *)addObserverForKeyPaths:(NSA *)keyPaths task:(AZBlockTask)task {
	return [keyPaths map:^id (id obj) { return [self addObserverForKeyPath:obj onQueue:nil task:task];       }];
}

- (AZBlockToken *)addObserverForKeyPath:(NSS *)keyPath task:(AZBlockTask)task {
	return [self addObserverForKeyPath:keyPath onQueue:nil task:task];
}

- (AZBlockToken *)addObserverForKeyPath:(NSS *)keyPath onQueue:(NSOQ *)queue task:(AZBlockTask)task {
	AZBlockToken *token = [NSProcessInfo.processInfo globallyUniqueString];
	dispatch_sync(AZObserverMutationQueueCreatingIfNecessary(), ^{
		NSMutableDictionary *dict = objc_getAssociatedObject(self, (__bridge const void *)(AZObserverMapKey));
		if (!dict) {
			dict = NSMD.new;
			objc_setAssociatedObject(self, (__bridge const void *)(AZObserverMapKey), dict, OBJC_ASSOCIATION_RETAIN);
			//			[dict release];
		}
		AZObserverTrampoline *trampoline = [AZObserverTrampoline.alloc initObservingObject:self keyPath:keyPath onQueue:queue task:task];
		dict[token] = trampoline;
		//		[trampoline release];
	});
	return token;
}

- (void)removeObserverWithBlockToken:(AZBlockToken *)token {
	dispatch_sync(AZObserverMutationQueueCreatingIfNecessary(), ^{
		NSMD *observationDictionary = objc_getAssociatedObject(self, (__bridge const void *)(AZObserverMapKey));
		AZObserverTrampoline *trampoline = observationDictionary[token];
		if (!trampoline) {
			NSLog(@"[NSObject(AZBlockObservation) removeObserverWithBlockToken]: Ignoring attempt to remove non-existent observer on %@ for token %@.", self, token);
			return;
		}
		[trampoline cancelObservation];
		[observationDictionary removeObjectForKey:token];
		// Due to a bug in the obj-c runtime, this dictionary does not get cleaned up on release when running without GC.
		if ([observationDictionary count] == 0) objc_setAssociatedObject(self, (__bridge const void *)(AZObserverMapKey), nil, OBJC_ASSOCIATION_RETAIN);
	});
}

- (void) observeNotificationsUsingBlocks:(NSS*) firstNotificationName, ... {

	azva_list_to_nsarray(firstNotificationName, namesAndBlocks);
	NSA* names = [namesAndBlocks subArrayWithMembersOfKind:NSS.class];
	NSA* justBlocks = [namesAndBlocks arrayByRemovingObjectsFromArray:names];
	[names eachWithIndex:^(id obj, NSInteger idx) {
		[self observeName:obj usingBlock:^(NSNotification *n) {	
			((void(^)(void))justBlocks[idx])();	
		}];	
	}];
}

@end

#import "AtoZUmbrella.h"
#import "AtoZFunctions.h"

@interface AZValueTransformer ()
@property (nonatomic, copy) id (^transformBlock)(id value);
@end


@implementation AZValueTransformer
+ (BOOL)allowsReverseTransformation {	return NO;}
- (id)transformedValue:(id)value {    return self.transformBlock(value);}
@synthesize transformBlock;
+ (instancetype)transformerWithBlock:(id (^)(id value))block {
	NSParameterAssert(block != NULL);
	AZValueTransformer *transformer = [self.alloc init];
	transformer.transformBlock = block;
	return transformer;
}

@end

//static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation NSObject (AtoZ)
 
 
-(void) propagateValue:(id)value forBinding:(NSString*)binding;
{
	NSParameterAssert(binding != nil);

	//WARNING: bindingInfo contains NSNull, so it must be accounted for
	NSDictionary* bindingInfo = [self infoForBinding:binding];
	if(!bindingInfo)
		return; //there is no binding

	//apply the value transformer, if one has been set
	NSDictionary* bindingOptions = [bindingInfo objectForKey:NSOptionsKey];
	if(bindingOptions){
		NSValueTransformer* transformer = [bindingOptions valueForKey:NSValueTransformerBindingOption];
		if(!transformer || (id)transformer == [NSNull null]){
			NSString* transformerName = [bindingOptions valueForKey:NSValueTransformerNameBindingOption];
			if(transformerName && (id)transformerName != [NSNull null]){
				transformer = [NSValueTransformer valueTransformerForName:transformerName];
			}
		}

		if(transformer && (id)transformer != [NSNull null]){
			if([[transformer class] allowsReverseTransformation]){
				value = [transformer reverseTransformedValue:value];
			} else {
				NSLog(@"WARNING: binding \"%@\" has value transformer, but it doesn't allow reverse transformations in %s", binding, __PRETTY_FUNCTION__);
			}
		}
	}

	id boundObject = [bindingInfo objectForKey:NSObservedObjectKey];
	if(!boundObject || boundObject == [NSNull null]){
		NSLog(@"ERROR: NSObservedObjectKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
		return;
	}

	NSString* boundKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
	if(!boundKeyPath || (id)boundKeyPath == [NSNull null]){
		NSLog(@"ERROR: NSObservedKeyPathKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
		return;
	}

	[boundObject setValue:value forKeyPath:boundKeyPath];
}


- (void)bind:(NSS*)binding toObject:(id)object withKeyPathUsingDefaults:(NSS*)keyPath {
	[self bind:binding toObject:object withKeyPath:keyPath nilValue:nil];
}

- (void)bind:(NSS*)binding toObject:(id)object withKeyPath:(NSS*)keyPath nilValue:(id)nilValue {
	[self bind:binding toObject:object withKeyPath:keyPath options:@{ NSContinuouslyUpdatesValueBindingOption: @(YES), NSNullPlaceholderBindingOption: nilValue}];
}

- (void)bind:(NSS*)binding toObject:(id)object withKeyPath:(NSS*)keyPath transform:(id (^)(id value))transformBlock {
	AZValueTransformer *transformer = [AZValueTransformer transformerWithBlock:transformBlock];
	[self bind:binding toObject:object withKeyPath:keyPath options:@{NSContinuouslyUpdatesValueBindingOption:@(YES), NSValueTransformerBindingOption:transformer}];
}

- (void)bind:(NSString *)binding toObject:(id)object withNegatedKeyPath:(NSString *)keyPath {
	[self bind:binding toObject:object withKeyPath:keyPath options:@{NSContinuouslyUpdatesValueBindingOption: @(YES), NSValueTransformerNameBindingOption : NSNegateBooleanTransformerName}];
}



- (void)performBlock:(void (^)())block
{
    block();
}

//- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
//{
//    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
//    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
//}

//+ (void) load { [$ swizzleMethod:@selector(description) with:@selector(swizzleDescription) in:self.class]; }

- (NSS*)swizzleDescription {

	return [self swizzleDescription];
//	return [self ISKINDA:NSC.class] ? ^{			NSS* colorname]	}() : nil;
}
- (NSS*) xmlRepresentation {
	return [NSS stringWithData:[AZXMLWriter dataWithPropertyList:self] encoding:NSUTF8StringEncoding];
}

- (BOOL)saveAs:(NSS*)file { return [self writeToFile:file atomically:YES]; }

- (NSURL *)urlified {
	NSURL *theURL;
	if ([self isKindOfClass:NSS.class]) {
		NSS *selfcp = [(NSS *)self startsWith : @"http://"] ? self.copy
		: $(@"http://%@", self);
		theURL = $URL(selfcp);
	}
	if ([self isKindOfClass:NSURL.class]) theURL = areSame([(NSURL *)self scheme], @"http") ? (NSURL *)self : [NSURL URLWithFormat:@"http://%@", self];
	return theURL;
}

// adapted from the CocoaDev MethodSwizzling page
/*
 + (BOOL) exchangeInstanceMethod:(SEL)sel1 withMethod:(SEL)sel2
 {
 Class myClass = [self class];
 Method method1 = NULL, method2 = NULL;

 // First, look for the methods
 method1 = class_getInstanceMethod(myClass, sel1);
 method2 = class_getInstanceMethod(myClass, sel2);
 // If both are found, swizzle them
 if ((method1 != NULL) && (method2 != NULL)) {
 method_exchangeImplementations(method1, method2);
 return true;
 }
 else {
 if (method1 == NULL) NSLog(@"swap failed: can't find %s", sel_getName(sel1));
 if (method2 == NULL) NSLog(@"swap failed: can't find %s", sel_getName(sel2));
 return false;
 }

 return YES;
 }

 + (BOOL) exchangeClassMethod:(SEL)sel1 withMethod:(SEL)sel2
 {
 Class myClass = [self class];
 Method method1 = NULL, method2 = NULL;

 // First, look for the methods
 method1 = class_getClassMethod(myClass, sel1);
 method2 = class_getClassMethod(myClass, sel2);

 // If both are found, swizzle them
 if ((method1 != NULL) && (method2 != NULL)) {
 method_exchangeImplementations(method1, method2);
 return true;
 }
 else {
 if (method1 == NULL) NSLog(@"swap failed: can't find %s", sel_getName(sel1));
 if (method2 == NULL) NSLog(@"swap failed: can't find %s", sel_getName(sel2));
 return false;
 }

 return YES;
 }



 -(void) propagateValue:(id)value forBinding:(NSString*)binding;
 {
 NSParameterAssert(binding != nil);

 //WARNING: bindingInfo contains NSNull, so it must be accounted for
 NSDictionary* bindingInfo = [self infoForBinding:binding];
 if(!bindingInfo)
 return; //there is no binding

 //apply the value transformer, if one has been set
 NSDictionary* bindingOptions = [bindingInfo objectForKey:NSOptionsKey];
 if(bindingOptions){
 NSValueTransformer* transformer = [bindingOptions valueForKey:NSValueTransformerBindingOption];
 if(!transformer || (id)transformer == [NSNull null]){
 NSString* transformerName = [bindingOptions valueForKey:NSValueTransformerNameBindingOption];
 if(transformerName && (id)transformerName != [NSNull null]){
 transformer = [NSValueTransformer valueTransformerForName:transformerName];
 }
 }

 if(transformer && (id)transformer != [NSNull null]){
 if([[transformer class] allowsReverseTransformation]){
 value = [transformer reverseTransformedValue:value];
 } else {
 NSLog(@"WARNING: binding \"%@\" has value transformer, but it doesn't allow reverse transformations in %s", binding, __PRETTY_FUNCTION__);
 }
 }
 }

 id boundObject = [bindingInfo objectForKey:NSObservedObjectKey];
 if(!boundObject || boundObject == [NSNull null]){
 NSLog(@"ERROR: NSObservedObjectKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
 return;
 }

 NSString* boundKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
 if(!boundKeyPath || (id)boundKeyPath == [NSNull null]){
 NSLog(@"ERROR: NSObservedKeyPathKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
 return;
 }

 [boundObject setValue:value forKeyPath:boundKeyPath];
 }
 */

- (void)DDLogError   {
	DDLogError(@"%@", self);
}                                                               // Red

- (void)DDLogWarn       {
	DDLogWarn(@"%@", self);
}                                                               // Orange

- (void)DDLogInfo               {
	DDLogInfo(@"%@", self);
}                                                               // Default (black)

- (void)DDLogVerbose {
	DDLogVerbose(@"%@", self);
}                                                               // Default (black)




- (void)bindArrayKeyPath:(NSS *)array toController:(NSArrayController *)controller {
	[self bind:array toObject:controller withKeyPath:@"arrangedObjects" options:nil];
}

- (id)performString:(NSS *)string;
{
	return [self performSelectorWithoutWarnings:NSSelectorFromString(string) withObject:nil];
}

- (id)performString:(NSS *)string withObject:(id)obj;
{
	return [self performSelectorWithoutWarnings:NSSelectorFromString(string) withObject:obj];
}

/*
 + (NSA*) instanceMethods
 {
 NSMA *array = NSMA.new;
 unsigned int method_count;
 Method *method_list = class_copyMethodList([self class], &method_count);
 int i;
 for (i = 0; i < method_count; i++) {
 //		[array addObject: ]
 //		[array addObject:[NuMethod.alloc initWithMethod:method_list[i]]];// autorelease]];
 }
 free(method_list);
 [array sortUsingSelector:@selector(compare:)];
 return array;
 }
 */
- (NSA *)instanceMethodNames {
	Class clazz             = [self class];         u_int count;
	Method *methods         = class_copyMethodList(clazz, &count);

	NSA*ns = [[@0 to : @(count - 1)] nmap:^id (id obj, NSUI index) {
		return $UTF8(sel_getName(method_getName(methods [(u_int)index]) ));
	}];
	return [ns cw_mapArray:^id(id object) {return [object containsAnyOf:@[@"cxx_destruct", @"init", @"dealloc"]] ? nil : object;}];
	//	free(	methods );
	//	return  methodArray;
}

- (NSS *)instanceMethodsInColumns {
	return [[self instanceMethodNames]formatAsListWithPadding:30];
}

/*! Get an array containing the names of the instance methods of a class. */
//- (NSA*) instanceMethodNames
//{
//	NSA* methods = [self instanceMethodArray];
//	return [methods mapSelector:@selector(name)];
//}

/**

 -(void) propagateValue: (id)value forBinding: (NSS*)binding;
 {
 NSParameterAssert(binding != nil);
 //WARNING: bindingInfo contains NSNull, so it must be accounted for
 NSDictionary* bindingInfo = [self infoForBinding:binding];
 if(!bindingInfo) return; //there is no binding
 //apply the value transformer, if one has been set
 NSDictionary* bindingOptions = [bindingInfo objectForKey:NSOptionsKey];
 if(bindingOptions){
 NSValueTransformer* transformer = [bindingOptions valueForKey:NSValueTransformerBindingOption];
 if(!transformer || (id)transformer == [NSNull null]){
 NSS* transformerName = [bindingOptions valueForKey:NSValueTransformerNameBindingOption];
 if(transformerName && (id)transformerName != [NSNull null]){
 transformer = [NSValueTransformer valueTransformerForName:transformerName];
 }
 }

 if(transformer && (id)transformer != [NSNull null]){
 if([[transformer class] allowsReverseTransformation]){
 value = [transformer reverseTransformedValue:value];
 } else {
 NSLog(@"WARNING: binding \"%@\" has value transformer, but it doesn't allow reverse transformations in %s", binding, __PRETTY_FUNCTION__);
 }}}
 id boundObject = [bindingInfo objectForKey:NSObservedObjectKey];
 if(!boundObject || boundObject == [NSNull null]){
 NSLog(@"ERROR: NSObservedObjectKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
 return;
 }
 NSS* boundKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
 if(!boundKeyPath || (id)boundKeyPath == [NSNull null]){
 NSLog(@"ERROR: NSObservedKeyPathKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
 return;
 }
 [boundObject setValue:value forKeyPath:boundKeyPath];
 }
 */
//- (NSA*) settableKeys
//{
//	return [[[self class] uncodableKeys] filter:^BOOL(id object) {
//		return [self canSetValueForKey:object];
//	}];
//}

//- (NSA*) keysWorthReading
//{
//	return [self.settableKeys filter:^BOOL(id object) {
//		return [self hasPropertyNamed:object];
//	}];
//}

//-(void) setWithDictionary: (NSD*)dic;
//{
//
//	NSCoder *aDecoder = NSCoder.new;
////	for (NSS *key in [dic codableKeys]) {
//	[[self settableKeys] do:^(NSS *key) {		[self setValue:[aDecoder decodeObjectForKey:key] forKey:key]; }];
//	//	[[dic allKeys] each:^(id obj) {
//	//		NSS *j = $(@"set%@:", [obj capitalizedString]);
//	//		if ([self respondsToString:j] )
//	//			[self performSelectorWithoutWarnings:NSSelectorFromString(j) withObject:[dic[obj]copy]];
//	//	}];
//}
+ (void)switchOn:(id<NSObject>)obj cases:casesList, ...
{
	va_list list;   va_start(list, casesList);      id<NSObject> o = casesList;
	for (;; ) {
		if (o) {
			caseBlock block = va_arg(list, caseBlock); [obj isEqual:o] ? block() : nil; break;
		}
		o = va_arg(list, id<NSObject>);
	}
	va_end(list);
}

+ (void)switchOn:(id<NSObject>)obj defaultBlock:(caseBlock)defaultBlock cases:casesList, ...
{
	va_list list;   va_start(list, casesList);              id<NSObject> o = casesList;             __block BOOL match = NO;
	for (;; ) {
		if (o) {
			caseBlock block = va_arg(list, caseBlock); [obj isEqual:o] ? ^{ block(); match = YES; } () : nil; break;
		}
		o = va_arg(list, id<NSObject>);
	}
	if (defaultBlock && !match) defaultBlock();
	va_end(list);
}


- (id)objectForKeyedSubscript:(id)key {
	return [self hasPropertyForKVCKey:key] ? [self valueForKey:key] : nil;         // [super objectForKeyedSubscript:key];
	//	NSArray *syms = [NSThread  callStackSymbols];
	//	if ([syms count] > 1) {
	//		NSLog(@"<%@ %p> %@ - caller: %@ ", [self class], self, NSStringFromSelector(_cmd),[syms objectAtIndex:1]);
	//	} else {
	//		NSLog(@"<%@ %p> %@", [self class], self, NSStringFromSelector(_cmd));
	//	}
	//	if (areSame(key, @"path")) NSLog(@"warning, path subscrip[t being set");
	//	NSLog(@"CMD: %@ requesting subscript:%@", [NSS stringWithUTF8String:__func__], key);

	/**	id result = nil;
	 //	if ([key isKindOfClass:[NSS class]])
	 result = [self respondsToString:key] ? [self valueForKey:key] : nil;
	 if (!result)
	 result = [self respondsToSelector:@selector(valueForKeyPath:)] ? [self valueForKeyPath:key] : nil;
	 if (!result)
	 result = [self respondsToSelector:@selector(objectForKey:)] ? [(id)self objectForKey:key] : nil;
	 if (!result)
	 result = [self respondsToSelector:@selector(objectForKeyPath:)] ? [(id)self objectForKeyPath:key] : nil;
	 if (!result)
	 result = [self respondsToSelector:@selector(valueForKey:)] ? [self valueForKey:key] : nil;
	 if (!result) result = [self valueForKey:key];
	 if (!result) NSLog(@"Cannot coerce value from: %@ for keyedSubstring: %@", self.propertiesPlease, key);
	 return result; */
}

- (BOOL)isKindOfAnyClass:(NSA *)classes;
{
	return [classes filterOne:^BOOL (Class object) {
		return [self isKindOfClass:object];
	}];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
	if (!obj || !key) return;
	if (![self canSetValueForKey:(NSS*)key]) return;
	if (areSame(obj, [self valueForKey:(id)key])) {
		LOGWARN(@"%@", @"Theyre already the same, doing nothing!"); return;
	}
	__block BOOL wasSet = NO;
	[self canSetValueForKey:(id)key] ? ^{
		//			NSLog(@"Setting Value: %@ forKey:%@", obj, key);
		[self setValue:obj forKey:(id)key];
		wasSet = [self[key] isEqualTo:obj];
		//			NSLog(@"New val: %@.", self[key]);
	} () : NSLog(@"Cannot set object:%@ for key:\"%@\" via subscript... \"%@\" does not respond. Current val:%@.", obj, key, self, self[key]);
	[self canSetValueForKeyPath:(NSS *)key] ? ^{
		NSLog(@"Setting Value: %@ forKeyPath:%@", obj, key);
		[self setValue:obj forKeyPath:(NSS *)key];
		//			NSLog(@"New val: %@.", self[key]);
		wasSet = [[self valueForKeyPath:(NSS *)key]isEqualTo:obj];
	} () : ^{  NSLog(@"Cannot set object:%@ for (dot)keypath:\"%@\" via subscript... \"%@\" does not respond. Current val:%@.", obj, key, self, self[key]); } ();
	//	}() :
	//	}();
	wasSet ? : NSLog(@"subscrpipt key:%@ NOT set, despite edfforts", key);
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
	//	block = [[block copy] autorelease];
	[self performSelector:@selector(fireBlockAfterDelay:) withObject:block afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block {
	block();
}

- (NSMD *)getDictionary {
	if (objc_getAssociatedObject(self, @"dictionary") == nil) objc_setAssociatedObject(self, @"dictionary", NSMD.new, OBJC_ASSOCIATION_RETAIN);
	return (NSMD *)objc_getAssociatedObject(self, @"dictionary");
}

+ (NSMA *)newInstances:(NSUI)count;
{
	return [[@0 to : @(count)] map:^id (id obj) {     return [self.class respondsToSelector:@selector(new)] ? self.new :[self.alloc init]; }].mutableCopy;
}

static char windowPosition;

- (void)setWindowPosition:(AZWindowPosition)pos {
	objc_setAssociatedObject(self, &windowPosition, @(pos), OBJC_ASSOCIATION_RETAIN);
}

- (AZWindowPosition)windowPosition {
	return [objc_getAssociatedObject(self, &windowPosition) integerValue];
}

//  Finds all properties of an object, and prints each one out as part of a string describing the class.
- (NSS *)autoDescribeWithClassType:(Class)classType {
	unsigned int count;
	objc_property_t *propList       = class_copyPropertyList(classType, &count);
	NSMS *propPrint         = NSMS.new;
	for (int i = 0; i < count; i++) {
		objc_property_t prop    = propList[i];
		const char *propName    = property_getName(prop);
		NSS *propNameStr    = @(propName);
		if (propName) {
			id value = [self valueForKey:propNameStr];
			[propPrint appendString:[NSS stringWithFormat:@"%@=%@ ; ", propNameStr, value]];
		}
	}
	free(propList);
	// Now see if we need to map any superclasses as well.
	Class superClass = class_getSuperclass(classType);
	if (superClass != nil && ![superClass isEqual:[NSObject class]]) {
		NSS *superString = [self autoDescribeWithClassType:superClass];
		[propPrint appendString:superString];
	}
	return propPrint;
}

+ (NSS *)autoDescribe {
	return $(@"%@:%p::%@", self.class, self, [self autoDescribeWithClassType:[self class]]);
}

- (NSS *)autoDescribe {
	Class clazz     = self.class;
	u_int count;
	Ivar *ivars     = class_copyIvarList(clazz, &count);
	NSMA *ivarArray = NSMA.new;
	for (int i = 0; i < count; i++) {
		const char *ivarName = ivar_getName(ivars[i]);
		[ivarArray addObject:[NSS stringWithUTF8String:ivarName]];
	}
	free(ivars);
	objc_property_t *properties = class_copyPropertyList(clazz, &count);
	NSMA *propertyArray = NSMA.new;
	for (int i = 0; i < count; i++) {
		const char *propertyName = property_getName(properties[i]);
		[propertyArray addObject:[NSS stringWithUTF8String:propertyName]];
	}
	free(properties);

	Method *methods = class_copyMethodList(clazz, &count);
	NSMA *methodArray = NSMA.new;
	for (int i = 0; i < count; i++) {
		SEL selector = method_getName(methods[i]);
		const char *methodName = sel_getName(selector);
		[methodArray addObject:[NSS stringWithUTF8String:methodName]];
	}
	free(methods);
	NSLog(@"%@",    @{      @"ivars" : [ivarArray formatAsListWithPadding:30],
			@"properties": [propertyArray formatAsListWithPadding:30],
			@"methods": [methodArray formatAsListWithPadding:30] });
}

@end

@implementation NSObject (SubclassEnumeration)

+ (NSA *)subclasses {
	NSMA *subClasses        = NSMA.new;
	Class *classes        = nil;
	int count           = objc_getClassList(NULL, 0);
	if (count) {
		classes                 = (Class *)malloc(sizeof(Class) * count);
		NSAssert(classes != NULL, @"Memory Allocation Failed in [Content +subclasses].");
		(void)objc_getClassList(classes, count);
	}
	if (classes) {
		for (int i = 0; i < count; i++) {
			Class myClass           = classes[i];
			Class superClass                = class_getSuperclass(myClass);
			if (superClass == self) [subClasses addObject:myClass];
		}
		free(classes);
	}
	return subClasses;
}

@end


//@interface NSString (VARARGLOGGING)
////- (void) log:(id) firstObject, ...;
//- (void) log:...;
//@end

@implementation NSString (VARARGLOGGING)


- (NSS *)formatWithArguments:(NSA *)arr {
	return [self.class evaluatePseudoFormat:self withArguments:arr];
}

+ (NSS *)evaluatePseudoFormat:(NSS *)fmt withArguments:(NSA *)arr {
	NSS *replacement;
	NSRNG varRange, scanRange;
	NSMS *evaluatedString          = fmt.mutableCopy;
	int length                                              = fmt.length;
	scanRange                                               = NSMakeRange(0, length);
	int index                                               = arr.count;

	while ( (varRange = [fmt rangeOfString:@"%@"  options:NSBackwardsSearch range:scanRange]).length > 0 && index >= 0) {
		replacement = arr[--index ];
		[evaluatedString replaceCharactersInRange:varRange withString:replacement];
		length = varRange.location;                                     scanRange = NSMakeRange(0, length);
	}
	return evaluatedString;
}

//void LOGWARN(NSString *format,...) {

- (void)log:(id)firstObject, ...{
	azva_list_to_nsarray(firstObject, things);

	[[self formatWithArguments:things] log];


	//	va_list argList; va_start (argList, self);
	//	NSS *mess       = [NSS stringWithFormat:self arguments:argList];
	//	va_end(argList);
	//	[mess log];
}
//	va_list     argList;		va_start    (argList, firstObject);
//
//	id eachObject;
//	va_list argumentList;
//	if (firstObject) // The first argument isn't part of the varargs list,
//	{
//		[self addObject: firstObject];// so we'll handle it separately.
//		va_start(argumentList, firstObject); // Start scanning for arguments after firstObject.
//		while (eachObject = va_arg(argumentList, id)) // As many times as we can get an argument of type "id"
//		{
//			[self addObject: eachObject]; // that isn't nil, add it to self's contents.
//		}
//		va_end(argumentList);
//
//	}

@end

//@interface  NSString (ObjCTypes)
//- (const char*) objCType;
//@end

@implementation NSObject (AG)

+ (NSS*)stringFromType:(const char*)type {

	return 	SameChar(type,"c") ? @"char" :
				SameChar(type,"i") ? @"int"  :
				SameChar(type,"s") ? @"short"  :
				SameChar(type,"l") ? @"long" :  // A long	l is treated as a 32-bit quantity on 64-bit programs.
				SameChar(type,"q") ? @"long long"  :
				SameChar(type,"C") ? @"unsigned char"  :
				SameChar(type,"I") ? @"unsigned int"  :
				SameChar(type,"S") ? @"unsigned short"  :
				SameChar(type,"l") ? @"unsigned long"  :
				SameChar(type,"Q") ? @"unsigned long long"  :
				SameChar(type,"f") ? @"float"  :
				SameChar(type,"d") ? @"double"  :
				SameChar(type,"B") ? @"C++ bool or a C99 _Bool"  :
				SameChar(type,"v") ? @"void"  :
				SameChar(type,"*") ? @"char *"  :
				SameChar(type,"@") ? @"An object (whether statically typed or typed id)" :
				SameChar(type,"#") ? @"A class object (Class)" :
				SameChar(type,":") ? @"SEL" :
				SameChar(type, "?") ? @"An unknown type (among other things, this code is used for function pointers)" :
				[$UTF8(type) startsWith:@"["] ? @"[An array type]" :
				[$UTF8(type) startsWith:@"{"] ? @"{A structure type}" :
				[$UTF8(type) startsWith:@"("]	? @"(A untion name=type...)" :
				[$UTF8(type) startsWith:@"b"]	? $(@"A bit field of %ld bits",[[$UTF8(type) stringByDeletingPrefix:@"b"] integerValue]) :
				[$UTF8(type) startsWith:@"^"]	? $(@"A pointer to type %@", [NSO stringFromType:[$UTF8(type) stringByDeletingPrefix:@"^"].UTF8String]) : nil ;
}

- (void*) performSelector:(SEL)selector withValue:(void*)value andValue:(void*)value2 {

	NSInvocation *invocation = [self invocationWithSelector:selector];
	[invocation setArgument:value atIndex:2];
	[invocation setArgument:value2 atIndex:3];
	[invocation invoke];
	NSUI length = [invocation.methodSignature methodReturnLength];
	// If method is non-void:
	return !(length > 0) ? NULL : ^{			void *buffer = (void *)malloc(length);		[invocation getReturnValue:buffer];		return buffer;		}();
}
- (void*) performSelector:(SEL)selector withValue:(void*)value {

	NSInvocation *invocation = [self invocationWithSelector:selector];
	[invocation setArgument:value atIndex:2];
	[invocation invoke];
	NSUI length = [invocation.methodSignature methodReturnLength];
	// If method is non-void:
	return !(length > 0) ? NULL : ^{			void *buffer = (void *)malloc(length);		[invocation getReturnValue:buffer];		return buffer;		}();
}
- (NSInvocation*) invocationWithSelector:(SEL) select {

	NSMethodSignature *signature	= [self methodSignatureForSelector:select];
	NSInvocation *invocation		= [NSInvocation invocationWithMethodSignature:signature];
	[invocation setTarget:self];
	[invocation setSelector:select];
	return invocation;
}
- (NSVAL*) invokeSelector:(SEL)selector, ... {			NSInvocation *invocation	= [self invocationWithSelector:selector];

	va_list args;	va_start(args, selector);	NSUI arg_count = invocation.methodSignature.numberOfArguments;
	for( NSInteger i = 0; i < arg_count - 2; i++ ) {
		id arg = va_arg(args, id);
		if (arg == nil || arg == AZNULL) { NSLog(@"Nil arg at spot # %ld of %ld",i+1, arg_count-1);  return nil; }
		if( [arg ISKINDA:NSVAL.class] ) {
			const char *type = [arg objCType];
			const char *expected = [invocation.methodSignature getArgumentTypeAtIndex:i+2];
			BOOL matchesSignature = SameChar(type, expected);
			if (!matchesSignature) {  NSLog(@"Mismatched signature at method argument %i.  Expected %@  got %@", i, [NSO stringFromType:expected], [NSO stringFromType:type]);
				return;
			}
			NSUI arg_size;		NSGetSizeAndAlignment(type , &arg_size, NULL);
			void * arg_buffer = malloc(arg_size);
			[arg getValue:arg_buffer];
			[invocation setArgument:arg_buffer atIndex: 2 + i ];
			free(arg_buffer);
		}	else 	[invocation setArgument:&arg atIndex: 2 + i];
	}
	va_end(args);
	[invocation invoke];
	NSValue    * ret_val  = nil;
	NSUInteger   ret_size = [invocation.methodSignature methodReturnLength];
	if(  ret_size > 0 ) {
		void * ret_buffer = malloc( ret_size );
		[invocation getReturnValue:ret_buffer];
		ret_val = [NSVAL valueWithBytes:ret_buffer objCType:[invocation.methodSignature methodReturnType]];
		free(ret_buffer);
	}
	return ret_val;
}
/*
- (NSValue*) invoke:(SEL)selector withArgs:(NSA*)args {
//	 get set up to use a variadic argument list
//	va_list args;
//	va_start(args, target);
// Do the standard NSInvocation setup
	NSMethodSignature * signature	= [self methodSignatureForSelector:selector];
	NSInvocation * invocation	= [NSInvocation invocationWithMethodSignature:signature];
	[invocation setTarget:    self];
	[invocation setSelector:selector];

//	Now then, here starts the fun part,	 get a count of how many arguments to expect, information	 which is encapsulated by the method signature.

	NSUInteger arg_count = args.count;
	for( NSInteger i = 0; i < arg_count - 2; i++ ) {
	//	 get an id value from the argument list.
		id arg = args[i];
		//	 if it is an NSValue, or subclass thereof, we have some extra
		 work to do before we can pass it on to the invocation
		if( [arg ISKINDA:NSVAL.class] ) {
			NSUInteger arg_size;
			//			 NSGetSizeAndAlignment will give us a size in bytes based on the type information that the runtime has stored, which is accessed (in NSValue's case) by calling	 [NSValue objCtype], 4 for an it, 1 for a char and so on.
			NSGetSizeAndAlignment([arg objCType], &arg_size, NULL);
			//			 We can't (AFAIK) directly access NSValue's bytes,	 so we'll need a temporary buffer to read the value into.	 It's possible that we could simply use a large buffer and rely on NSInvocation to know how much to copy, thus obviating	 the need for multiple malloc()s, but I haven't tested that yet
			void * arg_buffer = malloc(arg_size);
			[arg getValue:arg_buffer];			// copy the value, obvs
			//	 Now we pass the buffer to NSInvocation, which copies it. NB that we start at index 2, because index 0 and 1 are	 the id and SEL of the targeted  method
			[invocation setArgument:arg_buffer atIndex: 2 + i ];
			free(arg_buffer);
		}
		else if( [arg ISKINDA:NSN.class] ) {
			NSUInteger arg_size;
			//			 NSGetSizeAndAlignment will give us a size in bytes based on the type information that the runtime has stored, which is accessed (in NSValue's case) by calling	 [NSValue objCtype], 4 for an it, 1 for a char and so on.
			NSGetSizeAndAlignment([(NSN*)arg type], &arg_size, NULL);
			//			 We can't (AFAIK) directly access NSValue's bytes,	 so we'll need a temporary buffer to read the value into.	 It's possible that we could simply use a large buffer and rely on NSInvocation to know how much to copy, thus obviating	 the need for multiple malloc()s, but I haven't tested that yet
			void * arg_buffer = malloc(arg_size);
			[arg getValue:arg_buffer];			// copy the value, obvs
			// Now we pass the buffer to NSInvocation, which copies it. NB that we start at index 2, because index 0 and 1 are	 the id and SEL of the targeted  method
			[invocation setArgument:arg_buffer atIndex: 2 + i ];
			free(arg_buffer);
		}

		else {

			//		 If we have a non NSValue argument, just copy it
			[invocation setArgument:&arg atIndex: 2 + i];
		}
	}

	//	 indicate that we are done with the variadic argument list va_end(args);
	//	 do the bidniss
	[invocation invoke];
	//	 Of course now, we have to get the value back out.	 There are a couple f ways to do thsi, let's stick
	 with NSValue, since we're on such close terms.
	NSValue    * ret_val  = nil;
	NSUInteger   ret_size = [signature methodReturnLength];
	if(  ret_size > 0 ) {
		void * ret_buffer = malloc( ret_size );
		[invocation getReturnValue:ret_buffer];
		ret_val = [NSValue valueWithBytes:ret_buffer
										 objCType:[signature methodReturnType]];
		free(ret_buffer);
	}
	return ret_val;
}
*/

- (void*)performSelector:(SEL)aSelector withValues:(void *)context, ...{

	// Since we were not given any context arguments, just do a non-blocking invocation on a background thread.	We really would want to check to see that the selector is valid, takes no arguments, etc., but that is left as an exercise for the reader.
	// We'll need an NSInvocation, since it lets us define arguments for multiple parameters.

	NSMethodSignature *theSignature = [self methodSignatureForSelector:aSelector];
	NSInvocation *theInvocation = [NSInvocation invocationWithMethodSignature:theSignature];
	[theInvocation retainArguments];
	// Now for the real automagic fun!  We will loop through our arugment list,
	// and match up each parameter with the corresponding index value.
	// Since Objective-C actually converts messages into C methods:
	NSUI argumentCount = [theSignature numberOfArguments] - 2;
	[theInvocation setTarget:self];         // There's our index 0.
	[theInvocation setSelector:aSelector];  // There's our index 1.

	// Use the va_* macros to retrieve the arguments.
	va_list arguments;
	// Tell it where the optional args start.	Since the first parameter, the selector isn't optional, tell it to start with 'context'.
	va_start (arguments, context);
	// Now for arguments 2+
	NSUInteger i, count = argumentCount;

	void* currentValue = context;
	for (i = 0; i < count; i++)	{	// If we run out of arguments, then we pass nil to the remaining parameters.
//	char*s = @encode(typeof(&currentValue));
//	const char *fmt = $(@"\"%%%s\"", s).UTF8String;
//	printf(fmt, &currentValue);

		[theInvocation setArgument:&currentValue atIndex:(i + 2)]; // The +2 represents self and cmd offsets
		currentValue = va_arg(arguments, void*); // Read the next argument in the list.
	// We should also handle the case where we have *more* arguments than parameters.  This will let us cover cases where we are invoking other variadic methods (like arrayWithObjects:).
	}
	va_end (arguments); 	// Dispose of our C byte-array.

	[theInvocation invoke];

	NSUI length = [theInvocation.methodSignature methodReturnLength];
	// If method is non-void:
	return !(length > 0) ? NULL : ^{			void *buffer = (void *)malloc(length);		[theInvocation getReturnValue:buffer];		return buffer;		}();

	/// That's it! (For configuring our NSInvocation).  In this example, we are going to invoke all methods on a custom worker thread.

//	NSThread *customWorkerThread = [EBCustomThread sharedCustomThread];
//	/// Invoke on our custom worker thread.
//	[theInvocation performSelector:@selector(invoke) onThread:customWorkerThread withObject:nil waitUntilDone:NO];
// Our NSInvocation is already autoreleased, so we're done.
 
}

- (void)log {
	[self logInColor:RANDOMCOLOR];
}

- (void)logInColor:(NSC *)color {
	LOGCOLORS(color,$(@"%@",self), nil);
}

//- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
//{
//	//inside the method implementation:
//	Method thisMethod = class_getClassMethod([self class], selector);
//	const char * encoding = method_getTypeEncoding(thisMethod);
//	return [NSMethodSignature signatureWithObjCTypes: encoding];
//	NSString *sel = NSStringFromSelector(selector);
//	if ([sel rangeOfString:@"set"].location == 0) {
//		return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
//	} else {
//		return [NSMethodSignature signatureWithObjCTypes:"@@:"];
//	}
//}

//- (void)forwardInvocation:(NSInvocation *)invocation
//{
//	NSString *key = NSStringFromSelector([invocation selector]);
//	if ([key rangeOfString:@"set"].location == 0) {
//		key = [[key substringWithRange:NSMakeRange(3, [key length]-4)] lowercaseString];
//		NSString *obj;
//		[invocation getArgument:&obj atIndex:2];
//		[data setObject:obj forKey:key];
//	} else {
//		NSString *obj = [data objectForKey:key];
//		[invocation setReturnValue:&obj];
//	}
//}


- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 {
	NSMethodSignature *sig = [self methodSignatureForSelector:selector];
	if (sig) {
		NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sig];
		[invo setTarget:self];
		[invo setSelector:selector];
		[invo setArgument:&p1 atIndex:2];
		[invo setArgument:&p2 atIndex:3];
		[invo setArgument:&p3 atIndex:4];
		[invo invoke];
		if (sig.methodReturnLength) {
			id anObject;
			[invo getReturnValue:&anObject];
			return anObject;
		} else return nil;
	} else return nil;
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 withObject:(id)p4 {
	NSMethodSignature *sig = [self methodSignatureForSelector:selector];
	if (sig) {
		NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sig];
		[invo setTarget:self];
		[invo setSelector:selector];
		[invo setArgument:&p1 atIndex:2];
		[invo setArgument:&p2 atIndex:3];
		[invo setArgument:&p3 atIndex:4];
		[invo setArgument:&p4 atIndex:5];
		[invo invoke];
		if (sig.methodReturnLength) {
			id anObject;
			[invo getReturnValue:&anObject];
			return anObject;
		} else return nil;
	} else return nil;
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
           withObject:(id)p4 withObject:(id)p5 {
	NSMethodSignature *sig = [self methodSignatureForSelector:selector];
	if (sig) {
		NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sig];
		[invo setTarget:self];
		[invo setSelector:selector];
		[invo setArgument:&p1 atIndex:2];
		[invo setArgument:&p2 atIndex:3];
		[invo setArgument:&p3 atIndex:4];
		[invo setArgument:&p4 atIndex:5];
		[invo setArgument:&p5 atIndex:6];
		[invo invoke];
		if (sig.methodReturnLength) {
			id anObject;
			[invo getReturnValue:&anObject];
			return anObject;
		} else {
			return nil;
		}
	} else {
		return nil;
	}
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
           withObject:(id)p4 withObject:(id)p5 withObject:(id)p6 {
	NSMethodSignature *sig = [self methodSignatureForSelector:selector];
	if (sig) {
		NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sig];
		[invo setTarget:self];
		[invo setSelector:selector];
		[invo setArgument:&p1 atIndex:2];
		[invo setArgument:&p2 atIndex:3];
		[invo setArgument:&p3 atIndex:4];
		[invo setArgument:&p4 atIndex:5];
		[invo setArgument:&p5 atIndex:6];
		[invo setArgument:&p6 atIndex:7];
		[invo invoke];
		if (sig.methodReturnLength) {
			id anObject;
			[invo getReturnValue:&anObject];
			return anObject;
		} else {
			return nil;
		}
	} else {
		return nil;
	}
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
           withObject:(id)p4 withObject:(id)p5 withObject:(id)p6 withObject:(id)p7 {
	NSMethodSignature *sig = [self methodSignatureForSelector:selector];
	if (sig) {
		NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sig];
		[invo setTarget:self];
		[invo setSelector:selector];
		[invo setArgument:&p1 atIndex:2];
		[invo setArgument:&p2 atIndex:3];
		[invo setArgument:&p3 atIndex:4];
		[invo setArgument:&p4 atIndex:5];
		[invo setArgument:&p5 atIndex:6];
		[invo setArgument:&p6 atIndex:7];
		[invo setArgument:&p7 atIndex:8];
		[invo invoke];
		if (sig.methodReturnLength) {
			id anObject;
			[invo getReturnValue:&anObject];
			return anObject;
		} else return nil;
	} else return nil;
}

//- (IBAction)showMethodsInFrameWork: (id)sender {

//	[NSTask launchedTaskWithLaunchPath:@"/usr/bin/say" arguments:@[s]];

//	BOOL isSelected;	NSS*label;
//	BOOL isSegmented = [sender isKindOfClass:[NSSegmentedControl class]];
//		//	if (isSegmented) {
//	NSI selectedSegment = [sender selectedSegment];
//		//		 = [sender isSelectedForSegment:selectedSegment];
//	label = [sender labelForSegment:selectedSegment];
//	BOOL *optionPtr = &isSelected;
//		//	} else
//		//		label = [sender label];
//	SEL fabricated = NSSelectorFromString($(@"set%@:", label));
//	[[sender delegate] performSelector:fabricated withValue:optionPtr];
//	[[AZTalker sharedInstance] say:$(@"%@ is %@ selected", string, isSelected ? @"" : @"NOT")];
//}

- (NSS *)segmentLabel {
	return [self isKindOfClass:[NSSegmentedControl class]]
	? [(NSSegmentedControl *)self labelForSegment : [(NSSegmentedControl *)self selectedSegment]] : nil;
}

BOOL respondsToString(id obj, NSS *string) {
	return [obj respondsToString:string];
}

BOOL respondsTo(id obj, SEL selector) {
	return [obj respondsToSelector:selector];
}

- (BOOL)respondsToString:(NSS *)string {
	return [self respondsToSelector:NSSelectorFromString(string)];
}

- (id)respondsToStringThenDo:(NSS *)string {
	return [self respondsToStringThenDo:string.copy withObject:nil withObject:nil];
}

- (id)respondsToStringThenDo:(NSS *)string withObject:(id)obj {
	return [self respondsToStringThenDo:string.copy withObject:obj withObject:nil];
}

- (id)respondsToStringThenDo:(NSS *)string withObject:(id)obj withObject:(id)objtwo {
	SEL select = NSSelectorFromString(AH_RETAIN([string copy]));
	BOOL doesit =  [self respondsToSelector:select];
	return doesit && obj && objtwo ? [self performSelectorARC:select withObject:obj withObject:objtwo]
	: doesit && obj ? [self performSelectorARC:select withObject:obj]
	: doesit ? [self cw_ARCPerformSelector:select] : nil;
}

- (IBAction)performActionFromLabel:(id)sender;
{
	NSS *stringSel, *setter;
	if ([sender isKindOfClass:[NSPopUpButton class]]) stringSel = [sender titleOfSelectedItem];
	else if ([sender isKindOfClass:[NSButton class]]) stringSel = [sender title];
	else if ([sender respondsToSelector:@selector(label)]) stringSel = [sender label];
	setter = $(@"set%@:", [stringSel uppercaseString]);
	if ([self respondsToString:stringSel]) [self performSelectorSafely:NSSelectorFromString(stringSel)];
	else if ([self respondsToString:setter]) [self performSelectorWithoutWarnings:NSSelectorFromString(setter) withObject:nil];
}
- (IBAction)performActionFromSegmentLabel:(id)sender;
{
	if ([sender isKindOfClass:NSSegmentedControl.class]) {
		NSS *label = [sender labelForSegment:[sender selectedSegment]];                 //		BOOL *optionPtr = &isSelected;
		if ([self respondsToString:label]) [self performSelector:NSSelectorFromString(label) withValue:nil];
	}
}

- (IBAction)increment:(id)sender;
{
	BOOL isSegmented = [sender isKindOfClass:[NSSegmentedControl class]];
	if (isSegmented) {
		BOOL isSelected;        NSS *label;
		NSI selectedSegment = [sender selectedSegment];
		label = [sender labelForSegment:selectedSegment];
		//		BOOL *optionPtr = &isSelected;

		NSI prop = [self integerForKey:label];
		NSI newVal = (prop + 1);
		[self setValue:[NSVAL value:(const void *)newVal withObjCType:[self typeOfPropertyNamed:label]] forKey:label];
	}
}



- (void)setFromSegmentLabel:(id)sender {
	BOOL isSelected;        NSS *label;
	BOOL isSegmented = [sender isKindOfClass:[NSSegmentedControl class]];
	if (isSegmented) {
		NSI selectedSegment = [sender selectedSegment];
		//		 = [sender isSelectedForSegment:selectedSegment];
		label = [sender labelForSegment:selectedSegment];
		BOOL *optionPtr = &isSelected;

		SEL fabricated = NSSelectorFromString($(@"set%@:", label));
		[[sender delegate] performSelector:fabricated withValue:optionPtr];
	}
	//	[[AZTalker sharedInstance] say:$(@"%@ is %@ selected", string, isSelected ? @"" : @"NOT")];
}

//- (void)performActionFromLabel: (id)sender {
//
//	BOOL isSelected;	NSS*label;
//	BOOL isButton = [sender isKindOfClass:[NSButton class]];
//	NSI buttonState = [sender state];
//	//		 = [sender isSelectedForSegment:selectedSegment];
//	label = [sender label];
//	BOOL *optionPtr = &buttonState;
//	//	} else
//	//		label = [sender label];
//	SEL fabricated = NSSelectorFromString(label);
//	[[sender delegate] performSelector:fabricated withValue:optionPtr];
//	//	[[AZTalker sharedInstance] say:$(@"%@ is %@ selected", string, isSelected ? @"" : @"NOT")];
//}
//- (BOOL) respondsToSelector: (SEL) aSelector {
//	NSLog (@"%s", (char *) aSelector);
//	return ([super respondsToSelector: aSelector]);
//} // respondsToSelector

static const char * getPropertyType(objc_property_t property) {
	const char *attributes = property_getAttributes(property);
	printf("attributes=%s\n", attributes);
	char buffer[1 + strlen(attributes)];
	strcpy(buffer, attributes);
	char *state = buffer, *attribute;
	while ((attribute = strsep(&state, ",")) != NULL) {
		//	If you want a list of what will be returned for these primitives, search online for "objective-c" "Property Attribute Description Examples" apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
		// it's a C primitive type:
		return attribute[0] == 'T' && attribute[1] != '@' ? (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes]
		// it's an ObjC id type:
		: attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2 ? "id"
		// it's another ObjC object type:
		: attribute[0] == 'T' && attribute[1] == '@' ? (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes]
		: "";
	}
}

+ (NSD *)classPropsFor:(Class)klass {
	if (klass == NULL) return nil;
	NSMD *results = [NSMD dictionary];
	unsigned int outCount, i;
	objc_property_t *properties = class_copyPropertyList(klass, &outCount);
	for (i = 0; i < outCount; i++) {
		objc_property_t property = properties[i];
		const char *propName = property_getName(property);
		if (propName) {
			const char *propType = getPropertyType(property);
			NSS *propertyName = @(propName);
			NSS *propertyType = @(propType);
			results[propertyName] = propertyType;
		}
	}
	free(properties);       return results;                 // returning a copy here to make sure the dictionary is immutable
}

/*
 - (NSA*) methodDumpForClass: (Class)klass {

 int numClasses;
 Class *classes = NULL;
 classes = NULL;
 numClasses = objc_getClassList(NULL, 0);
 NSLog(@"Number of classes: %d", numClasses);

 if (numClasses > 0 )
 {
 classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
 numClasses = objc_getClassList(classes, numClasses);
 for (int i = 0; i < numClasses; i++) {
 NSLog(@"Class name: %s", class_getName(classes[i]));
 }
 free(classes);
 }

 int numClasses;
 Class *classes = NULL;

 classes = NULL;
 numClasses = objc_getClassList(NULL, 0);

 if (numClasses &lt; 1 ) { return nil; }
 classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
 numClasses = objc_getClassList(classes, numClasses);

 // Convert to NSArray of NSSs
 NSMA*rtn = [[NSMA alloc] init];
 const char *cname;
 for (int i=0; i&lt;numClasses; i++) {
 cname = class_getName(classes[i]);
 //	  if (NULL == strstr(cname, &quot;MusicalScale&quot;))
 //		  continue;
 [rtn addObject:[NSS stringWithCString:cname
 encoding:NSSEncodingConversionAllowLossy]];
 }
 free(classes);

 //	return rtn;
 return [rtn filteredArrayUsingPredicate:predicate];
 }	*/

- (NSS *)methods {
	return [[[self class] classMethods]formatAsListWithPadding:30];
}

+ (NSA *)classMethods {
	const char *className = class_getName([self class]);
	int unsigned numMethods;
	NSMA *ii = [NSMA array];
	Method *methods = class_copyMethodList(objc_getMetaClass(className), &numMethods);
	for (int i = 0; i < numMethods; i++) {
		[ii addObject:NSStringFromSelector(method_getName(methods[i]))];
		//		NSLog(@"%@", NSStringFromSelector(method_getName(methods[i])));
	}
	return ii.copy;
}

// aps suffix to avoid namespace collsion
//   ...for Andrew Paul Sardone
//- (NSD *)propertiesDictionariate;


- (NSS *)stringFromClass {
	return AZCLSSTR;
}

- (void)setIntValue:(NSI)i forKey:(NSS *)key     {
	[self setValue:[NSNumber numberWithInt:i] forKey:key];
}

- (void)setIntValue:(NSI)i forKeyPath:(NSS *)keyPath {
	[self setValue:[NSNumber numberWithInt:i] forKeyPath:keyPath];
}

- (void)setFloatValue:(CGF)f forKey:(NSS *)key       {
	[self setValue:[NSNumber numberWithFloat:f] forKey:key];
}

- (void)setFloatValue:(CGF)f forKeyPath:(NSS *)keyPath {
	[self setValue:[NSNumber numberWithFloat:f] forKeyPath:keyPath];
}

- (BOOL)isEqualToAnyOf:(id<NSFastEnumeration>)enumerable {
	for (id o in enumerable) {
		if ([self isEqual:o]) return YES;
	}
	return NO;
}

- (void)fire:(NSS *)notificationName {
	[AZNOTCENTER postNotificationName:notificationName object:self];
}

- (void)fire:(NSS *)notificationName userInfo:(NSD *)context  {
	[AZNOTCENTER postNotificationName:notificationName object:self userInfo:context];
}

- (id)observeObject:(NSS *)notificationName usingBlock:(void (^)(NSNOT *))block {
	return [AZNOTCENTER addObserverForName:notificationName object:self queue:nil usingBlock:block];
}

- (id)observeName:(NSS *)notificationName usingBlock:(void (^)(NSNOT *))block {
	return [AZNOTCENTER addObserverForName:notificationName object:self queue:nil usingBlock:block];
}

- (void)observeObject:(NSObject *)object forName:(NSS *)notificationName calling:(SEL)selector {
	[AZNOTCENTER addObserver:self selector:selector name:notificationName object:object];
}

- (void)observeName:(NSS *)notificationName calling:(SEL)selector {
	[AZNOTCENTER addObserver:self selector:selector name:notificationName object:nil];
}

- (void)stopObserving:(NSObject *)object forName:(NSS *)notificationName {
	[AZNOTCENTER removeObserver:self name:notificationName object:object];
}

- (BOOL)canPerformSelector: (SEL)aSelector {

	NSParameterAssert(aSelector != NULL);
	NSParameterAssert([self respondsToSelector:aSelector]);
	NSMethodSignature *methodSig = [self methodSignatureForSelector:aSelector];
	if (methodSig == nil) return NO;
	const char *retType = [methodSig methodReturnType];
	return (strcmp(retType, @encode(id)) == 0 || strcmp(retType, @encode(void)) == 0);
}
- (id)performSelectorSafely:(SEL)aSelector;
{
	NSParameterAssert(aSelector != NULL);
	NSParameterAssert([self respondsToSelector:aSelector]);
	NSMethodSignature *methodSig = [self methodSignatureForSelector:aSelector];
	if (methodSig == nil) return nil;
	const char *retType = [methodSig methodReturnType];
	if (strcmp(retType, @encode(id)) == 0 || strcmp(retType, @encode(void)) == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		return [self performSelector:aSelector];
#pragma clang diagnostic pop
	} else {
		NSLog(@"-[%@ performSelector:@selector(%@)] shouldn't be used. The selector doesn't return an object or void", [self className], NSStringFromSelector(aSelector));
		return nil;
	}
}

- (id)performSelectorARC:(SEL)selector withObject:(id)obj {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	return [self performSelector:selector withObject:obj];
#pragma clang diagnostic pop
}

- (id)performSelectorARC:(SEL)selector withObject:(id)one withObject:(id)two {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	return [self performSelector:selector withObject:one withObject:two];
#pragma clang diagnostic pop
}

- (id)performSelectorWithoutWarnings:(SEL)aSelector {
	return [self performSelectorSafely:aSelector];
}

- (id)performSelectorWithoutWarnings:(SEL)aSelector withObject:(id)obj {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	//	return (id)
	[self performSelector:aSelector withObject:obj];
#pragma clang diagnostic pop
}

- (id)performSelectorWithoutWarnings:(SEL)aSelector withObject:(id)obj withObject:(id)obj2 {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	//	return	(id)
	[self performSelector:aSelector withObject:obj withObject:obj2];
#pragma clang diagnostic pop
}

- (void)performSelector:(SEL)aSelector afterDelay:(NSTimeInterval)seconds {
	[self performSelector:aSelector withObject:nil afterDelay:seconds];
}

- (void)observeKeyPath:(NSS *)keyPath {
	[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSS *)keyPath {
	[self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)addObserver:(NSObject *)observer forKeyPaths:(id<NSFastEnumeration>)keyPaths {
	for (NSS *keyPath in keyPaths) {
		[self addObserver:observer forKeyPath:keyPath];
	}
}

- (void)removeObserver:(NSObject *)observer forKeyPaths:(id<NSFastEnumeration>)keyPaths {
	for (NSS *keyPath in keyPaths) {
		[self removeObserver:observer forKeyPath:keyPath];
	}
}

- (void)willChangeValueForKeys:(id<NSFastEnumeration>)keys {
	for (id key in keys) {
		[self willChangeValueForKey:key];
	}
}

- (void)didChangeValueForKeys:(id<NSFastEnumeration>)keys {
	for (id key in keys) {
		[self didChangeValueForKey:key];
	}
}

- (NSD *)dictionaryWithValuesForKeys {
	return [self dictionaryWithValuesForKeys:[self allKeys]];
}

- (NSA *)allKeys {
	Class clazz = self.class;        u_int count;
	objc_property_t *properties     = class_copyPropertyList(clazz, &count);
	NSMA *propertyArray = [NSMA arrayWithCapacity:count];
	for (int i = 0; i < count; i++) {
		const char *propertyName = property_getName(properties[i]);
		[propertyArray addObject:@(propertyName)];
	}
	free(properties);
	return propertyArray.copy;
}

- (void)setClass:(Class)aClass {
	NSAssert(class_getInstanceSize([self class]) == class_getInstanceSize(aClass), @"Classes must be the same size to swizzle.");
	object_setClass(self, aClass);
}

+ (instancetype)newFromDictionary:(NSD *)dic {
	return [self.class customClassWithProperties:dic];
}

//	In your custom class
+ (instancetype)customClassWithProperties:(NSD *)properties {
	return [self.class.alloc initWithProperties:properties];
}

// autorelease];}


- (instancetype)initWithDictionary:(NSD*)properties {
	return [self initWithProperties:properties];
}

+ (instancetype)instanceWithDictionary:(NSD *)properties; { return [self.class newFromDictionary:properties]; }

- (instancetype)initWithProperties:(NSD *)properties {
	//	if ([self isKindOfClass:[CALayer class]]) {
	//		if ([[properties allKeys]containsObject:@"frame"]){
	//			self[@"frame"] = [properties rectForKey:@"frame"] {
	//			[self setValuesForKeysWithDictionary:[properties dictionaryWithoutKey:@"frame"]];

	if ([properties.allKeys containsObject:@"frame"] && [self isKindOfClass:NSV.class]) {
		if (self = [(NSView *)self initWithFrame :[properties rectForKey:@"frame"]]) {
			[self setValuesForKeysWithDictionary:[properties dictionaryWithoutKey:@"frame"]];
		}
		//	if ([self isKindOfClass:[NSView class]]) if (self = [self init])
	}
	else if (self = [self init]) {
//    if (self != [self.class alloc]) return nil;
//	self  = [self alloc] ?: [self.alloc init];
		[self setValuesForKeysWithDictionary:properties];
	}
	return self;
}

@end
@implementation NSObject (PrimitiveEvocation)

- (void *)performSelector:(SEL)selector withValue:(void *)value {
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
	[invocation setSelector:selector];
	[invocation setTarget:self];
	[invocation setArgument:value atIndex:2];
	[invocation invoke];
	NSUInteger length = [[invocation methodSignature] methodReturnLength];

	if (length > 0) {                       // If method is non-void:
		void *buffer = (void *)malloc(length);
		[invocation getReturnValue:buffer];
		return buffer;
	}
	return NULL;                            // If method is void:
}

@end

@implementation NSD (PropertyMap)

- (void)mapPropertiesToObject:(id)instance {
	
//	NSA* codables = [self allKeys];
//	codables = [[instance class] respondsToSelector:@selector(codableKeys)] ? [instance class].codableKeys : self.allKeys;
//	if ([codables doesNotContainObjects:[self allKeys]]) {
//		NSLog(@"possible error:  not going to set values for keys: %@", [self.allKeys arrayByRemovingObjectsFromArray:codables]);
//	}
	
	[self each:^(NSS *propertyKey, id value) {
		[instance canSetValueForKey:propertyKey] && value ?
		[instance setValue:value forKey:propertyKey] :  ^{
			SEL select = NULL;
			select = [instance setterForPropertyNamed:propertyKey];
			if (select != NULL && [instance respondsToSelector:select])
				[instance performSelectorWithoutWarnings:select withObject:value];
		}();
	}];
}
@end

@implementation NSObject (KVCExtensions)

- (void)setPropertiesWithDictionary:(NSD *)dictionary {
	[dictionary mapPropertiesToObject:self];
}

// Can set value for key follows the Key Value Settings search pattern as defined in the apple documentation
- (BOOL)canSetValueForKey:(NSS *)key {
	NSS *capKey = [key     stringByReplacingCharactersInRange:NSMakeRange(0, 1) // Check for SEL-based setter
																  withString:[[key substringToIndex:1] uppercaseString]];
	if ([self respondsToString:$(@"set%@:", capKey)]) return YES;

	//	If you can access the instance variable directly, check if that exists.
	//	Patterns for instance variable naming:  1. _<key>  2. _is<Key>  3. <key>  4. is<Key>

	if ([[self class] accessInstanceVariablesDirectly]) { // Declare all the patters for the key
		const char *pattern1 = [$(@"_%@",          key) UTF8String];
		const char *pattern2 = [$(@"_is%@", capKey) UTF8String];
		const char *pattern3 = [$(@"%@",           key) UTF8String];
		const char *pattern4 = [$(@"is%@",  capKey) UTF8String];  unsigned int numIvars = 0;

		Ivar *ivarList = class_copyIvarList([self class], &numIvars);
		for (unsigned int i = 0; i < numIvars; i++) {
			const char *name = ivar_getName(*ivarList);
			if (strcmp(name, pattern1) == 0 || strcmp(name, pattern2) == 0 || strcmp(name, pattern3) == 0 || strcmp(name, pattern4) == 0) {
				return YES;
			}
			ivarList++;
		}
	}
	return NO;
}

// Traverse the key path finding you can set the values. Keypath is a set of keys delimited by "."
- (BOOL)canSetValueForKeyPath:(NSS *)keyPath {
	NSRange delimeterRange = [keyPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
	if (delimeterRange.location == NSNotFound) return [self canSetValueForKey:keyPath];
	NSS * first      = [keyPath substringToIndex:delimeterRange.location         ];
	NSS *rest       = [keyPath substringFromIndex:(delimeterRange.location + 1)];
	return [self canSetValueForKey:first] ? [[self valueForKey:first] canSetValueForKeyPath:rest] : NO;
}

@end


@implementation  NSObject (ImageVsColor)

- (NSC *)colorValue {
	if ([self isKindOfClass:NSC.class]) return (NSC *)self;
	NSC * c = [self isKindOfClass:NSIMG.class] ? ((NSIMG *)self).quantize[0] : nil;
	return c ? : [self respondsToString:@"color"] ? [self valueForKey:@"color"] : nil;
}

- (NSIMG *)imageValue;
{
	if ([self isKindOfClass:NSIMG.class]) return (NSIMG *)self;
	NSIMG * i = [self isKindOfClass:NSC.class] ? [NSIMG swatchWithColor:(NSC *)self size:AZSizeFromDimension(256)] : nil;
	return i ? : [self respondsToString:@"image"] ? [self valueForKey:@"image"] : nil;
}

@end

#import <ApplicationServices/ApplicationServices.h>

@implementation NSObject (NoodlePerformWhenIdle)

// Heard somewhere that this prototype may be missing in some cases so adding it here just in case.
CG_EXTERN CFTimeInterval CGEventSourceSecondsSinceLastEventType(CGEventSourceStateID source, CGEventType eventType)  AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;


// Semi-private method. Used by the public methods
- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterSystemIdleTime:(NSTimeInterval)delay withinTimeLimit:(NSTimeInterval)maxTime startTime:(NSTimeInterval)startTime {
	CFTimeInterval idleTime;
	NSTimeInterval timeSinceInitialCall;

	timeSinceInitialCall = [NSDate timeIntervalSinceReferenceDate] - startTime;

	if (maxTime > 0) {
		if (timeSinceInitialCall >= maxTime) {
			[self performSelectorWithoutWarnings:aSelector withObject:anArgument];
			return;
		}
	}

	idleTime = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateHIDSystemState, kCGAnyInputEventType);
	if (idleTime < delay) {
		NSTimeInterval fireTime;
		NSMethodSignature *signature;
		NSInvocation *invocation;

		signature = [self methodSignatureForSelector:@selector(performSelector:withObject:afterSystemIdleTime:withinTimeLimit:startTime:)];
		invocation = [NSInvocation invocationWithMethodSignature:signature];
		[invocation setSelector:@selector(performSelector:withObject:afterSystemIdleTime:withinTimeLimit:startTime:)];
		[invocation setTarget:self];
		[invocation setArgument:&aSelector atIndex:2];
		[invocation setArgument:&anArgument atIndex:3];
		[invocation setArgument:&delay atIndex:4];
		[invocation setArgument:&maxTime atIndex:5];
		[invocation setArgument:&startTime atIndex:6];

		fireTime = delay - idleTime;
		if (maxTime > 0) {
			fireTime = MIN(fireTime, maxTime - timeSinceInitialCall);
		}

		// Not idle for long enough. Set a timer and check back later
		[NSTimer scheduledTimerWithTimeInterval:fireTime invocation:invocation repeats:NO];
	} else {
		[self performSelectorWithoutWarnings:aSelector withObject:anArgument];
	}
}

- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterSystemIdleTime:(NSTimeInterval)delay {
	[self performSelector:aSelector withObject:anArgument afterSystemIdleTime:delay withinTimeLimit:-1];
}

- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterSystemIdleTime:(NSTimeInterval)delay withinTimeLimit:(NSTimeInterval)maxTime {
	SInt32 version;

	// NOTE: Even though CGEventSourceSecondsSinceLastEventType exists on Tiger,
	// it appears to hang on some Tiger systems. For now, only enabling for Leopard or later.
	if ((Gestalt(gestaltSystemVersion, &version) == noErr) && (version >= 0x1050)) {
		NSTimeInterval startTime;

		startTime = [NSDate timeIntervalSinceReferenceDate];

		[self performSelector:aSelector withObject:anArgument afterSystemIdleTime:delay withinTimeLimit:maxTime startTime:startTime];
	} else {
		// For pre-10.5, just call it after a delay. Change this if you want to throw an exception
		// instead.
		[self performSelector:aSelector withObject:anArgument afterDelay:delay];
	}
}

@end


// thanks Landon Fuller
#define VERIFIED_CLASS(className) ((className *) NSClassFromString(@"" # className))


@implementation NSObject (SadunUtilities)

// Return an array of an object's superclasses
- (NSA*)superclasses {
	Class cl = [self class];
	NSMutableArray *results = [NSMutableArray arrayWithObject:cl];

	do {
		cl = [cl superclass];
		[results addObject:cl];
	} while (![cl isEqual:[NSObject class]]);

	return results;
}

// Return an invocation based on a selector and variadic arguments
- (NSInvocation *)invocationWithSelector:(SEL)selector andArguments:(va_list)arguments {
	if (![self respondsToSelector:selector]) return NULL;

	NSMethodSignature * ms = [self methodSignatureForSelector:selector];
	if (!ms) return NULL;

	NSInvocation * inv = [NSInvocation invocationWithMethodSignature:ms];
	if (!inv) return NULL;

	[inv setTarget:self];
	[inv setSelector:selector];

	int argcount = 2;
	int totalArgs = [ms numberOfArguments];

	while (argcount < totalArgs) {
		char *argtype = (char *)[ms getArgumentTypeAtIndex:argcount];
		// printf("[%s] %d of %d\n", [NSStringFromSelector(selector) UTF8String], argcount, totalArgs); // debug
		if (strcmp(argtype, @encode(id)) == 0) {
			id argument = va_arg(arguments, id);
			[inv setArgument:&argument atIndex:argcount++];
		} else if (
                 (strcmp(argtype, @encode(char)) == 0) ||
                 (strcmp(argtype, @encode(unsigned char)) == 0) ||
                 (strcmp(argtype, @encode(short)) == 0) ||
                 (strcmp(argtype, @encode(unsigned short)) == 0) |
                 (strcmp(argtype, @encode(int)) == 0) ||
                 (strcmp(argtype, @encode(unsigned int)) == 0)
                 ) {
			int i = va_arg(arguments, int);
			[inv setArgument:&i atIndex:argcount++];
		} else if (
                 (strcmp(argtype, @encode(long)) == 0) ||
                 (strcmp(argtype, @encode(unsigned long)) == 0)
                 ) {
			long l = va_arg(arguments, long);
			[inv setArgument:&l atIndex:argcount++];
		} else if (
                 (strcmp(argtype, @encode(long long)) == 0) ||
                 (strcmp(argtype, @encode(unsigned long long)) == 0)
                 ) {
			long long l = va_arg(arguments, long long);
			[inv setArgument:&l atIndex:argcount++];
		} else if (
                 (strcmp(argtype, @encode(float)) == 0) ||
                 (strcmp(argtype, @encode(double)) == 0)
                 ) {
			double d = va_arg(arguments, double);
			[inv setArgument:&d atIndex:argcount++];
		} else if (strcmp(argtype, @encode(Class)) == 0) {
			Class c = va_arg(arguments, Class);
			[inv setArgument:&c atIndex:argcount++];
		} else if (strcmp(argtype, @encode(SEL)) == 0) {
			SEL s = va_arg(arguments, SEL);
			[inv setArgument:&s atIndex:argcount++];
		} else if (strcmp(argtype, @encode(char *)) == 0) {
			char *s = va_arg(arguments, char *);
			[inv setArgument:s atIndex:argcount++];
		} else {
			NSString *type = [NSString stringWithCString:argtype encoding:NSUTF8StringEncoding];
			if ([type isEqualToString:@"{CGRect={CGPoint=ff}{CGSize=ff}}"]) {
				CGRect arect = va_arg(arguments, CGRect);
				[inv setArgument:&arect atIndex:argcount++];
			} else if ([type isEqualToString:@"{CGPoint=ff}"]) {
				CGPoint apoint = va_arg(arguments, CGPoint);
				[inv setArgument:&apoint atIndex:argcount++];
			} else if ([type isEqualToString:@"{CGSize=ff}"]) {
				CGSize asize = va_arg(arguments, CGSize);
				[inv setArgument:&asize atIndex:argcount++];
			} else {
				// assume its a pointer and punt
				NSLog(@"%@", type);
				void *ptr = va_arg(arguments, void *);
				[inv setArgument:ptr atIndex:argcount++];
			}
		}
	}

	if (argcount != totalArgs) {
		printf("Invocation argument count mismatch: %ld expected, %d sent\n", (unsigned long)[ms numberOfArguments], argcount);
		return NULL;
	}

	return inv;
}

// Return an invocation with the given arguments
- (NSInvocation *)invocationWithSelectorAndArguments:(SEL)selector, ...
{
	va_list arglist;
	va_start(arglist, selector);
	NSInvocation *inv = [self invocationWithSelector:selector andArguments:arglist];
	va_end(arglist);
	return inv;
}

// Peform the selector using va_list arguments
- (BOOL)performSelector:(SEL)selector withReturnValue:(void *)result andArguments:(va_list)arglist {
	NSInvocation *inv = [self invocationWithSelector:selector andArguments:arglist];
	if (!inv) return NO;
	[inv invoke];
	if (result) [inv getReturnValue:result];
	return YES;
}

// Perform a selector with an arbitrary number of arguments
// Thanks to Kevin Ballard for assist!
- (BOOL)performSelector:(SEL)selector withReturnValueAndArguments:(void *)result, ...
{
	va_list arglist;
	va_start(arglist, result);
	NSInvocation *inv = [self invocationWithSelector:selector andArguments:arglist];
	if (!inv) return NO;
	[inv invoke];
	if (result) [inv getReturnValue:result];
	va_end(arglist);
	return YES;
}

// Returning objects by performing selectors
- (id)objectByPerformingSelectorWithArguments:(SEL)selector, ...
{
	id result;
	va_list arglist;
	va_start(arglist, selector);
	[self performSelector:selector withReturnValue:&result andArguments:arglist];
	va_end(arglist);

	CFShow((__bridge CFTypeRef)(result));
	return result;
}
/*
 - (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2
 {
 return [self objectByPerformingSelectorWithArguments:selector, object1, object2];
 }

 - (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1
 {
 return [self objectByPerformingSelectorWithArguments:selector, object1];
 }

 - (id) objectByPerformingSelector:(SEL)selector
 {
 return [self objectByPerformingSelectorWithArguments:selector];
 } */

- (id)objectByPerformingSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
	if (![self respondsToSelector:selector]) return nil;

	// Retrieve method signature and return type
	NSMethodSignature * ms = [self methodSignatureForSelector:selector];
	const char *returnType = [ms methodReturnType];

	// Create invocation using method signature and invoke it
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
	[inv setTarget:self];
	[inv setSelector:selector];
	if (object1) [inv setArgument:&object1 atIndex:2];
	if (object2) [inv setArgument:&object2 atIndex:3];
	[inv invoke];

	// return object
	if (strcmp(returnType, @encode(id)) == 0) {
		id riz = nil;
		[inv getReturnValue:&riz];
		return riz;
	}

	// return double
	if ((strcmp(returnType, @encode(float)) == 0) ||
		 (strcmp(returnType, @encode(double)) == 0)) {
		double f;
		[inv getReturnValue:&f];
		return [NSNumber numberWithDouble:f];
	}

	// return NSNumber version of byte. Use valueBy version for recovering chars
	if ((strcmp(returnType, @encode(char)) == 0) ||
		 (strcmp(returnType, @encode(unsigned char)) == 0)) {
		unsigned char c;
		[inv getReturnValue:&c];
		return [NSNumber numberWithInt:(unsigned int)c];
	}

	// return c-string
	if (strcmp(returnType, @encode(char *)) == 0) {
		char *s;
		[inv getReturnValue:s];
		return [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
	}

	// return integer
	long l;
	[inv getReturnValue:&l];
	return [NSNumber numberWithLong:l];
}

- (id)objectByPerformingSelector:(SEL)selector withObject:(id)object1 {
	return [self objectByPerformingSelector:selector withObject:object1 withObject:nil];
}

- (id)objectByPerformingSelector:(SEL)selector {
	return [self objectByPerformingSelector:selector withObject:nil withObject:nil];
}

// Delayed selectors
- (void)performSelector:(SEL)selector withCPointer:(void *)cPointer afterDelay:(NSTimeInterval)delay {
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
	[inv setTarget:self];
	[inv setSelector:selector];
	[inv setArgument:cPointer atIndex:2];
	[inv performSelector:@selector(invoke) withObject:nil afterDelay:delay];
}

- (void)performSelector:(SEL)selector withBool:(BOOL)boolValue afterDelay:(NSTimeInterval)delay {
	[self performSelector:selector withCPointer:&boolValue afterDelay:delay];
}

- (void)performSelector:(SEL)selector withInt:(int)intValue afterDelay:(NSTimeInterval)delay {
	[self performSelector:selector withCPointer:&intValue afterDelay:delay];
}

- (void)performSelector:(SEL)selector withFloat:(float)floatValue afterDelay:(NSTimeInterval)delay {
	[self performSelector:selector withCPointer:&floatValue afterDelay:delay];
}

- (void)performSelector:(SEL)selector afterDelay:(NSTimeInterval)delay {
	[self performSelector:selector withObject:nil afterDelay:delay];
}

// private. only sent to an invocation
- (void)getReturnValue:(void *)result {
	NSInvocation *inv = (NSInvocation *)self;
	[inv invoke];
	if (result) [inv getReturnValue:result];
}

// Delayed selector
- (void)performSelector:(SEL)selector withDelayAndArguments:(NSTimeInterval)delay, ...
{
	va_list arglist;
	va_start(arglist, delay);
	NSInvocation *inv = [self invocationWithSelector:selector andArguments:arglist];
	va_end(arglist);

	if (!inv) return;
	[inv performSelector:@selector(invoke) afterDelay:delay];
}

#pragma mark values
- (id)valueByPerformingSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
	if (![self respondsToSelector:selector]) return nil;

	// Retrieve method signature and return type
	NSMethodSignature * ms = [self methodSignatureForSelector:selector];
	const char *returnType = [ms methodReturnType];

	// Create invocation using method signature and invoke it
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
	[inv setTarget:self];
	[inv setSelector:selector];
	if (object1) [inv setArgument:&object1 atIndex:2];
	if (object2) [inv setArgument:&object2 atIndex:3];
	[inv invoke];


	// Place results into value
	void *bytes = malloc(16);
	[inv getReturnValue:bytes];
	NSValue *returnValue = [NSValue valueWithBytes:bytes objCType:returnType];
	free(bytes);
	return returnValue;
}

- (id)valueByPerformingSelector:(SEL)selector withObject:(id)object1 {
	return [self valueByPerformingSelector:selector withObject:object1 withObject:nil];
}

- (id)valueByPerformingSelector:(SEL)selector {
	return [self valueByPerformingSelector:selector withObject:nil withObject:nil];
}

// Return an array of all an object's selectors
+ (NSA*)getSelectorListForClass {
	NSMutableArray *selectors = [NSMutableArray array];
	unsigned int num;
	Method *methods = class_copyMethodList(self, &num);
	for (int i = 0; i < num; i++) {
		[selectors addObject:NSStringFromSelector(method_getName(methods[i]))];
	}
	free(methods);
	return selectors;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSD*)selectors {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] getSelectorListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self superclasses]) {
		[dict setObject:[cl getSelectorListForClass] forKey:NSStringFromClass(cl)];
	}
	return dict;
}

// Return an array of all an object's properties
+ (NSA*)getPropertyListForClass {
	NSMutableArray *propertyNames = [NSMutableArray array];
	unsigned int num;
	objc_property_t *properties = class_copyPropertyList(self, &num);
	for (int i = 0; i < num; i++) {
		[propertyNames addObject:[NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding]];
	}
	free(properties);
	return propertyNames;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSD*)properties {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] getPropertyListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self superclasses]) {
		[dict setObject:[cl getPropertyListForClass] forKey:NSStringFromClass(cl)];
	}
	return dict;
}

// Return an array of all an object's properties
+ (NSA*)getIvarListForClass {
	NSMutableArray *ivarNames = [NSMutableArray array];
	unsigned int num;
	Ivar *ivars = class_copyIvarList(self, &num);
	for (int i = 0; i < num; i++) {
		[ivarNames addObject:[NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding]];
	}
	free(ivars);
	return ivarNames;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSD*)ivars {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] getIvarListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self superclasses]) {
		[dict setObject:[cl getIvarListForClass] forKey:NSStringFromClass(cl)];
	}
	return dict;
}

// Return an array of all an object's properties
+ (NSA*)getProtocolListForClass {

//	Class clazz             = [self class];         u_int count;
//	Protocol **protocols      = class_copyProtocolList(self, &count);
//
//	return [[@0 to : @(count - 1)] nmap:^id (id obj, NSUI index) {
//		return $UTF8(sel_getName(method_getName(methods [(u_int)index]) ));
//	}];

	NSMutableArray *protocolNames = [NSMutableArray array];
	unsigned int num;
	__unsafe_unretained Protocol **protocols = class_copyProtocolList(self, &num);
	for (int i = 0; i < num; i++) {
		[protocolNames addObject:[NSString stringWithCString:protocol_getName(protocols[i]) encoding:NSUTF8StringEncoding]];
	}
	free(protocols);
	return protocolNames;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSD*)protocols {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] getProtocolListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self superclasses]) {
		[dict setObject:[cl getProtocolListForClass] forKey:NSStringFromClass(cl)];
	}
	return dict;
}

// Runtime checks of properties, etc.
- (BOOL)hasProperty:(NSS*)propertyName {
	NSMutableSet *set = [NSMutableSet set];
	NSDictionary *dict = self.propertiesPlease;
	for (NSArray * properties in [dict allValues]) {
		[set addObjectsFromArray:properties];
	}
	return [set containsObject:propertyName];
}

- (BOOL)hasIvar:(NSS*)ivarName {
	NSMutableSet *set = [NSMutableSet set];
	NSDictionary *dict = self.ivars;
	for (NSArray * ivars in [dict allValues]) {
		[set addObjectsFromArray:ivars];
	}
	return [set containsObject:ivarName];
}

+ (BOOL)classExists:(NSS*)className {
	return (NSClassFromString(className) != nil);
}

+ (id)instanceOfClassNamed:(NSS*)className {
	if (NSClassFromString(className) != nil) return [[[NSClassFromString(className) alloc] init] autorelease];
	else return nil;
}

// Return a C-string with a selector's return type
// may extend this idea to return a class
- (const char *)returnTypeForSelector:(SEL)selector {
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	return [ms methodReturnType];
}

// Choose the first selector that an object can respond to
// Thank Kevin Ballard for assist!
- (SEL)chooseSelector:(SEL)aSelector, ...
{
	if ([self respondsToSelector:aSelector]) return aSelector;

	va_list selectors;
	va_start(selectors, aSelector);
	SEL selector = va_arg(selectors, SEL);
	while (selector) {
		if ([self respondsToSelector:selector]) return selector;
		selector = va_arg(selectors, SEL);
	}

	return NULL;
}

// Perform the selector if possible, returning any return value. Otherwise return nil.
- (id)tryPerformSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2 {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	return ([self respondsToSelector:aSelector]) ? [self performSelector:aSelector withObject:object1 withObject:object2] : nil;
#pragma clang diagnostic pop

}

- (id)tryPerformSelector:(SEL)aSelector withObject:(id)object1 {
	return [self tryPerformSelector:aSelector withObject:object1 withObject:nil];
}

- (id)tryPerformSelector:(SEL)aSelector {
	return [self tryPerformSelector:aSelector withObject:nil withObject:nil];
}

@end


@class CKVOToken;

@interface CKVOBlockHelper : NSObject
@property (readonly, nonatomic, weak) id observedObject;
@property (readonly, nonatomic, strong) NSMutableDictionary *tokensByContext;
@property (readwrite, nonatomic, assign) NSInteger nextIdentifier;
- (id)initWithObject:(id)inObject;
- (CKVOToken *)insertNewTokenForKeyPath:(NSS*)inKeyPath block:(KVOFullBlock)inBlock;
- (void)removeHandlerForKey:(CKVOToken *)inToken;
- (void)dump;
@end

#pragma mark -

@interface CKVOToken : NSObject
@property (readonly, nonatomic, copy) NSString *keypath;
@property (readonly, nonatomic, assign) NSInteger index;
@property (readonly, nonatomic, copy) KVOFullBlock block;
@property (readonly, nonatomic, assign) void *context;
- (id)initWithKeyPath:(NSS*)inKey index:(NSInteger)inIndex block:(KVOFullBlock)inBlock;
@end

#pragma mark -

@implementation NSObject (NSObject_KVOBlock)

static void *KVO;

- (id)addKVOBlockForKeyPath:(NSS*)inKeyPath options:(NSKeyValueObservingOptions)inOptions handler:(KVOFullBlock)inHandler
{
	NSParameterAssert(inHandler);
	NSParameterAssert(inKeyPath);
	NSParameterAssert([NSThread isMainThread]); // TODO -- remove and grow a pair.

	CKVOBlockHelper *theHelper = [self helper:YES];
	NSParameterAssert(theHelper != NULL);

	CKVOToken *theToken = [theHelper insertNewTokenForKeyPath:inKeyPath block:inHandler];
	NSParameterAssert(theToken != NULL);

	void *theContext = theToken.context;
	NSParameterAssert(theContext != NULL);

	[self addObserver:theHelper forKeyPath:inKeyPath options:inOptions context:theContext];

	return(theToken);
}

- (void)removeKVOBlockForToken:(CKVOToken *)inToken
{
	NSParameterAssert([NSThread isMainThread]); // TODO -- remove and grow a pair.
	CKVOBlockHelper *theHelper = [self helper:NO];
	NSParameterAssert(theHelper != NULL);

	void *theContext = inToken.context;
	NSParameterAssert(theContext);
	NSString *theKeyPath = inToken.keypath;
	NSParameterAssert(theKeyPath.length > 0);
	[self removeObserver:theHelper forKeyPath:theKeyPath context:theContext];

	[theHelper removeHandlerForKey:inToken];
}

#pragma mark -

- (id)addOneShotKVOBlockForKeyPath:(NSS*)inKeyPath options:(NSKeyValueObservingOptions)inOptions handler:(KVOFullBlock)inHandler
{
	__block CKVOToken *theToken = NULL;
	KVOFullBlock theBlock = ^(NSString *keyPath, id object, NSDictionary *change) {
		inHandler(keyPath, object, change);
		[self removeKVOBlockForToken:theToken];
	};

	theToken = [self addKVOBlockForKeyPath:inKeyPath options:inOptions handler:theBlock];
	return(theToken);
}

- (void)KVODump
{
	CKVOBlockHelper *theHelper = [self helper:NO];
	[theHelper dump];
}

#pragma mark -

- (CKVOBlockHelper *)helper:(BOOL)inCreate
{
	CKVOBlockHelper *theHelper = objc_getAssociatedObject(self, &KVO);
	if (theHelper == NULL && inCreate == YES)
	{
		theHelper = [[CKVOBlockHelper alloc] initWithObject:self];

		objc_setAssociatedObject(self, &KVO, theHelper, OBJC_ASSOCIATION_RETAIN);
	}
	return(theHelper);
}

@end

#pragma mark -

@implementation CKVOBlockHelper

- (id)initWithObject:(id)inObject
{
	if ((self = [super init]) != NULL)
	{
		_observedObject = inObject;
	}
	return(self);
}

- (void)dealloc
{
	[_tokensByContext enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, CKVOToken *token, BOOL *stop)
	 {
		 void *theContext = token.context;
		 NSParameterAssert(theContext != NULL);
		 NSString *theKeypath = token.keypath;
		 NSParameterAssert(theKeypath != NULL);
		 [_observedObject removeObserver:self forKeyPath:theKeypath context:theContext];
	 }];
}

- (NSS*)debugDescription
{
	return([NSString stringWithFormat:@"%@ (%@, %@, %@)", [self description], self.observedObject, self.tokensByContext, [self.observedObject observationInfo]]);
}

- (void)dump
{
	printf("*******************************************************\n");
	printf("%s\n", [[self description] UTF8String]);
	printf("\tObserved Object: %p\n", (__bridge void *)self.observedObject);
	printf("\tKeys:\n");
	[_tokensByContext enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, CKVOToken *token, BOOL *stop) {
		printf("\t\t%s\n", [[index description] UTF8String]);
	}];
	printf("\tObservationInfo: %s\n", [[(__bridge id)[self.observedObject observationInfo] description] UTF8String]);
}

- (void)removeHandlerForKey:(CKVOToken *)inToken
{
	[_tokensByContext removeObjectForKey:@(inToken.index)];
	if (_tokensByContext.count == 0)
	{
		_tokensByContext = NULL;
	}
}

- (CKVOToken *)insertNewTokenForKeyPath:(NSS*)inKeyPath block:(KVOFullBlock)inBlock
{
	CKVOToken *theToken = [[CKVOToken alloc] initWithKeyPath:inKeyPath index:++self.nextIdentifier block:inBlock];
	if (_tokensByContext == NULL)
	{
		_tokensByContext = [NSMutableDictionary dictionary];
	}
	_tokensByContext[@(theToken.index)] = theToken;
	return(theToken);
}

#pragma mark -

- (void)observeValueForKeyPath:(NSS*)keyPath ofObject:(id)object change:(NSD*)change context:(void *)context;
{
	NSParameterAssert(context);

	NSNumber *theKey = @((NSInteger)context);

	CKVOToken *theToken= _tokensByContext[theKey];
	if (theToken == NULL)
	{
		NSLog(@"Warning: Could not find block for key: %@", theKey);
	}
	else
	{
		theToken.block(keyPath, object, change);
	}
}

@end

@implementation CKVOToken

- (id)initWithKeyPath:(NSS*)inKey index:(NSInteger)inIndex block:(KVOFullBlock)inBlock
{
	if ((self = [super init]) != NULL)
	{
		_keypath = inKey;
		_index = inIndex;
		_block = inBlock;
	}
	return self;
}

- (NSS*)description
{
	return([NSString stringWithFormat:@"%@ (%@ #%ld)", [super description], self.keypath, (unsigned long)self.index]);
}

- (void *)context
{
	return((void *)self.index);
}

@end


@implementation NSObject (FOOCoding)

- (id)initWithDictionary:(NSD*)dictionary;
{
	if (!(self = [self init])) return nil;

	[self setValuesForKeysWithDictionary:dictionary];

	return self;
}

- (NSA*)arrayForKey:(NSS*)key;
{
	return [self valueForKey:key assertingClass:[NSArray class]];
}

- (NSA*)arrayOfClass:(Class)objectClass forKey:(NSS*)key;
{
	NSAssert1([objectClass respondsToSelector:@selector(initWithDictionary:)], @"%@ does not respond to initWithDictionary:", NSStringFromClass(objectClass));

	NSArray *keyedObjects = [self arrayOfDictionariesForKey:key];
	if (!keyedObjects || ![keyedObjects isKindOfClass:[NSArray class]] || !keyedObjects.count)
		return nil;

	id newObject = nil;
	NSMutableArray *newObjects = [NSMutableArray array];
	for (NSDictionary *keyedObject in keyedObjects)
		if ((newObject = [[objectClass alloc] initWithDictionary:keyedObject]))
			[newObjects addObject:newObject];

	if (!newObjects.count)
		return nil;

	return newObjects;
}

- (NSA*)arrayOfClass:(Class)objectClass;
{
	NSAssert1([objectClass respondsToSelector:@selector(initWithDictionary:)], @"%@ does not respond to initWithDictionary:", NSStringFromClass(objectClass));

	if (![self isKindOfClass:[NSArray class]] || ![(NSA*)self count])
		return nil;

	id newObject = nil;
	NSMutableArray *newObjects = [NSMutableArray array];
	for (NSDictionary *keyedObject in (NSA*)self)
		if ((newObject = [[objectClass alloc] initWithDictionary:keyedObject]))
			[newObjects addObject:newObject];

	if (!newObjects.count)
		return nil;

	return newObjects;
}

- (NSA*)arrayOfDictionariesForKey:(NSS*)key;
{
	NSArray *allegedDictionaries = [self valueForKey:key assertingClass:[NSArray class]];
	if ([self contentsOfCollection:allegedDictionaries areKindOfClass:[NSDictionary class]])
		return allegedDictionaries;

	NSAssert(NO, @"Collection does not contain only dictionaries");
	return nil;
}

- (NSA*)arrayOfStringsForKey:(NSS*)key;
{
	NSArray *allegedStrings = [self valueForKey:key assertingClass:[NSArray class]];
	if ([self contentsOfCollection:allegedStrings areKindOfClass:[NSString class]])
		return allegedStrings;

	NSAssert(NO, @"Collection does not contain only strings");
	return nil;
}

- (BOOL)boolForKey:(NSS*)key;
{
	return [[self valueForKey:key assertingRespondsToSelector:@selector(boolValue)] boolValue];
}

- (NSData *)dataForKey:(NSS*)key;
{
	return [self valueForKey:key assertingClass:[NSData class]];
}

- (NSDate *)dateForKey:(NSS*)key;
{
	id value = [self valueForKey:key];
	if (!value || value == (id)[NSNull null]) return nil;
	if ([value isKindOfClass:[NSDate class]]) return value;

	if ([value isKindOfClass:[NSString class]])
		return [[[NSDateFormatter alloc] init] dateFromString:value];

	NSAssert1(NO, @"FOOCoding cannot make an NSDate from %@", NSStringFromClass([value class]));

	return nil;
}

- (NSD*)dictionaryForKey:(NSS*)key;
{
	return [self valueForKey:key assertingClass:[NSDictionary class]];
}

- (double)doubleForKey:(NSS*)key;
{
	return [[self valueForKey:key assertingRespondsToSelector:@selector(doubleValue)] doubleValue];
}

- (CGFloat)floatForKey:(NSS*)key;
{
	return [[self valueForKey:key assertingRespondsToSelector:@selector(floatValue)] floatValue];
}

- (NSInteger)integerForKey:(NSS*)key;
{
	return [[self valueForKey:key assertingRespondsToSelector:@selector(integerValue)] integerValue];
}

- (NSS*)stringForKey:(NSS*)key;
{
	return [self valueForKey:key assertingClass:[NSString class]];
}

- (NSUInteger)unsignedIntegerForKey:(NSS*)key;
{
	return [[self valueForKey:key assertingRespondsToSelector:@selector(unsignedIntegerValue)] unsignedIntegerValue];
}

- (NSURL *)URLForKey:(NSS*)key;
{
	id stringValue = [self valueForKey:key assertingClass:[NSString class]];
	return stringValue ? [NSURL URLWithString:stringValue] : nil;
}

- (id)valueForKeyOrKeyPath:(id)keyOrKeyPath  //AZAddition
{
	NSLog(@"%@: %@", NSStringFromSelector(_cmd), keyOrKeyPath);
	if (![keyOrKeyPath isKindOfClass:NSString.class]) return  nil;
	if ([keyOrKeyPath containsString:@"."]) {
		NSA* components = [keyOrKeyPath componentsSeparatedByString:@"."];
//		NSLog(@"serching for KP components: %@", components);
		__block id result = self;
		[components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([(NSS*)obj isIntegerNumber] && [result isKindOfClass:NSA.class]) {
				result = [(NSA*)result normal:[(NSS*)obj integerValue]];
			}
			else {
				result = [result vFK:obj];
				//[result respondsToSelector:[result getterForPropertyNamed:obj]] && [result hasPropertyForKey:obj]
					//	 ?  [result performSelectorWithoutWarnings:[result getterForPropertyNamed:obj]] : nil;
			}
			if (!result) *stop = YES;// else LOG_EXPR(result);
		}];
		return result;
//		 return [self vFKP:rawPath] ?: nil;
	}
	else if ([keyOrKeyPath isIntegerNumber] && [self isKindOfClass:NSA.class]) return [(NSA*)self normal:[(NSS*)keyOrKeyPath integerValue]];
	else if ([self respondsToString:keyOrKeyPath]) {
		return [self performString:keyOrKeyPath];
	}
	else return [self performSelectorWithoutWarnings:[self getterForPropertyNamed:keyOrKeyPath]] ?: nil;
	
}



- (id)valueForKey:(NSS*)key assertingProtocol:(Protocol*)proto;
{
	id value = [self vFK:key];
	if (!value || value == [NSNull null]) return nil;
	NSAssert1([value conformsToProtocol:proto], @"AZCoding expects an object conforming to prootcol %@", NSStringFromProtocol(proto));
	return [value conformsToProtocol:proto] ? value : nil;
}
- (id)valueForKey:(NSS*)key assertingClass:(Class)theClass;
{
	id value = [self valueForKey:key];
	if (!value || value == [NSNull null]) return nil;
	NSAssert2([value isKindOfClass:theClass], @"FOOCoding expects an object of class %@, but class of return value is %@", NSStringFromClass(theClass), NSStringFromClass([value class]));
	return [value isKindOfClass:theClass] ? value : nil;
}

- (id)valueForKey:(NSS*)key assertingRespondsToSelector:(SEL)theSelector;
{
	id value = [self valueForKey:key];
	if (!value || value == [NSNull null]) return nil;
	NSAssert2([value respondsToSelector:theSelector], @"Object of class %@ does not respond to selector %@", NSStringFromClass([value class]), NSStringFromSelector(theSelector));
	return [value respondsToSelector:theSelector] ? value : nil;
}

- (BOOL)contentsOfCollection:(id <NSFastEnumeration>)theCollection areKindOfClass:(Class)theClass;
{
	for (id theObject in theCollection) if (![theObject isKindOfClass:theClass]) return NO;
	return YES;
}

@end

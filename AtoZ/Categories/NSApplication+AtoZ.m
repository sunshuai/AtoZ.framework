
#import <AtoZ/AtoZ.h>
#import "NSApplication+AtoZ.h"

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#import <sys/xattr.h>
#else
#import <CoreServices/CoreServices.h>
#endif
#import <libkern/OSAtomic.h>
#import <sys/xattr.h>
#import <sys/sysctl.h>
#import <unistd.h>
#import <dirent.h>
#import <sys/stat.h>


void SetDockIconImage(NSImage*i) { NSDockTile *dock = NSApplication.sharedApplication.dockTile; NSImageView *iv;

  dock.contentView  = iv = [NSImageView.alloc initWithFrame:(NSRect){0,0,512,512}];
  iv.imageScaling   = NSImageScaleProportionallyUpOrDown;
  iv.image          = i;   [dock display];
}

@implementation NSMenu (SBAdditions)

+ (INST) menuWithItems:(NSA*)items { NSMenu *m = self.new;  m.itemArray = items;  return m; }

- (void)   setItemArray:(NSA*)items { for (NSMI*m in items) [self addItem:m]; }

- (NSMI*) selectedItem {
	NSMenuItem *menuItem = nil;
	for (NSMenuItem *item in [self itemArray])
	{
		if ([item state] == NSOnState)
		{
			menuItem = item;
			break;
		}
	}
	return menuItem;
}

- (void) selectItem:(NSMenuItem *)menuItem
{
	for (NSMenuItem *item in [self itemArray])
	{
		[item setState:(item == menuItem ? NSOnState : NSOffState)];
	}
}

- (NSMI*) selectItemWithRepresentedObject: representedObject {
	NSMenuItem *selectedItem = nil;
	for (NSMenuItem *item in [self itemArray])
	{
		id repObject = [item representedObject];
		BOOL equal = (!repObject && !representedObject) || [repObject isEqualTo:representedObject];
		[item setState:(equal ? (selectedItem ? NSOffState : NSOnState) : NSOffState)];
		if (equal)
		{
			if (!selectedItem)
				selectedItem = item;
		}
	}
	return selectedItem;
}

- (void) seselectItem {
	for (NSMenuItem *item in [self itemArray])
	{
		[item setState:NSOffState];
	}
}

- (NSMI*) addItemWithTitle:(NSS*)aString target:target action:(SEL)aSelector tag:(NSInteger)tag {

  NSMenuItem *item = NSMenuItem.new;
	[item setTitle:aString];
	[item setTarget:target];
	[item setAction:aSelector];
	[item setTag:tag];
	[self addItem:item];
	return item;
}

- (NSMI*) addItemWithTitle:(NSString *)aString representedObject:representedObject target:target action:(SEL)aSelector {
	NSMenuItem *item = [[NSMenuItem.alloc init] autorelease];
	[item setTitle:aString];
	[item setTarget:target];
	[item setAction:aSelector];
	[item setRepresentedObject:representedObject];
	[self addItem:item];
	return item;
}

@end

@implementation NSMenuItem (AtoZ)

- initWithTitle:(NSString*)aString    target:target
         action:(SEL)aSelector keyEquivalent:(NSS*)keyEquivalent
                           representedObject:representedObject {
	if (!(self = super.init)) return self;
	[self setTitle:aString];
	[self setTarget:target];
	[self setAction:aSelector];
	[self setRepresentedObject:representedObject];
	[self setKeyEquivalent:keyEquivalent];

	return self;
}

@end

NSString *const kShowDockIconUserDefaultsKey = @"ShowDockIcon";

@implementation NSApplication (AtoZ)

+ infoValueForKey:(NSS*)key {
	if ([[NSBundle mainBundle] localizedInfoDictionary][key]) {
		return [[NSBundle mainBundle] localizedInfoDictionary][key];
	}

	return [[NSBundle mainBundle] infoDictionary][key];
}

- (BOOL)showsDockIcon { return [AZUSERDEFS bFK:kShowDockIconUserDefaultsKey]; }

	/** this should be called from the application delegate's applicationDidFinishLaunching method or from some controller object's awakeFromNib method neat dockless hack using Carbon from <a href="http://codesorcery.net/2008/02/06/feature-requests-versus-the-right-way-to-do-it" title="http://codesorcery.net/2008/02/06/feature-requests-versus-the-right-way-to-do-it">http://codesorcery.net/2008/02/06/feature-requests-versus-the-right-way-...</a> */
	
- (void) setShowsDockIcon:(BOOL)flag {

	if (flag) {
		ProcessSerialNumber psn = { 0, kCurrentProcess };
		// display dock icon
		TransformProcessType(&psn, kProcessTransformToForegroundApplication);
		// enable menu bar
		SetSystemUIMode(kUIModeNormal, 0);

		// switch to Dock.app
		if ([[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"com.apple.dock" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:nil] == NO) {
			NSLog(@"Could not launch application with identifier 'com.apple.dock'.");
		}

		// switch back
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	}
}

- _IsIt_ launchAtLogin {

  LSSharedFileListItemRef loginItem = self.loginItem;

  BOOL result = loginItem ? YES : NO;

  if (loginItem) CFRelease(loginItem);

  return result;
}

- _Void_ setLaunchAtLogin:(BOOL)launchAtLogin {

  if (launchAtLogin == self.launchAtLogin) return;


  LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

  if (launchAtLogin) {
    CFURLRef appUrl = (__bridge CFURLRef)[[NSBundle mainBundle] bundleURL];
    LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef, kLSSharedFileListItemLast, NULL,
                                                                    NULL, appUrl, NULL, NULL);
    if (itemRef) CFRelease(itemRef);

  } else {

    LSSharedFileListItemRef loginItem = self.loginItem;

    LSSharedFileListItemRemove(loginItemsRef, loginItem);
    if (loginItem != nil) CFRelease(loginItem);
  }

  if (loginItemsRef) CFRelease(loginItemsRef);
}

#pragma mark Private Login Item Shit

- (LSSharedFileListItemRef)loginItem {

  NSURL *bundleURL = AZAPPBUNDLE.bundleURL;

  LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

  if (!loginItemsRef) return NULL;

  NSArray *loginItems = CFBridgingRelease(LSSharedFileListCopySnapshot(loginItemsRef, nil));

  LSSharedFileListItemRef result = NULL;

  for (id item in loginItems) {

    LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
    CFURLRef itemURLRef;

    if (LSSharedFileListItemResolve(itemRef, 0, &itemURLRef, NULL) == noErr) {
      NSURL *itemURL = (__bridge NSURL *)itemURLRef;

      if ([itemURL isEqual:bundleURL]) {
        result = itemRef;
        break;
      }
    }
  }

  if (result) CFRetain(result);
  CFRelease(loginItemsRef);

  return result;
}

@end



@implementation NSProcessInfo (Extensions)

// From http://developer.apple.com/mac/library/qa/qa2004/qa1361.html
- _IsIt_ isDebuggerAttached {
	struct kinfo_proc info;
	info.kp_proc.p_flag = 0;

	int mib[4];
	mib[0] = CTL_KERN;
	mib[1] = KERN_PROC;
	mib[2] = KERN_PROC_PID;
	mib[3] = getpid();
	size_t size = sizeof(info);
	int result = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);

	return !result && (info.kp_proc.p_flag & P_TRACED);  // We're being debugged if the P_TRACED flag is set
}

@end




@implementation NSWorkspace (SystemInfo)

+ (NSString*) systemVersion {
	SInt32 versionMajor, versionMinor, versionBugFix;

	OSErr maj = Gestalt(gestaltSystemVersionMajor, &versionMajor);
	OSErr min = Gestalt(gestaltSystemVersionMinor, &versionMinor);
	OSErr bug = Gestalt(gestaltSystemVersionBugFix, &versionBugFix);

	if (maj != noErr || min != noErr || bug != noErr)
		return nil;

	return $(@"%d.%d.%d", versionMajor, versionMinor, versionBugFix);
}

@end

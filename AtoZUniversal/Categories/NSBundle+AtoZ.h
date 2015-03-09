
@import Foundation;

@interface NSBundle (AtoZBundles)
+ (NSA*) bundlesFromStdin;
+ (NSA*) bundlesConformingTo:(Protocol*)p atPath:(NSS*)path;
- (NSA*) pluginsConformingTo:(Protocol*)p;
@prop_RO NSA* plugins;
@end

@interface NSBundle (AtoZ)


/*! @see __TEXT", "__info_plist etc */ + infoPlist;

/// :@"Fraise" => NSBundle </Volumes/4X4/Applications/Fraise.app> (not yet loaded)
+ (NSB*) bundleForApplicationName:(NSS*)appName;

///  :@"Fraise" -> org.fraise.Fraise
+ (NSS*) bundleIdentifierForApplicationName:(NSS*)appName;

//- (NSD*)     infoDictionaryWithIdentifier:(NSS*)identifier;

/*! from "__ARCLite__" to ZoneTotalDiff  ALL exported symbols.  Useless. */
- (NSA*) definedClasses;

/*! ( ..., "/System/Library/Frameworks/AVFoundation.framework",
           "/Volumes/4X4/DerivedData/AtoZ-hfqteqfcvjfinlajqwkydsqyzpiz/Build/Products/Debug/Zangetsu.framework"
) */
+ (NSA*) allFrameworkPaths;

+ (NSS*) appSuppDir;
+ (NSS*) appSuppFolder;
+ (NSS*) applicationSupportFolder;
+ (NSS*) appSuppSubPathNamed: (NSS*)name;

/*! Tries to figure out bundle from path...
@c [NSBundle calulatedBundleIDForPath:@"/Applications/TextMate.app"] -> com.macromates.textmate */
+ (NSS*) calulatedBundleIDForPath: (NSS*)path;

+ (INST) bundleForExecutable:(NSS*)path;

+ resourceOfClass:(Class)rClass inBundleWithClass:(Class)k withName:(NSString*)n init:(SEL)method;
- (NSA*) cacheImages;
- _Void_ cacheNamedImages;
- (NSA*) recursivePathsForResourcesOfType:(NSS*)type inDirectory:(NSS*)directoryPath;
- (NSS*) recursiveSearchForPathOfResourceNamed:(NSS*)name;

// [AZFWORKBUNDLE resourcesWithExtensions:@[@"caf"]]; ->  ( ...,  "/Users/localadmin/Library/Frameworks/AtoZ.framework/Resources/Sounds/short_low_high.caf", ... )
- (NSA*) resourcesWithExtensions:(NSA*)exts; // OK


@prop_RO NSA* imageResources; // BROKEN
/*! @brief	Returns the path to the application's icon file, derived from the .icns file specified by "CFBundleIconFile" in the application's Info.plist.	*/
@prop_RO NSS * appIconPath;
/*!
 @brief	Returns the image in the file specified by -appIconPath.	*/
@prop_RO NSIMG * appIcon;

// Returns first Info.plist found in bundle.
@prop_RO NSS * infoPlistPath;
@end


//- (NSA*) frameworkClasses;
//+ (NSMutableArray *)systemFrameworks;

    #define INITPLUGIN(PROTO,NAME)   id<PROTO>NAME = CONFORMANTBUNDLEOBJ(PROTO)

#define INITWITHPATH(PROTO,NAME,PATH) id <PROTO> NAME = [[[NSBundle bundleWithPath:PATH] principalClass] new]

#define CONFORMANTBUNDLEOBJ(PROTO)   ({ __block id<PROTO> x = nil;\
[[NSBundle pathsForResourcesOfType : @"plugin" inDirectory:NSBundle.mainBundle.builtInPlugInsPath]\
        enumerateObjectsUsingBlock : ^(id obj,NSUInteger idx,BOOL*stop){\
           NSBundle * bundlePlugin = [NSBundle bundleWithPath:obj];\
                      Class pClass = bundlePlugin.principalClass;\
                             *stop = ([pClass conformsToProtocol:@protocol(PROTO)]\
                                &&   ((x = pClass.new))); }]; x; })

NS_INLINE NSA *        BundlesFromStdin() {


  NSArray *args = NSProcessInfo.processInfo.arguments;
     // Now create a bundle at the specified path (retrieved from input argument)
  if (args.count < 2) return NSLogC(@"Please provide a path for the bundle"), nil;
  NSMA *bundles = NSMA.new;
  [args each:^(id o){ NSError *err; NSB *b;

    (b = [NSB bundleWithPath:o])  ?
      [b loadAndReturnError:&err] ? NSLogC(@"Returning loaded bundle: %@",b), [bundles addObject:b]
                                  : NSLogC(@"Error = %@", err.localizedDescription)
                                  : NSLogC(@"Bundle not found at path"); // Dynamically load bundle INITPLUGIN(GV,gv);
  }];
  return [bundles copy];
}

NS_INLINE NSA *       FilesAt(NSString*p) {   NSMutableArray *ps = NSMutableArray.new;
  [[NSFileManager.defaultManager contentsOfDirectoryAtPath:p error:nil]
    enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { [ps addObject:[p stringByAppendingPathComponent:obj]]; }]; return ps;
}
NS_INLINE NSA * BundlePlugins(NSBundle*b) {   NSMutableArray *bundles = NSMutableArray.new;

  [FilesAt(b.builtInPlugInsPath) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSBundle *bndl = [NSBundle bundleWithPath:obj];
    if (bndl) [bundles addObject:bndl];
  }]; return bundles;
}
NS_INLINE NSA * BundlePluginsConformingTo(NSBundle*b,    Protocol*p) { NSMutableArray *bundles = NSMutableArray.new;

  [BundlePlugins(b) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    Class x = [obj principalClass];
    if ([x conformsToProtocol:p]) [bundles addObject:x];
  }];return bundles;
}
NS_INLINE NSA * BundlesAtPathConformingTo(NSString*path, Protocol*p) { NSMutableArray *bundles = NSMutableArray.new;
  [FilesAt(path) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSBundle *tryB = [NSBundle bundleWithPath:obj];
    if (!tryB) return;
    Class x = [tryB principalClass];
    if ([x conformsToProtocol:p]) [bundles addObject:tryB];
  }];return bundles;
}




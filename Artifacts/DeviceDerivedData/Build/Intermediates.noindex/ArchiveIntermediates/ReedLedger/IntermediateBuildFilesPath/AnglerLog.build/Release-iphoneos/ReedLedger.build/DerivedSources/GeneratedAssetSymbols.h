#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"org.reedfolio.anglerledger";

/// The "ReedAccent" asset catalog color resource.
static NSString * const ACColorNameReedAccent AC_SWIFT_PRIVATE = @"ReedAccent";

/// The "atlas" asset catalog image resource.
static NSString * const ACImageNameAtlas AC_SWIFT_PRIVATE = @"atlas";

#undef AC_SWIFT_PRIVATE

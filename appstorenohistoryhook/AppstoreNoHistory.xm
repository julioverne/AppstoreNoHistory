#import <substrate.h>
#import <objc/runtime.h>
#import <dlfcn.h>

#define NSLog(...)

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.appstorenohistory.plist"
#define PLIST_PATH_Settings_Apps "/var/mobile/Library/Preferences/com.julioverne.appstorenohistory.apps.plist"

static BOOL Enabled;
static BOOL isiOS11;
static NSString* stringUpdatesHidden;

/*
@interface ASDSoftwareUpdate : NSObject
- (int)updateState;
@end

%hook ASDSoftwareUpdate
-(NSDate *)installDate
{
	if(Enabled && [self updateState]==1) {
		return nil;
	}
	return %orig;
}
-(long long)updateState
{
	long long ret = %orig;
	if(Enabled && ret==1) {
		return 2;
	}
	return ret;
}
%end*/

@implementation NSString (lib)
+ (id)dffdsfsd54:(id)format, ...
{
	va_list args;
    va_start(args, format);
    NSString *lString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
	if(Enabled) {
		if(isiOS11) {
			if([lString rangeOfString:@"software_update.is_offloaded"].location != NSNotFound) {
				lString = [lString stringByReplacingOccurrencesOfString:@"software_update.is_offloaded" withString:[NSString stringWithFormat:@"(software_update.update_state == 1%@)", stringUpdatesHidden?:@""]];
			}
		} else {
			if([lString rangeOfString:@"software_update.install_date"].location != NSNotFound) {
				lString = [lString stringByReplacingOccurrencesOfString:@"software_update.install_date" withString:@"software_update.update_state"];
			}
		}		
	}
    return [lString mutableCopy];
}
@end

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	@autoreleasepool {		
		NSDictionary *AppstoreUnrestrictPrefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary] copy];
		Enabled = (BOOL)[[AppstoreUnrestrictPrefs objectForKey:@"Enabled"]?:@YES boolValue];
		isiOS11 = (kCFCoreFoundationVersionNumber >= 1443.00);
		NSDictionary *AppstoreUnrestrictAppsPrefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings_Apps]?:[NSDictionary dictionary] copy];
		NSString* newStringUpdatesHidden = @"";
		for(NSString* bundleIdNow in [AppstoreUnrestrictAppsPrefs allKeys]) {
			if([AppstoreUnrestrictAppsPrefs[bundleIdNow]?:@NO boolValue]) {
				newStringUpdatesHidden = [newStringUpdatesHidden stringByAppendingString:[NSString stringWithFormat:@" OR software_update.bundle_id = '%@'", bundleIdNow]];
			}
		}
		stringUpdatesHidden = [newStringUpdatesHidden copy];
	}
}

%ctor
{	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("com.julioverne.appstorenohistory/Settings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	settingsChanged(NULL, NULL, NULL, NULL, NULL);
	//dlopen("/System/Library/PrivateFrameworks/AppStoreDaemon.framework/AppStoreDaemon", RTLD_GLOBAL);
	method_exchangeImplementations(class_getClassMethod([NSString class],@selector(stringWithFormat:)), class_getClassMethod([NSString class],@selector(dffdsfsd54:)));
	%init;
}


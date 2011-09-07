/**
 * Copyright 2003-2009, Mike Solomon <mas63@cornell.edu>
 * SIMBL is released under the GNU General Public License v2.
 * http://www.opensource.org/licenses/gpl-2.0.php
 */

#import "SIMBL.h"
#import "SIMBLAgent.h"

#include <mach_inject_bundle/mach_inject_bundle.h>

@implementation NSApplication (SystemVersion)

- (void)getSystemVersionMajor:(unsigned *)major
                        minor:(unsigned *)minor
                       bugFix:(unsigned *)bugFix;
{
    OSErr err;
    SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
    if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr) goto fail;
    if (systemVersion < 0x1040)
    {
        if (major) *major = ((systemVersion & 0xF000) >> 12) * 10 +
            ((systemVersion & 0x0F00) >> 8);
        if (minor) *minor = (systemVersion & 0x00F0) >> 4;
        if (bugFix) *bugFix = (systemVersion & 0x000F);
    }
    else
    {
        if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr) goto fail;
        if (major) *major = versionMajor;
        if (minor) *minor = versionMinor;
        if (bugFix) *bugFix = versionBugFix;
    }
    
    return;
    
fail:
    SIMBLLogNotice(@"Unable to obtain system version: %ld", (long)err);
    if (major) *major = 10;
    if (minor) *minor = 0;
    if (bugFix) *bugFix = 0;
}

@end


@implementation SIMBLAgent

- (void) applicationDidFinishLaunching:(NSNotification*)notificaion
{
	NSProcessInfo* procInfo = [NSProcessInfo processInfo];
	if ([(NSString*)[[procInfo arguments] lastObject] hasPrefix:@"-psn"]) {
		// if we were started interactively, load in launchd and terminate
		SIMBLLogNotice(@"installing into launchd");
		[self loadInLaunchd];
		[NSApp terminate:nil];
	}
	else {
		SIMBLLogInfo(@"agent started");
		[[[NSWorkspace sharedWorkspace] notificationCenter]
				addObserver:self selector:@selector(injectSIMBL:)
				name:NSWorkspaceDidLaunchApplicationNotification object:nil];
	}
}

- (void) loadInLaunchd
{
	NSTask* task = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:[NSArray arrayWithObjects:@"load", @"-F", @"-S", @"Aqua", @ SIMBLEAGENT_bundle_path "/Contents/Resources/net.culater.SIMBL.Agent.plist", nil]];
	[task waitUntilExit];
	if ([task terminationStatus] != 0)
		SIMBLLogNotice(@"launchctl returned %d", [task terminationStatus]);
}

- (void) injectSIMBL:(NSNotification*)notification
{
	// NOTE: if you change the log level externally, there is pretty much no way
	// to know when the changed. Just reading from the defaults doesn't validate
	// against the backing file very ofter, or so it seems.
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];

	NSDictionary* appInfo = [notification userInfo];
	NSString* appName = [appInfo objectForKey:@"NSApplicationName"];
	SIMBLLogInfo(@"%@ started", appName);
	SIMBLLogDebug(@"app start notification: %@", appInfo);
		
	// check to see if there are plugins to load
	if ([SIMBL shouldInstallPluginsIntoApplication:[NSBundle bundleWithPath:[appInfo objectForKey:@"NSApplicationPath"]]] == NO) {
		SIMBLLogDebug(@"no plugins for %@", appName);
		return;
	}
	
	// BUG: http://code.google.com/p/simbl/issues/detail?id=11
	// NOTE: believe it or not, some applications cause a crash deep in the
	// ScriptingBridge code. Due to the launchd behavior of restarting crashed
	// agents, this is mostly harmless. To reduce the crashing we leave a
	// blacklist to prevent injection.  By default, this is empty.
	NSString* appIdentifier = [appInfo objectForKey:@"NSApplicationBundleIdentifier"];
	NSArray* blacklistedIdentifiers = [defaults stringArrayForKey:@"SIMBLApplicationIdentifierBlacklist"];
	if (blacklistedIdentifiers != nil && 
			[blacklistedIdentifiers containsObject:appIdentifier]) {
		SIMBLLogNotice(@"ignoring injection attempt for blacklisted application %@ (%@)", appName, appIdentifier);
		return;
	}

	fprintf(stderr, "send inject event to %s\n", [appName UTF8String]);
	SIMBLLogDebug(@"send inject event");

	// Find the process to target
	pid_t pid = [[appInfo objectForKey:@"NSApplicationProcessIdentifier"] intValue];

	NSInteger progarch = [(NSRunningApplication*)[appInfo objectForKey:@"NSWorkspaceApplicationKey"] executableArchitecture];
	NSMutableString* cmd = [NSMutableString stringWithUTF8String:"\"" SIMBLEAGENT_bundle_path "/Contents/MacOS/inject_helper"];
	switch(progarch) {
		case NSBundleExecutableArchitectureI386:
			[cmd appendString:@"_32"];
			break;
		case NSBundleExecutableArchitectureX86_64:
			[cmd appendString:@"_64"];
			break;
		case NSBundleExecutableArchitecturePPC:
		case NSBundleExecutableArchitecturePPC64:
			SIMBLLogNotice(@"PPC/PPC64 not supported of %@ (%@)", appName, appIdentifier);
			return;			
		default:
			SIMBLLogNotice(@"unknown architecture of %@ (%@)", appName, appIdentifier);
			return;
	}
	[cmd appendFormat:@"\" %i", pid];
	system([cmd UTF8String]);
}
@end


int main(int argc, char *argv[])
{
	return NSApplicationMain(argc, (const char **)argv);
}


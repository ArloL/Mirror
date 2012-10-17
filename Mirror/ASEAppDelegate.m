#import "ASEAppDelegate.h"

#import <RoutingHTTPServer/RoutingHTTPServer.h>
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>

const static int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface ASEAppDelegate ()

@property (strong) RoutingHTTPServer * httpServer;

@end

@implementation ASEAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    self.httpServer = [RoutingHTTPServer new];
    self.httpServer.type = @"_airplay._tcp.";
    self.httpServer.port = 7000;
    
    NSError * error;
    
    if(![self.httpServer start:&error]) {
        DDLogError(@"%@: Could not start the HTTP server: %@", THIS_FILE, error);
    }
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end

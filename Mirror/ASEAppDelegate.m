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
    
    NSError * error;
    
    if(![self.httpServer start:&error]) {
        DDLogError(@"%@: Could not start the HTTP server: %@", THIS_FILE, error);
    }
    
    // GET METHODS
    
    [self.httpServer get:@"/server-info" withBlock:^(RouteRequest *request, RouteResponse *response) {
        DDLogVerbose(@"GET %@", request.url.path);
        NSString * body = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
                         <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n\
                         <plist version=\"1.0\">\n\
                         <dict>\n\
                         \t<key>deviceid</key>\n\
                         \t<string>94:0C:6D:E6:80:56</string>\n\
                         \t<key>features</key>\n\
                         \t<integer>119</integer>\n\
                         \t<key>model</key>\n\
                         \t<string>AppleTV2,1</string>\n\
                         \t<key>protovers</key>\n\
                         \t<string>1.0</string>\n\
                         \t<key>srcvers</key>\n\
                         \t<string>101.28</string>\n\
                         </dict>\n\
                         </plist>\n";
        [response respondWithString:body];
        
        NSString *date = [[NSDate date] descriptionWithCalendarFormat:@"%a %d %b %Y %H:%M:%S GMT" timeZone:nil locale:nil];
        [response setHeader:@"Date" value:date];
        
        [response setHeader:@"Content-Type" value:@"application/x-apple-plist+xml"];
        [response setHeader:@"X-Apple-Session-Id" value:@"00000000-0000-0000-0000-000000000000"];
    }];
    
    [self.httpServer get:@"/slideshow-features" withBlock:^(RouteRequest *request, RouteResponse *response) {
        DDLogVerbose(@"GET %@", request.url.path);
        response.statusCode = 200;
    }];
    
    [self.httpServer get:@"*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        DDLogVerbose(@"GET *, Requested path: %@", request.url.path);
    }];
    
    // POST METHODS
    
    [self.httpServer post:@"/reverse" withBlock:^(RouteRequest *request, RouteResponse *response) {
        DDLogVerbose(@"POST %@", request.url.path);
        
        response.statusCode = 101;
        
        NSString *date = [[NSDate date] descriptionWithCalendarFormat:@"%a %d %b %Y %H:%M:%S GMT" timeZone:nil locale:nil];
        [response setHeader:@"Date" value:date];
        [response setHeader:@"Upgrade" value:@"PTTH/1.0"];
        [response setHeader:@"Connection" value:@"Upgrade"];
    }];
    
    [self.httpServer post:@"*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        DDLogVerbose(@"POST *, Requested path: %@", request.url.path);
    }];
    
    // PUT METHODS
    
    [self.httpServer put:@"/photo" withBlock:^(RouteRequest *request, RouteResponse *response) {
        DDLogVerbose(@"PUT %@", request.url.path);
        DDLogVerbose(@"Length: %ld", request.body.length);
        //if (delegate && [delegate respondsToSelector:@selector(photoSent:)]) {
        //    [delegate photoSent:request.body];
        //}
    }];
    
    [self.httpServer put:@"*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        DDLogVerbose(@"PUT *, Requested path: %@", request.url.path);
    }];
    
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end

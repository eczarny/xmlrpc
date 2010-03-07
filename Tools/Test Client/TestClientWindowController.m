// 
// Copyright (c) 2010 Eric Czarny <eczarny@gmail.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of  this  software  and  associated documentation files (the "Software"), to
// deal  in  the Software without restriction, including without limitation the
// rights  to  use,  copy,  modify,  merge,  publish,  distribute,  sublicense,
// and/or sell copies  of  the  Software,  and  to  permit  persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED,  INCLUDING  BUT  NOT  LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY,  WHETHER  IN  AN  ACTION  OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
// 

//
// Test Client
// TestClientWindowController.m
//
// Created by Eric Czarny on Tuesday, July 7, 2009.
// Copyright (c) 2010 Divisible by Zero.
//

#import "TestClientWindowController.h"
#import "TestClientConstants.h"

@implementation TestClientWindowController

static TestClientWindowController *sharedInstance = nil;

- (id)init {
    if (self = [super initWithWindowNibName: TestClientWindowNibName]) {
        myResponse = nil;
    }
    
    return self;
}

#pragma mark -

+ (id)allocWithZone: (NSZone *)zone {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [super allocWithZone: zone];
            
            return sharedInstance;
        }
    }
    
    return nil;
}

#pragma mark -

+ (TestClientWindowController *)sharedController {
    @synchronized(self) {
        if (!sharedInstance) {
            [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

#pragma mark -

- (void)awakeFromNib {
    [[self window] center];
}

#pragma mark -

- (void)showTestClientWindow: (id)sender {
    [self showWindow: sender];
}

- (void)hideTestClientWindow: (id)sender {
    [self close];
}

#pragma mark -

- (void)toggleTestClientWindow: (id)sender {
    if ([[self window] isKeyWindow]) {
        [self hideTestClientWindow: sender];
    } else {
        [self showTestClientWindow: sender];
    }
}

#pragma mark -

- (void)sendRequest: (id)sender {
	NSURL *URL = [NSURL URLWithString: [myRequestURL stringValue]];	
	XMLRPCRequest *request = [[[XMLRPCRequest alloc] initWithURL: URL] autorelease];
	NSString *connectionIdentifier;
    
    [request setMethod: [myMethod stringValue] withParameter: [myParameter stringValue]];
    
	[myProgressIndicator startAnimation: self];
	
    [myRequestBody setString: [request body]];
    
	connectionIdentifier = [[XMLRPCConnectionManager sharedManager] spawnConnectionWithXMLRPCRequest: request delegate: self];
    
    [myActiveConnection setHidden: NO];
    
    [myActiveConnection setStringValue: [NSString stringWithFormat: @"Active Connection: %@", connectionIdentifier]];
    
    [mySendRequest setEnabled: NO];
}

#pragma mark -

- (void)dealloc {
    [myResponse release];
    
    [super dealloc];
}

#pragma mark -

#pragma mark Outline View Data Source Methods

#pragma mark -

- (id)outlineView: (NSOutlineView *)outlineView child: (NSInteger)index ofItem: (id)item {
    if (item == nil) {
        item = [myResponse object];
    }
    
    if ([item isKindOfClass: [NSDictionary class]]) {
        return [item objectForKey: [[item allKeys] objectAtIndex: index]];
    } else if ([item isKindOfClass: [NSArray class]]) {
        return [item objectAtIndex: index];
    }
    
    return item;
}

- (BOOL)outlineView: (NSOutlineView *)outlineView isItemExpandable: (id)item {
    if ([item isKindOfClass: [NSDictionary class]] || [item isKindOfClass: [NSArray class]]) {
        if ([item count] > 0) {
            return YES;
        }
    }
    
    return NO;
}

- (NSInteger)outlineView: (NSOutlineView *)outlineView numberOfChildrenOfItem: (id)item {
    if (item == nil) {
        item = [myResponse object];
    }
    
    if ([item isKindOfClass: [NSDictionary class]] || [item isKindOfClass: [NSArray class]]) {
        return [item count];
    } else if (item != nil) {
        return 1;
    }
    
    return 0;
}

- (id)outlineView: (NSOutlineView *)outlineView objectValueForTableColumn: (NSTableColumn *)tableColumn byItem: (id)item {
    NSString *columnIdentifier = (NSString *)[tableColumn identifier];
    
    if ([columnIdentifier isEqualToString: @"type"]) {
        id parentObject = [outlineView parentForItem: item] ? [outlineView parentForItem: item] : [myResponse object];
        
        if ([parentObject isKindOfClass: [NSDictionary class]]) {
            return [[parentObject allKeysForObject: item] objectAtIndex: 0];
        } else if ([parentObject isKindOfClass: [NSArray class]]) {
            return [NSString stringWithFormat: @"Item %d", [parentObject indexOfObject: item]];
        } else if ([item isKindOfClass: [NSString class]]) {
            return @"String";
        } else {
            return @"Object";
        }
    } else {
        if ([item isKindOfClass: [NSDictionary class]] || [item isKindOfClass: [NSArray class]]) {
            return [NSString stringWithFormat: @"%d items", [item count]];
        } else {
            return item;
        }
    }
    
    return nil;
}

#pragma mark -

#pragma mark XMLRPC Connection Delegate Methods

#pragma mark -

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
    [myProgressIndicator stopAnimation: self];
    
    [myActiveConnection setHidden: YES];
    
    [mySendRequest setEnabled: YES];
	
	if ([response isFault]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        
        [alert addButtonWithTitle: @"OK"];
        [alert setMessageText: @"The XML-RPC response returned a fault."];
        [alert setInformativeText: [NSString stringWithFormat: @"Fault String: %@", [response faultString]]];
        [alert setAlertStyle: NSCriticalAlertStyle];
        
        [alert runModal];
    } else {
        [response retain];
        
        [myResponse release];
        
        myResponse = response;
    }
    
    [myParsedResponse reloadData];
    
    [myResponseBody setString: [response body]];
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	
    [[NSApplication sharedApplication] requestUserAttention: NSCriticalRequest];
    
	[alert addButtonWithTitle: @"OK"];
	[alert setMessageText: @"The request failed!"];
	[alert setInformativeText: @"The request failed to return a valid response."];
	[alert setAlertStyle: NSCriticalAlertStyle];
    
	[alert runModal];
    
    [myParsedResponse reloadData];
    
    [myProgressIndicator stopAnimation: self];
	
    [myActiveConnection setHidden: YES];
    
	[mySendRequest setEnabled: YES];
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
	if ([challenge previousFailureCount] == 0) {
		NSURLCredential *credential = [NSURLCredential credentialWithUser: @"user" password: @"password" persistence: NSURLCredentialPersistenceNone];
		
		[[challenge sender] useCredential: credential  forAuthenticationChallenge: challenge];
	} else {
		[[challenge sender] cancelAuthenticationChallenge: challenge];
	}
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
	
}

@end

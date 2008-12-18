# The Cocoa XML-RPC Framework

The  Cocoa  XML-RPC  Framework  is  a  simple,  and  lightweight, XML-RPC client
framework written in Objective-C.

# Requirements

The  Cocoa  XML-RPC Framework has been built, and designed, for Mac OS X 10.4 or
later. This release should provide basic iPhone and iPod touch support.

This  version  of  the  Cocoa  XML-RPC  Framework includes a new event-based XML
parser.  The  previous  tree-based XML parser still exists, but is no longer the
default  XML-RPC  response  parser  nor included in the Xcode build. This should
hopefully provide better compatibility with the iPhone SDK.

# Usage

The  following  example of the Cocoa XML-RPC Framework assumes that the included
XML-RPC  test  server  is  available. More information on the test server can be
found in the README under:

    XMLRPC\Tools\test-server

Please review this document before moving forward.

## Invoking XML-RPC requests through the XML-RPC connection manager

Invoking an XML-RPC request through the XML-RPC connection manager is easy:

    NSURL *URL = [NSURL URLWithString: @"http://127.0.0.1:8080/"];	
    XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: URL];
    XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    
    [request setMethod: @"Echo.echo" withParameter: @"Hello World!"];
    
    NSLog(@"Request body: %@", [request body]);
    
    [manager spawnConnectionWithXMLRPCRequest: request delegate: self];
    
    [request release];

This  spawns  a  new XML-RPC connection, assigning that connection with a unique
identifer  and  returning  it  to  the  sender.  This  unique identifier, a UUID
expressed as an NSString, can then be used to obtain the XML-RPC connection from
the XML-RPC connection manager, as long as it is still active.

The  XML-RPC  connection  manager  has  been  designed to ease the management of
active XML-RPC connections. For example, the following method obtains an NSArray
of active XML-RPC connection identifiers:

    - (NSArray *)activeConnectionIdentifiers;

The  NSArray  returned  by this method contains a list of each active connection
identifier.  Provided  with  a  connection identifier, the following method will
return an instance of the requested XML-RPC connection:

    - (XMLRPCConnection *)connectionForIdentifier: (NSString *)connectionIdentifier;

Finally, for a delegate to receive XML-RPC responses, authentication challenges,
or  errors,  the  XMLRPCConnectionDelegate  protocol  must  be  implemented. For
example, the following will handle successful XML-RPC responses:

    - (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
        if ([response isFault]) {
            NSLog(@"Fault code: %@", [response faultCode]);
            
            NSLog(@"Fault string: %@", [response faultString]);
        } else {
            NSLog(@"Parsed response: %@", [response object]);
        }

        NSLog(@"Response body: %@", [response body]);
    }

Refer  to  XMLRPCConnectionDelegate.h for a full list of methods a delegate must
implement.  Each of these delegate methods plays a role in the life of an active
XML-RPC connection. 

# What if I find a bug, or what if I want to help?

Please, contact me with any questions, comments, suggestions, or problems. I try
to  make  the  time  to  answer  every  request.  If you find a bug, it would be
helpful to also provide steps to reproduce the problem.

Those  wishing  to  contribute  to  the  project  should  begin by obtaining the
latest source with Git:

    $ git clone git://github.com/eczarny/xmlrpc.git XMLRPC

Now that you have a copy of the project, create a new local branch:

    $ git checkout -b my-bug-fix

This new branch, my-bug-fix, is where all of your changes should go.

There  is  always  the possibility that new changes will be pushed to the remote
repository while you make your changes in the my-bug-fix branch. The best way to
keep  up-to-date  with  these changes is to pull them from the remote repository
and use them as the new base for the my-bug-fix branch:

    $ git checkout master
    $ git pull
    $ git rebase master my-bug-fix

The changes from the remote repository are pulled into your local master branch,
providing  you with the most recent base to apply your changes. The changes from
your my-bug-fix branch will then use the most recent changes you pulled from the
remote repository as their base.

Finally, create the patch that you plan on submitting:

    $ git format-patch master --stdout > my-bug-fix.diff

This  patch,  my-bug-fix.diff, now contains all of your changes. Please, be sure
to provide your patch with a detailed description of your changes.

# Acknowledgments

The  Base64  encoder/decoder found in NSStringAdditions and NSDataAdditions have
been adapted from code provided by Dave Winer.

The  idea  for  this framework came from examples provided by Brent Simmons, the
creator of NetNewsWire.

# License

Copyright (c) 2008 Eric Czarny.

The  Cocoa XML-RPC Framework  should  be  accompanied  by  a  LICENSE file, this
file  contains  the  license relevant to this distribution. If no LICENSE exists
please contact Eric Czarny <eczarny@gmail.com>.

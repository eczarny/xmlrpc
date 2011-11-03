package com.divisiblebyzero.xmlrpc.model;

// 
// Copyright (c) 2011 Eric Czarny <eczarny@gmail.com>
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
// xmlrpc.model.Server.java
// test-server
//
// Created by Eric Czarny on Friday, March 20, 2009.
// Copyright (c) 2011 Divisible by Zero.
//

import com.divisiblebyzero.xmlrpc.view.XmlRpcServerControlPanel;

import org.apache.xmlrpc.server.PropertyHandlerMapping;
import org.apache.xmlrpc.server.XmlRpcServer;
import org.apache.xmlrpc.webserver.WebServer;

public class Server {
    private static final int port = 8080;
    private WebServer embeddedWebServer;
    private XmlRpcServer embeddedXmlRpcServer;
    private boolean running;
    private XmlRpcServerControlPanel controlPanel;
    
    public Server(XmlRpcServerControlPanel controlPanel) {
        this.embeddedWebServer = new WebServer(Server.port);
        this.embeddedXmlRpcServer = this.embeddedWebServer.getXmlRpcServer();
        this.running = false;
        this.controlPanel = controlPanel;
        
        PropertyHandlerMapping propertyHandlerMapping = new PropertyHandlerMapping();
        
        try {
            propertyHandlerMapping.load(Thread.currentThread().getContextClassLoader(), "handlers.properties");
        } catch (Exception e) {
            this.controlPanel.addLogMessage(e.getMessage());
        }
        
        this.embeddedXmlRpcServer.setHandlerMapping(propertyHandlerMapping);
    }
    
    public void startEmbeddedWebServer() {
        try {
            this.embeddedWebServer.start();
            
            this.controlPanel.addLogMessage("The XML-RPC server has been started on port " + Server.port + ".");
        } catch (Exception e) {
            this.controlPanel.addLogMessage(e.getMessage());
        }
        
        this.running = true;
    }
    
    public void stopEmbeddedWebServer() {
        try {
            this.embeddedWebServer.shutdown();
            
            this.controlPanel.addLogMessage("The XML-RPC server has been stopped.");
        } catch (Exception e) {
            this.controlPanel.addLogMessage(e.getMessage());
        }
        
        this.running = false;
    }
    
    public boolean isRunning() {
    	return this.running;
    }
}

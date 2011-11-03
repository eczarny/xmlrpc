package com.divisiblebyzero.xmlrpc.controller;

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
// xmlrpc.controller.XmlRpcServerControlPanelController.java
// test-server
//
// Created by Eric Czarny on Friday, March 20, 2009.
// Copyright (c) 2011 Divisible by Zero.
//

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import com.divisiblebyzero.xmlrpc.model.Server;
import com.divisiblebyzero.xmlrpc.view.XmlRpcServerControlPanel;

public class XmlRpcServerControlPanelController implements ActionListener {
    private XmlRpcServerControlPanel controlPanel;
    private Server xmlRpcServer;
    
    public XmlRpcServerControlPanelController(XmlRpcServerControlPanel controlPanel) {
        this.controlPanel = controlPanel;
        this.xmlRpcServer = new Server(this.controlPanel);
    }
    
    public void actionPerformed(ActionEvent actionEvent) {
        String actionCommand = actionEvent.getActionCommand();
        
        if (actionCommand.equals("Start")) {
            this.startXmlRpcServer();
        } else if (actionCommand.equals("Stop")) {
            this.stopXmlRpcServer();
        } else if (actionCommand.equals("Restart")) {
            this.restartXmlRpcServer();
        }
        
        this.controlPanel.refreshControls();
    }
    
    public boolean isXmlRpcServerRunning() {
    	return this.xmlRpcServer.isRunning();
    }
    
    private void startXmlRpcServer() {
        this.controlPanel.addLogMessage("Starting the XML-RPC server.");
        
        this.xmlRpcServer.startEmbeddedWebServer();
    }
    
    private void stopXmlRpcServer() {
        if (this.xmlRpcServer == null) {
            this.controlPanel.addLogMessage("Unable to stop the XML-RPC server, none could be found.");
            
            return;
        }
        
        this.controlPanel.addLogMessage("Stopping the XML-RPC server.");
        
        this.xmlRpcServer.stopEmbeddedWebServer();
    }
    
    private void restartXmlRpcServer() {
        if (this.xmlRpcServer == null) {
            this.controlPanel.addLogMessage("Unable to restart the XML-RPC server, none could be found.");
            
            return;
        }
        
        this.controlPanel.addLogMessage("Restarting the XML-RPC server.");
        
        this.xmlRpcServer.stopEmbeddedWebServer();
        
        this.xmlRpcServer.startEmbeddedWebServer();
    }
}

package com.divisiblebyzero.xmlrpc.view;

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
// xmlrpc.view.XmlRpcServerControlPanel.java
// xmlrpc-server
//
// Created by Eric Czarny on Friday, March 20, 2009.
// Copyright (c) 2011 Divisible by Zero.
//

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Toolkit;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextPane;

import com.divisiblebyzero.xmlrpc.controller.XmlRpcServerControlPanelController;

public class XmlRpcServerControlPanel extends JFrame {
    private static final long serialVersionUID = -7835812670356078909L;
    private XmlRpcServerControlPanelController xmlRpcServerControlPanelController;
    private JTextPane logMessageTextPane;
    private JButton startButton;
    private JButton stopButton;
    private JButton restartButton;
    
    public XmlRpcServerControlPanel() {
        super("Control Panel");
        
        this.xmlRpcServerControlPanelController = new XmlRpcServerControlPanelController(this);
        
        int x = Toolkit.getDefaultToolkit().getScreenSize().width;
        int y = Toolkit.getDefaultToolkit().getScreenSize().height;
        
        int width, height;
        
        width = 500;
        height = 500;
        
        this.setBounds(((x - (width)) / 2), ((y - (height)) / 2) - (height / 4), width, height);
        
        this.setResizable(false);
        
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
        this.initialize();
        
        this.setVisible(true);
    }
    
    private void initialize() {
        Container container = this.getContentPane();
        
        container.setLayout(new BorderLayout());
        
        /* North Panel */
        container.add(new JPanel(), BorderLayout.NORTH);
        
        /* East Panel */
        container.add(new JPanel(), BorderLayout.EAST);
        
        /* Center Panel */
        JPanel center = new JPanel();
        center.setBorder(BorderFactory.createTitledBorder(" " + "Server Log" + " "));
        
        this.logMessageTextPane = new JTextPane();
        
        this.logMessageTextPane.setEditable(false);
        this.logMessageTextPane.setBackground(Color.WHITE);
        this.logMessageTextPane.setFont(new Font("Monospaced", Font.PLAIN, 12));
        
        this.logMessageTextPane.setText("Server awaiting action...");
        
        JScrollPane scrollableTextPane = new JScrollPane(this.logMessageTextPane);
        scrollableTextPane.setBorder(BorderFactory.createLineBorder(Color.GRAY));
        scrollableTextPane.setPreferredSize(new Dimension(435, 374));
        
        center.add(scrollableTextPane);
        
        container.add(center, BorderLayout.CENTER);
        
        /* South Panel */
        container.add(this.createSouthernPanel(), BorderLayout.SOUTH);
        
        /* West Panel */
        container.add(new JPanel(), BorderLayout.WEST);
    }
    
    private JPanel createSouthernPanel() {
        JPanel south = new JPanel();
        
        south.setPreferredSize(new Dimension(425, 47));
        
        /* Start & Stop Panel */
        JPanel startAndStopPanel = new JPanel();
        
        startButton = new JButton("Start");
        
        startButton.setPreferredSize(new Dimension(85, 25));
        startButton.addActionListener(this.xmlRpcServerControlPanelController);
        
        startAndStopPanel.add(startButton);
        
        startAndStopPanel.add(new JLabel(" / "));
        
        stopButton = new JButton("Stop");
        
        stopButton.setPreferredSize(new Dimension(85, 25));
        stopButton.addActionListener(this.xmlRpcServerControlPanelController);
        
        startAndStopPanel.add(stopButton);
        
        south.add(startAndStopPanel);
        
        JPanel padding = new JPanel();
        padding.setPreferredSize(new Dimension(150, 25));
        
        south.add(padding);
        
        /* Restart Panel */
        JPanel restartPanel = new JPanel();
        
        restartButton = new JButton("Restart");
        
        restartButton.setPreferredSize(new Dimension(95, 25));
        restartButton.addActionListener(this.xmlRpcServerControlPanelController);
        
        restartPanel.add(restartButton);
        
        south.add(restartPanel);
        
        this.refreshControls();
        
        return south;
    }
    
    public void addLogMessage(String message) {
        String existingLogMessages = this.logMessageTextPane.getText() + "\n";
        
        this.logMessageTextPane.setText(existingLogMessages + message);
    }
    
    public void refreshControls() {
    	if (this.xmlRpcServerControlPanelController.isXmlRpcServerRunning()) {
    		this.startButton.setEnabled(false);
    		this.stopButton.setEnabled(true);
    		this.restartButton.setEnabled(true);
    	} else {
    		this.startButton.setEnabled(true);
    		this.stopButton.setEnabled(false);
    		this.restartButton.setEnabled(false);
    	}
    }
}

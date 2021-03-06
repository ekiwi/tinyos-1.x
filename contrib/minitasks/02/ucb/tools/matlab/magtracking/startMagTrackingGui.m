%startMagTrackingGui
%This file sets matlab up to use the tool for watching the magtracking
%application.  Make sure you type "make" twice from the
%tinyos/tools/java/net/tinyos/magtracking directory to generate the
%appropriate java classes.  Also make sure you setup matlab properly by
%reading the tinyos/doc/tutorials/matlab.html file.
%make sure you run serial forwarder before trying to start this GUI and
%make sure that it serves on port 9001.

%     "Copyright (c) 2000 and The Regents of the University of California.  All rights reserved.
% 
%     Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without written agreement 
%     is hereby granted, provided that the above copyright notice and the following two paragraphs appear in all copies of this software.
%     
%     IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING 
%     OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%     THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
%     FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
%     PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
%     
%     Authors:  Kamin Whitehouse <kamin@cs.berkeley.edu>
%     Date:     Nov 18, 2002 

import net.tinyos.*
import net.tinyos.message.*
import net.tinyos.magtracking.*

%add this directory to the matlab path
addpath(pwd)
addpath([pwd '\networkStatistics'])

%connect to your serial forward objects with MoteInterface objects
mIF(1) = net.tinyos.message.MoteIF('localhost', 9001, 116, 29, 0);

%Create the message objects that you need to interact with your ranging
%motes.  Each packet type should have a different AM type and a different
%receiving function.  We will eavesdrop on these packets and try to display
%them graphically.
RouteByBroadcast = magtracking.RouteByBroadcast;
RouteByAddress = magtracking.RouteByAddress;
RouteByLocation = magtracking.RouteByLocation;

%register certain matlab functions to listen on certain moteIF
%objects for certain message types
mml(1) = net.tinyos.matlab.MatlabMessageListener;
mml(1).registerMessageListener('routeByBroadcastMessageReceived');
mml(1).registerMessageListener('magTrackingNetworkStatisticsMessageReceived');
mml(2) = net.tinyos.matlab.MatlabMessageListener;
mml(2).registerMessageListener('routeByAddressMessageReceived');
mml(2).registerMessageListener('magTrackingNetworkStatisticsMessageReceived');
mml(3) = net.tinyos.matlab.MatlabMessageListener;
mml(3).registerMessageListener('routeByLocationMessageReceived');
mml(3).registerMessageListener('magTrackingNetworkStatisticsMessageReceived');
mIF(1).registerListener(RouteByBroadcast, mml(1));
mIF(1).registerListener(RouteByAddress, mml(2));
mIF(1).registerListener(RouteByLocation, mml(3));


%start your mote interface so they receive packets
mIF(1).start;

%initialize the MAG_TRACKING variable, which holds the state of the gui
global MAG_NET_STATS
if isempty(MAG_NET_STATS)
    initializeMagTrackingNetworkStatistics;
end
global MAG_TRACKING
if isempty(MAG_TRACKING)
    initializeMagTracking;
end



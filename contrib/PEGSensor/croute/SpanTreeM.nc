/*
 * "Copyright (c) 2000-2002 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 * AUTHOR: nks
 * DATE:   6/21/03
 */

//!! Config 30 { SpanTreeRetries_t SpanTreeRetries = { build:0, route:0, surge:0 }; }
//!! SpanTreeReinitCmd = CreateCommand[SystemCommand]( CommandHood, Void_t, Void_t, 32, 33 );
//!! SpanTreeStatusCmd = CreateCommand[SystemCommand]( CommandHood, Void_t, SpanTreeStatus_t, 34, 35 );

includes ERBcast;

module SpanTreeM
{
  provides {
    interface ERoute;
    interface StdControl;
    command void getRouteData(SpanTreeStatusConcise_t* val);
    event void epochExpired(uint8_t* payload);
    }
  uses {
    interface RoutingSendByImplicit as BcastSend;
    interface RoutingSendByAddress as RouteSend;
    
    interface Receive as BcastRecv;
    interface RoutingReceive as RouteRecv;
    interface Leds;

    interface SpanTreeReinitCmd;
    interface SpanTreeStatusCmd;
  }
}
implementation {
  // buffer management structures:
  struct bufentry {
    TOS_Msg buf;
    struct bufentry * next;
  };
  enum { ER_MAX_BUFS = 3};
  struct bufentry bufs[ER_MAX_BUFS];
  struct bufentry * bufhead;
  uint8_t numbufs;

  uint16_t bcastseqno;
  SpanTreeRoute_t routes[MAX_TREES];
  SpanTreeCrumb_t crumbs[MAX_MOBILE_AGENTS];

  uint8_t currentTree;
  uint8_t currentType;

  uint16_t counter;
  // ------------------ HELPERS & INIT  ---------------------  

  // gets a free message buffer for use. returns NULL if none exists
  static TOS_MsgPtr getBuf()
    {
      struct bufentry * w = bufhead;
      if (w == NULL) return NULL;
      numbufs--;
      bufhead = bufhead->next;
      //      dbg(DBG_USR1, "SpanTree:getBuf() returned %p; numbufs%d\n",
      //          &w->buf, numbufs);
      initRoutingMsg( &w->buf, 0 );
      return &w->buf;
    }

  // returns a message buffer to the pool of buffers.
  static void returnBuf (TOS_MsgPtr ptr)
    {
      // watch out. we use a real disgusting hack here: the tosmsgptr offset
      // is taken to be the start of the enclosing bufentry struct. so we just
      // cast from tosmsgptr to bufentry and use it. ick, i know.
      if (ptr < (TOS_MsgPtr)bufs ||
          ptr > (TOS_MsgPtr)&bufs[ER_MAX_BUFS +1]) return;
      numbufs++;
      //      dbg(DBG_USR1, "SpanTree:returnBuf() received %p; numbufs=%d\n",
      //          ptr, numbufs);      
      ((struct bufentry*)ptr)->next = bufhead;
      bufhead = (struct bufentry*)ptr;
    }

  static void initBufs()
    {
      int i;
      numbufs = 0;
      bufhead = NULL;
      for (i = 0 ; i < ER_MAX_BUFS; i++) {
	returnBuf (&bufs[i].buf);
      }
    }

  static void initTree()
    {
      int i;
      bcastseqno = 1;
      for (i = 0; i < MAX_TREES; i++) {
        routes[i].hopCount = 0xff;        
        routes[i].parent = NO_ROUTE;
      }
      for (i = 0; i < MAX_MOBILE_AGENTS; i++) {
        crumbs[i].crumbseqno = 0;
        crumbs[i].parent = NO_ROUTE;
      }
    }

  command result_t StdControl.init ()
    {
      dbg(DBG_USR1, "SpanTree.init() called\n");
      initTree();
      initBufs();
      return SUCCESS;
    }
  
  command result_t StdControl.start ()
    {
      return SUCCESS;
    }

  command result_t StdControl.stop ()
    {
      return SUCCESS;
    }    
  
  // convert mobile agent number to an offset that we can use to index into
  // arrays. 
  uint8_t matoo (EREndpoint ma) {
    if (ma > MAX_MOBILE_AGENTS + MAX_TREES) return 0xff;
    if (ma < MAX_TREES) return 0xff;
    return ma - MAX_TREES;
  }

  static result_t fanout(EREndpoint dest, uint8_t * data, uint8_t len) 
    {
      int i;
      TOS_MsgPtr msgbuf;
      ERMsg * outgoing;
      
      if (dest == MA_ALL) {
        // fan the message out to all mobile agent by sending using the
        // queued send iface.
        for (i = 0 ; i < MAX_MOBILE_AGENTS; i++) {
          if (crumbs[i].parent != NO_ROUTE) {
            if (crumbs[i].parent == TOS_LOCAL_ADDRESS) {
              // just deliver it to us:
              signal ERoute.receive (dest, len, data);
              continue;
            }
            msgbuf = getBuf();
            if (!msgbuf) {
              dbg(DBG_USR1, "SpanTreeM: Recv couldn't get msg buffer\n");
              return FAIL;
            }
            outgoing = (ERMsg*)msgbuf->data;
            outgoing->type = CRUMB_TO_MOBILE;
            
            outgoing->treeNumber = i + MAX_TREES;
            outgoing->u.lmm.len = len;
            memcpy(outgoing->u.lmm.data, data, len);
            outgoing->u.lmm.crumbNumber = crumbs[i].crumbseqno;
            
            dbg(DBG_USR1, "+++SpanTree:RouteRcv: ma%d, nexthop %d \n", i,
                crumbs[matoo(outgoing->treeNumber)].parent);
            
	    msgbuf->length = ER_LMM_HDR_SIZE + len;
	    msgbuf->ext.retries = G_Config.SpanTreeRetries.route;
            call RouteSend.send(crumbs[matoo(outgoing->treeNumber)].parent,
                                msgbuf);
          }
        }
      } else {
        if (crumbs[matoo(dest)].parent == TOS_LOCAL_ADDRESS) {
          // just deliver it to us:
          signal ERoute.receive (dest, len, data);
          return SUCCESS;
        }
        // just send it to one mobile agent
        msgbuf = getBuf();
        if (!msgbuf) {
          dbg(DBG_USR1, "SpanTreeM: Recv couldn't get msg buffer\n");
          return FAIL;
        }
        dbg(DBG_USR1, "SpanTreeM: A\n");        
        outgoing = (ERMsg*) msgbuf->data;
        dbg(DBG_USR1, "SpanTreeM: B\n");        
        outgoing->type = CRUMB_TO_MOBILE;
        dbg(DBG_USR1, "SpanTreeM: C\n");        
            
        outgoing->treeNumber = dest;
        dbg(DBG_USR1, "SpanTreeM: D\n");        
        outgoing->u.lmm.len = len;
        dbg(DBG_USR1, "SpanTreeM: E\n");        
        memcpy(outgoing->u.lmm.data, data, len);
          dbg(DBG_USR1, "SpanTreeM: F\n");        
        outgoing->u.lmm.crumbNumber =
          crumbs[matoo(outgoing->treeNumber)].crumbseqno;

        dbg(DBG_USR1, "+++SpanTree:RouteRcv: ma%d, nexthop %d \n",
            matoo(outgoing->treeNumber),
            crumbs[outgoing->treeNumber].parent);

        msgbuf->length = ER_LMM_HDR_SIZE + len;
	msgbuf->ext.retries = G_Config.SpanTreeRetries.route;
        call RouteSend.send (crumbs[matoo(outgoing->treeNumber)].parent,
                             msgbuf);
      }      
      return SUCCESS;
    }
  
  // ------------------ OUTBOUND  ---------------------
  
  command result_t ERoute.build (EREndpoint local)
    {
      // initiate a broadcast wave using an increasing seq no rooted at this
      // node.
      TOS_MsgPtr msgbuf = getBuf();
      TOS_BcastMsg * pmsg;
      ERMsg * pemsg;
      if (!msgbuf) {
        dbg(DBG_USR1, "SpanTreeM: build couldn't get msg buffer\n");
        return FAIL;
      }
      pmsg = (TOS_BcastMsg*)msgbuf->data;
      pemsg = (ERMsg*)pmsg->data;
      pmsg->seqno = bcastseqno++;
      // we're the endpoint, so our parent is ourself.
      routes[local].hopCount = 0;
      routes[local].parent = TOS_LOCAL_ADDRESS;
      pemsg->type = TREE_BUILD;
      pemsg->treeNumber = local;
      pemsg->u.treeBuild.hopCount = 1;
      pemsg->u.treeBuild.parent = TOS_LOCAL_ADDRESS;

      dbg (DBG_USR1, "SpanTree.build(seqno 0x%x), %d\n", pmsg->seqno); 

      msgbuf->length = ER_BCAST_HDR + ER_TREE_BUILD_SIZE;
      msgbuf->ext.retries = G_Config.SpanTreeRetries.build;
      call BcastSend.send(msgbuf);
      return SUCCESS;
    }

  command result_t ERoute.buildTrail (EREndpoint local, EREndpoint tree,
                                      uint16_t seqno)
    {
      // builds a crumb trail
      TOS_MsgPtr msgbuf = getBuf();
      ERMsg * pemsg;
      if (!msgbuf) {
        dbg(DBG_USR1, "SpanTreeM: buildTrail couldn't get msg buffer\n");
        return FAIL;
      }
      pemsg = (ERMsg*)msgbuf->data;      

      // make sure that the tree is routable:
      if (tree >= MAX_TREES || routes[tree].parent == NO_ROUTE) return FAIL;

      // we're the crumb endpoint, so store ourself in the parent list
      crumbs[matoo(local)].parent = TOS_LOCAL_ADDRESS;
      crumbs[matoo(local)].crumbseqno = seqno;
      
      pemsg->type = CRUMB_BUILD;
      pemsg->treeNumber = tree;
      pemsg->u.crumbBuild.mobileAgent = local; // the agent number. 
      pemsg->u.crumbBuild.crumbNumber = seqno;
      pemsg->u.crumbBuild.parent = TOS_LOCAL_ADDRESS;

      dbg (DBG_USR1, "SpanTree.buildTrail(tree %d,seqno 0x%x), %d\n", tree,
           seqno);

      // and send it on its way using on the route am handler
      msgbuf->length = ER_CRUMB_BUILD_SIZE;
      msgbuf->ext.retries = G_Config.SpanTreeRetries.route;
      return call RouteSend.send (routes[tree].parent, msgbuf);
    }

  command result_t ERoute.send (EREndpoint dest, uint8_t dataLen,
                                uint8_t * data)
    {
      TOS_MsgPtr msgbuf = getBuf();
      // FIXME: we're just picking the first tree: should this be input param?
      EREndpoint tree_number = TREE_LANDMARK;
      ERMsg * pmsg;
      if (!msgbuf) {
        dbg(DBG_USR1, "SpanTreeM: ERoute.send couldn't get msg buffer\n");
        return FAIL;
      }
      pmsg = (ERMsg*)msgbuf->data;      
        
      if (dest < MAX_TREES) {
        // we're sending to a landmark (basestation) ; make sure we have
        // a next hope route in place, and send a base station message.
        if (routes[dest].parent == NO_ROUTE) return FAIL;
        pmsg->type = MSG_TO_BASE;
        pmsg->treeNumber = dest;
        pmsg->u.base.len = dataLen;
        memcpy (pmsg->u.base.data, data, dataLen);
	msgbuf->length = dataLen + ER_BASE_HDR_SIZE;
	msgbuf->ext.retries = G_Config.SpanTreeRetries.route;
        return call RouteSend.send (routes[dest].parent, msgbuf);
      }
      if (dest > MAX_TREES + MAX_MOBILE_AGENTS &&
          dest != MA_ALL) return FAIL;

      // we're the tree route, so we need to do the fanout right here and send
      // this as a TO_MOBILE message
      if (routes[tree_number].parent == TOS_LOCAL_ADDRESS) {      
        returnBuf(msgbuf); // we didn't end up using teh buffer.
        fanout (dest, data, dataLen);
        return SUCCESS;
      }
      
      // otherwise, we're sending to a mobile agent. so we'lls end a mesage to
      // the base station first, which will forward it on to the appropriate
      // mobile agents. 
      pmsg->type = CRUMB_TO_BASE;
      pmsg->treeNumber = tree_number;
      if (routes[pmsg->treeNumber].parent == NO_ROUTE) return FAIL;
      
      pmsg->u.lm.destination = dest;
      pmsg->u.lm.len = dataLen;
      memcpy (pmsg->u.lm.data, data, dataLen);
      msgbuf->length = dataLen + ER_LM_HDR_SIZE;
      msgbuf->ext.retries = G_Config.SpanTreeRetries.route;
      return call RouteSend.send (routes[pmsg->treeNumber].parent,
                                  msgbuf);
    }

  default event result_t ERoute.sendDone (EREndpoint dest, uint8_t * data)
    {
      return SUCCESS;
    }

  event result_t RouteSend.sendDone(TOS_MsgPtr msg, result_t success)
    {
      returnBuf(msg);
      return SUCCESS;
    }

  event result_t BcastSend.sendDone(TOS_MsgPtr msg,
                                                result_t success)
    {
      // watch out here, this event is also called with the ERBcast.send
      // because of the way the components have been routed. thus, we've coded
      // returnBuf to be fairly defensive about what it accepts.
      returnBuf(msg);
      return SUCCESS;
    }  

  // ------------------ RECV  ---------------------  
  // signal when bcast timer expired, time to forward
  event void epochExpired(uint8_t *payload) {
    // fill in the payload
    ERMsg * pmsg = (ERMsg*)payload;
    pmsg->type = currentType;
    pmsg->treeNumber = currentTree;
    pmsg->u.treeBuild.hopCount = routes[pmsg->treeNumber].hopCount + 1;
    pmsg->u.treeBuild.parent = TOS_LOCAL_ADDRESS;

  }

  
  event TOS_MsgPtr BcastRecv.receive(TOS_MsgPtr pMsg, void* payload,
                                     uint16_t payloadLen)
    {
      ERMsg * pmsg = (ERMsg*)payload;
      // broadcast messages are only received in generating the spanning tree.
      
      currentType = pmsg->type;
      dbg(DBG_USR1, "SpanTree:bcastRecv: Got message with type = %d\n",
          pmsg->type);
      switch (pmsg->type) {
      case TREE_BUILD:
        // we modify the message in this event BEFORE it is sent out the door
        // in the broadcast. thus, anyone who hears this message from us will
        // see the modified copy.
        dbg(DBG_USR1, "SpanTree:bcastRecv: tree build message\n");        

	// smaller hop or equal hop but better signal strength
	if (pmsg->u.treeBuild.hopCount < routes[pmsg->treeNumber].hopCount
	    || (pmsg->u.treeBuild.hopCount == routes[pmsg->treeNumber].hopCount && 
		pMsg->strength < routes[pmsg->treeNumber].signalStrength)) {
	  dbg (DBG_USR1, "TREE%d DIRECTED GRAPH: remove edge %d\n",
	       pmsg->treeNumber, pmsg->u.treeBuild.parent);          
	  // remember the tree for later 
	  currentTree = pmsg->treeNumber;

	  // set the input signal strength as best one we have
	  routes[pmsg->treeNumber].signalStrength = pMsg->strength;
	  // modify the route tables:
	  routes[pmsg->treeNumber].parent = pmsg->u.treeBuild.parent;
	  routes[pmsg->treeNumber].hopCount = pmsg->u.treeBuild.hopCount;
	
	  call Leds.set (pmsg->u.treeBuild.hopCount);
	  //call Leds.set(routes[pmsg->treeNumber].parent);
        
	  dbg (DBG_USR1, "TREE%d DIRECTED GRAPH: add edge %d\n",
	       pmsg->treeNumber, pmsg->u.treeBuild.parent);
        
	  // change the message so that recipients will use us as their parent
	  /*
	  pmsg->u.treeBuild.hopCount++;
	  pmsg->u.treeBuild.parent = TOS_LOCAL_ADDRESS;
	  */
	  break;
	}
      default:
      }
      return pMsg;
    }
  


  event TOS_MsgPtr RouteRecv.receive(TOS_MsgPtr pMsg)
    {
      ERMsg * pmsg = (ERMsg*)pMsg->data;
      //ERMsg * outgoing; //
      TOS_MsgPtr msgbuf;
      //uint8_t i; //unused
      
      dbg(DBG_USR1, "SpanTree:RouteRecv: message type %d\n", pmsg->type);

      switch (pmsg->type) {
      case CRUMB_BUILD:
        // building the crumb tree
        dbg(DBG_USR1, "SpanTree:RouteRcv: crumb build message for MA: %d\n",
            pmsg->u.crumbBuild.mobileAgent);

        // make sure that we have someone that we can forward the message on
        // to before proceeding [we drop otherwise]
        if (routes[pmsg->treeNumber].parent != NO_ROUTE) {
          dbg(DBG_USR1, "CRUMB%d DIRECTED GRAPH: remove edge %d\n",
              matoo(pmsg->u.crumbBuild.mobileAgent),              
              crumbs[matoo(pmsg->u.crumbBuild.mobileAgent)].parent);
          // store who the message came from. this will be used when sending
          // back to the mobile agent. 
          crumbs[matoo(pmsg->u.crumbBuild.mobileAgent)].crumbseqno =
            pmsg->u.crumbBuild.crumbNumber;
          crumbs[matoo(pmsg->u.crumbBuild.mobileAgent)].parent =
            pmsg->u.crumbBuild.parent;
          dbg(DBG_USR1, "CRUMB%d DIRECTED GRAPH: add edge %d\n",
              matoo(pmsg->u.crumbBuild.mobileAgent),
              crumbs[matoo(pmsg->u.crumbBuild.mobileAgent)].parent);
          //call Leds.yellowOn();
          
          if (routes[pmsg->treeNumber].parent != TOS_LOCAL_ADDRESS) {
            // modify the parent and then copy into own buffer and send
            pmsg->u.crumbBuild.parent = TOS_LOCAL_ADDRESS;
            msgbuf = getBuf();
            if (!msgbuf) {
              dbg(DBG_USR1, "SpanTreeM: receive couldn't get msg buffer\n");
              return FAIL;
            }
            memcpy (msgbuf->data, pMsg->data, pMsg->length);
	    msgbuf->length = pMsg->length;
	    msgbuf->ext.retries = G_Config.SpanTreeRetries.route;
            call RouteSend.send (routes[pmsg->treeNumber].parent, msgbuf);
          }
        }
        break;
      case MSG_TO_BASE:
        dbg(DBG_USR1, "SpanTree:RouteRcv: base station message\n");
        if (routes[pmsg->treeNumber].parent == TOS_LOCAL_ADDRESS) {
          // the message is for us! so deliver
          signal ERoute.receive (pmsg->treeNumber, pmsg->u.base.len,
                                 pmsg->u.base.data);
        } else if (routes[pmsg->treeNumber].parent != NO_ROUTE) {
          // send the message along          // copy into new buf first:
          msgbuf = getBuf();
          if (!msgbuf) {
            dbg(DBG_USR1, "SpanTreeM: receive couldn't get msg buffer\n");
            return FAIL;
          }
          memcpy (msgbuf->data, pMsg->data, pMsg->length);
          //call Leds.greenOn();          
	  msgbuf->length = pMsg->length;
	  msgbuf->ext.retries = G_Config.SpanTreeRetries.route;
          call RouteSend.send (routes[pmsg->treeNumber].parent, msgbuf);
        }
        break;
      case CRUMB_TO_BASE:
        dbg(DBG_USR1, "SpanTree:RouteRcv: crumb: to base message\n");
        
        if (routes[pmsg->treeNumber].parent == TOS_LOCAL_ADDRESS) {
          // we're the base station for this message. so we need to forward
          // the message on. we convert the message to a crumb to mobile
          // message and then send it out
          dbg(DBG_USR1, "SpanTree:RouteRcv: translating to LMM message\n");
          fanout (pmsg->u.lm.destination, pmsg->u.lm.data, pmsg->u.lm.len);
          
        } else if (routes[pmsg->treeNumber].parent != NO_ROUTE) {
          // we're just a router along the way to the base station, so send it
          // using the spanning tree routing.
          // copy into own buffer first
          msgbuf = getBuf();
          if (!msgbuf) {
            dbg(DBG_USR1, "SpanTreeM: Recv couldn't get msg buffer\n");
            return FAIL;
          }
          //call Leds.greenOn(); 
          memcpy (msgbuf->data, pMsg->data, pMsg->length);
	  msgbuf->length = pMsg->length;
	  msgbuf->ext.retries = G_Config.SpanTreeRetries.route;
          call RouteSend.send (routes[pmsg->treeNumber].parent, msgbuf);
        }
        break;
      case CRUMB_TO_MOBILE:
        dbg(DBG_USR1, "SpanTree:RouteRcv: route: to ma%d\n", pmsg->treeNumber);
        if (crumbs[matoo(pmsg->treeNumber)].parent == TOS_LOCAL_ADDRESS) {
          dbg(DBG_USR1, "SpanTree:RouteRcv: passing up (deliver) to ma%d\n",
              pmsg->treeNumber);          
	  counter++;
          // this message is for us: so deliver it
          signal ERoute.receive (pmsg->treeNumber, pmsg->u.lmm.len,
                                 pmsg->u.lmm.data);
        } else if (crumbs[matoo(pmsg->treeNumber)].parent != NO_ROUTE) {
          // we're just a router along the crumb path: so send the message
          // along using the crumb information for routing.
          // copy into own buffer first
          msgbuf = getBuf();
          if (!msgbuf) {
            dbg(DBG_USR1, "SpanTreeM: Recv couldn't get msg buffer\n");
            return FAIL;
          } 
          memcpy (msgbuf->data, pMsg->data, pMsg->length);
          //call Leds.redOn();           
	  msgbuf->length = pMsg->length;
	  msgbuf->ext.retries = G_Config.SpanTreeRetries.route;
          call RouteSend.send (crumbs[matoo(pmsg->treeNumber)].parent, msgbuf);
        }
        break;
      default:
      }
      return pMsg;
    }

  event void SpanTreeReinitCmd.receiveCall( SpanTreeReinitCmdArgs_t args )
  {
    initTree();
    call SpanTreeReinitCmd.dropReturn();
  }

  event void SpanTreeReinitCmd.receiveReturn( nodeID_t node, SpanTreeReinitCmdReturn_t rets )
  {
  }

  command void getRouteData(SpanTreeStatusConcise_t* val) {
    val->Route1 = routes[0];
    val->BCastSeqNo = bcastseqno;
    val->Crumb1 = crumbs[0];
    val->Crumb2 = crumbs[1];
    val->numPacketReceived = counter;
  }

  event void SpanTreeStatusCmd.receiveCall( SpanTreeStatusCmdArgs_t args )
  {
    SpanTreeStatus_t status = {
      Route1 : routes[0],
      Route2 : routes[1],
      BCastSeqNo : bcastseqno,
      Crumb1 : crumbs[0],
      Crumb2 : crumbs[1],
      numPacketReceived : counter
    };

    call SpanTreeStatusCmd.sendReturn( status );
  }

  event void SpanTreeStatusCmd.receiveReturn( nodeID_t node, SpanTreeStatusCmdReturn_t rets )
  {
  }
}


/**
 * Copyright (c) 2007, Institute of Parallel and Distributed Systems
 * (IPVS), Universität Stuttgart. 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 
 *  - Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 
 *  - Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the
 *    distribution.
 * 
 *  - Neither the names of the Institute of Parallel and Distributed
 *    Systems and Universität Stuttgart nor the names of its contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 */
package ncunit.avrora;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.StringTokenizer;

import ncunit.output.Comparison;
import ncunit.types.TypeSystem;
import net.tinyos.nesc.dump.xml.IntegerConstant;
import net.tinyos.nesc.dump.xml.Xfunction;
import net.tinyos.nesc.dump.xml.Xvariable;

import avrora.core.Program;
import avrora.core.Register;
import avrora.core.SourceMapping;
import avrora.monitors.Monitor;
import avrora.monitors.MonitorFactory;
import avrora.sim.BaseInterpreter;
import avrora.sim.Simulator;
import avrora.sim.State;
import avrora.sim.Simulator.Probe;
import avrora.sim.platform.Platform;
import avrora.util.Arithmetic;
import avrora.util.ClassMap;
import avrora.util.Option;
import avrora.util.StringUtil;
import avrora.util.Terminal;


public class NCUnitMonitor extends MonitorFactory {
	
    protected Option.Str TEST_COMPONENT = options.newOption("test-component", "", 
    	"This option contains the name of the component including the test cases.");
    protected Option.Long TEST_CASE = options.newOption("test-case", 0, 
    	"This option contains the number of the current test case.");
    protected Option.Str SYMBOL_TABLE = options.newOption("symbol-table", null,
		"This option contains the name of the file with the symbol table.");
    protected Option.Str XML_FILE = options.newOption("xml-file", "", "Name of the XML file generated by nesC");

	private static ClassMap assertClassMap;
	private static boolean assertFailed = false;
	private static HashMap<String, Integer> symbolTable;
	private TypeSystem typeSystem = null;
	
	private class AssertInfo {
		NCAssert assertClass;
		String message;
	}
	
	private HashMap<Simulator, LinkedList<AssertInfo>> javaAssertLists = new HashMap<Simulator, LinkedList<AssertInfo>>();
	private HashMap<Simulator, HashMap<String, LinkedList<String>>> callAssertLists = new HashMap<Simulator, HashMap<String, LinkedList<String>>>();

	class TestCaseStartProbe extends Simulator.Probe.Empty {

	    final Simulator simulator;
	    
	    /**
		 * 
		 */
		public TestCaseStartProbe(Simulator s) {
	        simulator = s;
		}

	    /* (non-Javadoc)
		 * @see avrora.monitors.Monitor#report()
		 */
		public void report() {
		}
		
		/* (non-Javadoc)
		 * @see avrora.sim.Simulator.Probe.Empty#fireAfter(avrora.sim.State, int)
		 */
		public void fireAfter(State state, int pc) {
			StringBuffer buf = new StringBuffer(200);
	        StringUtil.getIDTimeString(buf, simulator);
	        String message = "";
	        int messageAddr = simulator.getInterpreter().getRegisterWord(Register.R24);
	        int i=0;
	        int dataByte;
	        while ((dataByte = getUnsignedRAMData(simulator, messageAddr + i)) != 0) {
	        	message += (char) dataByte;
	        	i++;
	        }
			Terminal.append(Terminal.COLOR_BRIGHT_CYAN, buf, message);
            synchronized ( Terminal.class) {
                Terminal.println(buf.toString());
            }
		}
  }

	class TestCaseEndProbe extends Simulator.Probe.Empty {

	    final Simulator simulator;
	    
	    /**
		 * 
		 */
		public TestCaseEndProbe(Simulator s) {
	        simulator = s;
		}

	    /* (non-Javadoc)
		 * @see avrora.monitors.Monitor#report()
		 */
		public void report() {
		}
		
		/* (non-Javadoc)
		 * @see avrora.sim.Simulator.Probe.Empty#fireAfter(avrora.sim.State, int)
		 */
		public void fireAfter(State state, int pc) {
			LinkedList<AssertInfo> asserts = javaAssertLists.get(simulator);
			if (asserts != null) {
				for (AssertInfo currentInfo : asserts) {
					if (!currentInfo.assertClass.callAfter()) {
						StringBuffer buf = new StringBuffer(200);
				        StringUtil.getIDTimeString(buf, simulator);
						Terminal.append(Terminal.COLOR_BRIGHT_CYAN, buf, "nCUnit: Simulator assert failed callAfter -- "+currentInfo.message);
						assertFailed = true;
			            synchronized ( Terminal.class) {
			                Terminal.println(buf.toString());
			            }
					}
				}
			}
			HashMap<String, LinkedList<String>> mapForNode = callAssertLists.get(simulator);
			if (mapForNode != null) {
				for (String functionName : mapForNode.keySet()) {
					LinkedList<String> messageList = mapForNode.get(functionName);
					for (String message : messageList) {
						StringBuffer buf = new StringBuffer(200);
				        StringUtil.getIDTimeString(buf, simulator);
						Terminal.append(Terminal.COLOR_BRIGHT_CYAN, buf, "Warning: Function "+functionName+" not called at end of test function -- "+message);
			            synchronized ( Terminal.class) {
			                Terminal.println(buf.toString());
			            }
					}
				}
			}
		}
  }

  class TestCaseFailedProbe extends Simulator.Probe.Empty {

	    final Simulator simulator;
	    
	    /**
		 * 
		 */
		public TestCaseFailedProbe(Simulator s) {
	        simulator = s;
		}

	    /* (non-Javadoc)
		 * @see avrora.monitors.Monitor#report()
		 */
		public void report() {
		}
		
		/* (non-Javadoc)
		 * @see avrora.sim.Simulator.Probe.Empty#fireAfter(avrora.sim.State, int)
		 */
		public void fireAfter(State state, int pc) {
			StringBuffer buf = new StringBuffer(200);
	        StringUtil.getIDTimeString(buf, simulator);
	        String message = "";
	        int messageAddr = simulator.getInterpreter().getRegisterWord(Register.R24);
	        if (messageAddr != 0) {
		        int i=0;
		        int dataByte;
		        while ((dataByte = getUnsignedRAMData(simulator, messageAddr + i)) != 0) {
		        	message += (char) dataByte;
		        	i++;
		        }
	        }
			Terminal.append(Terminal.COLOR_BRIGHT_CYAN, buf, message);
			assertFailed = true;
          synchronized ( Terminal.class) {
              Terminal.println(buf.toString());
          }
		}
  }

  class JavaClassProbe extends Simulator.Probe.Empty {

	    final Simulator simulator;
	    
	    /**
		 * 
		 */
		public JavaClassProbe(Simulator s) {
	        simulator = s;
		}

	    /* (non-Javadoc)
		 * @see avrora.monitors.Monitor#report()
		 */
		public void report() {
		}
		
		/* (non-Javadoc)
		 * @see avrora.sim.Simulator.Probe.Empty#fireAfter(avrora.sim.State, int)
		 */
		public void fireAfter(State state, int pc) {
	        int infoAddr = simulator.getInterpreter().getRegisterWord(Register.R24);
	        if (infoAddr != 0) {
		        String message = "";
	        	String javaClass = "";
	        	int javaAddr = getUnsignedRAMData(simulator, infoAddr) | (getUnsignedRAMData(simulator, infoAddr + 1) << 8);
	        	int messageAddr = getUnsignedRAMData(simulator, infoAddr + 2) | (getUnsignedRAMData(simulator, infoAddr + 3) << 8);
		        int i=0;
		        int dataByte;
		        while ((dataByte = getUnsignedRAMData(simulator, javaAddr + i)) != 0) {
		        	javaClass += (char) dataByte;
		        	i++;
		        }
		        i=0;
		        while ((dataByte = getUnsignedRAMData(simulator, messageAddr + i)) != 0) {
		        	message += (char) dataByte;
		        	i++;
		        }
	        	long cycles = simulator.getClock().millisToCycles((getUnsignedRAMData(simulator, infoAddr + 4) & 0xff) | ((getUnsignedRAMData(simulator, infoAddr + 5) & 0xff) << 8)
	        		| ((getUnsignedRAMData(simulator, infoAddr + 6) & 0xff) << 16) | ((getUnsignedRAMData(simulator, infoAddr + 7) & 0xff) << 24));
		        NCAssert assertClass = (NCAssert) assertClassMap.getObjectOfClass(javaClass);
		        assertClass.init(simulator);
		        LinkedList<AssertInfo> asserts = javaAssertLists.get(simulator);
		        if (asserts == null) {
		        	asserts = new LinkedList<AssertInfo>();
		        	javaAssertLists.put(simulator, asserts);
		        }
		        final AssertInfo assertInfo = new AssertInfo();
		        assertInfo.assertClass = assertClass;
		        assertInfo.message = message;
		        asserts.add(assertInfo);
		        if (cycles > 0){
			        simulator.getClock().insertEvent(new Simulator.Event() {
						
						public void fire() {
							if (!assertInfo.assertClass.callTimer()) {
								StringBuffer buf = new StringBuffer(200);
						        StringUtil.getIDTimeString(buf, simulator);
								Terminal.append(Terminal.COLOR_BRIGHT_CYAN, buf, "nCUnit: Simulator assert failed callTimer -- "+assertInfo.message);
								assertFailed = true;
						        synchronized ( Terminal.class) {
						            Terminal.println(buf.toString());
						        }
							}
						}
					
					}, cycles);
		        }
		        if (!assertClass.callNow()) {
		        	// assert failed
					StringBuffer buf = new StringBuffer(200);
			        StringUtil.getIDTimeString(buf, simulator);
					Terminal.append(Terminal.COLOR_BRIGHT_CYAN, buf, "nCUnit: Simulator assert failed callNow -- "+message);
					assertFailed = true;
			        synchronized ( Terminal.class) {
			            Terminal.println(buf.toString());
			        }
		        }
	        }
		}
  }

  class AddCallAssertProbe extends Simulator.Probe.Empty {

	    final Simulator simulator;
	    
	    /**
		 * 
		 */
		public AddCallAssertProbe(Simulator s) {
	        simulator = s;
		}
		//Problem: AddCallMonitor wird nie aufgerufen
		//Eigentliches Problem: testcase nie ausgeführt

	    /* (non-Javadoc)
		 * @see avrora.monitors.Monitor#report()
		 */
		public void report() {
			HashMap<String, LinkedList<String>> mapForNode = callAssertLists.get(simulator);
			if (mapForNode != null) {
				for (String functionName : mapForNode.keySet()) {
					LinkedList<String> messageList = mapForNode.get(functionName);
					for (String message : messageList) {
						StringBuffer buf = new StringBuffer(200);
						Terminal.append(Terminal.COLOR_BRIGHT_CYAN, buf, "nCUnit: Assert failed: Function "+functionName+" not called -- "+message);
						assertFailed = true;
			            synchronized ( Terminal.class) {
			                Terminal.println(buf.toString());
			            }
					}
				}
			}
		}
		
		/* (non-Javadoc)
		 * @see avrora.sim.Simulator.Probe.Empty#fireAfter(avrora.sim.State, int)
		 */
		public void fireAfter(State state, int pc) {
	        int infoAddr = simulator.getInterpreter().getRegisterWord(Register.R24);
	        if (infoAddr != 0) {
		        String message = "";
	        	String functionName = "";
	        	int javaAddr = getUnsignedRAMData(simulator, infoAddr) | (getUnsignedRAMData(simulator, infoAddr + 1) << 8);
	        	int messageAddr = getUnsignedRAMData(simulator, infoAddr + 2) | (getUnsignedRAMData(simulator, infoAddr + 3) << 8);
	        	int paramNameAddr = getUnsignedRAMData(simulator, infoAddr + 4) | (getUnsignedRAMData(simulator, infoAddr + 5) << 8);
	        	int comparisonAddr = getUnsignedRAMData(simulator, infoAddr + 6) | (getUnsignedRAMData(simulator, infoAddr + 7) << 8);
	        	int compOperator = getUnsignedRAMData(simulator, infoAddr + 8);
		        int i=0;
		        int dataByte;
		        while ((dataByte = getUnsignedRAMData(simulator, javaAddr + i)) != 0) {
		        	functionName += (char) dataByte;
		        	i++;
		        }
				functionName = functionName.replaceAll("\\.", "\\$");

		        i=0;
		        while ((dataByte = getUnsignedRAMData(simulator, messageAddr + i)) != 0) {
		        	message += (char) dataByte;
		        	i++;
		        }
		        
		        String parameterName = "";
		        i = 0;
		        while ((dataByte = getUnsignedRAMData(simulator, paramNameAddr + i)) != 0) {
		        	parameterName += (char) dataByte;
		        	i++;
		        }
		        
		        byte[] comparisonValue = null;
		        
		        if (compOperator != 0) {
			        Xfunction function = typeSystem.getFunctionType(functionName);
			        if (function != null) {
			        	Xvariable parameter = typeSystem.getParameterType(function, parameterName);
			        	if (parameter != null) {
			        		int paramSize = (int) ((IntegerConstant) parameter.type.size).value;
			        		comparisonValue = new byte[paramSize];
			        		for (int j=0; j<paramSize; j++) {
			        			comparisonValue[j] = simulator.getInterpreter().getDataByte(comparisonAddr + j);
			        		}
			        	}
			        	else {
			        		System.err.println("Error: Parameter not found: "+parameterName);
			        	}
			        }
			        else {
			        	System.err.println("Error: Function not found: "+functionName);
			        }
		        }
		 
		        HashMap<String, LinkedList<String>> mapForNode = callAssertLists.get(simulator);
		        if (mapForNode == null) {
		        	mapForNode = new HashMap<String, LinkedList<String>>();
		        	callAssertLists.put(simulator, mapForNode);
		        }
		        LinkedList<String> messageList = mapForNode.get(functionName);
		        if (messageList == null) {
		        	messageList = new LinkedList<String>();
		        	mapForNode.put(functionName, messageList);
		        	// insert probe
		        	CallAssertProbe callAssertProbe = new CallAssertProbe(simulator, functionName, parameterName, comparisonValue, compOperator);
		            Program p = simulator.getProgram();
		            SourceMapping smap = p.getSourceMapping();
		            if (smap.getLocation(functionName) != null) {
		            	simulator.insertProbe(callAssertProbe, smap.getLocation(functionName).address);
		            }
		            else {
						StringBuffer buf = new StringBuffer(200);
				        StringUtil.getIDTimeString(buf, simulator);
						Terminal.append(Terminal.COLOR_BRIGHT_CYAN, buf, "nCUnit: Inserting probe for function failed -- "+functionName);
				        synchronized ( Terminal.class) {
				            Terminal.println(buf.toString());
				        }
		            }
		        }
		        messageList.add(message);
	        }
		}
  }

  class CallAssertProbe extends Simulator.Probe.Empty {

	    final Simulator simulator;
	    final String functionName;
	    final String parameterName;
	    final byte[] comparisonValue;
	    final int comparisonOperator;
	    
	    /**
		 * 
		 */
		public CallAssertProbe(Simulator s, String functionName, String parameterName, byte[] comparisonValue, int compOperator) {
	        simulator = s;
	        this.functionName = functionName;
	        this.parameterName = parameterName;
	        this.comparisonValue = comparisonValue;
	        this.comparisonOperator = compOperator;
		}

	    /* (non-Javadoc)
		 * @see avrora.monitors.Monitor#report()
		 */
		public void report() {
		}
		
		/* (non-Javadoc)
		 * @see avrora.sim.Simulator.Probe.Empty#fireAfter(avrora.sim.State, int)
		 */
		public void fireAfter(State state, int pc) {
			// remove function from list with messages when it is called
			if (comparisonOperator != 0) {
				Xfunction function = typeSystem.getFunctionType(functionName);
				if (function != null) {
					Xvariable parameter = typeSystem.getParameterType(function, parameterName);
					if (parameter != null) {
						Comparison comparison = new Comparison(simulator);
						if (comparisonOperator == 1) {
							if (comparison.equalsParam(function, parameter, comparisonValue)) {
								callAssertLists.get(simulator).remove(functionName);
							}
							else {
								StringBuffer buf = new StringBuffer(200);
						        StringUtil.getIDTimeString(buf, simulator);
								Terminal.append(Terminal.COLOR_BRIGHT_CYAN, buf, "Function "+functionName+" called but comparison of parameter "+parameterName+" failed");
					            synchronized ( Terminal.class) {
					                Terminal.println(buf.toString());
					            }
							}
						}
						else if (comparisonOperator == 2) {
							if (comparison.notEqualsParam(function, parameter, comparisonValue)) {
								callAssertLists.get(simulator).remove(functionName);
							}
							else {
								StringBuffer buf = new StringBuffer(200);
						        StringUtil.getIDTimeString(buf, simulator);
								Terminal.append(Terminal.COLOR_BRIGHT_CYAN, buf, "Function "+functionName+" called but comparison of parameter "+parameterName+" failed");
					            synchronized ( Terminal.class) {
					                Terminal.println(buf.toString());
					            }
							}
						}
					}
				}
			}
			else {
				callAssertLists.get(simulator).remove(functionName);
			}
			// TODO insert output of parameters here
		}
  }

  class GetDataPointerProbe extends Simulator.Probe.Empty {

	    final Simulator simulator;
	    
	    /**
		 * 
		 */
		public GetDataPointerProbe(Simulator s) {
	        simulator = s;
		}

		/* (non-Javadoc)
		 * @see avrora.sim.Simulator.Probe.Empty#fireAfter(avrora.sim.State, int)
		 */
		public void fireAfter(State state, int pc) {
	        int infoAddr = simulator.getInterpreter().getRegisterWord(Register.R24);
	        if (infoAddr != 0) {
	        	String variableName = "";
	        	int variableAddr = (getUnsignedRAMData(simulator, infoAddr + 2)) | (getUnsignedRAMData(simulator, infoAddr + 3) << 8);
		        int i=0;
		        int dataByte;
		        while ((dataByte = getUnsignedRAMData(simulator, variableAddr + i)) != 0) {
		        	variableName += (char) dataByte;
		        	i++;
		        }
				variableName = variableName.replaceAll("\\.", "\\$");
				
				int varAddress = symbolTable.get(variableName);
				simulator.getInterpreter().setDataByte(infoAddr, (byte) (varAddress & 0xff));
				simulator.getInterpreter().setDataByte(infoAddr + 1, (byte) (varAddress >> 8));
	        }
		}
  }

  class Mon implements Monitor {
        final Simulator simulator;
        final Platform platform;
        
        TestCaseStartProbe testCaseStartProbe;
        TestCaseEndProbe testCaseEndProbe;
        TestCaseFailedProbe testCaseFailedProbe;
        JavaClassProbe javaClassProbe;
        AddCallAssertProbe addCallAssertProbe;
        GetDataPointerProbe getDataPointerProbe;
        
        private static final String TEST_CASE_START_POS = "RealMain$testStart";
        private static final String TEST_CASE_END_POS = "RealMain$testEnd";
        private static final String TEST_CASE_FAILED_POS = "AssertM$assertFailMsg";
        private static final String JAVA_CLASS_POS = "AssertM$assertJavaClassMsg";
        private static final String ADD_CALL_ASSERT_POS = "AssertM$assertCallsMsg";
        private static final String GET_DATA_POINTER_POS = "AssertM$getDataPointer";
        
        private void insertProbe(Probe probe, String functionName) {
            Program p = simulator.getProgram();
            SourceMapping smap = p.getSourceMapping();

            if (smap.getLocation(functionName) != null) {
            	simulator.insertProbe(probe, smap.getLocation(functionName).address);
            }
            else {
            	System.out.println(functionName+" not found");
            }
        	
        }

        Mon(Simulator s) {
            simulator = s;
            platform = simulator.getMicrocontroller().getPlatform();

            symbolTable = new HashMap<String, Integer>();
            if (SYMBOL_TABLE.get() != null){
                readSymbolTable(SYMBOL_TABLE.get());
            }
            
            if (XML_FILE.get() == null) {
            	System.err.println("ERROR: No XML file specified for ncUnit");
            	System.exit(1);
            }
            typeSystem = new TypeSystem(XML_FILE.get());

            testCaseStartProbe = new TestCaseStartProbe(simulator);
            insertProbe(testCaseStartProbe, TEST_CASE_START_POS);
			
            testCaseEndProbe = new TestCaseEndProbe(simulator);
            insertProbe(testCaseEndProbe, TEST_CASE_END_POS);
			
            testCaseFailedProbe = new TestCaseFailedProbe(simulator);
            insertProbe(testCaseFailedProbe, TEST_CASE_FAILED_POS);

            javaClassProbe = new JavaClassProbe(simulator);
            insertProbe(javaClassProbe, JAVA_CLASS_POS);

            addCallAssertProbe = new AddCallAssertProbe(simulator);
            insertProbe(addCallAssertProbe, ADD_CALL_ASSERT_POS);
            
            getDataPointerProbe = new GetDataPointerProbe(simulator);
            insertProbe(getDataPointerProbe, GET_DATA_POINTER_POS);
            
            updateTestCase();
        }
        
        public void report() {
        	addCallAssertProbe.report();
        	if (!assertFailed) {
	            synchronized ( Terminal.class) {
	                Terminal.println("nCUnit: Completed test case successfully");
	            }
        	}
        	else {
	            synchronized ( Terminal.class) {
	                Terminal.println("nCUnit: Assertion failed during test case");
	            }
        	}
        }
        
        private void updateTestCase() {
            Program p = simulator.getProgram();
            SourceMapping smap = p.getSourceMapping();
            SourceMapping.Location location = smap.getLocation(TEST_COMPONENT.get()+"$_testCaseNumber");
            if ( location != null ) {
                BaseInterpreter bi = simulator.getInterpreter();
//                System.out.println("Location: "+location.address);
//                System.out.println("TestCase before: "+bi.getProgramByte(location.address));
                bi.writeFlashByte(location.address, Arithmetic.low((int) TEST_CASE.get()));
//                System.out.println("TestCase after: "+bi.getProgramByte(location.address));
            }
        
        }

        private void readSymbolTable(String symbolTableFile) {
        	try {
    			BufferedReader reader = new BufferedReader(new FileReader(symbolTableFile));
    			String currentLine = reader.readLine();
    			while (currentLine != null) {
    				StringTokenizer tokenizer = new StringTokenizer(currentLine);
    				if (tokenizer.hasMoreTokens()) {
    					String firstToken = tokenizer.nextToken();
    					String lastToken = firstToken;
    					while (tokenizer.hasMoreTokens()) {
    						lastToken = tokenizer.nextToken();
    					}
    					try {
    						Integer address = Integer.valueOf(firstToken, 16);
    						symbolTable.put(lastToken, address);
    					} catch (NumberFormatException ex) {
    					}
    				}
    				
    				currentLine = reader.readLine();
    			}
    			reader.close();
    		} catch (FileNotFoundException e) {
    			e.printStackTrace();
    		} catch (IOException e) {
    			e.printStackTrace();
    		}
        }


    }

    /**
     * create a new monitor
     */
    public NCUnitMonitor() {
        super("The \"NCUnit\" monitor tracks success and failure of test cases.");
        assertClassMap = new ClassMap("Assert", NCAssert.class);
    }
    
    private int getUnsignedRAMData(Simulator simulator, int address) {
    	byte signedByte = simulator.getInterpreter().getDataByte(address);
    	//make it unsigned
    	ByteBuffer bb = ByteBuffer.allocate(4);
    	bb.put(new byte[] {0, 0, 0, signedByte});
    	bb.rewind();
    	int unsignedByteVal = bb.getInt();
    	return unsignedByteVal;
    }
    
    /**
     * create a new monitor, calls the constructor
     *
     * @see avrora.monitors.MonitorFactory#newMonitor(avrora.sim.Simulator)
     */
    public avrora.monitors.Monitor newMonitor(Simulator s) {
        return new Mon(s);
    }
}


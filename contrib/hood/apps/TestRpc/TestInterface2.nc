interface TestInterface2
{
  event void testEvent1();
  event result_t testEvent3(uint8_t something);
  event result_t* testEvent4(uint8_t something, uint16_t* data);
  event RpcCommandMsg testEvent5(RpcCommandMsg data);
  event RpcCommandMsg* testEvent6(RpcCommandMsg* data);
  event void testEvent7(RpcCommandMsg data);
  event RpcCommandMsg testEvent8();
}

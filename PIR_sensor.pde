
#include <WaspSensorEvent.h>

packetXBee* paq_sent;
int8_t state=0;
long previous=0;
//char*  data="Test message!\n";
char* data="0013A2004086A4B7#100#80";
int g=0;
uint8_t  PANID[2]={0x12,0x34};
 
void setup()
{
  
   // Inits the XBee 802.15.4 library
  xbee802.init(XBEE_802_15_4,FREQ2_4G,NORMAL);
  
  // Powers XBee
  xbee802.ON();
  delay(3000);

// Turn on the sensor board
  SensorEvent.setBoardMode(SENS_ON);

  // Turn on the RTC
  RTC.ON();

}
 
void loop()
{
  XBee.println("Hola");
  paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
  paq_sent->mode=BROADCAST;
  paq_sent->MY_known=0;
  paq_sent->packetID=0x55;
  paq_sent->opt=0; 
  xbee802.hops=0;
  xbee802.setOriginParams(paq_sent, "5678", MY_TYPE);
  
  xbee802.setDestinationParams(paq_sent,"9101", data, MY_TYPE, DATA_ABSOLUTE);
  
  //xbee802.setDestinationParams(paq_sent, "0013A2004086A4B7", data, MAC_TYPE, DATA_ABSOLUTE);  //  gateway
//  xbee802.setDestinationParams(paq_sent, "0013A2004086A493", data, MAC_TYPE, DATA_ABSOLUTE);
  //xbee802.setDestinationParams(paq_sent, "0013A20040304F74", data, MAC_TYPE, DATA_ABSOLUTE);
  SensorEvent.attachInt(); 
  PWR.sleep(UART0_OFF | UART1_OFF | BAT_OFF | RTC_OFF);
  //delay(1000);
  SensorEvent.detachInt();
    
// Load the interruption flag
     SensorEvent.loadInt();
    
    // 3. In case the interruption came from socket 7
      if( SensorEvent.intFlag & SENS_SOCKET7)
       {
         XBee.setMode(XBEE_ON);
         XBee.begin();
         delay(1000);
         xbee802.sendXBee(paq_sent);
         XBee.println("Hahahhahahahaha");
          if( !xbee802.error_TX )
          {
            XBee.println("okk");
          }
         else
         {
            XBee.println("Cant Send !!!! ");
         } 
          
      }
     free(paq_sent);
      paq_sent=NULL;
    // Clean the interruption flag
    clearIntFlag();
   
   delay(1000);
}

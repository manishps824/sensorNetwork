 packetXBee* paq_sent;
 packetXBee* newPaq_sent;
 long mytime=0;
 int8_t state=0;
 long previous=0;
 long recvTime=0;
 long sendingTime;
 char*  data="holaaaa!";
 char *mydata;
 char *mac;
 char *speedString;
 char *decreasedString;
 int g=0;
 int c;
 int d;
 int e;
 int speed;
 int decreasedspeed;
 long temp;
 char *copyMsg;
 int flag = 1;

void setup()
{
  // Inits the XBee 802.15.4 library
  xbee802.init(XBEE_802_15_4,FREQ2_4G,NORMAL);

  // Powers XBee
  xbee802.ON();
  delay(1500);
}

void loop()
{
  
  
   // Waiting the answer
  
  previous=millis();
  while( (millis()-previous) < 20000 )
  {
    if( XBee.available() )
    {
      xbee802.treatData();
      if( !xbee802.error_RX )
      {
          flag= 1;
        // Writing the parameters of the packet received
          newPaq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
          newPaq_sent->mode=UNICAST;
          newPaq_sent->MY_known=0;
          newPaq_sent->packetID=0x52;
          newPaq_sent->opt=0; 
          xbee802.setOriginParams(newPaq_sent, "5678", MY_TYPE);
        
        while(xbee802.pos>0)
        {
          paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
          paq_sent->mode=UNICAST;
          paq_sent->MY_known=0;
          paq_sent->packetID=0x52;
          paq_sent->opt=0; 
          xbee802.hops=0;
          xbee802.setOriginParams(paq_sent, "5678", MY_TYPE);
          
          XBee.print("Data: ");
          mydata = (char*)malloc((xbee802.packet_finished[xbee802.pos-1]->data_length)*sizeof(char));
          for(int f=0;f<xbee802.packet_finished[xbee802.pos-1]->data_length;f++)
          {
            XBee.print(xbee802.packet_finished[xbee802.pos-1]->data[f],BYTE);
            mydata[f] = xbee802.packet_finished[xbee802.pos-1]->data[f];  
            //XBee.print(mydata[f]);      
          }
          XBee.println("");
         copyMsg = strdup(mydata); 
         mac = strtok(mydata, "#"); //first_part points to "user"
	 speedString = strtok(NULL, "#");   //sec_part points to "name"
      	 decreasedString = strtok(NULL,"#");
       	 c = strlen(mac);
      	 d = strlen(speedString);
      	 e = strlen(decreasedString);
      	 //XBee.println(mac);
        speed = atoi(speedString);
      	 decreasedspeed = atoi(decreasedString);
         mytime = 1000/decreasedspeed;
         recvTime=millis();          
         sendingTime = recvTime + (1000*mytime);
         
         //print
         
         /*XBee.println(speed);
         XBee.println(decreasedspeed);         
         XBee.println(mytime);
         XBee.println(recvTime);         
         XBee.println(sendingTime);
         */
         delay((mytime*1000) - 3000);
           xbee802.setDestinationParams(paq_sent, mac, data, MAC_TYPE, DATA_ABSOLUTE);
         //XBee.println("paramset");
         //XBee.println(millis());
         temp = sendingTime + 3000;
         //XBee.println(temp);
         //char *mydata ="0013A2004086A4B7#100#80";
         xbee802.setDestinationParams(newPaq_sent, "0013A2004086A492", copyMsg, MAC_TYPE, DATA_ABSOLUTE);        
        
        while(millis() < temp)
         {
            
           if(millis() > sendingTime && flag == 1)
           {
             flag = 0;
             xbee802.sendXBee(newPaq_sent);
             if( !xbee802.error_TX )
                  {
                    XBee.println("ok");
                  }
           } 
          // XBee.println(millis());
           xbee802.sendXBee(paq_sent);
            if( !xbee802.error_TX )
                  {
                    XBee.println("ok");
                  }         
           
         }
        // XBee.println("Hahahhahahahaha");
         free(newPaq_sent);
         newPaq_sent = NULL;
         
         free(paq_sent);
         paq_sent = NULL;
         
         free(mydata);
         mydata = NULL;
         
         free(xbee802.packet_finished[xbee802.pos-1]);
         xbee802.packet_finished[xbee802.pos-1]=NULL;
         xbee802.pos--;
        }
      }
    }
  }

  delay(1000);
}

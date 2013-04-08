//code for those intermediate nodes that will also be sending trigger to next node

 packetXBee* paq_sent;
 packetXBee* newPaq_sent;
 long mytime=0;
 int8_t state=0;
 long previous=0;
 long recvTime=0;
 long sendingTime;
 char data[100];
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
 int sentToNextflag = 0;
 long waitForPrev = 0;
 long tempWaitForPrev = 0;
 long tempWaitForPrev1 = 0;
 int flag = 0;
 long recvFromInit = 0;
 int id = 2;
 

void setup()
{
  ACC.begin();    // opens I2C bus
  ACC.setMode(ACC_ON); // starts accelerometer
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
      
      if(flag==0)
      {
      recvFromInit = millis();
      }
      
      xbee802.treatData();
      if( !xbee802.error_RX )
      {
          sentToNextflag= 0;
        // Writing the parameters of the packet received
          
        
        while(xbee802.pos>0)
        {
          
          //---------if data at given position in array then process it to get speed and mac addr of database---------------------------------------
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
         //------------------------------processing done--------------------------------------------------------------------------------------------
         
         //------------------------------if brodcast packet----------------------------------------------------------------------------------------
         
         if (flag==0 && (xbee802.packet_finished[xbee802.pos-1]->packetID == 0x55))
         {
           flag = 1;
           XBee.println("flag set....breaking\nwaitForPrevious:");
           waitForPrev = recvFromInit + (id*mytime*1000);
           XBee.println(waitForPrev);
           XBee.println("flag set");
         }
         //------------------------------handling of broadcast packet done -------------------------------------------------------------------------
         else
         {
          
          //--------prepare the packet to be sent to the database------------------------
          paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
          paq_sent->mode=UNICAST;
          paq_sent->MY_known=0;
          paq_sent->packetID=0x52;
          paq_sent->opt=0; 
          xbee802.hops=0;
          xbee802.setOriginParams(paq_sent, "5678", MY_TYPE); 
          //--------------------------------------------------------------------------
          
          //----------prepare the packet to be sent to the next node------------------
            newPaq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
            newPaq_sent->mode=UNICAST;
            newPaq_sent->MY_known=0;
            newPaq_sent->packetID=0x52;
            newPaq_sent->opt=0; 
            xbee802.setOriginParams(newPaq_sent, "5678", MY_TYPE);
           
           //-----------begin the waiting and sending procedure--------------------------
           delay((mytime*1000) - 3000);
           temp = sendingTime + 3000;
           xbee802.setDestinationParams(newPaq_sent, "0013A2004086A492", copyMsg, MAC_TYPE, DATA_ABSOLUTE);        
          
          
          //------------------send packets till required-----------------------------------------
          while(millis() < temp)
           {
               XBee.println(copyMsg);
               XBee.println("\n");
               sprintf(data,"W01#ACCX#%d#ACCY#%d#ACCZ#%d%c#%d#%s%c\n",ACC.getX(), ACC.getY(), ACC.getZ(), '\r',id, copyMsg,'\n'); 
               xbee802.setDestinationParams(paq_sent, mac, data, MAC_TYPE, DATA_ABSOLUTE);
                xbee802.sendXBee(paq_sent);
                if( !xbee802.error_TX )
                      {
                        XBee.println("ok");
                      }
             //---------------if time to send to next node then send to next node-------------------
               if(millis() > sendingTime && sentToNextflag == 0)
               {
                 sentToNextflag = 1;
                 xbee802.sendXBee(newPaq_sent);
                 if( !xbee802.error_TX )
                      {
                        XBee.println("ok");
                      }
               } 
               //-----------------------data sent to next node-------------------------------------------         
             
           }
          //-----------------------sending data over-----------------------------------------------------
           free(newPaq_sent);
           newPaq_sent = NULL;
           flag = 0;
           
            free(paq_sent);
            paq_sent = NULL;
       }
         
        
         
         free(mydata);
         mydata = NULL;
         
         free(xbee802.packet_finished[xbee802.pos-1]);
         xbee802.packet_finished[xbee802.pos-1]=NULL;
         xbee802.pos--;
        }
      }
    }
    else if(flag == 1)
    {
      tempWaitForPrev = waitForPrev - 3000;
      tempWaitForPrev1 = waitForPrev + 3000;
      if(millis() > tempWaitForPrev)
      {
         
          XBee.println("Sending default data"); 
          paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
          paq_sent->mode=UNICAST;
          paq_sent->MY_known=0;
          paq_sent->packetID=0x52;
          paq_sent->opt=0; 
          xbee802.hops=0;
          xbee802.setOriginParams(paq_sent, "5678", MY_TYPE);
          sprintf(data,"W01#ACCX#%d#ACCY#%d#ACCZ#%d%c#%d#%s%c\n",ACC.getX(), ACC.getY(), ACC.getZ(), '\r', id ,copyMsg,'\n'); 
          xbee802.setDestinationParams(paq_sent, mac, data, MAC_TYPE, DATA_ABSOLUTE);
          XBee.println(millis());
          while(millis() < tempWaitForPrev1)
           {  
            xbee802.sendXBee(paq_sent);
            if( !xbee802.error_TX )
             {
              XBee.println("ok");
             }
           }         
          free(paq_sent);
          paq_sent = NULL;
          flag = 0;  
       }  
  }
  
  }

  delay(1000);
}

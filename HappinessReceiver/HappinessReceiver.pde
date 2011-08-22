// receiver.pde
//
// Simple example of how to use VirtualWire to receive messages
// Implements a simplex (one-way) receiver with an Rx-B1 module
//
// See VirtualWire.h for detailed API docs
// Author: Mike McCauley (mikem@open.com.au)
// Copyright (C) 2008 Mike McCauley
// $Id: receiver.pde,v 1.3 2009/03/30 00:07:24 mikem Exp $

#include <VirtualWire.h>
#undef int
#undef abs
#undef double
#undef float
#undef round

#define rxPin 13
#define vccPin 11

void setup()
{
  Serial.begin(9600);	// Debugging only

  pinMode(vccPin, OUTPUT);
  digitalWrite(vccPin, HIGH);
  
  pinMode(rxPin, INPUT);
  digitalWrite(rxPin, LOW);

  // Initialise the IO and ISR
  vw_set_rx_pin(rxPin);
  vw_setup(1000);	 // Bits per sec

  vw_rx_start();       // Start the receiver PLL running
  Serial.println("Setup complete");
}

void loop()
{
  uint8_t buf[VW_MAX_MESSAGE_LEN];
  uint8_t buflen = VW_MAX_MESSAGE_LEN;

  if (vw_get_message(buf, &buflen)) // Non-blocking
  {
    if(buflen == 5){
      unsigned int location = buf[0];
      unsigned int happy = ((buf[1] << 0) & 0xFF) + ((buf[2] << 8) & 0xFF00);
      unsigned int sad = ((buf[3] << 0) & 0xFF) + ((buf[4] << 8) & 0xFF00);
      Serial.print("Location: ");
      Serial.print(location);
      Serial.print(" happy: ");
      Serial.print(happy);
      Serial.print(" sad: ");
      Serial.println(sad);
    }else{
      Serial.println("Wrong packet length");
    }
  }
}


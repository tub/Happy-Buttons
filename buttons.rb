#simplest ruby program to read from arduino serial, 
#using the SerialPort gem
#(http://rubygems.org/gems/serialport)

require 'rubygems'
require 'net/http'
require 'uri'
require "serialport"


#def read_serial

rest_api = URI.parse('http://localhost:4567/readings')

#params for serial port
port_str = "/dev/tty.usbmodemfd121"  #may be different for you
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

serialBuffer = ""
locationBuffer = {}

#just read forever
while true do
  serialBuffer.concat(sp.getc)
  if(serialBuffer =~ /Location: (\d+) happy: (\d+) sad: (\d+)\r\n/m)
  then 
        printf("L: %s :) %s :( %s\n", $1, $2, $3)
        prevLoc = locationBuffer[$1];
	currLoc = [$2, $3]
        if(prevLoc != currLoc)
	then
		puts("Updating db")
		locationBuffer[$1] = currLoc
		res = Net::HTTP.post_form(rest_api,
                              {'location' => $1, 'happy' => $2, 'sad' => $3})
	end	
	serialBuffer = ""
  end
end

sp.close                       #see note 1

#end


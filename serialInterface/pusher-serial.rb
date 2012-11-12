require 'rubygems'
require 'pusher-client'
require 'JSON'
require 'serialport'


# Open a serial connection
usbmodem = ARGV[0]
sp = SerialPort.new(usbmodem, 1200)

# Define emily parser for control data
# FORMAT: {'control': 'w', 'number': 100}
def emilyControl(data, sp)
	parsedData = JSON.parse(data)
	control = parsedData['control']
	number = parsedData['number']
	
	#number.times {puts control}
	number.times {sp.write control}
end

# Check if Serial interface provided
if ARGV.length == 0
	abort("Usage: ruby pusher-serial.rb serialinterface")
end

# Setup Pusher Client
PusherClient.logger = Logger.new(STDOUT)
options = {:secret => ''} 
socket = PusherClient::Socket.new('6af61db87df1695de8d2', options)

# Subscribe to emily channel
socket.subscribe('emily')

# Bind to a channel event
socket['emily'].bind('control') do |data|
	emilyControl(data, sp)
end

socket.connect

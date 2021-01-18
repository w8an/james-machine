-----------------
--   autorun.lua
-----------------
print("delay 5")
for i = 1, 5 do tmr.delay(1) end  -- 5 second delay
print()

file = "servo.lua"
print( "Loading servo positions ["..file.."] .." )
print()
dofile( file )
print( " Servo positions in degrees:" )
print( " ----------------" )
print( " servo_idle : " .. servo_idle )
print( " servo_up   : " .. servo_up )
print( " servo_down : " .. servo_down )
print()

file = "machine.lua"
print( "Loading controller ["..file.."] .." )
dofile( file )
print()

-- Run controller
print( "Starting controller.." )
th_run = thread.start( machine )
print()

print( "Threads:" )
thread.list()
print()



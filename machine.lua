print("Machine Controller")
print("Steven R. Stuart, Jan 2021")
print(os.cpu().." "..os.board())
print(os.version())
------
-- dofile("servo.lua")

btn_up_port = pio.GPIO19
btn_dn_port = pio.GPIO21
sensor_port = pio.GPIO4
btn_stop_port = pio.GPIO18
servo_port = pio.GPIO5
running_led = pio.GPIO22

pio.pin.setdir( pio.OUTPUT, running_led )
pio.pin.setdir( pio.INPUT,  btn_stop_port, btn_up_port, btn_dn_port, sensor_port )
pio.pin.setpull( pio.PULLUP, btn_stop_port, btn_up_port, btn_dn_port, sensor_port )

machine = function()

  local hydraulic = function( position )
    if position == "D" then 
       print( "Going DOWN" )
       svo:write( servo_down )
    elseif position == "U" then 
       print( "Going UP" )
       svo:write( servo_up )
    else -- idle 
       print( "Going NOWHERE" )
       svo:write( servo_idle )
    end
    tmr.delayms(500)
  end

  local count = 0
  local runningLed = function()
    count = count + 1
    if count >= 9 then count = 0 end
    if count < 5 then
       pio.pin.sethigh( running_led )
    else
       pio.pin.setlow( running_led )
    end
  end

  svo = servo.attach( servo_port )
  svo:write( servo_idle )

  local sensor = 0
  local stop, up, dn = 0, 0, 0
  local io_state, store_state = 0, 0

  while( true ) do

    stop = pio.pin.getval( btn_stop_port ) -- 1
    dn = pio.pin.getval( btn_dn_port ) -- 2
    up = pio.pin.getval( btn_up_port ) -- 4
    sensor =  pio.pin.getval( sensor_port ) -- 8

    io_state = 0  
    if stop == 0 then io_state = io_state + 1 end -- 0x0001 btn
    if dn == 0 then io_state = io_state + 2 end -- 0x0010 down btn
    if up == 0 then io_state = io_state + 4 end -- 0x0100 up btn
    if sensor  == 0 then io_state = io_state + 8 end -- 0x1000 mark sensor

    if io_state ~= store_state then -- io_state has changed
        store_state = io_state
        if io_state == 1 then 
            print("sig: STOP")
            hydraulic()
        elseif io_state == 2 or io_state == 10 then 
            print("sig: DOWN")
            hydraulic("D")
        elseif io_state == 4 or io_state == 12 then 
            print("sig: UP")
            hydraulic("U")
        elseif io_state == 8 then 
            print("sig: SENSOR")
            hydraulic()
        else 
            print()
        end
    end
    tmr.delayms(100)
    runningLed()
  end
  svo:detach()
  pio.pin.setlow( running_led )
end


const { Gpio } = require( 'onoff' );
const { exec } = require('child_process');

// set BCM 4 pin as 'output'
const fanOut = new Gpio( '4', 'out' );

exec('cat /sys/class/thermal/thermal_zone0/temp',{maxBuffer: 1024 * 500}, (err, stdout, stderr) => {
  console.log(stdout)
  if (stdout > 80000){
    console.log("Starting fan")
    fanOut.writeSync(1)
  }
  else {
    console.log("Stopping fan")
    fanOut.writeSync(0)
  }
});
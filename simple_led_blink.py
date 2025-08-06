#!/usr/bin/env python3
"""
Simple LED Blink Example
Perfect for beginners learning LED control
"""

import time

# For Raspberry Pi GPIO
try:
    import RPi.GPIO as GPIO
    RASPBERRY_PI = True
except ImportError:
    RASPBERRY_PI = False
    print("RPi.GPIO not available - running in simulation mode")

class SimpleLED:
    """Simple LED control class"""
    
    def __init__(self, pin=18):
        self.pin = pin
        self.state = False
        
        if RASPBERRY_PI:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            GPIO.setup(self.pin, GPIO.OUT)
            GPIO.output(self.pin, GPIO.LOW)
            print(f"LED initialized on GPIO pin {self.pin}")
        else:
            print(f"LED simulator initialized on pin {self.pin}")
    
    def on(self):
        """Turn LED on"""
        self.state = True
        if RASPBERRY_PI:
            GPIO.output(self.pin, GPIO.HIGH)
        print("LED ON")
    
    def off(self):
        """Turn LED off"""
        self.state = False
        if RASPBERRY_PI:
            GPIO.output(self.pin, GPIO.LOW)
        print("LED OFF")
    
    def toggle(self):
        """Toggle LED state"""
        if self.state:
            self.off()
        else:
            self.on()
    
    def blink(self, times=10, interval=0.5):
        """Blink LED specified number of times"""
        print(f"Blinking LED {times} times with {interval}s interval")
        for i in range(times):
            self.on()
            time.sleep(interval)
            self.off()
            time.sleep(interval)
    
    def cleanup(self):
        """Clean up GPIO"""
        if RASPBERRY_PI:
            GPIO.cleanup()
        print("LED cleanup completed")

def main():
    """Main function demonstrating LED control"""
    # Create LED instance (default pin 18)
    led = SimpleLED()
    
    try:
        print("Starting LED demo...")
        
        # Turn on for 2 seconds
        print("1. Turning LED on for 2 seconds")
        led.on()
        time.sleep(2)
        led.off()
        
        time.sleep(1)
        
        # Blink 5 times
        print("2. Blinking LED 5 times")
        led.blink(times=5, interval=0.3)
        
        time.sleep(1)
        
        # Fast blink 10 times
        print("3. Fast blinking 10 times")
        led.blink(times=10, interval=0.1)
        
        print("Demo completed!")
        
    except KeyboardInterrupt:
        print("\nDemo interrupted by user")
    finally:
        led.cleanup()

if __name__ == "__main__":
    main()
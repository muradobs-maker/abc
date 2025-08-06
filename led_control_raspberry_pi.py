#!/usr/bin/env python3
"""
LED Control System for Raspberry Pi
Supports multiple LEDs with various control modes using GPIO pins
Author: LED Control System
Version: 1.0

Requirements:
- RPi.GPIO library
- Python 3.x

Installation:
sudo apt-get update
sudo apt-get install python3-rpi.gpio
"""

import RPi.GPIO as GPIO
import time
import threading
import signal
import sys
from typing import List, Dict, Optional

class LEDController:
    """
    Comprehensive LED control system for Raspberry Pi
    """
    
    def __init__(self, led_pins: List[int], pwm_pins: List[int] = None):
        """
        Initialize LED controller
        
        Args:
            led_pins: List of GPIO pins connected to LEDs
            pwm_pins: List of GPIO pins that support PWM for brightness control
        """
        self.led_pins = led_pins
        self.pwm_pins = pwm_pins or []
        self.num_leds = len(led_pins)
        self.led_states = [False] * self.num_leds
        self.pwm_objects = {}
        self.running = False
        self.current_mode = 0
        self.thread = None
        
        # Setup GPIO
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        
        # Initialize LED pins
        for pin in self.led_pins:
            GPIO.setup(pin, GPIO.OUT)
            GPIO.output(pin, GPIO.LOW)
        
        # Initialize PWM pins
        for pin in self.pwm_pins:
            GPIO.setup(pin, GPIO.OUT)
            pwm = GPIO.PWM(pin, 1000)  # 1kHz frequency
            pwm.start(0)
            self.pwm_objects[pin] = pwm
        
        # Setup signal handler for clean exit
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
        
        print("LED Controller initialized")
        print(f"LED pins: {self.led_pins}")
        print(f"PWM pins: {self.pwm_pins}")
    
    def signal_handler(self, signum, frame):
        """Handle shutdown signals"""
        print("\nShutting down LED controller...")
        self.stop()
        sys.exit(0)
    
    def set_led(self, index: int, state: bool):
        """Set individual LED state"""
        if 0 <= index < self.num_leds:
            GPIO.output(self.led_pins[index], GPIO.HIGH if state else GPIO.LOW)
            self.led_states[index] = state
    
    def set_led_brightness(self, pin: int, brightness: float):
        """Set LED brightness using PWM (0.0 to 100.0)"""
        if pin in self.pwm_objects:
            brightness = max(0.0, min(100.0, brightness))
            self.pwm_objects[pin].ChangeDutyCycle(brightness)
    
    def all_on(self):
        """Turn on all LEDs"""
        for i in range(self.num_leds):
            self.set_led(i, True)
        for pin in self.pwm_pins:
            self.set_led_brightness(pin, 100.0)
    
    def all_off(self):
        """Turn off all LEDs"""
        for i in range(self.num_leds):
            self.set_led(i, False)
        for pin in self.pwm_pins:
            self.set_led_brightness(pin, 0.0)
    
    def blink_all(self, interval: float = 0.5, duration: float = None):
        """Blink all LEDs"""
        start_time = time.time()
        while self.running and (duration is None or time.time() - start_time < duration):
            self.all_on()
            time.sleep(interval)
            self.all_off()
            time.sleep(interval)
    
    def chase_sequence(self, interval: float = 0.2, duration: float = None):
        """LED chase sequence"""
        start_time = time.time()
        index = 0
        while self.running and (duration is None or time.time() - start_time < duration):
            self.all_off()
            self.set_led(index, True)
            index = (index + 1) % self.num_leds
            time.sleep(interval)
    
    def knight_rider(self, interval: float = 0.1, duration: float = None):
        """Knight Rider style LED sweep"""
        start_time = time.time()
        position = 0
        direction = 1
        
        while self.running and (duration is None or time.time() - start_time < duration):
            self.all_off()
            
            # Create trailing effect
            for i in range(max(0, position - 2), min(self.num_leds, position + 3)):
                if i == position:
                    self.set_led(i, True)
                elif abs(i - position) == 1:
                    if self.led_pins[i] in self.pwm_pins:
                        self.set_led_brightness(self.led_pins[i], 50.0)
                    else:
                        self.set_led(i, True)
                elif abs(i - position) == 2:
                    if self.led_pins[i] in self.pwm_pins:
                        self.set_led_brightness(self.led_pins[i], 20.0)
            
            position += direction
            if position >= self.num_leds - 1 or position <= 0:
                direction = -direction
            
            time.sleep(interval)
    
    def fade_sequence(self, pin: int, duration: float = 2.0):
        """Fade LED in and out"""
        if pin not in self.pwm_pins:
            print(f"Pin {pin} does not support PWM")
            return
        
        steps = 100
        step_delay = duration / (2 * steps)
        
        # Fade in
        for brightness in range(0, 101):
            if not self.running:
                break
            self.set_led_brightness(pin, brightness)
            time.sleep(step_delay)
        
        # Fade out
        for brightness in range(100, -1, -1):
            if not self.running:
                break
            self.set_led_brightness(pin, brightness)
            time.sleep(step_delay)
    
    def pattern_display(self, pattern: List[List[bool]], interval: float = 0.5):
        """Display custom LED pattern"""
        for frame in pattern:
            if not self.running:
                break
            for i, state in enumerate(frame[:self.num_leds]):
                self.set_led(i, state)
            time.sleep(interval)
    
    def binary_counter(self, max_count: int = None, interval: float = 0.5):
        """Display binary counter on LEDs"""
        max_count = max_count or (2 ** self.num_leds - 1)
        count = 0
        
        while self.running and count <= max_count:
            # Convert count to binary and display on LEDs
            for i in range(self.num_leds):
                bit = (count >> i) & 1
                self.set_led(i, bool(bit))
            
            count += 1
            time.sleep(interval)
    
    def rainbow_fade(self, duration: float = None):
        """Rainbow fade effect on PWM LEDs"""
        if not self.pwm_pins:
            print("No PWM pins available for rainbow effect")
            return
        
        start_time = time.time()
        hue = 0
        
        while self.running and (duration is None or time.time() - start_time < duration):
            # Simple RGB color wheel simulation
            for i, pin in enumerate(self.pwm_pins[:3]):  # Use first 3 PWM pins as RGB
                phase = (hue + i * 120) % 360
                brightness = (1 + math.cos(math.radians(phase))) * 50
                self.set_led_brightness(pin, brightness)
            
            hue = (hue + 1) % 360
            time.sleep(0.05)
    
    def random_blink(self, duration: float = None, interval: float = 0.1):
        """Random LED blinking pattern"""
        import random
        start_time = time.time()
        
        while self.running and (duration is None or time.time() - start_time < duration):
            # Randomly turn LEDs on/off
            for i in range(self.num_leds):
                self.set_led(i, random.choice([True, False]))
            time.sleep(interval)
    
    def start_mode(self, mode: int, **kwargs):
        """Start LED control mode in a separate thread"""
        if self.thread and self.thread.is_alive():
            self.stop()
        
        self.running = True
        self.current_mode = mode
        
        mode_functions = {
            0: lambda: self.all_off(),
            1: lambda: self.all_on(),
            2: lambda: self.blink_all(kwargs.get('interval', 0.5)),
            3: lambda: self.chase_sequence(kwargs.get('interval', 0.2)),
            4: lambda: self.knight_rider(kwargs.get('interval', 0.1)),
            5: lambda: self.binary_counter(kwargs.get('max_count', 255), kwargs.get('interval', 0.5)),
            6: lambda: self.random_blink(kwargs.get('duration', None), kwargs.get('interval', 0.1))
        }
        
        if mode in mode_functions:
            self.thread = threading.Thread(target=mode_functions[mode])
            self.thread.daemon = True
            self.thread.start()
            print(f"Started mode {mode}")
        else:
            print(f"Invalid mode: {mode}")
    
    def stop(self):
        """Stop LED control and cleanup"""
        self.running = False
        if self.thread and self.thread.is_alive():
            self.thread.join(timeout=1.0)
        
        self.all_off()
        
        # Cleanup PWM
        for pwm in self.pwm_objects.values():
            pwm.stop()
        
        GPIO.cleanup()
        print("LED controller stopped and cleaned up")

def main():
    """Main function with interactive mode"""
    # Define GPIO pins (adjust according to your setup)
    LED_PINS = [18, 19, 20, 21, 22, 23, 24, 25]  # Regular GPIO pins
    PWM_PINS = [12, 13, 16]  # PWM-capable pins
    
    controller = LEDController(LED_PINS, PWM_PINS)
    
    print("\nLED Control System")
    print("Available modes:")
    print("0 - All Off")
    print("1 - All On") 
    print("2 - Blink All")
    print("3 - Chase Sequence")
    print("4 - Knight Rider")
    print("5 - Binary Counter")
    print("6 - Random Blink")
    print("q - Quit")
    
    try:
        while True:
            choice = input("\nEnter mode (0-6) or 'q' to quit: ").strip().lower()
            
            if choice == 'q':
                break
            elif choice.isdigit():
                mode = int(choice)
                if 0 <= mode <= 6:
                    controller.start_mode(mode)
                else:
                    print("Invalid mode. Please enter 0-6.")
            else:
                print("Invalid input. Please enter a number 0-6 or 'q'.")
    
    except KeyboardInterrupt:
        pass
    finally:
        controller.stop()

if __name__ == "__main__":
    # Import math for rainbow effect
    import math
    main()
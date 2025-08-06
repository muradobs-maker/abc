# LED Control Code Collection

This repository contains comprehensive LED control code for multiple platforms and use cases. Whether you're working with Arduino, Raspberry Pi, or want to simulate LED behavior in a web browser, you'll find the appropriate code here.

## 📁 Files Overview

### 🔧 Hardware Control
- **`led_control_arduino.ino`** - Arduino LED control with multiple modes and patterns
- **`led_control_raspberry_pi.py`** - Comprehensive Raspberry Pi GPIO LED control
- **`simple_led_blink.py`** - Simple beginner-friendly LED blink example

### 🌐 Web Simulation
- **`led_simulator.html`** - Interactive web-based LED simulator with beautiful UI

## 🚀 Quick Start

### Arduino Setup

1. **Hardware Requirements:**
   - Arduino (Uno, Nano, or compatible)
   - 8 LEDs
   - 8 current-limiting resistors (220Ω - 1kΩ)
   - Breadboard and jumper wires
   - Push button (optional)
   - Potentiometer (optional)

2. **Wiring:**
   ```
   LEDs: Connect to digital pins 2-9 through resistors
   PWM LED: Connect to pin 11 through resistor
   Button: Connect to pin 12 with pull-up
   Potentiometer: Connect to analog pin A0
   ```

3. **Upload and Run:**
   - Open `led_control_arduino.ino` in Arduino IDE
   - Select your board and port
   - Upload the code
   - Open Serial Monitor to see mode information

4. **Controls:**
   - Button press cycles through modes
   - Potentiometer controls animation speed
   - Serial monitor shows current mode

### Raspberry Pi Setup

1. **Install Dependencies:**
   ```bash
   sudo apt-get update
   sudo apt-get install python3-rpi.gpio
   ```

2. **Hardware Wiring:**
   ```
   LEDs: Connect to GPIO pins 18, 19, 20, 21, 22, 23, 24, 25
   PWM LEDs: Use pins 12, 13, 16 for brightness control
   Use appropriate resistors (220Ω - 1kΩ)
   ```

3. **Run the Code:**
   ```bash
   # Full-featured controller
   python3 led_control_raspberry_pi.py
   
   # Simple blink example
   python3 simple_led_blink.py
   ```

### Web Simulator

1. **No Installation Required:**
   - Simply open `led_simulator.html` in any modern web browser
   - Works on desktop, tablet, and mobile devices

2. **Features:**
   - Interactive LED clicking
   - Multiple animation modes
   - Speed control
   - Color selection
   - Custom pattern editor
   - Keyboard shortcuts

## 🎮 Features Comparison

| Feature | Arduino | Raspberry Pi | Web Simulator |
|---------|---------|--------------|---------------|
| Basic On/Off | ✅ | ✅ | ✅ |
| Blink Patterns | ✅ | ✅ | ✅ |
| Chase Sequence | ✅ | ✅ | ✅ |
| Knight Rider | ✅ | ✅ | ✅ |
| PWM/Brightness | ✅ | ✅ | ✅ |
| Speed Control | ✅ | ✅ | ✅ |
| Custom Patterns | ✅ | ✅ | ✅ |
| Interactive UI | Serial | Terminal | Web Interface |
| Color Support | Hardware | Hardware | Visual |

## 🎯 Available LED Modes

### 1. Basic Controls
- **All On** - Turn on all LEDs
- **All Off** - Turn off all LEDs
- **Individual Control** - Toggle specific LEDs

### 2. Animation Patterns
- **Blink** - All LEDs blink simultaneously
- **Chase** - LEDs light up in sequence
- **Knight Rider** - Sweeping pattern with trailing effect
- **Wave** - Sine wave pattern
- **Random** - Random LED blinking
- **Binary Counter** - Display binary numbers

### 3. Advanced Features
- **Speed Control** - Adjust animation timing
- **PWM Brightness** - Smooth brightness transitions
- **Custom Patterns** - Create and save your own sequences
- **Color Modes** - Different LED colors (web simulator)

## ⌨️ Keyboard Shortcuts (Web Simulator)

- `1` - All LEDs On
- `0` - All LEDs Off  
- `b` - Toggle Blink mode
- `c` - Toggle Chase mode
- `k` - Toggle Knight Rider mode
- `w` - Toggle Wave mode
- `r` - Toggle Random mode
- `Space` - Stop all animations

## 🔧 Customization

### Arduino Customization
```cpp
// Modify pin assignments
const int LED_PINS[] = {2, 3, 4, 5, 6, 7, 8, 9};
const int NUM_LEDS = 8;

// Add custom patterns
const int patterns[][PATTERN_LENGTH] = {
  {1, 0, 1, 0, 1, 0, 1, 0}, // Your custom pattern
  // Add more patterns...
};
```

### Raspberry Pi Customization
```python
# Change GPIO pins
LED_PINS = [18, 19, 20, 21, 22, 23, 24, 25]
PWM_PINS = [12, 13, 16]

# Create custom controller
controller = LEDController(LED_PINS, PWM_PINS)
```

### Web Simulator Customization
```javascript
// Modify LED count
this.numLEDs = 16; // Change to desired number

// Add custom animations
runAnimation(mode) {
    switch (mode) {
        case 'myCustomMode':
            this.myCustomAnimation();
            break;
    }
}
```

## 🛠️ Troubleshooting

### Arduino Issues
- **LEDs not lighting:** Check wiring and resistor values
- **Erratic behavior:** Ensure stable power supply
- **Button not working:** Check pull-up resistor configuration

### Raspberry Pi Issues
- **Permission denied:** Run with `sudo` or add user to GPIO group
- **GPIO already in use:** Ensure no other programs are using GPIO pins
- **Import errors:** Install RPi.GPIO with `pip3 install RPi.GPIO`

### Web Simulator Issues
- **Animations not smooth:** Try a different browser or reduce animation speed
- **Patterns not saving:** Check if browser allows local storage
- **Mobile responsiveness:** Rotate device or zoom out for better view

## 📚 Learning Resources

### Beginner Tips
1. Start with `simple_led_blink.py` for basic concepts
2. Use the web simulator to understand patterns visually
3. Experiment with timing and sequences
4. Always use appropriate resistors to protect LEDs

### Advanced Projects
- RGB LED color mixing
- Sound-reactive LED displays
- Network-controlled LED arrays
- Integration with sensors and IoT devices

## 🤝 Contributing

Feel free to contribute improvements, additional patterns, or platform support:
1. Fork the repository
2. Create a feature branch
3. Add your enhancements
4. Submit a pull request

## 📄 License

This code is provided for educational and hobbyist use. Feel free to modify and distribute according to your needs.

## 🆘 Support

If you encounter issues or have questions:
1. Check the troubleshooting section
2. Review the code comments for implementation details
3. Test with simple examples first
4. Ensure proper hardware connections

---

**Happy LED controlling! 🔆**
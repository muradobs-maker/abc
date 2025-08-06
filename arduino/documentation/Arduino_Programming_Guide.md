# Arduino Programming Complete Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Arduino Basics](#arduino-basics)
4. [Programming Fundamentals](#programming-fundamentals)
5. [Hardware Interfacing](#hardware-interfacing)
6. [Advanced Topics](#advanced-topics)
7. [Project Examples](#project-examples)
8. [Troubleshooting](#troubleshooting)
9. [Resources](#resources)

## Introduction

Arduino is an open-source electronics platform based on easy-to-use hardware and software. It's intended for anyone making interactive projects. This guide will take you from beginner to advanced Arduino programming.

### What is Arduino?
- Microcontroller development platform
- Open-source hardware and software
- Easy-to-learn programming language (based on C/C++)
- Large community and extensive libraries
- Perfect for prototyping and learning electronics

### Arduino Boards
- **Arduino Uno**: Most popular, great for beginners
- **Arduino Nano**: Compact version of Uno
- **Arduino Mega**: More pins and memory
- **ESP32**: WiFi and Bluetooth enabled
- **Arduino Pro Mini**: Small, low-power applications

## Getting Started

### Arduino IDE Setup
1. Download Arduino IDE from [arduino.cc](https://arduino.cc)
2. Install the software
3. Connect your Arduino board via USB
4. Select your board: Tools → Board → Arduino Uno
5. Select the correct port: Tools → Port → (your port)

### Your First Program
```cpp
void setup() {
  // Initialize digital pin LED_BUILTIN as an output
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_BUILTIN, HIGH);   // Turn the LED on
  delay(1000);                       // Wait for a second
  digitalWrite(LED_BUILTIN, LOW);    // Turn the LED off
  delay(1000);                       // Wait for a second
}
```

## Arduino Basics

### Program Structure
Every Arduino program (sketch) has two main functions:
- `setup()`: Runs once when the program starts
- `loop()`: Runs continuously after setup()

### Data Types
```cpp
// Integer types
int myInt = 123;              // 16-bit integer (-32,768 to 32,767)
unsigned int myUInt = 65535;  // 16-bit unsigned integer (0 to 65,535)
long myLong = 123456L;        // 32-bit integer
byte myByte = 255;            // 8-bit unsigned integer (0 to 255)

// Floating point
float myFloat = 3.14;         // 32-bit floating point
double myDouble = 3.14159;    // Same as float on Arduino

// Boolean and character
bool myBool = true;           // true or false
char myChar = 'A';            // Single character

// Strings
String myString = "Hello";    // String object
char myCharArray[] = "Hello"; // Character array
```

### Variables and Constants
```cpp
// Variables
int sensorValue;              // Declaration
int ledPin = 13;              // Declaration with initialization

// Constants
const int BUTTON_PIN = 2;     // Constant integer
#define LED_PIN 13            // Preprocessor constant
```

### Control Structures

#### Conditional Statements
```cpp
// if-else
if (sensorValue > 500) {
  digitalWrite(ledPin, HIGH);
} else if (sensorValue > 200) {
  digitalWrite(ledPin, LOW);
} else {
  // Do something else
}

// switch-case
switch (mode) {
  case 1:
    // Mode 1 actions
    break;
  case 2:
    // Mode 2 actions
    break;
  default:
    // Default actions
    break;
}
```

#### Loops
```cpp
// for loop
for (int i = 0; i < 10; i++) {
  Serial.println(i);
}

// while loop
while (digitalRead(buttonPin) == HIGH) {
  // Wait for button release
}

// do-while loop
do {
  sensorValue = analogRead(A0);
} while (sensorValue < 100);
```

### Functions
```cpp
// Function declaration
int addNumbers(int a, int b);

void setup() {
  Serial.begin(9600);
  int result = addNumbers(5, 3);
  Serial.println(result);
}

void loop() {
  // Main loop
}

// Function definition
int addNumbers(int a, int b) {
  return a + b;
}
```

## Programming Fundamentals

### Digital I/O
```cpp
// Pin modes
pinMode(13, OUTPUT);          // Set pin as output
pinMode(2, INPUT);            // Set pin as input
pinMode(2, INPUT_PULLUP);     // Input with internal pull-up resistor

// Digital write
digitalWrite(13, HIGH);       // Set pin high (5V)
digitalWrite(13, LOW);        // Set pin low (0V)

// Digital read
int buttonState = digitalRead(2);  // Read digital pin
if (buttonState == HIGH) {
  // Button is pressed (assuming pull-down circuit)
}
```

### Analog I/O
```cpp
// Analog read (0-1023 for 10-bit ADC)
int sensorValue = analogRead(A0);

// Convert to voltage (assuming 5V reference)
float voltage = sensorValue * (5.0 / 1023.0);

// Analog write (PWM) - only on PWM pins
analogWrite(9, 128);  // 50% duty cycle (0-255 range)
```

### Serial Communication
```cpp
void setup() {
  Serial.begin(9600);  // Initialize serial at 9600 baud
}

void loop() {
  // Print to serial monitor
  Serial.print("Sensor value: ");
  Serial.println(analogRead(A0));
  
  // Read from serial
  if (Serial.available()) {
    String input = Serial.readString();
    Serial.print("You entered: ");
    Serial.println(input);
  }
  
  delay(1000);
}
```

### Timing Functions
```cpp
// Delay functions
delay(1000);          // Delay 1 second (blocking)
delayMicroseconds(100); // Delay 100 microseconds

// Non-blocking timing
unsigned long previousMillis = 0;
const long interval = 1000;

void loop() {
  unsigned long currentMillis = millis();
  
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    // Do something every second
  }
}
```

## Hardware Interfacing

### LEDs
```cpp
const int ledPin = 13;

void setup() {
  pinMode(ledPin, OUTPUT);
}

void loop() {
  digitalWrite(ledPin, HIGH);
  delay(500);
  digitalWrite(ledPin, LOW);
  delay(500);
}
```

### Buttons
```cpp
const int buttonPin = 2;
const int ledPin = 13;
int buttonState = 0;

void setup() {
  pinMode(ledPin, OUTPUT);
  pinMode(buttonPin, INPUT_PULLUP);
}

void loop() {
  buttonState = digitalRead(buttonPin);
  
  if (buttonState == LOW) {  // Button pressed (pull-up configuration)
    digitalWrite(ledPin, HIGH);
  } else {
    digitalWrite(ledPin, LOW);
  }
}
```

### Potentiometer
```cpp
const int potPin = A0;
const int ledPin = 9;

void setup() {
  Serial.begin(9600);
}

void loop() {
  int potValue = analogRead(potPin);
  int brightness = map(potValue, 0, 1023, 0, 255);
  
  analogWrite(ledPin, brightness);
  
  Serial.print("Pot: ");
  Serial.print(potValue);
  Serial.print(" -> Brightness: ");
  Serial.println(brightness);
  
  delay(100);
}
```

### Servo Motor
```cpp
#include <Servo.h>

Servo myServo;
const int servoPin = 9;

void setup() {
  myServo.attach(servoPin);
}

void loop() {
  // Sweep from 0 to 180 degrees
  for (int pos = 0; pos <= 180; pos++) {
    myServo.write(pos);
    delay(15);
  }
  
  // Sweep from 180 to 0 degrees
  for (int pos = 180; pos >= 0; pos--) {
    myServo.write(pos);
    delay(15);
  }
}
```

### LCD Display
```cpp
#include <LiquidCrystal.h>

// Initialize the library with interface pins
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup() {
  lcd.begin(16, 2);  // Set LCD dimensions
  lcd.print("Hello, World!");
}

void loop() {
  lcd.setCursor(0, 1);
  lcd.print(millis() / 1000);  // Display uptime in seconds
}
```

### Temperature Sensor (DHT22)
```cpp
#include <DHT.h>

#define DHT_PIN 2
#define DHT_TYPE DHT22

DHT dht(DHT_PIN, DHT_TYPE);

void setup() {
  Serial.begin(9600);
  dht.begin();
}

void loop() {
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  
  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }
  
  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.print("%  Temperature: ");
  Serial.print(temperature);
  Serial.println("°C");
  
  delay(2000);
}
```

## Advanced Topics

### Interrupts
```cpp
const int buttonPin = 2;
const int ledPin = 13;
volatile bool buttonPressed = false;

void setup() {
  pinMode(buttonPin, INPUT_PULLUP);
  pinMode(ledPin, OUTPUT);
  
  // Attach interrupt
  attachInterrupt(digitalPinToInterrupt(buttonPin), buttonISR, FALLING);
  
  Serial.begin(9600);
}

void loop() {
  if (buttonPressed) {
    Serial.println("Button was pressed!");
    digitalWrite(ledPin, !digitalRead(ledPin));  // Toggle LED
    buttonPressed = false;
  }
  
  // Other non-blocking code here
}

void buttonISR() {
  buttonPressed = true;
}
```

### EEPROM Storage
```cpp
#include <EEPROM.h>

void setup() {
  Serial.begin(9600);
  
  // Write to EEPROM
  int value = 123;
  EEPROM.write(0, value);
  
  // Read from EEPROM
  int readValue = EEPROM.read(0);
  Serial.print("Value from EEPROM: ");
  Serial.println(readValue);
}

void loop() {
  // Main loop
}
```

### Multiple Files and Libraries
Create a header file `myLibrary.h`:
```cpp
#ifndef MY_LIBRARY_H
#define MY_LIBRARY_H

class MyClass {
  private:
    int pin;
    
  public:
    MyClass(int p);
    void initialize();
    void update();
};

#endif
```

Create implementation file `myLibrary.cpp`:
```cpp
#include "myLibrary.h"
#include <Arduino.h>

MyClass::MyClass(int p) {
  pin = p;
}

void MyClass::initialize() {
  pinMode(pin, OUTPUT);
}

void MyClass::update() {
  digitalWrite(pin, !digitalRead(pin));
}
```

### Memory Management
```cpp
void setup() {
  Serial.begin(9600);
  
  // Check available RAM
  Serial.print("Free RAM: ");
  Serial.println(freeRam());
}

int freeRam() {
  extern int __heap_start, *__brkval;
  int v;
  return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval);
}
```

### State Machines
```cpp
enum State {
  IDLE,
  RUNNING,
  PAUSED,
  STOPPED
};

State currentState = IDLE;
unsigned long stateTimer = 0;

void loop() {
  switch (currentState) {
    case IDLE:
      if (digitalRead(startButton) == LOW) {
        currentState = RUNNING;
        stateTimer = millis();
      }
      break;
      
    case RUNNING:
      // Running logic here
      if (millis() - stateTimer > 5000) {  // Auto-pause after 5 seconds
        currentState = PAUSED;
      }
      break;
      
    case PAUSED:
      if (digitalRead(startButton) == LOW) {
        currentState = RUNNING;
        stateTimer = millis();
      }
      break;
      
    case STOPPED:
      // Cleanup and reset
      currentState = IDLE;
      break;
  }
}
```

## Project Examples

### 1. Basic Projects
- **Blink LED**: Classic first project
- **Button Control**: Control LED with button
- **Analog Reading**: Read potentiometer values
- **Serial Communication**: Send/receive data

### 2. Intermediate Projects
- **LCD Display**: Show sensor data on LCD
- **Servo Control**: Control servo with potentiometer
- **Temperature Monitor**: DHT22 sensor with alerts
- **Light-following Robot**: Using light sensors

### 3. Advanced Projects
- **IoT Sensor Hub**: Multiple sensors with WiFi
- **Data Logger**: SD card storage with RTC
- **Web Server**: ESP32 with web interface
- **MQTT Communication**: IoT messaging protocol

## Troubleshooting

### Common Issues

#### Compilation Errors
```
Error: 'Serial' was not declared in this scope
Solution: Make sure to include proper headers and check spelling
```

#### Upload Issues
- Check board selection in Tools menu
- Verify correct COM port
- Ensure Arduino is properly connected
- Try pressing reset button during upload

#### Hardware Issues
- Check wiring connections
- Verify power supply
- Test with multimeter
- Check component orientations

### Debugging Techniques
```cpp
// Use Serial.print for debugging
Serial.print("Debug: variable value = ");
Serial.println(myVariable);

// Add debug flags
#define DEBUG 1

#if DEBUG
  Serial.println("Debug message");
#endif

// Use LED indicators for status
digitalWrite(statusLED, digitalRead(sensorPin));
```

### Best Practices

1. **Code Organization**
   - Use meaningful variable names
   - Comment your code
   - Break complex code into functions
   - Use consistent indentation

2. **Hardware Design**
   - Use pull-up/pull-down resistors for buttons
   - Add current-limiting resistors for LEDs
   - Consider power requirements
   - Plan for expandability

3. **Performance**
   - Avoid long delays in loop()
   - Use interrupts for time-critical tasks
   - Minimize memory usage
   - Use appropriate data types

## Resources

### Official Documentation
- [Arduino Reference](https://www.arduino.cc/reference/en/)
- [Arduino Libraries](https://www.arduino.cc/en/Reference/Libraries)
- [Arduino Forum](https://forum.arduino.cc/)

### Learning Resources
- [Arduino Project Hub](https://create.arduino.cc/projecthub)
- [Adafruit Learning System](https://learn.adafruit.com/)
- [SparkFun Tutorials](https://learn.sparkfun.com/)

### Tools and Software
- [Fritzing](http://fritzing.org/) - Circuit design
- [Tinkercad Circuits](https://www.tinkercad.com/) - Online simulation
- [PlatformIO](https://platformio.org/) - Advanced IDE

### Components Suppliers
- [Arduino Store](https://store.arduino.cc/)
- [Adafruit](https://www.adafruit.com/)
- [SparkFun](https://www.sparkfun.com/)
- [DigiKey](https://www.digikey.com/)
- [Mouser](https://www.mouser.com/)

### Community
- [Arduino Subreddit](https://www.reddit.com/r/arduino/)
- [Arduino Discord](https://discord.gg/jQJFwW7)
- [Stack Overflow Arduino Tag](https://stackoverflow.com/questions/tagged/arduino)

---

## Conclusion

This guide covers the fundamentals of Arduino programming from basic concepts to advanced techniques. The key to mastering Arduino is practice and experimentation. Start with simple projects and gradually work your way up to more complex systems.

Remember:
- Start small and build incrementally
- Test frequently
- Document your projects
- Don't be afraid to experiment
- Join the Arduino community for support

Happy coding!
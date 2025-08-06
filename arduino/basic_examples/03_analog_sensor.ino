/*
  Analog Sensor Reading Example
  
  This program reads an analog sensor (potentiometer, photoresistor, etc.)
  and displays the values on the serial monitor. It also controls an LED
  based on the sensor value.
  
  Hardware Required:
  - Arduino board
  - Potentiometer (or photoresistor + 10kΩ resistor)
  - LED + 220Ω resistor (optional, can use built-in LED)
  - Breadboard and jumper wires
  
  Connections:
  - Sensor: Connect to analog pin A0
  - LED: Connect to digital pin 9 (PWM capable)
  
  For Potentiometer:
  - Connect outer pins to 5V and GND
  - Connect middle pin to A0
  
  For Photoresistor:
  - Connect one end to 5V
  - Connect other end to A0 and to 10kΩ resistor
  - Connect other end of resistor to GND
  
  Created: 2024
*/

const int sensorPin = A0;    // Analog input pin
const int ledPin = 9;        // PWM output pin for LED
const int builtinLedPin = 13; // Built-in LED pin

// Variables for sensor readings
int sensorValue = 0;         // Raw sensor value (0-1023)
float voltage = 0.0;         // Converted voltage (0-5V)
int ledBrightness = 0;       // LED brightness (0-255)

// Variables for averaging readings
const int numReadings = 10;
int readings[numReadings];
int readIndex = 0;
int total = 0;
int average = 0;

void setup() {
  // Initialize serial communication
  Serial.begin(9600);
  
  // Initialize pins
  pinMode(ledPin, OUTPUT);
  pinMode(builtinLedPin, OUTPUT);
  
  // Initialize all readings to 0
  for (int thisReading = 0; thisReading < numReadings; thisReading++) {
    readings[thisReading] = 0;
  }
  
  Serial.println("=== Analog Sensor Reading Demo ===");
  Serial.println("Raw Value | Voltage | Average | LED Brightness");
  Serial.println("----------|---------|---------|---------------");
}

void loop() {
  // Read the analog sensor
  sensorValue = analogRead(sensorPin);
  
  // Convert to voltage (0-5V)
  voltage = sensorValue * (5.0 / 1023.0);
  
  // Calculate running average
  total = total - readings[readIndex];
  readings[readIndex] = sensorValue;
  total = total + readings[readIndex];
  readIndex = readIndex + 1;
  
  if (readIndex >= numReadings) {
    readIndex = 0;
  }
  
  average = total / numReadings;
  
  // Map sensor value to LED brightness (0-255)
  ledBrightness = map(sensorValue, 0, 1023, 0, 255);
  
  // Control LEDs based on sensor value
  analogWrite(ledPin, ledBrightness);
  
  // Blink built-in LED based on sensor threshold
  if (sensorValue > 512) {
    digitalWrite(builtinLedPin, HIGH);
  } else {
    digitalWrite(builtinLedPin, LOW);
  }
  
  // Print values to serial monitor
  Serial.print(sensorValue);
  Serial.print("       | ");
  Serial.print(voltage, 2);
  Serial.print("V   | ");
  Serial.print(average);
  Serial.print("     | ");
  Serial.println(ledBrightness);
  
  // Check for extreme values and provide feedback
  if (sensorValue < 50) {
    Serial.println("  -> Very low reading detected");
  } else if (sensorValue > 950) {
    Serial.println("  -> Very high reading detected");
  }
  
  // Small delay for readability
  delay(200);
}

/*
  Additional Functions for Enhanced Functionality
*/

// Function to calibrate sensor (call during setup if needed)
void calibrateSensor() {
  int minVal = 1023;
  int maxVal = 0;
  
  Serial.println("Calibrating sensor for 5 seconds...");
  Serial.println("Vary the sensor input during this time.");
  
  unsigned long startTime = millis();
  while (millis() - startTime < 5000) {
    int reading = analogRead(sensorPin);
    if (reading > maxVal) maxVal = reading;
    if (reading < minVal) minVal = reading;
    
    // Blink LED during calibration
    digitalWrite(builtinLedPin, (millis() / 250) % 2);
    delay(10);
  }
  
  Serial.print("Calibration complete. Min: ");
  Serial.print(minVal);
  Serial.print(", Max: ");
  Serial.println(maxVal);
  
  digitalWrite(builtinLedPin, LOW);
}
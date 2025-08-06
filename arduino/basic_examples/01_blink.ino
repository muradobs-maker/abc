/*
  Blink LED Example
  
  This is the classic "Hello World" program for Arduino.
  It blinks the built-in LED on and off every second.
  
  Hardware Required:
  - Arduino board (any model)
  - Built-in LED (usually connected to pin 13)
  
  Created: 2024
  Modified: 2024
*/

// Pin 13 has an LED connected on most Arduino boards
const int ledPin = 13;

void setup() {
  // Initialize the digital pin as an output
  pinMode(ledPin, OUTPUT);
  
  // Initialize serial communication (optional, for debugging)
  Serial.begin(9600);
  Serial.println("Blink LED Example Started");
}

void loop() {
  digitalWrite(ledPin, HIGH);   // Turn the LED on
  Serial.println("LED ON");
  delay(1000);                  // Wait for 1 second
  
  digitalWrite(ledPin, LOW);    // Turn the LED off
  Serial.println("LED OFF");
  delay(1000);                  // Wait for 1 second
}
/*
  LCD Display Example
  
  This program demonstrates how to control a 16x2 LCD display
  using the LiquidCrystal library. It shows various text operations
  and real-time information display.
  
  Hardware Required:
  - Arduino board
  - 16x2 LCD display (HD44780 compatible)
  - 10kΩ potentiometer (for contrast adjustment)
  - Breadboard and jumper wires
  
  LCD Connections:
  - VSS to ground
  - VDD to 5V
  - V0 to potentiometer wiper (contrast)
  - RS to digital pin 12
  - Enable to digital pin 11
  - D4 to digital pin 5
  - D5 to digital pin 4
  - D6 to digital pin 3
  - D7 to digital pin 2
  - A to 5V (backlight)
  - K to ground (backlight)
  
  Created: 2024
*/

#include <LiquidCrystal.h>

// Initialize the library with interface pins
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

// Variables for dynamic display
unsigned long previousMillis = 0;
const long interval = 1000;  // Update interval in milliseconds
int displayMode = 0;         // Current display mode
const int maxModes = 4;      // Number of display modes

// Sensor simulation variables
int temperature = 20;
int humidity = 50;
int lightLevel = 500;

// Custom characters (8x5 pixel patterns)
byte thermometer[8] = {
  B00100,
  B01010,
  B01010,
  B01110,
  B11111,
  B11111,
  B01110,
  B00000
};

byte droplet[8] = {
  B00100,
  B00100,
  B01010,
  B01010,
  B10001,
  B10001,
  B01110,
  B00000
};

byte sun[8] = {
  B00000,
  B10101,
  B01110,
  B11111,
  B01110,
  B10101,
  B00000,
  B00000
};

void setup() {
  // Initialize LCD with dimensions
  lcd.begin(16, 2);
  
  // Create custom characters
  lcd.createChar(0, thermometer);
  lcd.createChar(1, droplet);
  lcd.createChar(2, sun);
  
  // Initialize serial for debugging
  Serial.begin(9600);
  
  // Display startup message
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Arduino LCD Demo");
  lcd.setCursor(0, 1);
  lcd.print("Starting...");
  delay(2000);
  
  Serial.println("LCD Display Demo Started");
  Serial.println("Display modes will cycle every few seconds");
}

void loop() {
  unsigned long currentMillis = millis();
  
  // Update display every interval
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    
    // Simulate sensor readings
    updateSensorValues();
    
    // Display current mode
    displayCurrentMode();
    
    // Cycle through display modes
    displayMode = (displayMode + 1) % maxModes;
    
    // Debug output
    Serial.print("Display Mode: ");
    Serial.print(displayMode);
    Serial.print(" | Temp: ");
    Serial.print(temperature);
    Serial.print("°C | Humidity: ");
    Serial.print(humidity);
    Serial.print("% | Light: ");
    Serial.println(lightLevel);
  }
  
  // Small delay to prevent overwhelming the display
  delay(50);
}

void displayCurrentMode() {
  lcd.clear();
  
  switch (displayMode) {
    case 0:
      displayWelcome();
      break;
    case 1:
      displayTemperature();
      break;
    case 2:
      displayHumidity();
      break;
    case 3:
      displayLightLevel();
      break;
  }
}

void displayWelcome() {
  lcd.setCursor(0, 0);
  lcd.print("  Arduino LCD   ");
  lcd.setCursor(0, 1);
  lcd.print("   Demo Mode    ");
}

void displayTemperature() {
  lcd.setCursor(0, 0);
  lcd.write(byte(0)); // Custom thermometer character
  lcd.print(" Temperature");
  
  lcd.setCursor(0, 1);
  lcd.print("    ");
  lcd.print(temperature);
  lcd.print((char)223); // Degree symbol
  lcd.print("C");
  
  // Temperature bar graph
  int bars = map(temperature, 0, 40, 0, 8);
  lcd.setCursor(8, 1);
  for (int i = 0; i < 8; i++) {
    if (i < bars) {
      lcd.print((char)255); // Full block
    } else {
      lcd.print("-");
    }
  }
}

void displayHumidity() {
  lcd.setCursor(0, 0);
  lcd.write(byte(1)); // Custom droplet character
  lcd.print(" Humidity");
  
  lcd.setCursor(0, 1);
  lcd.print("     ");
  lcd.print(humidity);
  lcd.print("%");
  
  // Humidity bar graph
  int bars = map(humidity, 0, 100, 0, 8);
  lcd.setCursor(8, 1);
  for (int i = 0; i < 8; i++) {
    if (i < bars) {
      lcd.print((char)255); // Full block
    } else {
      lcd.print("-");
    }
  }
}

void displayLightLevel() {
  lcd.setCursor(0, 0);
  lcd.write(byte(2)); // Custom sun character
  lcd.print(" Light Level");
  
  lcd.setCursor(0, 1);
  lcd.print("   ");
  lcd.print(lightLevel);
  
  // Light level bar graph
  int bars = map(lightLevel, 0, 1023, 0, 8);
  lcd.setCursor(8, 1);
  for (int i = 0; i < 8; i++) {
    if (i < bars) {
      lcd.print((char)255); // Full block
    } else {
      lcd.print("-");
    }
  }
}

void updateSensorValues() {
  // Simulate changing sensor values
  temperature += random(-2, 3);
  temperature = constrain(temperature, 15, 35);
  
  humidity += random(-5, 6);
  humidity = constrain(humidity, 30, 80);
  
  lightLevel += random(-50, 51);
  lightLevel = constrain(lightLevel, 0, 1023);
}

// Utility functions for advanced LCD operations
void scrollText(String text, int row, int delayTime) {
  // Scroll text horizontally across the display
  int textLength = text.length();
  
  for (int position = 0; position < textLength - 15; position++) {
    lcd.setCursor(0, row);
    lcd.print(text.substring(position, position + 16));
    delay(delayTime);
  }
}

void blinkText(String text, int row, int col, int times) {
  // Blink text at specified position
  for (int i = 0; i < times; i++) {
    lcd.setCursor(col, row);
    lcd.print(text);
    delay(500);
    
    // Clear the text
    lcd.setCursor(col, row);
    for (int j = 0; j < text.length(); j++) {
      lcd.print(" ");
    }
    delay(500);
  }
}
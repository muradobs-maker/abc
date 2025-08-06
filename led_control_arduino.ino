/*
 * LED Control System for Arduino
 * Supports multiple LEDs with various control modes
 * Author: LED Control System
 * Version: 1.0
 */

// Pin definitions
const int LED_PINS[] = {2, 3, 4, 5, 6, 7, 8, 9}; // Digital pins for LEDs
const int NUM_LEDS = 8;
const int PWM_LED_PIN = 11; // PWM pin for fade effects
const int BUTTON_PIN = 12; // Button for mode switching
const int POTENTIOMETER_PIN = A0; // Analog pin for speed control

// Variables
int currentMode = 0;
int ledStates[NUM_LEDS] = {0}; // Track LED states
unsigned long previousMillis = 0;
unsigned long interval = 500; // Default blink interval
int fadeValue = 0;
int fadeDirection = 5;
int patternIndex = 0;
bool buttonPressed = false;
bool lastButtonState = false;

// LED Patterns
const int PATTERN_LENGTH = 8;
const int patterns[][PATTERN_LENGTH] = {
  {1, 0, 0, 0, 0, 0, 0, 0}, // Single LED sweep
  {1, 1, 0, 0, 0, 0, 0, 0}, // Double LED sweep
  {1, 0, 1, 0, 1, 0, 1, 0}, // Alternating pattern
  {1, 1, 1, 1, 0, 0, 0, 0}, // Half and half
  {1, 1, 1, 1, 1, 1, 1, 1}, // All on
  {0, 0, 0, 0, 0, 0, 0, 0}  // All off
};

void setup() {
  Serial.begin(9600);
  
  // Initialize LED pins as outputs
  for (int i = 0; i < NUM_LEDS; i++) {
    pinMode(LED_PINS[i], OUTPUT);
    digitalWrite(LED_PINS[i], LOW);
  }
  
  pinMode(PWM_LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  
  Serial.println("LED Control System Initialized");
  Serial.println("Modes: 0=Blink, 1=Chase, 2=Fade, 3=Pattern, 4=Knight Rider, 5=All On, 6=All Off");
}

void loop() {
  // Read potentiometer for speed control
  int potValue = analogRead(POTENTIOMETER_PIN);
  interval = map(potValue, 0, 1023, 50, 2000);
  
  // Check button press for mode switching
  bool currentButtonState = digitalRead(BUTTON_PIN) == LOW;
  if (currentButtonState && !lastButtonState) {
    currentMode = (currentMode + 1) % 7;
    Serial.print("Mode changed to: ");
    Serial.println(currentMode);
    resetLEDs();
  }
  lastButtonState = currentButtonState;
  
  // Execute current mode
  switch (currentMode) {
    case 0:
      blinkMode();
      break;
    case 1:
      chaseMode();
      break;
    case 2:
      fadeMode();
      break;
    case 3:
      patternMode();
      break;
    case 4:
      knightRiderMode();
      break;
    case 5:
      allOnMode();
      break;
    case 6:
      allOffMode();
      break;
  }
  
  delay(10); // Small delay for stability
}

void blinkMode() {
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    
    // Toggle all LEDs
    for (int i = 0; i < NUM_LEDS; i++) {
      ledStates[i] = !ledStates[i];
      digitalWrite(LED_PINS[i], ledStates[i]);
    }
  }
}

void chaseMode() {
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    
    // Turn off all LEDs
    for (int i = 0; i < NUM_LEDS; i++) {
      digitalWrite(LED_PINS[i], LOW);
    }
    
    // Turn on current LED
    digitalWrite(LED_PINS[patternIndex], HIGH);
    patternIndex = (patternIndex + 1) % NUM_LEDS;
  }
}

void fadeMode() {
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= 30) { // Smooth fade
    previousMillis = currentMillis;
    
    analogWrite(PWM_LED_PIN, fadeValue);
    fadeValue += fadeDirection;
    
    if (fadeValue <= 0 || fadeValue >= 255) {
      fadeDirection = -fadeDirection;
    }
  }
}

void patternMode() {
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    
    // Cycle through different patterns
    int currentPattern = (patternIndex / PATTERN_LENGTH) % 6;
    int currentStep = patternIndex % PATTERN_LENGTH;
    
    for (int i = 0; i < NUM_LEDS; i++) {
      digitalWrite(LED_PINS[i], patterns[currentPattern][i]);
    }
    
    patternIndex++;
  }
}

void knightRiderMode() {
  static int position = 0;
  static int direction = 1;
  
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval / 2) {
    previousMillis = currentMillis;
    
    // Turn off all LEDs
    for (int i = 0; i < NUM_LEDS; i++) {
      digitalWrite(LED_PINS[i], LOW);
    }
    
    // Create trailing effect
    digitalWrite(LED_PINS[position], HIGH);
    if (position + direction >= 0 && position + direction < NUM_LEDS) {
      digitalWrite(LED_PINS[position + direction], LOW);
    }
    
    position += direction;
    
    // Reverse direction at ends
    if (position >= NUM_LEDS - 1 || position <= 0) {
      direction = -direction;
    }
  }
}

void allOnMode() {
  for (int i = 0; i < NUM_LEDS; i++) {
    digitalWrite(LED_PINS[i], HIGH);
  }
  analogWrite(PWM_LED_PIN, 255);
}

void allOffMode() {
  for (int i = 0; i < NUM_LEDS; i++) {
    digitalWrite(LED_PINS[i], LOW);
  }
  analogWrite(PWM_LED_PIN, 0);
}

void resetLEDs() {
  for (int i = 0; i < NUM_LEDS; i++) {
    digitalWrite(LED_PINS[i], LOW);
    ledStates[i] = 0;
  }
  analogWrite(PWM_LED_PIN, 0);
  patternIndex = 0;
  fadeValue = 0;
  fadeDirection = 5;
}

// Function to set individual LED
void setLED(int ledIndex, bool state) {
  if (ledIndex >= 0 && ledIndex < NUM_LEDS) {
    digitalWrite(LED_PINS[ledIndex], state);
    ledStates[ledIndex] = state;
  }
}

// Function to set LED brightness (for PWM pins)
void setLEDBrightness(int ledPin, int brightness) {
  brightness = constrain(brightness, 0, 255);
  analogWrite(ledPin, brightness);
}

// Function to create custom pattern
void customPattern(int pattern[], int length, int repeatCount) {
  for (int repeat = 0; repeat < repeatCount; repeat++) {
    for (int step = 0; step < length; step++) {
      for (int i = 0; i < NUM_LEDS && i < length; i++) {
        digitalWrite(LED_PINS[i], (pattern[step] >> i) & 1);
      }
      delay(interval);
    }
  }
}
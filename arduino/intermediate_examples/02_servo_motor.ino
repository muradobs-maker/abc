/*
  Servo Motor Control Example
  
  This program demonstrates various servo motor control techniques
  including sweep patterns, position control, and sensor-based movement.
  
  Hardware Required:
  - Arduino board
  - Servo motor (standard 9g or similar)
  - Potentiometer (10kΩ)
  - Push button
  - 10kΩ pull-up resistor for button
  - Breadboard and jumper wires
  
  Connections:
  - Servo signal (orange/yellow) to digital pin 9
  - Servo power (red) to 5V
  - Servo ground (brown/black) to GND
  - Potentiometer middle pin to A0
  - Potentiometer outer pins to 5V and GND
  - Button one side to digital pin 2
  - Button other side to GND
  - 10kΩ resistor from pin 2 to 5V
  
  Created: 2024
*/

#include <Servo.h>

Servo myServo;              // Create servo object
const int servoPin = 9;     // Servo control pin
const int potPin = A0;      // Potentiometer pin
const int buttonPin = 2;    // Button pin

// Servo control variables
int currentPosition = 90;   // Current servo position
int targetPosition = 90;    // Target servo position
int servoSpeed = 2;         // Speed of servo movement (degrees per update)

// Control mode variables
int controlMode = 0;        // Current control mode
const int maxModes = 5;     // Number of control modes
bool buttonPressed = false;
bool lastButtonState = HIGH;

// Timing variables
unsigned long previousMillis = 0;
const long updateInterval = 20;  // Update servo every 20ms

// Movement pattern variables
float sweepAngle = 0;       // For sine wave movement
int sweepDirection = 1;     // Sweep direction
int sweepSpeed = 1;         // Sweep speed

void setup() {
  // Initialize servo
  myServo.attach(servoPin);
  myServo.write(currentPosition);
  
  // Initialize pins
  pinMode(buttonPin, INPUT_PULLUP);
  
  // Initialize serial communication
  Serial.begin(9600);
  Serial.println("=== Servo Motor Control Demo ===");
  Serial.println("Press button to cycle through control modes:");
  Serial.println("0: Manual (Potentiometer)");
  Serial.println("1: Sweep 0-180");
  Serial.println("2: Sine Wave");
  Serial.println("3: Random Movement");
  Serial.println("4: Step Sequence");
  Serial.println("================================");
  
  delay(1000);
}

void loop() {
  unsigned long currentMillis = millis();
  
  // Check button press
  checkButton();
  
  // Update servo position based on current mode
  if (currentMillis - previousMillis >= updateInterval) {
    previousMillis = currentMillis;
    
    switch (controlMode) {
      case 0:
        manualControl();
        break;
      case 1:
        sweepControl();
        break;
      case 2:
        sineWaveControl();
        break;
      case 3:
        randomControl();
        break;
      case 4:
        stepSequenceControl();
        break;
    }
    
    // Smooth movement to target position
    smoothMove();
    
    // Debug output every 500ms
    static unsigned long lastDebug = 0;
    if (currentMillis - lastDebug >= 500) {
      lastDebug = currentMillis;
      printStatus();
    }
  }
}

void checkButton() {
  bool currentButtonState = digitalRead(buttonPin);
  
  // Detect button press (falling edge)
  if (lastButtonState == HIGH && currentButtonState == LOW) {
    controlMode = (controlMode + 1) % maxModes;
    Serial.print("Switched to mode ");
    Serial.print(controlMode);
    Serial.print(": ");
    Serial.println(getModeDescription(controlMode));
    
    // Reset variables for new mode
    sweepAngle = 0;
    sweepDirection = 1;
    
    delay(50); // Debounce delay
  }
  
  lastButtonState = currentButtonState;
}

void manualControl() {
  // Read potentiometer and map to servo range
  int potValue = analogRead(potPin);
  targetPosition = map(potValue, 0, 1023, 0, 180);
}

void sweepControl() {
  // Simple back and forth sweep
  currentPosition += sweepDirection * sweepSpeed;
  
  if (currentPosition >= 180) {
    currentPosition = 180;
    sweepDirection = -1;
  } else if (currentPosition <= 0) {
    currentPosition = 0;
    sweepDirection = 1;
  }
  
  targetPosition = currentPosition;
}

void sineWaveControl() {
  // Sine wave movement pattern
  sweepAngle += 0.1; // Adjust for speed
  if (sweepAngle >= 2 * PI) {
    sweepAngle = 0;
  }
  
  // Map sine wave (-1 to 1) to servo range (0 to 180)
  targetPosition = 90 + (sin(sweepAngle) * 80);
}

void randomControl() {
  // Random movement with occasional direction changes
  static unsigned long lastRandomChange = 0;
  static int randomDirection = 1;
  
  if (millis() - lastRandomChange > random(1000, 3000)) {
    targetPosition = random(20, 160);
    lastRandomChange = millis();
  }
}

void stepSequenceControl() {
  // Predefined step sequence
  static int stepIndex = 0;
  static unsigned long lastStepTime = 0;
  int steps[] = {0, 45, 90, 135, 180, 135, 90, 45};
  int numSteps = sizeof(steps) / sizeof(steps[0]);
  
  if (millis() - lastStepTime > 1000) {
    targetPosition = steps[stepIndex];
    stepIndex = (stepIndex + 1) % numSteps;
    lastStepTime = millis();
  }
}

void smoothMove() {
  // Smooth movement to target position
  if (currentPosition < targetPosition) {
    currentPosition += servoSpeed;
    if (currentPosition > targetPosition) {
      currentPosition = targetPosition;
    }
  } else if (currentPosition > targetPosition) {
    currentPosition -= servoSpeed;
    if (currentPosition < targetPosition) {
      currentPosition = targetPosition;
    }
  }
  
  // Constrain to valid servo range
  currentPosition = constrain(currentPosition, 0, 180);
  
  // Update servo position
  myServo.write(currentPosition);
}

void printStatus() {
  Serial.print("Mode: ");
  Serial.print(controlMode);
  Serial.print(" | Position: ");
  Serial.print(currentPosition);
  Serial.print("° | Target: ");
  Serial.print(targetPosition);
  Serial.print("° | Pot: ");
  Serial.println(analogRead(potPin));
}

String getModeDescription(int mode) {
  switch (mode) {
    case 0: return "Manual (Potentiometer)";
    case 1: return "Sweep 0-180";
    case 2: return "Sine Wave";
    case 3: return "Random Movement";
    case 4: return "Step Sequence";
    default: return "Unknown";
  }
}

// Advanced servo functions
void servoAttach() {
  if (!myServo.attached()) {
    myServo.attach(servoPin);
    Serial.println("Servo attached");
  }
}

void servoDetach() {
  if (myServo.attached()) {
    myServo.detach();
    Serial.println("Servo detached (power saving)");
  }
}

void calibrateServo() {
  Serial.println("Calibrating servo...");
  
  // Move to known positions for calibration
  Serial.println("Moving to 0 degrees");
  myServo.write(0);
  delay(1000);
  
  Serial.println("Moving to 90 degrees");
  myServo.write(90);
  delay(1000);
  
  Serial.println("Moving to 180 degrees");
  myServo.write(180);
  delay(1000);
  
  Serial.println("Returning to center");
  myServo.write(90);
  delay(1000);
  
  Serial.println("Calibration complete");
}
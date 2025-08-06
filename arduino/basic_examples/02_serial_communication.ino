/*
  Serial Communication Example
  
  This program demonstrates basic serial communication between
  Arduino and a computer. It reads input from the serial monitor
  and echoes it back with additional information.
  
  Hardware Required:
  - Arduino board
  - USB cable for serial connection
  
  Instructions:
  1. Upload this code to your Arduino
  2. Open Serial Monitor (Tools > Serial Monitor)
  3. Set baud rate to 9600
  4. Type messages and press Enter
  
  Created: 2024
*/

String inputString = "";      // String to hold incoming data
boolean stringComplete = false;  // Whether the string is complete

void setup() {
  // Initialize serial communication at 9600 baud
  Serial.begin(9600);
  
  // Print startup message
  Serial.println("=== Arduino Serial Communication Demo ===");
  Serial.println("Type a message and press Enter");
  Serial.println("Commands:");
  Serial.println("  'help' - Show this help message");
  Serial.println("  'status' - Show Arduino status");
  Serial.println("  'led on' - Turn on built-in LED");
  Serial.println("  'led off' - Turn off built-in LED");
  Serial.println("==========================================");
  
  // Initialize built-in LED
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  
  // Reserve 200 bytes for the inputString
  inputString.reserve(200);
}

void loop() {
  // Check if a complete string has been received
  if (stringComplete) {
    // Process the received command
    processCommand(inputString);
    
    // Clear the string for next input
    inputString = "";
    stringComplete = false;
  }
}

void processCommand(String command) {
  command.trim(); // Remove whitespace
  command.toLowerCase(); // Convert to lowercase
  
  Serial.print("Received: ");
  Serial.println(command);
  
  if (command == "help") {
    Serial.println("Available commands:");
    Serial.println("  help - Show this help");
    Serial.println("  status - Arduino status");
    Serial.println("  led on - Turn LED on");
    Serial.println("  led off - Turn LED off");
  }
  else if (command == "status") {
    Serial.println("Arduino Status:");
    Serial.print("  Uptime: ");
    Serial.print(millis());
    Serial.println(" ms");
    Serial.print("  Free RAM: ");
    Serial.print(getFreeRam());
    Serial.println(" bytes");
    Serial.print("  LED State: ");
    Serial.println(digitalRead(LED_BUILTIN) ? "ON" : "OFF");
  }
  else if (command == "led on") {
    digitalWrite(LED_BUILTIN, HIGH);
    Serial.println("LED turned ON");
  }
  else if (command == "led off") {
    digitalWrite(LED_BUILTIN, LOW);
    Serial.println("LED turned OFF");
  }
  else {
    Serial.println("Unknown command. Type 'help' for available commands.");
  }
  
  Serial.println(); // Empty line for readability
}

// Function to get free RAM (useful for debugging)
int getFreeRam() {
  extern int __heap_start, *__brkval;
  int v;
  return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval);
}

// Serial event handler - called when data is available
void serialEvent() {
  while (Serial.available()) {
    // Get the new byte
    char inChar = (char)Serial.read();
    
    // Add it to the inputString
    inputString += inChar;
    
    // If the incoming character is a newline, set a flag
    if (inChar == '\n') {
      stringComplete = true;
    }
  }
}
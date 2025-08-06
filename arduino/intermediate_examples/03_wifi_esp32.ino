/*
  ESP32 WiFi Web Server Example
  
  This program demonstrates WiFi connectivity and web server functionality
  on ESP32. It creates a simple web interface to control LEDs and read sensors.
  
  Note: This code is specifically for ESP32. For Arduino Uno with WiFi shield,
  use WiFi library instead of WiFi.h
  
  Hardware Required:
  - ESP32 development board
  - LED + 220Ω resistor (or use built-in LED)
  - Potentiometer (optional, for sensor simulation)
  - Breadboard and jumper wires
  
  Connections:
  - LED to GPIO 2 (built-in LED on most ESP32 boards)
  - Potentiometer middle pin to GPIO 34 (ADC pin)
  - Potentiometer outer pins to 3.3V and GND
  
  Setup:
  1. Install ESP32 board package in Arduino IDE
  2. Select your ESP32 board from Tools > Board
  3. Update WiFi credentials below
  4. Upload the code
  5. Open Serial Monitor to see IP address
  6. Open the IP address in a web browser
  
  Created: 2024
*/

#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>

// WiFi credentials - UPDATE THESE
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Web server on port 80
WebServer server(80);

// Pin definitions
const int ledPin = 2;        // Built-in LED (GPIO 2)
const int sensorPin = 34;    // Analog sensor pin (ADC)

// Control variables
bool ledState = false;
int sensorValue = 0;
float temperature = 0.0;
unsigned long lastSensorRead = 0;
const long sensorInterval = 1000;  // Read sensor every second

// Device information
String deviceName = "ESP32-WebServer";
String firmwareVersion = "1.0.0";
unsigned long startTime;

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.println("ESP32 WiFi Web Server Starting...");
  
  // Initialize pins
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  
  // Record start time
  startTime = millis();
  
  // Connect to WiFi
  connectToWiFi();
  
  // Setup web server routes
  setupWebServer();
  
  // Start the server
  server.begin();
  Serial.println("Web server started!");
  Serial.print("Open http://");
  Serial.print(WiFi.localIP());
  Serial.println(" in your browser");
}

void loop() {
  // Handle web server clients
  server.handleClient();
  
  // Read sensors periodically
  if (millis() - lastSensorRead >= sensorInterval) {
    readSensors();
    lastSensorRead = millis();
  }
  
  // Small delay to prevent watchdog issues
  delay(10);
}

void connectToWiFi() {
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println();
    Serial.println("WiFi connected successfully!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    Serial.print("Signal strength: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  } else {
    Serial.println();
    Serial.println("Failed to connect to WiFi!");
    Serial.println("Please check your credentials and try again.");
  }
}

void setupWebServer() {
  // Root page - main interface
  server.on("/", handleRoot);
  
  // API endpoints
  server.on("/api/status", handleStatus);
  server.on("/api/led/on", handleLedOn);
  server.on("/api/led/off", handleLedOff);
  server.on("/api/led/toggle", handleLedToggle);
  server.on("/api/sensor", handleSensorData);
  server.on("/api/info", handleDeviceInfo);
  
  // Handle 404 errors
  server.onNotFound(handleNotFound);
}

void handleRoot() {
  String html = generateMainPage();
  server.send(200, "text/html", html);
}

void handleStatus() {
  DynamicJsonDocument doc(1024);
  
  doc["led_state"] = ledState;
  doc["sensor_value"] = sensorValue;
  doc["temperature"] = temperature;
  doc["uptime"] = millis() - startTime;
  doc["free_heap"] = ESP.getFreeHeap();
  doc["wifi_rssi"] = WiFi.RSSI();
  
  String response;
  serializeJson(doc, response);
  
  server.send(200, "application/json", response);
}

void handleLedOn() {
  ledState = true;
  digitalWrite(ledPin, HIGH);
  server.send(200, "text/plain", "LED turned ON");
}

void handleLedOff() {
  ledState = false;
  digitalWrite(ledPin, LOW);
  server.send(200, "text/plain", "LED turned OFF");
}

void handleLedToggle() {
  ledState = !ledState;
  digitalWrite(ledPin, ledState ? HIGH : LOW);
  server.send(200, "text/plain", ledState ? "LED turned ON" : "LED turned OFF");
}

void handleSensorData() {
  DynamicJsonDocument doc(512);
  
  doc["raw_value"] = sensorValue;
  doc["voltage"] = (sensorValue * 3.3) / 4095.0;  // ESP32 ADC is 12-bit
  doc["temperature"] = temperature;
  doc["timestamp"] = millis();
  
  String response;
  serializeJson(doc, response);
  
  server.send(200, "application/json", response);
}

void handleDeviceInfo() {
  DynamicJsonDocument doc(1024);
  
  doc["device_name"] = deviceName;
  doc["firmware_version"] = firmwareVersion;
  doc["chip_model"] = ESP.getChipModel();
  doc["chip_revision"] = ESP.getChipRevision();
  doc["cpu_frequency"] = ESP.getCpuFreqMHz();
  doc["flash_size"] = ESP.getFlashChipSize();
  doc["free_heap"] = ESP.getFreeHeap();
  doc["uptime"] = millis() - startTime;
  doc["wifi_ssid"] = WiFi.SSID();
  doc["wifi_ip"] = WiFi.localIP().toString();
  doc["wifi_rssi"] = WiFi.RSSI();
  
  String response;
  serializeJson(doc, response);
  
  server.send(200, "application/json", response);
}

void handleNotFound() {
  String message = "File Not Found\n\n";
  message += "URI: " + server.uri() + "\n";
  message += "Method: " + (server.method() == HTTP_GET ? "GET" : "POST") + "\n";
  message += "Arguments: " + server.args() + "\n";
  
  for (uint8_t i = 0; i < server.args(); i++) {
    message += " " + server.argName(i) + ": " + server.arg(i) + "\n";
  }
  
  server.send(404, "text/plain", message);
}

void readSensors() {
  // Read analog sensor
  sensorValue = analogRead(sensorPin);
  
  // Convert to simulated temperature (example conversion)
  float voltage = (sensorValue * 3.3) / 4095.0;
  temperature = (voltage - 0.5) * 100.0;  // Simulated temperature sensor
  
  // Debug output
  Serial.print("Sensor: ");
  Serial.print(sensorValue);
  Serial.print(" | Voltage: ");
  Serial.print(voltage, 2);
  Serial.print("V | Temp: ");
  Serial.print(temperature, 1);
  Serial.println("°C");
}

String generateMainPage() {
  String html = "<!DOCTYPE html><html><head>";
  html += "<title>ESP32 Web Server</title>";
  html += "<meta name='viewport' content='width=device-width, initial-scale=1'>";
  html += "<style>";
  html += "body { font-family: Arial, sans-serif; margin: 20px; background-color: #f0f0f0; }";
  html += ".container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }";
  html += ".header { text-align: center; color: #333; margin-bottom: 30px; }";
  html += ".section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }";
  html += ".button { background-color: #4CAF50; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; margin: 5px; }";
  html += ".button:hover { background-color: #45a049; }";
  html += ".button.off { background-color: #f44336; }";
  html += ".button.off:hover { background-color: #da190b; }";
  html += ".status { font-family: monospace; background-color: #f9f9f9; padding: 10px; border-radius: 5px; }";
  html += ".refresh { float: right; }";
  html += "</style>";
  html += "<script>";
  html += "function toggleLED() { fetch('/api/led/toggle').then(() => updateStatus()); }";
  html += "function ledOn() { fetch('/api/led/on').then(() => updateStatus()); }";
  html += "function ledOff() { fetch('/api/led/off').then(() => updateStatus()); }";
  html += "function updateStatus() {";
  html += "  fetch('/api/status').then(r => r.json()).then(data => {";
  html += "    document.getElementById('ledStatus').innerHTML = data.led_state ? 'ON' : 'OFF';";
  html += "    document.getElementById('sensorValue').innerHTML = data.sensor_value;";
  html += "    document.getElementById('temperature').innerHTML = data.temperature.toFixed(1) + '°C';";
  html += "    document.getElementById('uptime').innerHTML = Math.floor(data.uptime / 1000) + 's';";
  html += "    document.getElementById('freeHeap').innerHTML = data.free_heap + ' bytes';";
  html += "    document.getElementById('wifiRssi').innerHTML = data.wifi_rssi + ' dBm';";
  html += "  });";
  html += "}";
  html += "setInterval(updateStatus, 2000);";
  html += "</script>";
  html += "</head><body>";
  
  html += "<div class='container'>";
  html += "<div class='header'><h1>ESP32 Web Server</h1></div>";
  
  html += "<div class='section'>";
  html += "<h2>LED Control</h2>";
  html += "<button class='button' onclick='ledOn()'>Turn ON</button>";
  html += "<button class='button off' onclick='ledOff()'>Turn OFF</button>";
  html += "<button class='button' onclick='toggleLED()'>Toggle</button>";
  html += "<p>LED Status: <span id='ledStatus'>" + String(ledState ? "ON" : "OFF") + "</span></p>";
  html += "</div>";
  
  html += "<div class='section'>";
  html += "<h2>Sensor Data <button class='button refresh' onclick='updateStatus()'>Refresh</button></h2>";
  html += "<div class='status'>";
  html += "Sensor Value: <span id='sensorValue'>" + String(sensorValue) + "</span><br>";
  html += "Temperature: <span id='temperature'>" + String(temperature, 1) + "°C</span><br>";
  html += "</div>";
  html += "</div>";
  
  html += "<div class='section'>";
  html += "<h2>System Status</h2>";
  html += "<div class='status'>";
  html += "Uptime: <span id='uptime'>" + String((millis() - startTime) / 1000) + "s</span><br>";
  html += "Free Heap: <span id='freeHeap'>" + String(ESP.getFreeHeap()) + " bytes</span><br>";
  html += "WiFi RSSI: <span id='wifiRssi'>" + String(WiFi.RSSI()) + " dBm</span><br>";
  html += "IP Address: " + WiFi.localIP().toString() + "<br>";
  html += "Chip Model: " + String(ESP.getChipModel()) + "<br>";
  html += "</div>";
  html += "</div>";
  
  html += "</div>";
  html += "<script>updateStatus();</script>";
  html += "</body></html>";
  
  return html;
}
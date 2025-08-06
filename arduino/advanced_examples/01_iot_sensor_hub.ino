/*
  IoT Sensor Hub - Advanced Arduino Project
  
  This project creates a comprehensive IoT sensor hub that:
  - Reads multiple sensors (temperature, humidity, light, motion)
  - Connects to WiFi and sends data to cloud services
  - Implements local data logging with timestamps
  - Provides web interface for configuration and monitoring
  - Includes alert system for threshold violations
  - Supports OTA (Over-The-Air) firmware updates
  
  Hardware Required:
  - ESP32 development board
  - DHT22 temperature/humidity sensor
  - LDR (Light Dependent Resistor) + 10kΩ resistor
  - PIR motion sensor
  - MicroSD card module + SD card
  - Real-time clock (DS3231) module
  - Status LEDs (Red, Green, Blue)
  - Buzzer (optional)
  - Breadboard and jumper wires
  
  Libraries Required:
  - WiFi
  - WebServer
  - ArduinoJson
  - DHT sensor library
  - RTClib
  - SD
  - ArduinoOTA
  - PubSubClient (for MQTT)
  
  Created: 2024
*/

#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <RTClib.h>
#include <SD.h>
#include <ArduinoOTA.h>
#include <PubSubClient.h>
#include <HTTPClient.h>

// Pin definitions
#define DHT_PIN 4
#define DHT_TYPE DHT22
#define LDR_PIN 34
#define PIR_PIN 5
#define SD_CS_PIN 5
#define LED_RED 25
#define LED_GREEN 26
#define LED_BLUE 27
#define BUZZER_PIN 32

// Network configuration
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* mqtt_server = "your-mqtt-broker.com";
const char* mqtt_user = "your-mqtt-username";
const char* mqtt_password = "your-mqtt-password";

// Cloud service configuration
const char* thingspeak_api_key = "YOUR_THINGSPEAK_API_KEY";
const char* webhook_url = "https://your-webhook-url.com/data";

// Initialize components
DHT dht(DHT_PIN, DHT_TYPE);
RTC_DS3231 rtc;
WebServer server(80);
WiFiClient espClient;
PubSubClient mqtt(espClient);

// Sensor data structure
struct SensorData {
  float temperature;
  float humidity;
  int lightLevel;
  bool motionDetected;
  unsigned long timestamp;
  String dateTime;
};

// System configuration
struct Config {
  int readingInterval = 30000;  // 30 seconds
  int uploadInterval = 300000;  // 5 minutes
  float tempThresholdHigh = 30.0;
  float tempThresholdLow = 10.0;
  float humidityThresholdHigh = 80.0;
  int lightThresholdLow = 100;
  bool alertsEnabled = true;
  bool mqttEnabled = true;
  bool thingspeakEnabled = true;
  bool sdLoggingEnabled = true;
};

// Global variables
SensorData currentReading;
Config systemConfig;
unsigned long lastReading = 0;
unsigned long lastUpload = 0;
unsigned long lastMqttReconnect = 0;
bool systemInitialized = false;
String logFileName;

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== IoT Sensor Hub Starting ===");
  
  // Initialize pins
  initializePins();
  
  // Initialize sensors and modules
  initializeSensors();
  
  // Connect to WiFi
  connectToWiFi();
  
  // Initialize services
  initializeServices();
  
  // Setup web server
  setupWebServer();
  
  // Initialize OTA updates
  setupOTA();
  
  // Create log file
  createLogFile();
  
  systemInitialized = true;
  setStatusLED(LED_GREEN, true);
  Serial.println("=== System Ready ===");
}

void loop() {
  unsigned long currentTime = millis();
  
  // Handle OTA updates
  ArduinoOTA.handle();
  
  // Handle web server
  server.handleClient();
  
  // Maintain MQTT connection
  if (systemConfig.mqttEnabled && !mqtt.connected()) {
    if (currentTime - lastMqttReconnect > 5000) {
      reconnectMQTT();
      lastMqttReconnect = currentTime;
    }
  }
  mqtt.loop();
  
  // Read sensors at specified interval
  if (currentTime - lastReading >= systemConfig.readingInterval) {
    readAllSensors();
    processAlerts();
    logDataToSD();
    lastReading = currentTime;
  }
  
  // Upload data at specified interval
  if (currentTime - lastUpload >= systemConfig.uploadInterval) {
    uploadData();
    lastUpload = currentTime;
  }
  
  delay(100);
}

void initializePins() {
  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_BLUE, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(PIR_PIN, INPUT);
  
  // Turn off all LEDs initially
  setStatusLED(LED_RED, false);
  setStatusLED(LED_GREEN, false);
  setStatusLED(LED_BLUE, false);
}

void initializeSensors() {
  Serial.println("Initializing sensors...");
  
  // Initialize DHT sensor
  dht.begin();
  setStatusLED(LED_BLUE, true);
  delay(1000);
  
  // Initialize RTC
  if (!rtc.begin()) {
    Serial.println("RTC initialization failed!");
  } else {
    Serial.println("RTC initialized");
    if (rtc.lostPower()) {
      Serial.println("RTC lost power, setting time!");
      rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
    }
  }
  
  // Initialize SD card
  if (systemConfig.sdLoggingEnabled) {
    if (!SD.begin(SD_CS_PIN)) {
      Serial.println("SD card initialization failed!");
      systemConfig.sdLoggingEnabled = false;
    } else {
      Serial.println("SD card initialized");
    }
  }
  
  setStatusLED(LED_BLUE, false);
}

void connectToWiFi() {
  setStatusLED(LED_BLUE, true);
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
    Serial.println("WiFi connected!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nWiFi connection failed!");
  }
  
  setStatusLED(LED_BLUE, false);
}

void initializeServices() {
  // Initialize MQTT
  if (systemConfig.mqttEnabled) {
    mqtt.setServer(mqtt_server, 1883);
    mqtt.setCallback(mqttCallback);
  }
}

void readAllSensors() {
  Serial.println("Reading sensors...");
  
  // Read DHT22 sensor
  currentReading.temperature = dht.readTemperature();
  currentReading.humidity = dht.readHumidity();
  
  // Read light sensor
  currentReading.lightLevel = analogRead(LDR_PIN);
  
  // Read motion sensor
  currentReading.motionDetected = digitalRead(PIR_PIN);
  
  // Get timestamp
  DateTime now = rtc.now();
  currentReading.timestamp = now.unixtime();
  currentReading.dateTime = String(now.year()) + "-" + 
                           String(now.month()) + "-" + 
                           String(now.day()) + " " + 
                           String(now.hour()) + ":" + 
                           String(now.minute()) + ":" + 
                           String(now.second());
  
  // Print readings
  Serial.println("=== Sensor Readings ===");
  Serial.print("Temperature: ");
  Serial.print(currentReading.temperature);
  Serial.println("°C");
  Serial.print("Humidity: ");
  Serial.print(currentReading.humidity);
  Serial.println("%");
  Serial.print("Light Level: ");
  Serial.println(currentReading.lightLevel);
  Serial.print("Motion: ");
  Serial.println(currentReading.motionDetected ? "Detected" : "None");
  Serial.print("DateTime: ");
  Serial.println(currentReading.dateTime);
  Serial.println("=====================");
}

void processAlerts() {
  if (!systemConfig.alertsEnabled) return;
  
  bool alertTriggered = false;
  String alertMessage = "ALERT: ";
  
  // Temperature alerts
  if (currentReading.temperature > systemConfig.tempThresholdHigh) {
    alertMessage += "High temperature (" + String(currentReading.temperature) + "°C) ";
    alertTriggered = true;
  } else if (currentReading.temperature < systemConfig.tempThresholdLow) {
    alertMessage += "Low temperature (" + String(currentReading.temperature) + "°C) ";
    alertTriggered = true;
  }
  
  // Humidity alert
  if (currentReading.humidity > systemConfig.humidityThresholdHigh) {
    alertMessage += "High humidity (" + String(currentReading.humidity) + "%) ";
    alertTriggered = true;
  }
  
  // Light alert
  if (currentReading.lightLevel < systemConfig.lightThresholdLow) {
    alertMessage += "Low light (" + String(currentReading.lightLevel) + ") ";
    alertTriggered = true;
  }
  
  // Motion alert
  if (currentReading.motionDetected) {
    alertMessage += "Motion detected ";
    alertTriggered = true;
  }
  
  if (alertTriggered) {
    Serial.println(alertMessage);
    triggerAlert();
    
    // Send alert via MQTT
    if (mqtt.connected()) {
      mqtt.publish("sensors/alerts", alertMessage.c_str());
    }
  }
}

void triggerAlert() {
  // Flash red LED and sound buzzer
  for (int i = 0; i < 3; i++) {
    setStatusLED(LED_RED, true);
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    setStatusLED(LED_RED, false);
    digitalWrite(BUZZER_PIN, LOW);
    delay(200);
  }
}

void logDataToSD() {
  if (!systemConfig.sdLoggingEnabled) return;
  
  File dataFile = SD.open(logFileName, FILE_APPEND);
  if (dataFile) {
    String logEntry = currentReading.dateTime + "," +
                     String(currentReading.temperature) + "," +
                     String(currentReading.humidity) + "," +
                     String(currentReading.lightLevel) + "," +
                     String(currentReading.motionDetected ? 1 : 0);
    
    dataFile.println(logEntry);
    dataFile.close();
    Serial.println("Data logged to SD card");
  } else {
    Serial.println("Error opening log file");
  }
}

void uploadData() {
  if (WiFi.status() != WL_CONNECTED) return;
  
  Serial.println("Uploading data...");
  
  // Upload to ThingSpeak
  if (systemConfig.thingspeakEnabled) {
    uploadToThingSpeak();
  }
  
  // Send via MQTT
  if (systemConfig.mqttEnabled && mqtt.connected()) {
    publishMQTTData();
  }
  
  // Send to webhook
  sendToWebhook();
}

void uploadToThingSpeak() {
  HTTPClient http;
  String url = "http://api.thingspeak.com/update?api_key=" + String(thingspeak_api_key) +
               "&field1=" + String(currentReading.temperature) +
               "&field2=" + String(currentReading.humidity) +
               "&field3=" + String(currentReading.lightLevel) +
               "&field4=" + String(currentReading.motionDetected ? 1 : 0);
  
  http.begin(url);
  int httpResponseCode = http.GET();
  
  if (httpResponseCode > 0) {
    Serial.println("ThingSpeak upload successful");
  } else {
    Serial.println("ThingSpeak upload failed");
  }
  
  http.end();
}

void publishMQTTData() {
  DynamicJsonDocument doc(1024);
  doc["temperature"] = currentReading.temperature;
  doc["humidity"] = currentReading.humidity;
  doc["light"] = currentReading.lightLevel;
  doc["motion"] = currentReading.motionDetected;
  doc["timestamp"] = currentReading.timestamp;
  doc["datetime"] = currentReading.dateTime;
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  mqtt.publish("sensors/data", jsonString.c_str());
  Serial.println("MQTT data published");
}

void sendToWebhook() {
  HTTPClient http;
  http.begin(webhook_url);
  http.addHeader("Content-Type", "application/json");
  
  DynamicJsonDocument doc(1024);
  doc["device_id"] = "sensor_hub_001";
  doc["temperature"] = currentReading.temperature;
  doc["humidity"] = currentReading.humidity;
  doc["light"] = currentReading.lightLevel;
  doc["motion"] = currentReading.motionDetected;
  doc["timestamp"] = currentReading.timestamp;
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  int httpResponseCode = http.POST(jsonString);
  
  if (httpResponseCode > 0) {
    Serial.println("Webhook sent successfully");
  } else {
    Serial.println("Webhook send failed");
  }
  
  http.end();
}

void reconnectMQTT() {
  if (mqtt.connect("SensorHub", mqtt_user, mqtt_password)) {
    Serial.println("MQTT connected");
    mqtt.subscribe("sensors/config");
  } else {
    Serial.print("MQTT connection failed, rc=");
    Serial.println(mqtt.state());
  }
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  String message;
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  
  Serial.print("MQTT message received: ");
  Serial.println(message);
  
  // Process configuration updates
  if (String(topic) == "sensors/config") {
    processConfigUpdate(message);
  }
}

void processConfigUpdate(String config) {
  DynamicJsonDocument doc(1024);
  deserializeJson(doc, config);
  
  if (doc.containsKey("reading_interval")) {
    systemConfig.readingInterval = doc["reading_interval"];
  }
  if (doc.containsKey("upload_interval")) {
    systemConfig.uploadInterval = doc["upload_interval"];
  }
  if (doc.containsKey("temp_threshold_high")) {
    systemConfig.tempThresholdHigh = doc["temp_threshold_high"];
  }
  
  Serial.println("Configuration updated via MQTT");
}

void setupWebServer() {
  server.on("/", handleRoot);
  server.on("/api/data", handleApiData);
  server.on("/api/config", HTTP_GET, handleGetConfig);
  server.on("/api/config", HTTP_POST, handleSetConfig);
  server.on("/api/logs", handleLogs);
  server.onNotFound(handleNotFound);
  
  server.begin();
  Serial.println("Web server started");
}

void setupOTA() {
  ArduinoOTA.setHostname("sensor-hub");
  ArduinoOTA.setPassword("your-ota-password");
  
  ArduinoOTA.onStart([]() {
    String type = (ArduinoOTA.getCommand() == U_FLASH) ? "sketch" : "filesystem";
    Serial.println("Start updating " + type);
  });
  
  ArduinoOTA.onEnd([]() {
    Serial.println("\nEnd");
  });
  
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
  });
  
  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed");
  });
  
  ArduinoOTA.begin();
  Serial.println("OTA ready");
}

void createLogFile() {
  if (!systemConfig.sdLoggingEnabled) return;
  
  DateTime now = rtc.now();
  logFileName = "/sensors_" + String(now.year()) + "_" + 
                String(now.month()) + "_" + String(now.day()) + ".csv";
  
  // Check if file exists, if not create header
  if (!SD.exists(logFileName)) {
    File dataFile = SD.open(logFileName, FILE_WRITE);
    if (dataFile) {
      dataFile.println("DateTime,Temperature,Humidity,Light,Motion");
      dataFile.close();
      Serial.println("Log file created: " + logFileName);
    }
  }
}

void setStatusLED(int pin, bool state) {
  digitalWrite(pin, state ? HIGH : LOW);
}

// Web server handlers
void handleRoot() {
  String html = generateDashboard();
  server.send(200, "text/html", html);
}

void handleApiData() {
  DynamicJsonDocument doc(1024);
  doc["temperature"] = currentReading.temperature;
  doc["humidity"] = currentReading.humidity;
  doc["light"] = currentReading.lightLevel;
  doc["motion"] = currentReading.motionDetected;
  doc["timestamp"] = currentReading.timestamp;
  doc["datetime"] = currentReading.dateTime;
  doc["uptime"] = millis();
  doc["free_heap"] = ESP.getFreeHeap();
  doc["wifi_rssi"] = WiFi.RSSI();
  
  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

void handleGetConfig() {
  DynamicJsonDocument doc(1024);
  doc["reading_interval"] = systemConfig.readingInterval;
  doc["upload_interval"] = systemConfig.uploadInterval;
  doc["temp_threshold_high"] = systemConfig.tempThresholdHigh;
  doc["temp_threshold_low"] = systemConfig.tempThresholdLow;
  doc["humidity_threshold_high"] = systemConfig.humidityThresholdHigh;
  doc["light_threshold_low"] = systemConfig.lightThresholdLow;
  doc["alerts_enabled"] = systemConfig.alertsEnabled;
  doc["mqtt_enabled"] = systemConfig.mqttEnabled;
  doc["thingspeak_enabled"] = systemConfig.thingspeakEnabled;
  doc["sd_logging_enabled"] = systemConfig.sdLoggingEnabled;
  
  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

void handleSetConfig() {
  if (server.hasArg("plain")) {
    String body = server.arg("plain");
    processConfigUpdate(body);
    server.send(200, "text/plain", "Configuration updated");
  } else {
    server.send(400, "text/plain", "Bad Request");
  }
}

void handleLogs() {
  if (!systemConfig.sdLoggingEnabled) {
    server.send(404, "text/plain", "SD logging disabled");
    return;
  }
  
  File dataFile = SD.open(logFileName);
  if (dataFile) {
    String logs = dataFile.readString();
    dataFile.close();
    server.send(200, "text/plain", logs);
  } else {
    server.send(404, "text/plain", "Log file not found");
  }
}

void handleNotFound() {
  server.send(404, "text/plain", "File not found");
}

String generateDashboard() {
  // This would contain a comprehensive HTML dashboard
  // For brevity, returning a simple version
  String html = "<!DOCTYPE html><html><head><title>IoT Sensor Hub</title>";
  html += "<meta name='viewport' content='width=device-width, initial-scale=1'>";
  html += "<style>body{font-family:Arial;margin:20px;background:#f0f0f0;}";
  html += ".container{max-width:1200px;margin:0 auto;background:white;padding:20px;border-radius:10px;}";
  html += ".sensor{display:inline-block;margin:10px;padding:15px;border:1px solid #ddd;border-radius:5px;min-width:200px;}";
  html += ".value{font-size:24px;font-weight:bold;color:#333;}";
  html += ".unit{font-size:14px;color:#666;}";
  html += "</style></head><body>";
  
  html += "<div class='container'>";
  html += "<h1>IoT Sensor Hub Dashboard</h1>";
  
  html += "<div class='sensor'>";
  html += "<h3>Temperature</h3>";
  html += "<div class='value'>" + String(currentReading.temperature, 1) + "</div>";
  html += "<div class='unit'>°C</div>";
  html += "</div>";
  
  html += "<div class='sensor'>";
  html += "<h3>Humidity</h3>";
  html += "<div class='value'>" + String(currentReading.humidity, 1) + "</div>";
  html += "<div class='unit'>%</div>";
  html += "</div>";
  
  html += "<div class='sensor'>";
  html += "<h3>Light Level</h3>";
  html += "<div class='value'>" + String(currentReading.lightLevel) + "</div>";
  html += "<div class='unit'>lux</div>";
  html += "</div>";
  
  html += "<div class='sensor'>";
  html += "<h3>Motion</h3>";
  html += "<div class='value'>" + String(currentReading.motionDetected ? "Detected" : "None") + "</div>";
  html += "</div>";
  
  html += "<p>Last Update: " + currentReading.dateTime + "</p>";
  html += "<p>System Uptime: " + String(millis() / 1000) + " seconds</p>";
  
  html += "</div>";
  html += "</body></html>";
  
  return html;
}
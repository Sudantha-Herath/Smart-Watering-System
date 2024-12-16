#include <WiFi.h>
#include <FirebaseESP32.h>

// Wi-Fi credentials
#define WIFI_SSID ""
#define WIFI_PASSWORD ""

// Firebase credentials
#define FIREBASE_HOST "https://smart-watering-system-8de5d-default-rtdb.firebaseio.com/"
#define FIREBASE_AUTH "Tk3CU5sIbmEBiqxwJeWXju5d96a501HgRKsCZmEG"

// Firebase and Wi-Fi objects
FirebaseData firebaseData;
FirebaseConfig firebaseConfig;
FirebaseAuth firebaseAuth;

// Pin definitions
#define SOIL_SENSOR_PIN 34 // Analog pin for Soil Moisture Sensor
#define PUMP_PIN 18         // GPIO pin for Pump (via relay)
#define LED_PIN 4          // GPIO pin for LED indicator

// Variables
int soilMoisture = 0;      // Soil moisture percentage
bool manualControl = false; // Manual mode state
bool pumpStatus = false;   // Pump state (on/off)

// Setup function
void setup() {
  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nWi-Fi Connected!");

  // Setup Firebase
  firebaseConfig.host = FIREBASE_HOST;
  firebaseConfig.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&firebaseConfig, &firebaseAuth);

  // Initialize pins
  pinMode(SOIL_SENSOR_PIN, INPUT);
  pinMode(PUMP_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);

  digitalWrite(PUMP_PIN, LOW); // Ensure pump is off initially
  digitalWrite(LED_PIN, LOW);  // Ensure LED is off initially
}

// Main loop
void loop() {
  // Read soil moisture
  int sensorValue = analogRead(SOIL_SENSOR_PIN);
  soilMoisture = map(sensorValue, 0, 2900, 0, 100);
  Serial.println("Soil Moisture: " + String(soilMoisture) + "%");

  // Send soil moisture to Firebase
  Firebase.setInt(firebaseData, "/soilMoisture", soilMoisture);

  // Check manual control state
  if (Firebase.getBool(firebaseData, "/manualControl")) {
    manualControl = firebaseData.boolData();
  }

  // Check pump status from Firebase in manual mode
  if (manualControl) {
    if (Firebase.getBool(firebaseData, "/pumpStatus")) {
      pumpStatus = firebaseData.boolData();
      digitalWrite(PUMP_PIN, pumpStatus ? HIGH : LOW);
      digitalWrite(LED_PIN, pumpStatus ? HIGH : LOW); // Control LED
    }
  } else {
    // Automatic mode: Control pump based on soil moisture
    if (soilMoisture >= 80) {
      digitalWrite(PUMP_PIN, HIGH); // Turn on pump
      digitalWrite(LED_PIN, HIGH); // Turn on LED
      pumpStatus = true;
    } else {
      digitalWrite(PUMP_PIN, LOW); // Turn off pump
      digitalWrite(LED_PIN, LOW);  // Turn off LED
      pumpStatus = false;
    }
  }

  // Update pump status in Firebase
  Firebase.setBool(firebaseData, "/pumpStatus", pumpStatus);

  delay(1000); // Delay for stability
}

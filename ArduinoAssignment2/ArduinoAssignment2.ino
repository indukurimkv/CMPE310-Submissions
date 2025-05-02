#define LED1_PIN 11 // The pin number of the first LED
#define LED2_PIN 13 // The pin number of the second LED
// Whether to deactivate unused LED(turn it off while other blinks)
#define ACTIVATE_ONE_ONLY 1

// Properties to store how to blink leds
struct BlinkProperty{
  int ledNum = 1;
  int ledDelay = 1000;
  long lastBlinkMs = 0;
} blinkProp;

// Which prompt to show in a loop iteration
enum PromptType{
  LED_NUM_PROMPT,
  LED_DELAY_PROMPT,
  NO_PROMPT
} promptType;

// Stores the input read in so far
String buffer;

void setup() {
  // put your setup code here, to run once:
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  Serial.begin(9600);
  buffer = "";

  // Display "which led" prompt
  promptType = LED_NUM_PROMPT;
}

void loop() {
  // Show the Prompt based on state of promptType
  switch(promptType){
    case LED_NUM_PROMPT:
      Serial.println("Which LED? (1 or 2): ");
      promptType = NO_PROMPT;
      break;
    case LED_DELAY_PROMPT:
      Serial.println("What delay interval? (ms): ");
      promptType = NO_PROMPT;
      break;
  }

  // Clear the input buffer so far
  while(Serial.available()){
    buffer.concat((char)Serial.read());
    if(buffer.endsWith(String('\n')) && countChars(buffer, '\n') == 1){
      // Recieved the led num, so ask for led delay
      promptType = LED_DELAY_PROMPT;
    } else if(buffer.endsWith(String('\n')) && countChars(buffer, '\n') == 2){
      // Recieved both parameters, so restart prompting loop
      promptType = LED_NUM_PROMPT;
    }
  }
  // Check if the user input both paramters
  if(countChars(buffer, '\n') == 2){
    updateBlink();
  }
  blink();
}

// Counts how many of a given character are in a string
int countChars(String s, char c){
  int count = 0;
  // Loop through String and increment count if char found
  for(int i = 0; i < s.length(); i++){
    if(s.charAt(i) == c){
      count++;
    }
  }
  return count;
}

void updateBlink(){
  // Split buffer into paramters
  String ledNum = buffer.substring(0, buffer.indexOf('\n'));
  String ledDelay = buffer.substring(ledNum.length());
  // Perform validity checks
  if(
    ledNum.toInt() == 0 
    || ledNum.toInt() > 2 
    || ledNum.toInt() < 1
    || ledDelay.toInt() <= 0
  ){
    Serial.println("Invalid Input!!");
  } else{
    // Update led blink paramters
    blinkProp.ledNum = ledNum.toInt();
    blinkProp.ledDelay = ledDelay.toInt();
  }
  // Clear buffer
  buffer = "";
}

void blink(){
  // Return if blink time has not ocurred yet
  if(millis() - blinkProp.lastBlinkMs < blinkProp.ledDelay){
    return;
  }
  // Blink the led
  switch(blinkProp.ledNum){
    case 1:
      digitalWrite(LED1_PIN, !digitalRead(LED1_PIN));
      if(ACTIVATE_ONE_ONLY){ digitalWrite(LED2_PIN, 0); }
      blinkProp.lastBlinkMs += blinkProp.ledDelay;
      break;
    case 2:
      digitalWrite(LED2_PIN, !digitalRead(LED2_PIN));
      if(ACTIVATE_ONE_ONLY){ digitalWrite(LED1_PIN, 0); }
      blinkProp.lastBlinkMs += blinkProp.ledDelay;
      break;
    default:
      Serial.println("Invalid led number. Timing out for 5 seconds!");
      blinkProp.lastBlinkMs += 5000;
  }
}

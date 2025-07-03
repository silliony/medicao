// ----------- Configurações -------------
const int freq = 60;           // Frequência da senoide (Hz)
const int fs = 9600;           // Taxa de amostragem (Hz)
const int tam = 100;           // Tamanho do buffer
const float PI2 = 2 * 3.14159;

int senoide[tam];              // Buffer da senoide
int contador = 0;              // Contador de amostras

// ---------- Inicialização --------------
void setup() {
  Serial.begin(9600);
}

// ---------- Loop principal -------------
void loop() {
  // Gera 100 amostras da senoide
  for (int i = 0; i < tam; i++) {
    float t = (contador + i) / (float)fs;
    float valor = sin(PI2 * freq * t);
    
    // Escala de -1~1 para 0~1023 (ADC 10 bits)
    senoide[i] = (int)( (valor + 1.0) * 511.5 );
  }

  // Envia os dados pela porta serial (uma linha por amostra)
  for (int i = 0; i < tam; i++) {
    Serial.println(senoide[i]);
  }

  contador += tam;

  // Espera para simular 100 amostras a 9600 Hz
  delayMicroseconds((100.0 / fs) * 1e6);  // ≈10.4 ms
}


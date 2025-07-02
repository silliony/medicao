//------------------ Inicialização ----------------------

void setup() {

  Serial.begin(9600);
  
  // Configuração dos pinos de entrada
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);

  // Configuração do registrador ADCMUX
  ADMUX = 0x00;
  ADMUX |= 0x40;   // Seleciona AVcc como referência de tensão

  // Configuração do prescaler do ADC e habilitação de interrupções
  ADCSRA = 0x00;
  ADCSRA |= 0x05;  // Prescaler em 128 (para clock ADC ≈ 125 kHz)
  ADCSRA |= 0x08;  // Habilita interrupção do ADC
  ADCSRA |= 0x20;  // Habilita o auto trigger

  // Configuração do modo de disparo do trigger
  ADCSRB = 0x00;   // Habilita o free running mode

  // Desabilita os buffers digitais dos pinos analógicos
  DIDR0 = 0xFF;

  // Habilita interrupções globais
  SREG |= 0x80;

  // Habilita o ADC e inicia a aquisição
  ADCSRA |= 0x80;  // Habilita o ADC
  ADCSRA |= 0x40;  // Inicia a conversão
}

//------------------ Variáveis Globais ------------------

const int N = 4;          // Número de canais (tensão, corrente, temperatura, iluminância)
const int tam = 100;      // Tamanho do vetor de amostras

bool procStatus = false;  // Flag para iniciar o processamento dos dados
int dataVector[N][tam];   // Vetor de dados para armazenar as amostras de cada canal
int counter = 0;          // Controla o número de amostras coletadas

//---------- Loop principal de processamento ------------

void loop() {
  if (procStatus == true){
    noInterrupts();  // Desabilita interrupções durante o processamento

    //Serial.println("Tensao\tCorrente\tTemperatura\tIluminancia");

    for (int i = 1; i < tam; i++) {
      Serial.print(dataVector[0][i]);  // Tensão
      Serial.print("\t");
      Serial.print(dataVector[1][i]);  // Corrente
      Serial.print("\t");
      Serial.print(dataVector[2][i]);  // Temperatura
      Serial.print("\t");
      Serial.println(dataVector[3][i]); // Iluminância
    }

    procStatus = false;  // Libera para próxima aquisição
    interrupts();        // Reabilita interrupções
  }
}

//--------------- Rotina de Interrupção -----------------

ISR(ADC_vect) {
  int sample;
  int CH=0;

  // Lê a amostra mais recente
  sample = ADCL;        // Lê o byte menos significativo
  sample += ADCH << 8;  // Lê o byte mais significativo

  // Armazena os dados do canal atual. Após 'tam' amostras, inicia o processamento
  if (procStatus == false) {
                    -    CH = ADMUX & 0x0F;            // Obtém o número do canal atual

    if ( CH == 3 || CH == 4) {     // Verifica se o canal lido é o de temperatura ou iluminância
      if(counter == 0 || counter % 10 == 0) {
        for (int i = 0; i < 10 && (counter + i) < tam; i++) {
           dataVector[CH][counter + i] = sample; // Armazena a amostra em 10 posições do vetor
        }
      }
    }
    else {
      dataVector[CH][counter] = sample;   // Armazena a amostra no vetor correspondente
    }

    if (++CH < N) {        // Verifica se ainda faltam canais a serem lidos
      ADMUX += 1;          // Avança para o próximo canal
    } else {
      ADMUX &= 0xF0;       // Retorna para o canal 0
      counter++;           // Avança o índice de amostras
    }

    // Verifica se já foi coletado o número total de amostras
    if (counter == tam) {
      counter = 0;
      procStatus = true;   // Sinaliza para iniciar o processamento dos dados
    }
  }
}
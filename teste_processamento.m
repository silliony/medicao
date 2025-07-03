clc; clear all; close all;

% -------- Configurações iniciais --------
porta = "COM14";     % Ajuste para sua porta
baud = 9600;
tam = 100;

s = serialport(porta, baud);
configureTerminator(s, "LF");
flush(s);  % Limpa buffer

% -------- Inicialização dos buffers --------
dados = zeros(1, tam * 10);     % Valores brutos do ADC
vInst = zeros(1, tam * 10);     % Valores processados em volts
tempo = (0:length(dados)-1) / 9600;

% -------- Inicialização do gráfico --------
h_fig = figure;
h_adc = plot(tempo, dados, '-b', 'DisplayName', 'ADC (0-1023)');
hold on;
h_vinst = plot(tempo, vInst, '-r', 'DisplayName', 'Tensão (V)');
xlabel('Tempo (s)');
ylabel('Sinal');
ylim([-200 1050]);
%xlim([0, 1*(1/60)])
title('Senoide recebida e processada em tempo real');
legend();
grid on;

% -------- Loop de aquisição contínua --------
disp("Aguardando dados do Arduino...");

while ishandle(h_fig)
    novo_bloco = zeros(1, tam);

    % Lê 100 amostras da porta serial
    for i = 1:tam
        linha = readline(s);
        novo_bloco(i) = str2double(linha);
    end

    % Processa novo bloco com função externa
    novo_vinst = tensaoInstantanea(novo_bloco);

    % Atualiza buffers
    dados = [dados(tam+1:end), novo_bloco];
    vInst = [vInst(tam+1:end), novo_vinst];

    % Atualiza gráfico
    set(h_adc, 'YData', dados);
    set(h_vinst, 'YData', vInst);
    drawnow;
end

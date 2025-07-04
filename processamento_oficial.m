clc; clear all; close all;

% -------- Configurações iniciais --------
porta = "COM14";
baud = 9600;
tam = 100;

s = serialport(porta, baud);
configureTerminator(s, "LF");
flush(s);

% -------- Buffers (10 blocos = histórico) --------
buff_len = tam * 10;
corrente = zeros(1, buff_len);
corrente_inst = zeros(1, buff_len);
corrente_rms = zeros(1, buff_len);
tensao = zeros(1, buff_len);
tensao_inst = zeros(1, buff_len);
tensao_rms = zeros(1, buff_len);
iluminancia = zeros(1, buff_len);
temperatura = zeros(1, buff_len);
tempo = (0:buff_len-1) / 9600;

iluminancia_proc = zeros(1, buff_len);
temperatura_proc = zeros(1, buff_len);
potencia_inst = zeros(1, buff_len);
energia_total = zeros(1, buff_len);

% -------- Figura 1: Corrente e Tensão --------
fig1 = figure('Name', 'Corrente e Tensão');

subplot(2,1,1);
yyaxis left;
h_corrente = plot(tempo, corrente, '-b', 'DisplayName', 'Corrente (ADC)');
ylabel('Corrente (ADC)');
ylim([0, 1023]);

yyaxis right;
hold on;
h_corrente_inst = plot(tempo, corrente_inst, '-', 'Color', [1 0.5 0], 'DisplayName', 'Corrente Inst. (mA)');
h_corrente_rms = plot(tempo, corrente_rms, '--m', 'DisplayName', 'Corrente RMS (mA)');
hold off;
ylabel('Corrente (mA)');
legend([h_corrente, h_corrente_inst, h_corrente_rms]);
ylim([-200,200])
grid on;

subplot(2,1,2);
yyaxis left;
h_tensao = plot(tempo, tensao, '-b', 'DisplayName', 'Tensão (ADC)');
ylabel('Tensão (ADC)');
ylim([0, 1023]);

yyaxis right;
hold on;
h_tensao_inst = plot(tempo, tensao_inst, '-', 'Color', [1 0.5 0], 'DisplayName', 'Tensão Inst. (V)');
h_tensao_rms = plot(tempo, tensao_rms, '--m', 'DisplayName', 'Tensão RMS (V)');
hold off;
ylabel('Tensão (V)');
ylim([-300, 300]);

xlabel('Tempo (s)');
legend([h_tensao, h_tensao_inst, h_tensao_rms]);
grid on;

% -------- Figura 2: Potência e Energia --------
fig2 = figure('Name', 'Potência e Energia');

subplot(2,1,1);
h_potencia = plot(tempo, potencia_inst, '-k', 'DisplayName', 'Potência Instantânea (mW)');
ylabel('Potência (mW)');
xlabel('Tempo (s)');
legend('show');
grid on;

subplot(2,1,2);
h_energia = plot(tempo, energia_total, '-r', 'DisplayName', 'Energia Acumulada (mJ)');
ylabel('Energia (mJ)');
xlabel('Tempo (s)');
legend('show');
grid on;

% -------- Figura 3: Iluminância e Temperatura --------
fig3 = figure('Name', 'Iluminância e Temperatura');

subplot(2,1,1);
yyaxis left;
h_ilum = plot(tempo, iluminancia, '-', 'DisplayName', 'Iluminância (ADC)');
ylabel('ADC');
ylim([0, 1023]);

yyaxis right;
h_ilum_proc = plot(tempo, iluminancia_proc, '--g', 'DisplayName', 'Iluminância (lux)');
ylabel('Lux');
legend([h_ilum, h_ilum_proc]);
grid on;

subplot(2,1,2);
yyaxis left;
h_temp = plot(tempo, temperatura, '-', 'DisplayName', 'Temperatura (ADC)');
ylabel('ADC');
ylim([0, 1023]);

yyaxis right;
h_temp_proc = plot(tempo, temperatura_proc, '--r', 'DisplayName', 'Temperatura (°C)');
ylabel('°C');
xlabel('Tempo (s)');
legend([h_temp, h_temp_proc]);
grid on;

% -------- Loop de aquisição contínua --------
disp("Aguardando dados do Arduino...");

while ishandle(fig1) && ishandle(fig2) && ishandle(fig3)
    nova_corrente = zeros(1, tam);
    nova_tensao = zeros(1, tam);
    nova_ilum = zeros(1, tam);
    nova_temp = zeros(1, tam);

    for i = 1:tam
        linha = readline(s);
        valores = sscanf(linha, '%d,%d,%d,%d');
        if numel(valores) == 4
            nova_corrente(i) = valores(1);
            nova_tensao(i) = valores(2);
            nova_ilum(i) = valores(3);
            nova_temp(i) = valores(4);
        end
    end

    nova_tensao_inst = tensaoInstantanea(nova_tensao);
    nova_corrente_inst = correnteInstantanea(nova_corrente);

    corrente_rms_valor = valorRMS(nova_corrente_inst);
    tensao_rms_valor = valorRMS(nova_tensao_inst);
    nova_tensao_rms = tensao_rms_valor * ones(1, tam);
    nova_corrente_rms = corrente_rms_valor * ones(1, tam);

    nova_temp_proc = processarTemperatura(nova_temp);
    nova_ilum_proc = processarIluminancia(nova_ilum);

    nova_potencia_inst = potenciaInstantanea(nova_tensao_inst, nova_corrente_inst);
    nova_energia_total = energiaTotal([potencia_inst(tam+1:end), nova_potencia_inst], tempo);

    corrente = [corrente(tam+1:end), nova_corrente];
    corrente_inst = [corrente_inst(tam+1:end), nova_corrente_inst];
    corrente_rms = [corrente_rms(tam+1:end), nova_corrente_rms];
    tensao = [tensao(tam+1:end), nova_tensao];
    tensao_inst = [tensao_inst(tam+1:end), nova_tensao_inst];
    tensao_rms = [tensao_rms(tam+1:end), nova_tensao_rms];
    iluminancia = [iluminancia(tam+1:end), nova_ilum];
    temperatura = [temperatura(tam+1:end), nova_temp];
    iluminancia_proc = [iluminancia_proc(tam+1:end), nova_ilum_proc];
    temperatura_proc = [temperatura_proc(tam+1:end), nova_temp_proc];
    potencia_inst = [potencia_inst(tam+1:end), nova_potencia_inst];
    energia_total = nova_energia_total;

    % Atualiza gráficos
    set(h_corrente, 'YData', corrente);
    set(h_corrente_inst, 'YData', corrente_inst);
    set(h_corrente_rms, 'YData', corrente_rms);
    set(h_tensao, 'YData', tensao);
    set(h_tensao_inst, 'YData', tensao_inst);
    set(h_tensao_rms, 'YData', tensao_rms);
    set(h_ilum, 'YData', iluminancia);
    set(h_ilum_proc, 'YData', iluminancia_proc);
    set(h_temp, 'YData', temperatura);
    set(h_temp_proc, 'YData', temperatura_proc);
    set(h_potencia, 'YData', potencia_inst);
    set(h_energia, 'YData', energia_total);

    drawnow;
end

% -------- Funções auxiliares --------

function Pinst = potenciaInstantanea(V, I)
    Pinst = V .* I; % mV * mA = µW
    Pinst = Pinst / 1000; % Convertendo para mW
end

function energia = energiaTotal(Pinst, tempo)
    dt = mean(diff(tempo)); % Intervalo de amostragem
    energia = cumtrapz(tempo, Pinst); % Energia acumulada em mW·s = mJ
end

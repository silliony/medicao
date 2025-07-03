% Calcula a corrente instântanea
function I = correnteInstantanea(corrente_adc)

% Converte valor lido (adc) para o valor real
% Retira offset de 2,4V do ampop
% Retira ganho de 1,6 do ampop
% Retira ganho de 8 do ampiso
% Multiplicação por 1000 para escala em mA

    Vadc = 5 / 1023;
    Vshunt = (corrente_adc * Vadc - 2.4) / (1.6 * 8);
    I = (Vshunt / 1.56) * 1000;
end

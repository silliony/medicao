% Calcula a potência instantânea
function Pinst = potenciaInstantanea(V, I)

% Divisão por 1000 para escala de corrente em A
    Pinst = V .* (I/1000);
end

% Calcula a energia total de um conjunto de amostras
function energia = energiaTotal(Pinst, tempo)
    energia = tempo * sum(Pinst);
end

% Calcula a energia total pela integral da potência instantânea
function energia = energiaTotal(Pinst, tempo)
    energia = trapz(tempo, Pinst);
end

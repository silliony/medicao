function temp = processarTemperatura(data)
    v = (5 / 1023) * data;
    temp = v / (8.6 * 0.01);
end

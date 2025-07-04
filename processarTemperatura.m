function temp = processarTemperatura(data)
    v = (5 / 1024) * data;
    temp = v / (6.6 * 0.01);
end
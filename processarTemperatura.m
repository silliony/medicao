function temp = processarTemperatura(data)
    v = (5 / 1024) * data;
    temp = v / 0.01;
end
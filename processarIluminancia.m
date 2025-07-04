function iluminancia = processarIluminancia(data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    tensao = (5 / 1023) * data;
    iluminancia = (tensao * 1000) / 1.54;
end

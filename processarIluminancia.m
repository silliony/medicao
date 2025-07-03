function iluminancia = processarIluminancia(data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    tensao = (5 / 1023) * data;
    i = tensao / 22000;
    iluminancia = i / 0.07;
end
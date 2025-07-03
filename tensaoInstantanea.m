function vInst = tensaoInstantanea(data)
    v = (5 / 1023) * data;
    vInst = (v - 2.4) * 75;
end
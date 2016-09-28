fid = fopen('sin_rom.txt','w');

fprintf(fid,'MEMORY_INITIALIZATION_RADIX = 10;\n');

fprintf(fid,'MEMORY_INITIALIZATION_VECTOR =\n');

for i = 0:1:pi/2*100

    y = sin(i/100);

    rom =floor( y * 2^12);

    if i == 157

        fprintf(fid,'%d;',rom);

    else

        fprintf(fid,'%d,',rom);

    end

   

    if mod(i,10)==0 && i ~= 0

        fprintf(fid,'\n');

    end

end

fclose(fid);
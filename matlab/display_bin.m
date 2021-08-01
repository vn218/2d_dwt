file = fopen('dwt.bin', 'r');
a = fread(file,256*256,'uint8=>uint8');
k = 1;
for i = 1:256
    for j = 1:256
        b(i,j) = a(k);
        k = k + 1;
    end
end
imshow(b); 
fclose(file);

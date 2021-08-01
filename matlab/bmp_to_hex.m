b = imread("lena.BMP");
b =imresize(b,[256,256]);
imshow(b);
k = 1;
for i=1:256
    for j = 1:256
        a(k) = b(i,j);
        k = k+1;
    end
end    
out = fopen('lena.hex','wt');
for i=1:65536
    fprintf(out,'%x\n',a(i));
end

fclose(out);

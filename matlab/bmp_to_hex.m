b = imread("lena.BMP");
b =imresize(b,[256,256]);
b = imrotate(b,90);
imshow(b);
k = 1;
for i=256:-1:1
    for j = 1:256
        a(k) = b(i,j);
        k = k+1;
    end
end
out = fopen('lena.hex','wt');
fprintf(out,'%x\n',a);
fclose(out);

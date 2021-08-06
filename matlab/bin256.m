file = fopen('dwt.bin', 'r');
a = fread(file,256*256,'uint8=>uint8');
k = 1;
b = zeros([256,256]);
for i = 1:256
    for j = 1:256
        b(i,j) = a(k);
         
%         if (i>128 || j>128)
%             b(i,j) = b(i,j)*4;
%         
%         end
        
        k = k + 1;
    end
end
b = b*(1.6*1.6);

figure(1);
imagesc(b);
colormap gray;


x = idwt2(b(1:128,1:128),b(1:128,129:256),b(129:256,1:128),b(129:256,129:256),'db2');
x = imresize(x,[256,256]);
x = uint8(x);

figure(2);
imshow(x);
%imwrite(b,'db4.tif');
fclose(file);

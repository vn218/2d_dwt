file = fopen('dwt256_L2.bin', 'r');
a = fread(file,256*256,'uint8=>uint8');
k = 1;
b = zeros([256,256]);
for i = 1:256
    for j = 1:256
        b(i,j) = a(k);
        
        k = k + 1;
    end
end
b = b*(1.6*1.6);
b(1:128,1:128) = b(1:128,1:128)*(1.6*1.6);

figure(1);

subplot(4,4,1);
imagesc(b(1:64,1:64));
colormap gray;

subplot(4,4,2);
imagesc(b(1:64,65:128));
colormap gray;

subplot(4,4,5);
imagesc(b(65:128,1:64));
colormap gray;

subplot(4,4,6);
imagesc(b(65:128,65:128));
colormap gray;

subplot(4,4,[3,4,7,8]);
imagesc(b(1:128,129:256));
colormap gray;

subplot(4,4,[9,10,13,14]);
imagesc(b(129:256,1:128));
colormap gray;

subplot(4,4,[11,12,15,16]);
imagesc(b(129:256,129:256));
colormap gray;

x = idwt2(b(1:64,1:64),b(65:128,1:64),b(1:64,65:128),b(65:128,65:128),'db2');
x = imresize(x,[128,128]);
x = idwt2(x,b(129:256,1:128),b(1:128,129:256),b(129:256,129:256),'db2');
x = imresize(x,[256,256]);
x = uint8(x);

figure(2);
imshow(x);
%imwrite(b,'db4.tif');
fclose(file);

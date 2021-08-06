file = fopen('dwt.bin', 'r');
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

figure(1);

subplot(2,2,1);
imagesc(b(1:128,1:128));
colormap gray;
title('Approximation');

subplot(2,2,2);
imagesc(b(1:128,129:256));
colormap gray;
title("Vertical");

subplot(2,2,3);
imagesc(b(129:256,1:128));
colormap gray;
title("Horizontal");

subplot(2,2,4);
imagesc(b(129:256,129:256));
colormap gray;
title("Diagonal");

x = idwt2(b(1:128,1:128),b(129:256,1:128),b(1:128,129:256),b(129:256,129:256),'db2');
x = imresize(x,[256,256]);
x = uint8(x);

figure(2);
imshow(x);
%imwrite(b,'db4.tif');
fclose(file);

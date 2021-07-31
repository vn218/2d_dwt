file = fopen('dwt.bin', 'r');
a = fread(file,256*256,'uint8=>uint8');
a = reshape(a,256,256);
imshow(a); 
fclose(file);

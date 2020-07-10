clc; clear all
addpath('./YUV_Handling_Functions','./functions', './mat'); 

%% Set the video information
v_t_dir=sprintf('./data/ClassroomImage/image/v0.yuv'); 
v_t_r_dir=sprintf('./data/ClassroomImage/depth/v0_d.yuv'); 
v_s_dir=sprintf('./data/ClassroomImage/image/v7.yuv');  
v_s_r_dir=sprintf('./data/ClassroomImage/depth/v7_d.yuv');  

nFrame = 1; iFrame=1;   
W=4096; H=2048;
%% Read the video sequence

[Y_t,U_t,V_t] = yuvRead(v_t_dir, W, H ,nFrame);  
[Y_s,U_s,V_s] = yuvRead(v_s_dir, W, H ,nFrame);   
[Y_r_t,U_r_t,V_r_t] = yuvRead(v_t_r_dir, W, H ,nFrame);   
[Y_r_s,U_r_s,V_r_s] = yuvRead(v_s_r_dir, W, H ,nFrame); 

erp_t_Y=Y_t(:,:,iFrame); erp_t_U=U_t(:,:,iFrame); erp_t_V=V_t(:,:,iFrame); 
erp_s_Y=Y_s(:,:,iFrame); erp_s_U=U_s(:,:,iFrame); erp_s_V=V_s(:,:,iFrame); 
erp_s_disp_Y=Y_r_s(:,:,iFrame); erp_s_disp_U=U_r_s(:,:,iFrame); erp_s_disp_V=V_r_s(:,:,iFrame); 

%resize due to original image is to large (you can remove here and set your W, H)
target_gt = erp_t_Y;
source_img = erp_s_Y;
source_disp = erp_s_disp_Y;

%resize due to original image is to large (you can remove here and set your W, H)
newW=512; newH=256; % my original image was W=4096, H=2048
target_gt = imresize(target_gt, 1/8, 'bicubic', 'Antialiasing', true);
source_img = imresize(source_img, 1/8, 'bicubic', 'Antialiasing', true);
source_disp = imresize(source_disp, 1/8, 'bicubic', 'Antialiasing', true);

%% Camera Center Coordinate
% modify depend on your data
c_t=[0.0000000000, 0.0000000000, -0.0000000000];  %v_target
c_s=[0.0000000000, -0.0600000000, -0.0000000000]; %v_source

%% Warping     
% modify depend on your data
Rnear_inv=1/0.8; Rfar_inv=1/1000;

warped_img=warp_ERP(c_t,c_s,source_img,source_disp,newW,newH,Rnear_inv,Rfar_inv);
         

warp_dir=sprintf('./result/warp_source_to_target_Y.png');     
source_dir=sprintf('./result/source_Y.png');     
target_dir=sprintf('./result/target_Y.png');     

imwrite(uint8(warped_img), warp_dir);
imwrite(uint8(target_gt), target_dir);
imwrite(uint8(source_img), source_dir);
function source_to_target=warp_ERP(c_t,c_s,erp_s,erp_s_disparity,W,H,Rnear_inv,Rfar_inv)
if max(max(erp_s))<=255
    v_max=255; % since 16-bit data
elseif (max(max(erp_s))<=65535)&&(max(max(erp_s))>255)
    v_max=65535;
else
    msg = 'Bitstream Error';
    error(msg)
end

HW=H*W;
%Translation vector between 2 viewpoints
T=c_s-c_t;

%%%Caution!!!%%% (m:[0, 4095], n:[0,2047])
m2=meshgrid(0:W-1); m2=m2(1:H,:);
n2=transpose(meshgrid(0:W-1)); n2=n2(1:H,:);  

%Latitude and Longtitude(Based on Camera coordiante)
lat_s=0.5*pi-((n2)/H)*pi; %theta(radian)
lng_t=2*pi*((m2)/W)-pi; %phi(radian)   

%Calculate R
% Rnear_inv=1/0.8; Rfar_inv=1/1000;
R_s=1./((((Rnear_inv-Rfar_inv).*double(erp_s_disparity))./double(v_max))+Rfar_inv);

%Calculate x, y, z
X_s=R_s.*cos(lat_s).*cos(lng_t); Y_s=R_s.*sin(lat_s); Z_s=-R_s.*cos(lat_s).*sin(lng_t); 

%Calculate new latitude and longtitude after align
R_t_est=sqrt((X_s+T(1)).^2+(Y_s+T(2)).^2+(Z_s+T(3)).^2); 
lat_t_est=asin((Y_s+T(2))./R_t_est); 
lng_t_est=atan2(-(Z_s+T(3)),(X_s+T(1))); 

m1_calculated_index=(lng_t_est/(2*pi)+0.5)*W+1; m1_calculated_index=round(m1_calculated_index(:)); %without round() 
n1_calculated_index=(0.5-lat_t_est/pi)*H+1; n1_calculated_index=round(n1_calculated_index(:));%without round()
R1_est_1d=R_t_est(:);
erp2_1d=erp_s(:);

nm_real=transpose(vertcat(transpose(n1_calculated_index), transpose(m1_calculated_index)));  

%% Get Neighbors and Pick nearest one(which has smallest R1_est)
% all neighbors which satisfy threshold of Euclidean distance;
% nearest_n=zeros(HW,1); nearest_m=zeros(HW,1); 
nm_grid=transpose(vertcat(transpose(n2(:)+1), transpose(m2(:)+1)));
nearest_Y=zeros(HW,1);
[Idx,~] = rangesearch(nm_real,nm_grid,1.5);
for i=1:1:HW    
    curr_idx=Idx{i};
    if isempty(curr_idx)==1
       nearest_Y(i)=0; 
    elseif isempty(curr_idx)==0
       [~, min_id]=min(R1_est_1d(curr_idx));
       neighbors5_Y=erp2_1d(curr_idx);
       nearest_Y(i)=neighbors5_Y(min_id);
    end    
end
source_to_target=reshape(nearest_Y,H,W);

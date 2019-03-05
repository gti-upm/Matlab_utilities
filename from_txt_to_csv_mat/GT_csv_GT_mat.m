function GT_csv_GT_mat(gt_filename, img_dir)

images = getFileSet(img_dir,'.jpg');

gt_bboxes=csvread(gt_filename);

gtruth=struct;
gt_prefixes=strsplit(gt_filename,'_');

for t=1:size(gt_bboxes,1)
    
   if length(find(gt_bboxes(t,:)))>1
       
      if mod(length(find(gt_bboxes(t,:))),2)==0
         disp(strcat('Error ', num2str(t)));
      end
      
      for b=1:4:length(gt_bboxes(t,2:end))
          
          selected_bbox=(gt_bboxes(t,b+1:b+4));
          
          if ~isempty(find(~selected_bbox))>0 && length(find(~selected_bbox))<4
          
              selected_bbox(~selected_bbox)=1;
              gt_bboxes(t,b+1:b+4)=selected_bbox;
              
          end
          
      end
      
      num_obj=(length(find(gt_bboxes(t,:)))-1)/4;
       
      gtruth(t).n_frame=t; % cabe discutirlo el número que demos o desde donde empecemos
      %gtruth(t).frame_name=strcat(gt_prefixes{2},'_',sprintf('%06d',t-1),'.jpg'); %damos solo el nombre exacto de la imagen
      gtruth(t).frame_name = images{t};
      
      class_names=cell(1,num_obj);
      class_names(:)={'Person'};
      gtruth(t).type=class_names;
      
      list_ids=find(gt_bboxes(t,:));
      gtruth(t).id=((list_ids(2:4:end)-2)/4).';
      
      gt_data=reshape(gt_bboxes(t,2:end),[4, length(gt_bboxes(t,2:end))/4]).';
      
      gt_data=[gt_data(:,3:4), gt_data(:,2), gt_data(:,1)];
      
      % Quitamos aquellas filas de ceros
      gt_data( ~any(gt_data,2), : ) = [];
      
      gtruth(t).bbox=gt_data;
      
   else
      gtruth(t).n_frame=t;
      gtruth(t).frame_name=images{t};
      gtruth(t).type=[];
      gtruth(t).id=[];
      gtruth(t).bbox=[];
       
   end
      
   
    
    
end



save(strcat('groundTruth_', gt_prefixes{2}, '.mat'),'gtruth');

end


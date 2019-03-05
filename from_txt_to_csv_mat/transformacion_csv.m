function [] = transformacion_csv(xml_name,groundtruth_directory,training_frame_interval,test_frame_interval)

%%
groundtruth_filtering=0;       % boolean to indicate if groundtruth data are filtered according to masks or not

% Start program
%groundtruth_directory=strcat(pwd,'\');
% Necessary to be able to use Polygon Intersection functions
% Add directory where Polygon Intersection files are located 
polygon_intersections_path=strcat(groundtruth_directory,'Matlab_Polygons_intersection\Matlab_Polygons_intersection\');
addpath(genpath(polygon_intersections_path));

groundtruth_xml=xml2struct(strcat(groundtruth_directory,xml_name));

num_lines_data=length(groundtruth_xml.Children(4).Children(2).Children);

% Only execute the program if the xml file is not empty (i.e. there are noted samples)
if(num_lines_data>=4)
    % Number of frames of the sequence
    num_frames=str2num(groundtruth_xml.Children(4).Children(2).Children(2).Children(4).Children(2).Attributes(1).Value(:)');
    
    % Resolution values of the images will be set by default unless it is specified in the
    % xml file
    if(~isempty(groundtruth_xml.Children(4).Children(2).Children(2).Children(8).Children)...
    && ~isempty(groundtruth_xml.Children(4).Children(2).Children(2).Children(10).Children))
        image_width=str2num(groundtruth_xml.Children(4).Children(2).Children(2).Children(8).Children(2).Attributes.Value(:)');
        image_height=str2num(groundtruth_xml.Children(4).Children(2).Children(2).Children(10).Children(2).Attributes.Value(:)');
    else
        image_width=1280;
        image_height=720;
    end
    
    % To identify number of objects: classes + mask
    num_lines_descriptors=length(groundtruth_xml.Children(2).Children);
    num_objects=(num_lines_descriptors-3)/2;
    % Groundtruth data of all classes 
    class_groundtruths=cell(1,num_objects-1);
    classes_groundtruths_bboxes=cell(1,num_objects-1);
    
    if(num_objects-1==0)
        class_groundtruths=cell(1,1);
        class_groundtruths_bboxes=cell(1,1);
        class_groundtruths{1}=(1:num_frames)';
        class_groundtruths_bboxes{1}=(1:num_frames)';
    end
    
    % Class names in strings
    class_names=cell(1,num_objects);
    % Groundtruth data of positive samples, regardless of the class
    detection_groundtruths=(1:num_frames)';
    detection_groundtruths_bboxes=(1:num_frames)';
    
    % Initialization of groundtruth info by setting the number of row in the first column,
    % which is equivalent to the number of frame in the sequence. In addition, we save the 
    % class names in the cell array "class_names"
    
     for i=4:2:num_lines_descriptors-1
        class_name=groundtruth_xml.Children(2).Children(i).Attributes(1).Value(:)';
        if (~strcmp(class_name,'mask'))
            class_names{1,(i-2)/2}=class_name;
        
            attribute_type=groundtruth_xml.Children(2).Children(i).Children(2).Attributes(3).Value;
            initial_attribute=strfind(attribute_type,'#');
            attribute_type=attribute_type(initial_attribute+1:end);
            if(strcmp(attribute_type,'bbox'))
              % Variable which extracts bounding box info
              boundingbox_info=zeros(1,5);
            else
             % Variable which extracts point coordinates
              boundingbox_info=zeros(1,3);
            end
        
        end
        
        % Initialization of detection info of all classes
        if((i-2)/2<=num_objects-1)
            class_groundtruths_bboxes{1,(i-2)/2}=(1:num_frames)';
            class_groundtruths{1,(i-2)/2}=(1:num_frames)';
        end
     end
     
    empties = find(cellfun(@isempty,class_names)); % identify the empty cells
    class_names(empties) = [];                      % remove the empty cells
    
    % Number of masks found automatically in the xml file 
    num_masks_auto=0;
    % Initialization of mask info container
    S=struct;
    
    % We avoid the default file object (we assume that it is situated at
    % the beginning)
    
    % First we get the info related to masks and we save it in the struct 
    
    if(groundtruth_filtering)

    for i=4:2:num_lines_data-1
           data_class=groundtruth_xml.Children(4).Children(2).Children(i).Attributes(3).Value(:)';
           data_id=str2num(groundtruth_xml.Children(4).Children(2).Children(i).Attributes(2).Value(:)');
           
           if(strcmp(data_class,'mask'))
               num_masks_auto=num_masks_auto+1;
               mask_container_rows=[];
               mask_vertexes=groundtruth_xml.Children(4).Children(2).Children(i).Children(2).Children(2).Children;
               for j=2:2:length(mask_vertexes)-1
                   vertex_x=str2num(mask_vertexes(j).Attributes(1).Value(:)');
                   vertex_y=str2num(mask_vertexes(j).Attributes(2).Value(:)');
                   mask_container_rows=[mask_container_rows; vertex_x, vertex_y];
               end
               S(num_masks_auto).P(1).x=[mask_container_rows(:,1)' mask_container_rows(1,1)];
               S(num_masks_auto).P(1).y=[mask_container_rows(:,2)' mask_container_rows(1,2)];
               S(num_masks_auto).P(1).hole=0;
               S(num_masks_auto).P(1).id=data_id;
               S(num_masks_auto).P(1).class=data_class;
           end
         
    end
   
        % We represent the boundaries of the image and we include them in a
        % new mask
        x_image_limit=[0 image_width-1];
        y_image_limit=[0 image_height-1];
                       
        S(num_masks_auto+1).P(1).x=x_image_limit([1 1 2 2 1]);
        S(num_masks_auto+1).P(1).y=y_image_limit([1 2 2 1 1]);
        S(num_masks_auto+1).P(1).hole=0;
        S(num_masks_auto+1).P(1).id=0.0001; % Not relevant 
        S(num_masks_auto+1).P(1).class='image';

    end

   disp('Ready to process groundtruth data');
    
   data_progress=0;
        if (strcmp(attribute_type,'bbox'))
            data_progress=waitbar(0,'Processing bounding boxes...');
        else
            data_progress=waitbar(0,'Processing points...');
        end
        

        
    % Once we have the masks, regardless of where they were situated in the
    % xml, we get and filter bounding boxes (besides, they are necessary to filter) 
    for i=4:2:num_lines_data-1
        
        % Class and id of the sample
        data_class=groundtruth_xml.Children(4).Children(2).Children(i).Attributes(3).Value(:)';
        data_id=str2num(groundtruth_xml.Children(4).Children(2).Children(i).Attributes(2).Value(:)');
        
        if(~strcmp(data_class,'mask'))
            
               groundtruth_data=groundtruth_xml.Children(4).Children(2).Children(i).Children(2).Children;
               
               % We obtain the class of the bounding box and we set a label
               % according to how classes are sorted in "class_names" (e.g.
               % if "car" appears second in "class_names" we put 2).
               for j=1:length(class_names)
               if strcmp(class_names{1,j},data_class)
                   class_label=j;
               end
               end
               
                for j=2:2:length(groundtruth_data)-1
                    % We assume that all data about each bounding box or point are
                    % valid (i.e. they are marked as valid in the ViPer
                    % Project).
                    % At this point we explore each line in the xml file
                    % which begins with "data:bbox" or "data::point"
                    frame_interval=groundtruth_data(j).Attributes(1).Value(:)';
                    separation_pos=strfind(frame_interval,':');
                    first_frame=str2num(frame_interval(1:separation_pos-1));
                    % Assert that the frame interval is correct (i.e. first
                    % frame must be less than num_frames, otherwise the
                    % noting is not considered; besides, last frame must be 
                    % limited to num_frames at the most)
                    if(first_frame<=num_frames)
                    last_frame=min(str2num(frame_interval(separation_pos+1:end)),num_frames);
                    for k=2:length(boundingbox_info)
                        boundingbox_info(k)=str2num(groundtruth_data(j).Attributes(k).Value(:)'); 
                    end
                    
                    % Processing where we consider all masks, overlaps,
                    % percentages, occlusions and other things...
  
                    % This particular case is valid for Gelderland scenario and with bounding boxes
                    %  (or another with the same denomination of their masks)
                    if (groundtruth_filtering && strcmp(attribute_type,'bbox'))
                       
                        % First we create the bounding box with all their
                        % vertexes
                        xbboxlimit=[boundingbox_info(4), boundingbox_info(4)+boundingbox_info(3)];
                        ybboxlimit=[boundingbox_info(5), boundingbox_info(5)+boundingbox_info(2)];
                        
                        Geo_input(2).P(1).x = xbboxlimit([1 1 2 2 1]);
                        Geo_input(2).P(1).y = ybboxlimit([1 2 2 1 1]);
                        Geo_input(2).P(1).hole=0;
                        Geo_input(2).P(1).id=data_id;
                        Geo_input(2).P(1).class=data_class;
                        
                        % Next we compute the intersection of the bounding
                        % box with each of the masks
                        for k=1:num_masks_auto+1
                            Geo_input(1)=S(k);
                            
                            [xi,yi]=polyxpoly(Geo_input(1).P(1).x,Geo_input(1).P(1).y,...
                                Geo_input(2).P(1).x,Geo_input(2).P(1).y);
                            [in,on]=inpolygon(Geo_input(2).P(1).x,Geo_input(2).P(1).y,...
                            Geo_input(1).P(1).x,Geo_input(1).P(1).y);
                        
                        % We compute the intersection function only if
                        % there is intersection with common area, in order to
                        % avoid error in the execution
                        if((numel(Geo_input(2).P(1).x(in&~on))>0) || (polyarea(xi,yi)>0))
                            Geo_output=Polygons_intersection(Geo_input,0,1e-6);
                        
                        % Modification of bounding box according to the masks    
                        switch k
                            % ROI
                            case 1
                            % Criteria to decide if the object is situated on the cycling infrastructure 
                            highway_xbounds=sort(S(num_masks_auto).P(1).x,'descend');
                            [xcycleboundary, ycycleboundary]= polyxpoly([0 image_width-1],[min(Geo_input(2).P(1).y), ...
                            min(Geo_input(2).P(1).y)],[min(S(num_masks_auto).P(1).x),highway_xbounds(2)],...
                            [min(S(num_masks_auto).P(1).y),max(S(num_masks_auto).P(1).y)]);
                            % Study of cases on the cycling infrastructure
                            % which are not completely inside the ROI
                            if((length(Geo_output)==3) && (~isempty(xcycleboundary)) && (min(Geo_input(2).P(1).x)<=xcycleboundary))
                                ROI_y_sort=sort(Geo_input(1).P(1).y,'descend');
                                ROI_y_sort=unique(ROI_y_sort,'stable');
                                % 50 % overlap at least at the bottom part (we consider the third largest y coordinate of the ROI)
                                if((max(Geo_input(2).P(1).y)>ROI_y_sort(3)) && (Geo_output(3).area<Geo_output(2).area))
                                boundingbox_info(2:5)=zeros(1,4);
                                break;
                                end
                                % More than 50 % overlap necessary at the top part 
                                if((max(Geo_input(2).P(1).y)<=ROI_y_sort(3)) &&... 
                                (Geo_output(3).area<1.1*Geo_output(2).area))
                                boundingbox_info(2:5)=zeros(1,4);
                                break;
                                end
                                
                            end
                            
                            % Highway tunnels (important note: Geo_output(3) always means "polygon inside")
                            case {2,3}
                                % Delete bounding box if it is completely
                                % in the tunnel
                                if(length(Geo_output)<3)
                                   boundingbox_info(2:5)=zeros(1,4);
                                   break; 
                                else
                                % 50 % overlap
                                if(Geo_output(3).area>Geo_output(2).area)
                                    if ((~(strcmp(Geo_input(2).P(1).class,'lorry')) ||... 
                                    (strcmp(Geo_input(2).P(1).class,'lorrytrailer'))||...
                                    (strcmp(Geo_input(2).P(1).class,'bus'))))
                                    boundingbox_info(2:5)=zeros(1,4);
                                    break;
                                 % More than 50 % overlap in the case of big vehicles   
                                    elseif(Geo_output(3).area>1.25*Geo_output(2).area)
                                    boundingbox_info(2:5)=zeros(1,4);
                                    break;
                                    end
                                end
                                end
                            % Cycling infrastructure tunnel
                            case 4
                                if((length(Geo_output)<3) || (Geo_output(2).area<Geo_output(3).area/3))
                                    boundingbox_info(2:5)=zeros(1,4);
                                    break;
                                end
                             % Limit the bounding box in order to be
                             % strictly inside the image dimensions
                            case num_masks_auto+1
                                 boundingbox_info(4)=min(Geo_output(length(Geo_output)).P(1).x);
                                 boundingbox_info(5)=min(Geo_output(length(Geo_output)).P(1).y);
                                 boundingbox_info(3)=max(Geo_output(length(Geo_output)).P(1).x)-min(Geo_output(length(Geo_output)).P(1).x);
                                 boundingbox_info(2)=max(Geo_output(length(Geo_output)).P(1).y)-min(Geo_output(length(Geo_output)).P(1).y);
                                 break;
                        end
                        % If there was no intersection with area inside the
                        % ROI, bounding box is deleted 
                        elseif(k==1)
                            boundingbox_info(2:5)=zeros(1,4);
                            break;
                        end
                        end
                    else if (groundtruth_filtering && strcmp(attribute_type,'point'))
                            
                            % need to complete
                        end    
                    end
                    
                    
                   
                    % After every possible modification of the groundtruth,
                    % we compute the groundtruth point
                    
                    if (strcmp(attribute_type,'bbox'))
                    % Center of the bounding box, in Cartesian coordinates: [x,y]
                    gt_point=round([boundingbox_info(4)+(boundingbox_info(3)/2),boundingbox_info(5)+(boundingbox_info(2)/2)]);
                    else
                    % the resulted point in Cartesian coordinates: [x,y]
                    gt_point=round([boundingbox_info(2),boundingbox_info(3)]);
                    end
                    % Then in the specified interval, we save the
                    % groundtruth point
                    for t=first_frame:last_frame
                        
                        boundingbox_info(1)=t;
                        
                        % We can save data this way, but there might be a
                        % lot of zeros of course. 
                        class_groundtruths{1,class_label}(boundingbox_info(1),2*(data_id)+2:2*(data_id)+3)=gt_point;
                        
                        
                        % Cell where we save only detections, regardless of 
                        % their classes, in order of appearance in the xml
                        % file
                        detection_groundtruths(boundingbox_info(1),i-2:i-1)=gt_point;
                        
                        if strcmp(attribute_type,'bbox')
                            
                        class_groundtruths_bboxes{1,class_label}(boundingbox_info(1),4*data_id+2:4*data_id+5)=boundingbox_info(2:end);
                        detection_groundtruths_bboxes(boundingbox_info(1),2*i-6:2*i-3)=boundingbox_info(2:end);
                        %detection_groundtruths_bboxes(boundingbox_info(1),(5/2)*i-8:(5/2)*i-5)=boundingbox_info(2:end);
                        %if any(boundingbox_info(2:end))
                        %detection_groundtruths_bboxes(boundingbox_info(1),(5/2)*i-4)=class_label;
                        %else
                        %detection_groundtruths_bboxes(boundingbox_info(1),(5/2)*i-4)=0;
                        %end
                        end
                        
                    end
                    end
                end 
        end
        waitbar(i/(num_lines_data-1));
    end
   
    close(data_progress);
    % Finishing touch of the groundtruth data and export into .csv files
    
    groundtruth_prefix=strcat('groundTruth_',xml_name(1:end-4));
    for i=1:length(class_groundtruths)
        % We remove zero columns
        class_groundtruths{1,i}=class_groundtruths{1,i}(:,any(class_groundtruths{1,i}));
        
        if strcmp(attribute_type,'bbox')
        class_groundtruths_bboxes{1,i}=class_groundtruths_bboxes{1,i}(:,any(class_groundtruths_bboxes{1,i}));
        end
        
        if(~isempty(training_frame_interval))
        
        groundtruth_filename_training=strcat(groundtruth_prefix,'_training_class_',class_names{1,i},'.csv');
        csvwrite(strcat(groundtruth_directory,groundtruth_filename_training),class_groundtruths{1,i}...
        (training_frame_interval(1):training_frame_interval(2),:));
    
            if strcmp(attribute_type,'bbox')
                
                groundtruth_filename_training=strcat(groundtruth_prefix,'_training_class_',class_names{1,i},'_bboxes.csv');
                csvwrite(strcat(groundtruth_directory,groundtruth_filename_training),class_groundtruths_bboxes{1,i}...
                (training_frame_interval(1):training_frame_interval(2),:));
                
            end
        end
        if(~isempty(test_frame_interval))
        
        groundtruth_filename_test=strcat(groundtruth_prefix,'_test_class_',class_names{1,i},'.csv');
        csvwrite(strcat(groundtruth_directory,groundtruth_filename_test),class_groundtruths{1,i}...
        (test_frame_interval(1):test_frame_interval(2),:));
            
            if strcmp(attribute_type,'bbox')
                
                groundtruth_filename_test=strcat(groundtruth_prefix,'_test_class_',class_names{1,i},'_bboxes.csv');
                csvwrite(strcat(groundtruth_directory,groundtruth_filename_test),class_groundtruths_bboxes{1,i}...
                (test_frame_interval(1):test_frame_interval(2),:));
            
            end
    
        end
       
    end

    detection_groundtruths=detection_groundtruths(:,any(detection_groundtruths));
    %num_samples=size(detection_groundtruths,2);
    
    if strcmp(attribute_type,'bbox')
        detection_groundtruths_bboxes=detection_groundtruths_bboxes(:,any(detection_groundtruths_bboxes));
    end
    
    if(~isempty(training_frame_interval))
    csvwrite(strcat(groundtruth_directory,groundtruth_prefix,'_training_detection.csv'),detection_groundtruths...
    (training_frame_interval(1):training_frame_interval(2),:));

        if strcmp(attribute_type,'bbox')
            
            csvwrite(strcat(groundtruth_directory,groundtruth_prefix,'_training_class_detection_bboxes.csv'),detection_groundtruths_bboxes...
            (training_frame_interval(1):training_frame_interval(2),:));
            
        end

    end
    
    if(~isempty(test_frame_interval))
    csvwrite(strcat(groundtruth_directory,groundtruth_prefix,'_test_detection.csv'),detection_groundtruths...
    (test_frame_interval(1):test_frame_interval(2),:));

        if strcmp(attribute_type,'bbox')
            
            csvwrite(strcat(groundtruth_directory,groundtruth_prefix,'_test_class_detection_bboxes.csv'),detection_groundtruths_bboxes...
            (test_frame_interval(1):test_frame_interval(2),:));
            
        end
        
    end
end


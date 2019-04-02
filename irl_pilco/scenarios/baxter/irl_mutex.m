%pass control to linux VM

%1. Pass control to BAXTER
fprintf('Passing control to %s\n',BAXTER_ID)
disp('Waiting to regain control.')
pathname = fileparts(mutex_path); %defined in settings file
mutex_file = fullfile(pathname,mutex_filename);

mutex_fid = fopen(mutex_file,'w'); %Get file handle
fprintf(mutex_fid,'%s',BAXTER_ID); %Pass control to BAXTER
fclose(mutex_fid); %Close file

%2. keep checking if 'MATLAB' is written in, that control is passed back
while(true)
    
    pause(10); %Pause
    mutex_value = fileread(mutex_file); %Read mutex value
    fprintf('mutex:%s\n',mutex_value)
    if(strcmp(mutex_value,SELF_ID))
        fprintf('Obtained execution control from %s\n.',BAXTER_ID);
        break;
    end

end
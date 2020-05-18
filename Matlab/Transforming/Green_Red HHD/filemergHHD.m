function   FilemergHHD(Files,folder,destination)
 %Script designed for merging .xls file obtained from xlstranform
    %It merges files that share the same name but contain a different _Stx
    %ending.
    %Search for file 1 and the 2 and 3 subsequently.
    
    %Javier Cabello (javic.1994@gmail.com)
%%
    %Obtain all the files in the folder, and stop when all of them are read
    %and eliminated from the list
    jjj=1;
    while jjj<size(Files,1)
        %First checking: Get the name of the root file
        %Get the name of the file
        file=getfield(Files(jjj), 'name');
        %Read name
        ID = strsplit(file,'_');
        %%Always start with St1 files.
        if contains(ID(end),'St1')
            Name=ID(1);
            for i=2:(size(ID,2)-1)
                Name=string(strcat(Name,'_',ID(i)));
            end
            Name
            %%
            %ID(1): Determine the procedure for the two types of protocols used: HHR and
            %HHM*
            %ID(2) species in the file 
            %Add the name of the file to the folder to call the file
            file=strcat(folder,'\',file);
            %Name of the new file
            write=char(strcat(destination,'\',Name,'.xlsx'));
            [~,~,raw]=xlsread(file);
            xlswrite(write,raw,1,'A1');
            %HHM experiments are formed of 6 files
            if contains(ID(1),'HHD')
                count=7;
            %HHR experiments are formed of 4 files
            elseif contains(ID(1),'HHD2')
                count=5;
            %If it is not a St1 file, keep counting.
            else
                jjj=jjj+1;
                break
            end
            %%
            tick=3; %Counter to select where to write in the xls file
            for jj=2:count
                parche=strcat(folder,'\',Name,'_St',num2str(jj),'.xlsx');
                %If the next file exists, add it to the St1 file
                if exist(parche)
                    raw=xlsread(parche);
                    %If its kinetics, write the whole thing in a determined
                    %position
                    if jj==4 && contains(ID(1),'HHD')
                        xlswrite(write,raw,1,'A15');
                    elseif jj==2 && contains(ID(1),'HHD2')
                        xlswrite(write,raw,1,'A7');
                    %If not, just write the medians in order with "tick"
                    else
                        if contains(ID(1),'HHD')
                            tick=tick+2;
                        else 
                            tick=tick+1;
                        end
                        xlswrite(write,raw,1,strcat('B',num2str(tick)));
                    end
                %If a file doesnt exists, break the loop
                else
                    Error=strcat(parche,'does not exists, aborting')
                    break
                end
            end
            jjj=jjj+count;
        else
            jjj=jjj+1;
        end
    end
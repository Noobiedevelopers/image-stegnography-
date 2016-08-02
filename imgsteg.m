function varargout = imgsteg(varargin)
%             Steganography
%Hide image in another image using LSB method 
%author:Nilanj Patel,Dhaval Jardosh,Sumit Patel    date:18 May 2013
%
%in GUI select one of the task 'hide image'  or 'Recover image'

%select 'hide image' radiobutton to hide image and click the 'select cover image'
%button to select a cover image(jpg or png).Then 'select secret image'
%button activates, click it to select image you want to hide in
%cover image if it is too big error dialog appears,select 
%a smaller image.After selecting secret image 'hide' button
%activates click it to hide secret image in cover image.
%Dialog box appears to save that image.

%select 'recover image' radiobutton to recover secret image
%image from cover image.Select a cover image (png).
%Then 'recover' button activates click it to recover image.
%Secret image appears in axes 2,and it will be saved in 
%current directory with random name.

%NOTE:selecting radiobutton in between the process 
%clear the axes.Then you have to restart the whole process 
%from selecting the cover image and then continue.
%
%water.png has a hidden image use GUI to recover it.
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imgsteg_OpeningFcn, ...
                   'gui_OutputFcn',  @imgsteg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before imgsteg is made visible.
function imgsteg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imgsteg (see VARARGIN)

% Choose default command line output for imgsteg
handles.output = hObject;
handles.rad1=1;
handles.rad2=0;
handles.cfilename=' ';
handles.cpathname=' '; 
handles.sfilename=' ';
handles.spathname=' '; 
handles.equ=0;
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton3,'Enable','off');

axes(handles.axes1);
axis off
axes(handles.axes2);
axis off

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imgsteg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imgsteg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lsb=1;
[handles.cfilename,handles.cpathname] = uigetfile(  {'*.jpg';'*.png';'*.bmp';'*.*'}, ...
        'Select cover image');
axes(handles.axes1);
I=imread([handles.cpathname handles.cfilename]);

imageinfo_cover=imfinfo([handles.cpathname handles.cfilename]);
val_red=I(:,:,1);
if handles.rad2==1
emb=zeros(3,7);
emb(1,:)=bitget(val_red(1,50:56),lsb);
emb(2,:)=bitget(val_red(1,57:63),lsb);
emb(3,:)=bitget(val_red(1,64:70),lsb);
emb_double=bi2de(emb);
emb=char(emb_double);
emb=emb';
 if ~strcmp(emb,'yes')
     axes(handles.axes1);cla
     errordlg(['No hidden image in ' handles.cfilename],'Select another Image'); 
 else
     image(I),axis off
     set(handles.pushbutton3,'Enable','on');
 end
else
     image(I),axis off
     image_height=imageinfo_cover.Height;
     image_width=imageinfo_cover.Width;
     handles.equ=((image_height-1)*(image_width-mod(image_width,8)))/8;
     set(handles.pushbutton2,'Enable','on');
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.rad2==1

else
    [handles.sfilename handles.spathname]=uigetfile({'*.jpg';'*.png'},'Select an Image');
    imageinfo_cover=imfinfo([handles.spathname handles.sfilename]);
    image_height=imageinfo_cover.Height;
    image_width=imageinfo_cover.Width;
    
    equ=image_width*image_height;
    
    if equ <=handles.equ
    I=imread([handles.spathname handles.sfilename]);
    set(handles.pushbutton3,'Enable','on');
    axes(handles.axes2);
    image(I);axis off
    else
    errordlg('Select another Image','Image too big');    
    end
    guidata(hObject, handles);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.rad1==1
lsb=1;   
I=imread([handles.cpathname handles.cfilename]);
imageinfo_cover=imfinfo([handles.cpathname handles.cfilename]);
image_height=imageinfo_cover.Height;
image_width=imageinfo_cover.Width;


val_red=I(:,:,1); %get the red color matrix

I_sec=imread([handles.spathname handles.sfilename]);
imageinfo_sec=imfinfo([handles.spathname handles.sfilename]); %get information of secret image
i_sec_height=imageinfo_sec.Height;          % secret image height 
i_sec_width=imageinfo_sec.Width;            % secret image width 

val_red=double(val_red);

%hide the secret image height  
i_sec_height_bin=de2bi(i_sec_height,16);
val_red(1,1:16)=bitset(val_red(1,1:16),1,i_sec_height_bin);

%hide the secret image width  
i_sec_width_bin=de2bi(i_sec_width,16);
val_red(1,17:32)=bitset(val_red(1,17:32),1,i_sec_width_bin);

%hide an identity, that this image has a secret image.
emb=('yes');
emb_bin=de2bi(double(emb));
val_red(1,50:56)=bitset(val_red(1,50:56),lsb,emb_bin(1,1:7));
val_red(1,57:63)=bitset(val_red(1,57:63),lsb,emb_bin(2,1:7));
val_red(1,64:70)=bitset(val_red(1,64:70),lsb,emb_bin(3,1:7));

I(:,:,1)=val_red;  

i_sec_length=i_sec_height*i_sec_width;
I_sec_bin=zeros(i_sec_length*3,8);


I_sec_bin=de2bi(double(I_sec));    %convert the secret image to binary
Ipix_counter=1;                    %set a counter for the  pixels


len=mod(image_width,8);            
len=image_width-len;               

for count_hi=2:image_height
    count_wi=1;
    for count_wi=1:8:len-8
          val_red(count_hi,count_wi:count_wi+7)=...
                bitset(val_red(count_hi,count_wi:count_wi+7),1,I_sec_bin(Ipix_counter,:));
        
         Ipix_counter=Ipix_counter+1;
       if Ipix_counter>i_sec_length*3
         break;
       end

    
    end
       if Ipix_counter>i_sec_length*3
         break;
       end
      
end

I(:,:,1)=val_red;

[filename, pathname] = uiputfile('.png', 'Save Image as');
imwrite(I,[pathname filename ],'png');
set(handles.pushbutton3,'Enable','off');
set(handles.pushbutton2,'Enable','off');
axes(handles.axes1);cla
axes(handles.axes2);cla
msgbox(['The secret image ' handles.sfilename ' is in '  filename]);
else
  %case 2:Dercyption(Reocver the secret image from cover image)
lsb=1;
I=imread([handles.cpathname handles.cfilename]);    

imageinfo_cover=imfinfo([handles.cpathname handles.cfilename]);%cover image information
image_height=imageinfo_cover.Height;         %cover image height
image_width=imageinfo_cover.Width;           %cover image width

val_red=I(:,:,1);                            %get the red color matrix

%extract the secret image height and width from 1st 32pixel of cover image
i_sec_height=bi2de(bitget(double(val_red(1,1:16)),1));
i_sec_width=bi2de(bitget(double(val_red(1,17:32)),1));
i_sec_length=i_sec_height*i_sec_width;

I_sec_bi=zeros(i_sec_length*3,8);%initialize a zero matrix
Ipix_counter=1;                  %counter for pixels

len=mod(image_width,8);            
len=image_width-len;               

for count_hi=2:image_height
    count_wi=1;
    for count_wi=1:8:len-8
       I_sec_bi(Ipix_counter,1:8)=...
       bitget(val_red(count_hi,count_wi:count_wi+7),1);
        
       Ipix_counter=Ipix_counter+1;
       if Ipix_counter>i_sec_length*3
         break;
       end

     
    end
        if Ipix_counter>i_sec_length*3
         break;
       end
end

image1=reshape(bi2de(I_sec_bi),i_sec_height,i_sec_width,3);
image1=uint8(image1);
rn=num2str(rand(1,1));
imwrite(image1,[num2str(rn(3:end)) '.png'],'png');
axes(handles.axes2);
image(image1);axis off
msgbox(['The image '  rn(3:end) '.png is extracted from ' handles.cfilename ' ,it is in your current directory']);  
end    

% --------------------------------------------------------------------
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Tag')   % Get Tag of selected object
    case 'radiobutton1'
        handles.rad1=1;
        handles.rad2=0;
        guidata(hObject, handles);
        % code piece when radiobutton1 is selected goes here
         axes(handles.axes1);cla
         axes(handles.axes2);cla 
         set(handles.pushbutton3,'String','Hide');
         set(handles.pushbutton3,'Enable','off');
         set(handles.pushbutton2,'Enable','off');
         set(handles.pushbutton1,'Enable','on');
   
    case 'radiobutton2'
        % code piece when radiobutton2 is selected goes here
        % ...
        handles.rad2=1;
        handles.rad1=0;
        guidata(hObject, handles);
         axes(handles.axes1);cla
         axes(handles.axes2);cla
         set(handles.pushbutton3,'String','Recover');
         set(handles.pushbutton3,'Enable','off');
         set(handles.pushbutton2,'Enable','off');
         set(handles.pushbutton1,'Enable','on');
end


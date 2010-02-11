function varargout = grdtrend_mir(varargin)
% M-File changed by desGUIDE 
%   The output is a structure with the following fields (or empty):
%   out.opt_what -> It wil be '-T','-D' or 'W' and optionaly it may have a 'r' apended
%   out.opt_N    -> Number of model parameters (allways)

%	Copyright (c) 2004-2006 by J. Luis
%
%	This program is free software; you can redistribute it and/or modify
%	it under the terms of the GNU General Public License as published by
%	the Free Software Foundation; version 2 of the License.
%
%	This program is distributed in the hope that it will be useful,
%	but WITHOUT ANY WARRANTY; without even the implied warranty of
%	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%	GNU General Public License for more details.
%
%	Contact info: w3.ualg.pt/~jluis/mirone
% --------------------------------------------------------------------

	hObject = figure('Tag','figure1','Visible','off');
	grdtrend_mir_LayoutFcn(hObject);
	handles = guihandles(hObject);
	movegui(hObject,'center')

	if ~isempty(varargin)
		handMir  = varargin{1};
		handles.Z = getappdata(handMir.figure1,'dem_z');
		handles.have_nans = handMir.have_nans;
	else
        errordlg('GRDTREND: wrong number of arguments.','Error')
        delete(hObject);    return
	end
    
	if (handMir.no_file)
		errordlg('GRDTREND: You didn''t even load a file. What are you expecting then?','ERROR')
        delete(hObject);    return
	end
	if (~handMir.validGrid)
        errordlg('GRDTREND: This operation is deffined only for images derived from DEM grids.','ERROR')
        delete(hObject);    return
	end
	if (isempty(handles.Z))
        errordlg('GRDTREND: Grid was not saved in memory. Increase "Grid max size" and start over.','ERROR')
        delete(hObject);    return
	end

	handles.hMirFig = handMir.figure1;
	handles.head = handMir.head;

	% Give a Pro look (3D) to the frame boxes 
	bgcolor = get(0,'DefaultUicontrolBackgroundColor');
	framecolor = max(min(0.65*bgcolor,[1 1 1]),[0 0 0]);
	h_f = findobj(hObject,'Style','Frame');
	for i=1:length(h_f)
        frame_size = get(h_f(i),'Position');
        f_bgc = get(h_f(i),'BackgroundColor');
        usr_d = get(h_f(i),'UserData');
        if abs(f_bgc(1)-bgcolor(1)) > 0.01           % When the frame's background color is not the default's
            frame3D(hObject,frame_size,framecolor,f_bgc,usr_d)
        else
            frame3D(hObject,frame_size,framecolor,'',usr_d)
            delete(h_f(i))
        end
	end

	% Recopy the text fields on top of previously created frames (uistack is to slow)
	h_t = handles.text2;
	for i=1:length(h_t)
        usr_d = get(h_t(i),'UserData');
        t_size = get(h_t(i),'Position');   t_str = get(h_t(i),'String');    fw = get(h_t(i),'FontWeight');
        bgc = get (h_t(i),'BackgroundColor');   fgc = get (h_t(i),'ForegroundColor');
        uicontrol('Parent',hObject, 'Style','text', 'Position',t_size,'String',t_str, ...
            'BackgroundColor',bgc,'ForegroundColor',fgc,'FontWeight',fw,'UserData',usr_d);
	end
	delete(h_t)

	guidata(hObject, handles);

	set(hObject,'Visible','on');
	if (nargout),   varargout{1} = hObject;     end

% -------------------------------------------------------------------------------------
function radiobutton_trend_Callback(hObject, handles)
	if (get(hObject,'Value'))
        set(handles.radiobutton_residuals,'Value',0)
        set(handles.radiobutton_weights,'Value',0)
	else
        set(hObject,'Value',1)
	end

% -------------------------------------------------------------------------------------
function radiobutton_residuals_Callback(hObject, handles)
	if (get(hObject,'Value'))
		set(handles.radiobutton_trend,'Value',0)
		set(handles.radiobutton_weights,'Value',0)
	else
		set(hObject,'Value',1)
	end

% -------------------------------------------------------------------------------------
function radiobutton_weights_Callback(hObject, handles)
	if (get(hObject,'Value'))
        set(handles.radiobutton_trend,'Value',0)
        set(handles.radiobutton_residuals,'Value',0)
        set(handles.checkbox_RobustFit,'Value',1)
	else
        set(hObject,'Value',1)
	end

% -------------------------------------------------------------------------------------
function pushbutton_Help_Nmodel_Callback(hObject, handles)
message = {'The trend surface is defined by:'
    ' '
    'm1  +  m2*x + m3*y + m4*x*y + m5*x*x + m6*y*y + m7*x*x*x + m8*x*x*y + m9*x*y*y + m10*y*y*y'
    ''
    'The user must specify "Number of mode parameters", the number of model'
    'parameters to use; thus, 3 fits a bilinear trend, 6 a quadratic surface,'
    'and so on. Optionally, select "Robust fit" to perform a robust fit.'};
helpdlg(message,'Help on model parameters');

% -------------------------------------------------------------------------------------
function pushbutton_OK_Callback(hObject, handles)
	% See what to compute
	if (get(handles.radiobutton_trend,'Value'))
        opt_what = '-T';
		tmp.name = 'Trend grid';
	elseif (get(handles.radiobutton_residuals,'Value'))
        opt_what = '-D';
		tmp.name = 'Residuals grid';
	elseif (get(handles.radiobutton_weights,'Value'))
        opt_what = '-W';
		tmp.name = 'Weights grid';
	else
        errordlg('Nothing selected in "What to compute"','Error');  return
	end

	% Find the model, but first check if "Robust" was choosen
	if (get(handles.checkbox_RobustFit,'Value'))
        opt_N = '-Nr';
	else
        opt_N = '-N';
	end

	val = get(handles.popup_Nmodel,'Value');
	str = get(handles.popup_Nmodel, 'String');
	switch str{val};
		case '1',       opt_N = [opt_N '1'];
		case '2',       opt_N = [opt_N '2'];
		case '3',       opt_N = [opt_N '3'];
		case '4',       opt_N = [opt_N '4'];
		case '5',       opt_N = [opt_N '5'];
		case '6',       opt_N = [opt_N '6'];
		case '7',       opt_N = [opt_N '7'];
		case '8',       opt_N = [opt_N '8'];
		case '9',       opt_N = [opt_N '9'];
		case '10',      opt_N = [opt_N '10'];
	end

	set(handles.figure1,'pointer','watch');     set(handles.hMirFig,'pointer','watch')
	newZ = grdtrend_m(handles.Z,handles.head,opt_what,opt_N);
	if (handles.have_nans && opt_what(2) == 'T' && get(handles.check_NaNs, 'Val'))
		newZ(isnan(handles.Z)) = nan;		% Reset the NaNs where they belong
	end
	zz = grdutils(newZ,'-L');       handles.head(5:6) = zz(1:2);
	set(handles.figure1,'pointer','arrow');     set(handles.hMirFig,'pointer','arrow')
	tmp.X = linspace(handles.head(1),handles.head(2),size(handles.Z,2));
	tmp.Y = linspace(handles.head(3),handles.head(4),size(handles.Z,1));
	tmp.head = handles.head;
	mirone(newZ,tmp);
	figure(handles.figure1)         % Don't let this figure forgotten behind the newly created one

% -------------------------------------------------------------------------------------
% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata)
	if isequal(get(hObject,'CurrentKey'),'escape')
		delete(hObject);
	end

% --- Creates and returns a handle to the GUI figure. 
function grdtrend_mir_LayoutFcn(h1)
set(h1,...
'Color',get(0,'factoryUicontrolBackgroundColor'),...
'KeyPressFcn',@figure1_KeyPressFcn,...
'MenuBar','none',...
'Name','grdtrend',...
'NumberTitle','off',...
'Position',[520 686 290 114],...
'Resize','off',...
'Tag','figure1');

uicontrol('Parent',h1,...
'Position',[10 70 271 35],...
'Style','frame',...
'Tag','frame1');

uicontrol('Parent',h1,...
'Callback',{@grdtrend_mir_uicallback,h1,'radiobutton_trend_Callback'},...
'Position',[24 79 60 15],...
'String','Trend',...
'Style','radiobutton',...
'TooltipString','Compute the trend surface resulting from the choosen model',...
'Tag','radiobutton_trend');

uicontrol('Parent',h1,...
'Callback',{@grdtrend_mir_uicallback,h1,'radiobutton_residuals_Callback'},...
'Position',[112 79 80 15],...
'String','Residuals',...
'Style','radiobutton',...
'TooltipString','Compute the residuals. That is, The difference (input data - trend)',...
'Tag','radiobutton_residuals');

uicontrol('Parent',h1,...
'Callback',{@grdtrend_mir_uicallback,h1,'radiobutton_weights_Callback'},...
'Position',[205 79 80 15],...
'String','Weights',...
'Style','radiobutton',...
'TooltipString','Compute the weights of the fit between the data and the model',...
'Tag','radiobutton_weights');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Position',[10 18 53 22],...
'String',{  '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; '10' },...
'Style','popupmenu',...
'Value',1,...
'Tag','popup_Nmodel');

uicontrol('Parent',h1,...
'Position',[67 23 100 15],...
'String','Robust Fit',...
'Style','checkbox',...
'TooltipString','This is a matematical thing. Either you know what it is or not.',...
'Tag','checkbox_RobustFit');

uicontrol('Parent',h1,...
'Callback',{@grdtrend_mir_uicallback,h1,'pushbutton_Help_Nmodel_Callback'},...
'FontWeight','bold',...
'ForegroundColor',[0 0 1],...
'Position',[171 18 22 22],...
'String','?',...
'Tag','pushbutton_Help_Nmodel');

uicontrol('Parent',h1,...
'Enable','inactive',...
'Position',[11 43 185 15],...
'HorizontalAlignment','left',...
'String','Number of model parameters',...
'Style','text',...
'Tag','text1');

uicontrol('Parent',h1,...
'Position',[67 2 110 15],...
'String','Protect NaNs',...
'Style','checkbox',...
'TooltipString','If checked put the NaNs back on the trend surface',...
'Value',1,...
'Tag','check_NaNs');

uicontrol('Parent',h1,...
'Callback',{@grdtrend_mir_uicallback,h1,'pushbutton_OK_Callback'},...
'Position',[214 10 66 21],...
'String','OK',...
'Tag','pushbutton_OK');

uicontrol('Parent',h1,...
'Enable','inactive',...
'Position',[20 95 110 17],...
'String','What to compute',...
'Style','text',...
'Tag','text2');

function grdtrend_mir_uicallback(hObject, eventdata, h1, callback_name)
% This function is executed by the callback and than the handles is allways updated.
feval(callback_name,hObject,guidata(h1));

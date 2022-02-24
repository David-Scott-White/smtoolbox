function varargout = discGUI(varargin)
% discGUI MATLAB code for discGUI.fig
%      discGUI, by itself, creates a new discGUI or raises the existing
%      singleton*.
%
%      H = discGUI returns the handle to a new discGUI or the handle to
%      the existing singleton*.
%
%      discGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in discGUI.M with the given input arguments.
%
%      discGUI('Property','Value',...) creates a new discGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before discGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to discGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help discGUI

% Last Modified by GUIDE v2.5 26-Jan-2022 14:32:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @discGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @discGUI_OutputFcn, ...
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

% LAYOUT OF THIS FILE
% ===================
% 1. OpeningFcn, OutputFcn, and print and keypress callbacks
% 2. Callbacks and/or CreateFcns in alphabetical order



% --- Executes just before discGUI is made visible.
function discGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to discGUI (see VARARGIN)

handles.data = varargin{:};

% make axes array to simplify goToROI input
handles.ax_array = [handles.axes1 handles.axes2 handles.axes3 handles.axes4];
[handles.data.names, handles.channel_colors] = initChannels(handles.data);

handles.popupmenu_channelSelect.String = handles.data.names;

% init indices
% idx(1) = roi idx, idx(2) = ch idx
handles.idx(1) = 1;
handles.idx(2) = 1;

% init disc_input from function
handles.disc_input = initDISC();

% show lines after DISC fit 
handles.show_lines = 0; 

% init variables for filter values
handles.filters.enableSNR = 0;
handles.filters.enablenumStates = 0;
handles.filters.snr_min = [];
handles.filters.snr_max = [];
handles.filters.numstates_min = [];
handles.filters.numstates_max = [];

% Choose default command line output for discGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using discGUI.
% initial load of ROI 1 at channel 1
if strcmp(get(hObject,'Visible'),'off')    
    % set value for sem
%     if isfield(handles.data, 'alignTransform')
%         rmse = handles.data.alignTransform.rmse;
%         rmse = mean(rmse)*2; 
%         handles.edit_dist.String = num2str(rmse); 
%         handles.data.maxdist = rmse; 
%         handles.checkbox_centroid.Value = 1;
%     end
    guidata(hObject, handles);
    goToROI(handles.data, handles.idx, handles.ax_array,...
        handles.channel_colors,  handles.show_lines);
     guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = discGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;


function PrintMenuItem_Callback(hObject, eventdata, handles)
% loads the standard print dialog
printdlg(handles.figure_main)


% --- Executes on key press with focus on figure_main or any of its controls.
function figure_main_WindowKeyPressFcn(hObject, eventdata, handles)
% handles all key presses as labeled on buttons. easily extended with the
% proper strings
switch eventdata.Key
    case 'rightarrow'
        uicontrol(handles.pushbutton_nextROI)
        pushbutton_nextROI_Callback(handles.pushbutton_nextROI,[],handles)
    case 'leftarrow'
        uicontrol(handles.pushbutton_prevROI)
        pushbutton_prevROI_Callback(handles.pushbutton_prevROI,[],handles)
    case 'uparrow'
        uicontrol(handles.pushbutton_toggleSelect)
        pushbutton_toggleSelect_Callback(handles.pushbutton_toggleSelect,[],handles)
    case 'downarrow'
        uicontrol(handles.pushbutton_toggleDeselect)
        pushbutton_toggleDeselect_Callback(handles.pushbutton_toggleDeselect,[],handles)
    case 'period'
        uicontrol(handles.pushbutton_nextSelected)
        pushbutton_nextSelected_Callback(handles.pushbutton_nextSelected,[],handles)
    case 'comma'
        uicontrol(handles.pushbutton_prevSelected)
        pushbutton_prevSelected_Callback(handles.pushbutton_prevSelected,[],handles)
        
    case 'd'
        % custom analysis option by button press 
        handles.disc_input.input_type = 'alpha_value';
        handles.disc_input.input_value = 0.05;
        handles.disc_input.divisive = 'AIC_GMM';
        handles.disc_input.agglomerative = 'AIC_GMM';
        handles.disc_input.viterbi = 10;
        handles.disc_input.return_k = 0;
        [handles.data, handles.disc_input] = analyzeFromGUI(handles.data,...
            handles.disc_input, handles.idx, 0, 0);
        guidata(hObject, handles);
        handles.show_lines = 1; 
        handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
            handles.channel_colors,  handles.show_lines);
        
    case 'l'
        if handles.show_lines
            handles.show_lines = 0;
        else
            handles.show_lines = 1;
        end
        handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
            handles.channel_colors, handles.show_lines);
    case 'f'
        pushbutton28_Callback(hObject, eventdata, handles)
        
end


function menuFile_exportDat_Callback(hObject, eventdata, handles)
exportText(handles.data, handles.idx(2));

function menuFile_exportFigs_Callback(hObject, eventdata, handles)
exportFigs(handles.data, handles.idx, handles.channel_colors);

function menuFile_expRelSel_Callback(hObject, eventdata, handles)
saveData(handles.data, 1, hObject);

function menuFile_loadData_Callback(hObject, eventdata, handles, fp)
if ~exist('fp', 'var')
    data = loadData();
    if ~isempty(data)
        handles.data = data;
    else
        return
    end
else
    handles.data = loadData(fp);
end
% reset to channel 1, roi 1
handles.idx = [1 1];

[handles.data.names, handles.channel_colors] = initChannels(handles.data);
% reset channel popup and filter strings
handles.popupmenu_channelSelect.String = handles.data.names;
handles.popupmenu_channelSelect.Value = 1;
handles.text_snr_filt.String = 'any';
handles.text_numstates_filt.String = 'any';

% recall axes from gui to send to goToROI
guidata(handles.figure_main, handles);
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors, handles.show_lines);

function menuFile_saveData_Callback(hObject, eventdata, handles)
saveData(handles.data);


function menuPlots_dwellAnalysis_Callback(hObject, eventdata, handles)
getDwellTimes(handles.data, handles.idx(2)); % double check this 

function menuPlots_numStatesHist_Callback(hObject, eventdata, handles)
plotNumStates(handles.data, handles.idx(2), 1);

function menuPlots_snrHist_Callback(hObject, eventdata, handles)
handles.data = plotSNR(handles.data, handles.idx(2), 1);
guidata(hObject, handles);

function menuPlots_stateOccupancy_Callback(hObject, eventdata, handles)
handles.data = getStateOccupancy(handles.data, handles.idx(2));
guidata(hObject, handles);

function popupmenu_channelSelect_Callback(hObject, eventdata, handles)
% changes the channel selected via popup, and remains on the current ROI.
% Supports an arbitrary number of channels

popup_sel_index = get(handles.popupmenu_channelSelect, 'Value');
for ii = 1:size(handles.data.rois,2)
    switch popup_sel_index
        case ii
            handles.idx(2) = ii;
            handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
                handles.channel_colors,  handles.show_lines);
            guidata(hObject, handles);
    end
end


% executes during object creation, after setting all properties.
function popupmenu_channelSelect_CreateFcn(hObject, eventdata, handles)
% creates popup and fetches channel names
% Supports an arbitrary number of channels (though colors would need to be
% adapted as such in initChannels)

% create menu with default colors
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

% names set in OpeningFcn, as this function does will not yet have access
% to handles.data
hObject.Value = 1;
hObject.FontSize = 10;
hObject.FontName = 'arial';


function pushbutton_analyzeAll_Callback(hObject, eventdata, handles)
% sets condition to run DISC on all ROIs and brings up param dialog
% will also return params, as they may have been changed in the dialog
[handles.data, handles.disc_input] = analyzeFromGUI(handles.data,...
    handles.disc_input, handles.idx, 1, 1);
guidata(hObject, handles); % update gui
% display ROI selected before analysis
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors, handles.show_lines);


function pushbutton_analyzeThis_Callback(hObject, eventdata, handles)
% sets condition to run DISC on the current ROI and brings up param dialog
% will also return params, as they may have been changed in the dialog
[handles.data, handles.disc_input] = analyzeFromGUI(handles.data,...
    handles.disc_input, handles.idx, 0, 1);
guidata(hObject, handles); % update gui
% display ROI selected before analysis
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors, handles.show_lines);


function pushbutton_clearAll_Callback(hObject, eventdata, handles)
% clears analysis fields for all ROIs
[handles.data.rois(:, handles.idx(2)).disc_fit] = deal([]);
[handles.data.rois(:, handles.idx(2)).SNR] = deal([]);
guidata(hObject, handles);
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors, handles.show_lines);


function pushbutton_clearThis_Callback(hObject, eventdata, handles)
% clears analysis fields for current ROI
handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit = [];
handles.data.rois(handles.idx(1), handles.idx(2)).SNR = [];
guidata(hObject, handles);
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors, handles.show_lines);


function pushbutton_customROI_Callback(hObject, eventdata, handles)
% jump to any given ROI via a dialog
handles.idx(1) = -1;
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors, handles.show_lines);
guidata(hObject, handles);


function pushbutton_filter_Callback(hObject, eventdata, handles)

handles.filters = traceSelection(handles.filters);
% apply the selection 
handles = applyTraceSelection(handles); 

guidata(hObject, handles);
% redraw titles
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors, handles.show_lines);


function pushbutton_nextROI_Callback(hObject, eventdata, handles)
% go to the next ROI, stops at end of channel
handles.idx(1) = handles.idx(1) + 1;
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors,  handles.show_lines);
guidata(hObject, handles);


function pushbutton_nextSelected_Callback(hObject, eventdata, handles)
% finds next ROI with "selected" status and goes to it in the GUI
j = find(vertcat(handles.data.rois(handles.idx(1)+1:end, handles.idx(2)).status) == 1);
if ~isempty(j)
    handles.idx(1) = handles.idx(1) + j(1);
    handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
        handles.channel_colors,  handles.show_lines);
    guidata(hObject, handles);
end


function pushbutton_prevROI_Callback(hObject, eventdata, handles)
% go to the previous ROI, stops at 1
handles.idx(1) = handles.idx(1) - 1;
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors,  handles.show_lines);
guidata(hObject, handles);


function pushbutton_prevSelected_Callback(hObject, eventdata, handles)
% finds previous ROI with "selected" status and goes to it in the GUI
j = find(vertcat(handles.data.rois(1:handles.idx(1)-1, handles.idx(2)).status) == 1);
if ~isempty(j)
    handles.idx(1) = j(end);
    handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
        handles.channel_colors,  handles.show_lines);
    guidata(hObject, handles);
end


function pushbutton_toggleDeselect_Callback(hObject, eventdata, handles)
% change "status" field for ROI (and title if necessary)
% change status on all channels
for ii = 1:size(handles.data.rois, 2)
    handles.data.rois(handles.idx(1), ii).status = 0;
end
guidata(hObject, handles);

% count # of selected, update trajectory title
numsel = nnz(vertcat(handles.data.rois(:,handles.idx(2)).status)==1);
if handles.data.rois(handles.idx(1), handles.idx(2)).status == 1
    title_txt = sprintf('ROI # %u of %u - Status: Selected  (%u selected)',...
        handles.idx(1), size(handles.data.rois,1), numsel);
elseif handles.data.rois(handles.idx(1), handles.idx(2)).status == 0
    title_txt = sprintf('ROI # %u of %u - Status: Unselected  (%u selected)',...
        handles.idx(1), size(handles.data.rois,1), numsel);
else
    title_txt = sprintf('ROI # %u of %u - Status: null  (%u selected)',...
        handles.idx(1), size(handles.data.rois,1), numsel);
end
title(handles.axes1, title_txt);


function pushbutton_toggleSelect_Callback(hObject, eventdata, handles)
% change "status" field for ROI (and title if necessary)
% change status on all channels
for ii = 1:size(handles.data.rois,2)
    handles.data.rois(handles.idx(1),ii).status = 1;
end
guidata(hObject, handles);

% count # of selected, update trajectory title
numsel = nnz(vertcat(handles.data.rois(:,handles.idx(2)).status)==1);
if handles.data.rois(handles.idx(1), handles.idx(2)).status == 1
    title_txt = sprintf('ROI # %u of %u - Status: Selected  (%u selected)',...
        handles.idx(1), size(handles.data.rois,1), numsel);
elseif handles.data.rois(handles.idx(1), handles.idx(2)).status == 0
    title_txt = sprintf('ROI # %u of %u - Status: Unselected  (%u selected)',...
        handles.idx(1), size(handles.data.rois,1), numsel);
else
    title_txt = sprintf('ROI # %u of %u - Status: null  (%u selected)',...
        handles.idx(1), size(handles.data.rois,1), numsel);
end
title(handles.axes1, title_txt);


% --- Executes on button press in pushbutton_truncate.
function pushbutton_truncate_Callback(hObject, eventdata, handles)
handles.data = truncateTrace(handles.data,handles.idx,0); 
guidata(hObject, handles);
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors,  handles.show_lines);

% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
handles.data = resetTrace(handles.data,handles.idx,0);
guidata(hObject, handles);
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors,  handles.show_lines);

% --- Executes on button press in pushbutton_truncateAll.
function pushbutton_truncateAll_Callback(hObject, eventdata, handles)
    answer = questdlg('Undo all time series truncation?', ...
    'Yes','No');
switch answer
    case 'Yes'
        handles.data = truncateTrace(handles.data,handles.idx,1); 
        guidata(hObject, handles);
        handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
            handles.channel_colors, handles.show_lines);
end

% --- Executes on button press in pushbutton_resetAll.
function pushbutton_resetAll_Callback(hObject, eventdata, handles)
answer = questdlg('Undo all time series truncation?', ...
    'Yes','No');
switch answer
    case 'Yes'
        handles.data = resetTrace(handles.data,handles.idx,1);
        guidata(hObject, handles);
        handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
            handles.channel_colors, handles.show_lines);
end


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotSpot(handles.data, handles.idx)


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotCentroidCorrelation(handles.data)


% --- Executes on button press in checkbox_centroid.
function checkbox_centroid_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_centroid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_centroid



function edit_dist_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dist as text
%        str2double(get(hObject,'String')) returns contents of edit_dist as a double


% --- Executes during object creation, after setting all properties.
function edit_dist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% THESE FUNCTIONS REALLY NEED SOME CLEANING.... 2021-12-22 DSW

% --- Executes on button press in pushbutton_up.
function pushbutton_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

roi = handles.data.rois(handles.idx(1), handles.idx(2));
if isfield(roi.disc_fit,'allIdeal') || isfield(roi.disc_fit,'all_ideal')
    nStatesCurrent = size(roi.disc_fit.components,1);
    if isfield(roi.disc_fit,'allIdeal')
        maxStates = size(roi.disc_fit.allIdeal,1);
    else
        maxStates = size(roi.disc_fit.all_ideal,1);
    end

    if nStatesCurrent < maxStates
        nStatesNew = nStatesCurrent+1;
        if isfield(roi.disc_fit,'allIdeal')
            newIdeal = roi.disc_fit.allIdeal(:,nStatesNew);
        else
            newIdeal = roi.disc_fit.all_ideal(:,nStatesNew);
        end
        
        % run viterbi again? will need to do if DISC...
        if ~isempty(roi.disc_fit.parameters)
            viterbiIter = double(roi.disc_fit.parameters.viterbi);
            if viterbiIter
                newIdeal = runViterbi(roi.time_series, newIdeal, viterbiIter);
            end
        end
        [comps, ideal, class] = computeCenters(roi.time_series, newIdeal);
        handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.components = comps;
        handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.ideal = ideal;
        handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.class = class;
        
        guidata(hObject, handles);
        handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
            handles.channel_colors, handles.show_lines);
        
    end
end


% --- Executes on button press in pushbutton_down.
function pushbutton_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

roi = handles.data.rois(handles.idx(1), handles.idx(2));
if isfield(roi.disc_fit,'allIdeal') || isfield(roi.disc_fit,'all_ideal')
    nStatesCurrent = size(roi.disc_fit.components,1);
    if nStatesCurrent > 1
        nStatesNew = nStatesCurrent-1;
        if isfield(roi.disc_fit,'allIdeal')
            newIdeal = roi.disc_fit.allIdeal(:,nStatesNew);
        else
            newIdeal = roi.disc_fit.all_ideal(:,nStatesNew);
        end
        
        % run viterbi again? will need to do if DISC...
        if ~isempty(roi.disc_fit.parameters)
            viterbiIter = double(roi.disc_fit.parameters.viterbi);
            if viterbiIter
                newIdeal = runViterbi(roi.time_series, newIdeal, viterbiIter);
            end
        end
        [comps, ideal, class] = computeCenters(roi.time_series, newIdeal);
        handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.components = comps;
        handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.ideal = ideal;
        handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.class = class;
        
        guidata(hObject, handles);
        handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
            handles.channel_colors, handles.show_lines);
        
    end
end


% --- Executes on button press in removeEventButton.
function removeEventButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeEventButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Which event to remove?'};
dlgtitle = 'Event Removal';
dims = [1 35];
definput = {'1'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

if ~isempty(answer)
    roi = handles.data.rois(handles.idx(1), handles.idx(2));
    ss = roi.disc_fit.class;
    events = findEvents(ss);
    idx = str2double(answer{1});
    if idx <= size(events,1)
        eventStart = events(idx,1);
        eventStop = events(idx,2);
        eventState = events(idx,4);
        if eventState > min(events(:,4))
            ss(eventStart:eventStop) = eventState-1;
        else
            ss(eventStart:eventStop) = eventState+1;
        end
        [comps, ideal, class] = computeCenters(roi.time_series, ss);
        handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.components = comps;
        handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.ideal = ideal;
        handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.class = class;
        
        guidata(hObject, handles);
        handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
            handles.channel_colors, handles.show_lines);
    end
end


% --- Executes on button press in pb_threshold.
function pb_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to pb_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi = handles.data.rois(handles.idx(1), handles.idx(2));
ts = roi.time_series; 

prompt = {'Bin Frames above:', 'Viterbi (boolean):'};
dlgtitle = 'Threshold Input';
dims = [1 35];
definput = {num2str(round(mean(ts)*1.25)),'1'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

ss = ones(length(ts),1); 
ss(ts >= str2double(answer(1))) = 2; 
c0 = computeCenters(ts, ss);  
% refine within std of bin
x = 2;
ss(ss >= (c0(2,2)-c0(2,3)*x)) = 2;
[comps, ideal, class] = computeCenters(ts, ss);

if str2double(answer(2))
    data_fit = runViterbi(ts, ss, 10);
    [comps, ideal, class] = computeCenters(ts, data_fit);
end
handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.components = comps;
handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.ideal = ideal;
handles.data.rois(handles.idx(1), handles.idx(2)).disc_fit.class = class;
guidata(hObject, handles);
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors, handles.show_lines);


% --- Executes on button press in pushbutton_selectAll.
function pushbutton_selectAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.data.rois.status] = deal(1);
guidata(hObject, handles);
handles.idx = goToROI(handles.data, handles.idx, handles.ax_array,...
    handles.channel_colors, handles.show_lines);


% --- Executes on button press in pushbutton_scrollSpot.
function pushbutton_scrollSpot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_scrollSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
scrollSpot(handles.data, handles.idx)
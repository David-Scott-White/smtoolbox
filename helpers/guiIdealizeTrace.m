function handles = guiIdealizeTrace(hObject, handles)
% Idealize the trace(s)
% see guiIdealizationOptions.m

% chaIdx = handles.popupmenuChannel.Value;
chaIdx = handles.info.channelIndex;
if ~isfield(handles.data, 'idealParm') || isempty(handles.data.idealParm{chaIdx})
        % set default
        handles = guiIdealizationOptions(hObject, handles);
        guidata(hObject, handles);
end

parm = handles.data.idealParm{chaIdx};
applyToAll = handles.checkboxApplyToAll.Value;

switch handles.data.idealParm{chaIdx}.method
    
    case 'DISC'
        if applyToAll
            % modify waitbar for some other options (cancel, show nrois)
            wb = waitbar(0, ['DISC: Idealizing all | Channel ', num2str(chaIdx)]);
            for i = 1:handles.info.nrois
                handles.data.rois(i, chaIdx).fit = ...
                    runDISC(handles.data.rois(i, chaIdx).timeSeries, parm);
                
                % store events
                handles.data.rois(i,chaIdx).events =...
                    findEvents(handles.data.rois(i, chaIdx).fit.class); 
                
                waitbar(i/handles.info.nrois, wb);
            end
            close(wb);
        else
            roiIdx = handles.info.roiIndex;
            handles.data.rois(roiIdx, chaIdx).fit = ...
                runDISC(handles.data.rois(roiIdx, chaIdx).timeSeries, parm);
            
            % store events
            handles.data.rois(roiIdx,chaIdx).events =...
                    findEvents(handles.data.rois(roiIdx, chaIdx).fit.class); 
        end
              
    case 'SKM'
        
    case 'vbHMM'
        
    case 'Gaussian CP'
        
    case 'Threshold'
        roi = handles.data.rois(handles.info.roiIndex, handles.info.channelIndex);
        ts = roi.timeSeries;
        
        prompt = {'Bin Frames above:', 'Viterbi (boolean):'};
        dlgtitle = 'Threshold Input';
        dims = [1 35];
        definput = {num2str(round(mean(ts)*1.1)),'1'};
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
        handles.data.rois(handles.info.roiIndex, handles.info.channelIndex).fit.components = comps;
        handles.data.rois(handles.info.roiIndex, handles.info.channelIndex).fit.ideal = ideal;
        handles.data.rois(handles.info.roiIndex, handles.info.channelIndex).fit.class = class;
        handles.data.rois(handles.info.roiIndex, handles.info.channelIndex).fit.method = 'threshold';
        handles.data.rois(handles.info.roiIndex, handles.info.channelIndex).events =...
                    findEvents(handles.data.rois(handles.info.roiIndex, handles.info.channelIndex).fit.class); 
        guidata(hObject, handles);
        
end
guidata(hObject, handles);

end
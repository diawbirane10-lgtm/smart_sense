function results=verifier_simulink_rd()
% Linear nominal model consistency, not implementation/hardware validation.
root=fileparts(fileparts(mfilename('fullpath')));
out=fullfile(root,'ingenierie','revue_RD_20261106');
load(fullfile(out,'MODELES_LINEAIRES.mat'),'irPlant','usPlant','fs');
name='SmartSense_RD_Linear';
if bdIsLoaded(name),close_system(name,0);end
new_system(name);cleaner=onCleanup(@()close_system(name,0));
Ts=1/fs; t=(0:Ts:.005).';
plants={irPlant,usPlant};frequencies=[1e4,4e4];amplitudes=[1e-6,.01];
set_param(name,'Solver','FixedStepDiscrete','FixedStep',num2str(Ts,17),...
    'StopTime',num2str(t(end),17),'ReturnWorkspaceOutputs','on');
maxError=zeros(1,2);
for i=1:2
    tag=['Channel',num2str(i)];sys=plants{i};
    add_block('simulink/Sources/Sine Wave',[name,'/',tag,'_Input'],...
        'Amplitude',num2str(amplitudes(i),17),'Frequency',num2str(2*pi*frequencies(i),17),...
        'SampleTime',num2str(Ts,17),'Position',[40 60+140*i 100 95+140*i]);
    [A,B,C,D]=ssdata(sys);
    add_block('simulink/Discrete/Discrete State-Space',[name,'/',tag,'_Plant'],...
        'A',mat2str(A,17),'B',mat2str(B,17),'C',mat2str(C,17),'D',mat2str(D,17),...
        'SampleTime',num2str(Ts,17),'Position',[180 60+140*i 360 110+140*i]);
    add_block('simulink/Sinks/To Workspace',[name,'/',tag,'_Record'],...
        'VariableName',['y',num2str(i)],'SaveFormat','Timeseries',...
        'Position',[440 60+140*i 550 100+140*i]);
    add_line(name,[tag,'_Input/1'],[tag,'_Plant/1']);
    add_line(name,[tag,'_Plant/1'],[tag,'_Record/1']);
end
note=Simulink.Annotation(name,'IR and ultrasound | nominal linear models | SYNTHETIC ONLY');
note.Position=[40 35 620 70];
save_system(name,fullfile(out,[name,'.slx']));
simulation=sim(name);
for i=1:2
    y=simulation.get(['y',num2str(i)]);
    expected=lsim(plants{i},amplitudes(i)*sin(2*pi*frequencies(i)*y.Time),y.Time);
    maxError(i)=max(abs(expected(:)-y.Data(:)));
end
assert(all(maxError<1e-8),'Simulink and MATLAB mismatch');
results=struct('type','Nominal discrete linear simulation, not real-time hardware test',...
    'sample_rate_Hz',fs,'duration_s',t(end),'max_difference_V',maxError,'passed',true);
fid=fopen(fullfile(out,'RESULTATS_SIMULINK.json'),'w','n','UTF-8');
assert(fid>=0);fprintf(fid,'%s',jsonencode(results,PrettyPrint=true));fclose(fid);
disp(results);
end

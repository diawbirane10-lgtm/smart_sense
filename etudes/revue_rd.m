function report = revue_rd()
% Revue physique V1, simulations uniquement. Aucune performance mesuree.
root=fileparts(fileparts(mfilename('fullpath')));
out=fullfile(root,'ingenierie','revue_RD_20261106');
if ~isfolder(out), mkdir(out); end
audit=jsondecode(fileread(fullfile(out,'AUDIT_NATIF.json')));
c=audit.components;
rng(61106,'twister');
f=logspace(2,6,1400); s=1i*2*pi*f;
ir=irTransfer(s,c); us=usTransfer(s,c);
ir10=abs(irTransfer(1i*2*pi*1e4,c));
us40=abs(usTransfer(1i*2*pi*4e4,c));
% Uniform independent component tolerances, no temperature/aging model.
n=5000; irGain=zeros(n,1);usGain=zeros(n,1);irF0=zeros(n,1);usF0=zeros(n,1);
for k=1:n
    mc=c; names=fieldnames(c);
    for j=1:numel(names)
        name=names{j};
        if ~startsWith(name,{'R','C'}), continue; end
        v=c.(name).value;
        t=regexp(v,'([\d.]+)%','tokens','once');
        tol=.01; if startsWith(name,'C'), tol=.05; end
        if ~isempty(t),tol=str2double(t{1})/100;end
        mc.(name).numericOverride=val(c,name)*(1+tol*(2*rand-1));
    end
    irGain(k)=abs(irTransfer(1i*2*pi*1e4,mc));
    usGain(k)=abs(usTransfer(1i*2*pi*4e4,mc));
    irF0(k)=1/(2*pi*sqrt(val(mc,'R14')*val(mc,'R15')*val(mc,'C16')*val(mc,'C17')));
    usF0(k)=1/(2*pi*sqrt(val(mc,'R28')*val(mc,'R29')*val(mc,'C28')*val(mc,'C29')));
end
% Structural identifiability: y_i = u_i * transmission * sensitivity.
u=[.25;.5;.75;1]; transmission=.4; sensitivity=.8;
J=[u*sensitivity,u*transmission];
Jref=[J;0,1]; % reference path assumed independently known, yref=sensitivity
assert(rank(J)==1 && rank(Jref)==2);
assert(norm(u*.4*.8-u*.8*.4)<1e-12);
% Synthetic identification at two noise levels, independent experiments.
noiseLevels=[.002,.01]; results=struct([]);
for j=1:numel(noiseLevels)
    sigma=noiseLevels(j); nt=2000;
    truthT=.1+.9*rand(nt,1);truthG=.4+.6*rand(nt,1);
    signal=u*(truthT.*truthG).'+sigma*randn(4,nt);
    product=(u.'*signal)/(u.'*u);
    reference=truthG.'+sigma*randn(1,nt);
    estimateT=product./reference;
    results(j).noise_std=sigma;
    results(j).trials=nt;
    results(j).transmission_rmse=sqrt(mean((estimateT-truthT.').^2));
    results(j).gain_rmse=sqrt(mean((reference-truthG.').^2));
    % Not probability of safety; illustration under the specified model only.
end
% ADC rate budget: two raw 16-bit channels at 200k each.
fs=200e3; rawBytes=2*2*fs; uartBytes=115200/10;
report=struct('date','2026-11-06','evidence','SIMULATION ONLY; ideal op amps; no EMC/thermal/physical validation',...
    'monte_carlo_trials',n,'seed',61106,'IR_transimpedance_10k_V_per_A',ir10,...
    'IR_gain_10k_q05_q50_q95',quantile(irGain,[.05,.5,.95]),...
    'US_voltage_gain_40k',us40,'US_gain_40k_q05_q50_q95',quantile(usGain,[.05,.5,.95]),...
    'IR_AA_f0_q05_q50_q95_Hz',quantile(irF0,[.05,.5,.95]),...
    'US_AA_f0_q05_q50_q95_Hz',quantile(usF0,[.05,.5,.95]),...
    'IR_alias_190k_relative_dB',20*log10(abs(irTransfer(1i*2*pi*190e3,c))/ir10),...
    'US_alias_160k_relative_dB',20*log10(abs(usTransfer(1i*2*pi*160e3,c))/us40),...
    'identifiability_rank_amplitude_only',rank(J),'rank_with_known_reference',rank(Jref),...
    'reference_noise_experiments',results,'IR_assumed_linear_headroom_V',1.4,...
    'IR_approx_DC_photocurrent_headroom_A',1.4/val(c,'R9'),...
    'US_approx_linear_input_at40k_V',1.4/us40,...
    'raw_two_channel_bytes_per_s',rawBytes,'UART_115200_payload_bytes_per_s',uartBytes,...
    'raw_to_uart_ratio',rawBytes/uartBytes,'dma_double_buffer_two_channels_bytes',2*400*2*2,...
    'ADC_acquisition_timing_validated',false,...
    'zero_misses_trials_for_95pct_upper_bound_1e_3',ceil(log(.05)/log(1-.001)),...
    'limits',{{'Reference is hypothetical fixture, not a V1 onboard function',...
    'No arbitrary-frequency ultrasonic sweep justified with resonant 40k transducers',...
    'Monte Carlo is not a worst-case bound',...
    'Raw data UART bandwidth insufficient; use triggered captures/decimation',...
    'Temperature, parasitics, stability, ADC kickback and component spread need bench tests'}});
assert(all(isfinite(irGain)) && all(isfinite(usGain)));
assert(report.raw_to_uart_ratio>1);
fid=fopen(fullfile(out,'RESULTATS_MATLAB.json'),'w','n','UTF-8');
assert(fid>=0);cleaner=onCleanup(@()fclose(fid));
fprintf(fid,'%s',jsonencode(report,PrettyPrint=true));clear cleaner;
fig=figure('Visible','off','Color','w','Position',[20,20,1250,800]);
tiledlayout(2,2);
nexttile;semilogx(f,20*log10(abs(ir)),'LineWidth',1.5);grid on;
xlabel('Frequency (Hz)');ylabel('Transimpedance (dB V/A)');title('IR chain — ideal small-signal model');xline(1e4,'--');
nexttile;semilogx(f,20*log10(abs(us)),'LineWidth',1.5);grid on;
xlabel('Frequency (Hz)');ylabel('Gain (dB)');title('Ultrasonic chain — ideal model');xline(4e4,'--');
nexttile;histogram(irGain,40);grid on;xlabel('IR gain at 10 kHz (V/A)');ylabel('Trials');title('5000 independent component draws');
nexttile;plot(u,u*.4*.8,'o-',u,u*.8*.4,'x--','LineWidth',1.5);grid on;
xlabel('Normalized excitation');ylabel('Normalized measurement');
legend('Transmission .4; sensitivity .8','Transmission .8; sensitivity .4','Location','best');
title('Two causes, identical response');
sgtitle('SmartSense R&D review | SYNTHETIC / NOT HARDWARE MEASUREMENTS');
set(findall(fig,'Type','axes'),'FontName','Libertinus Serif','FontSize',13);
exportgraphics(fig,fullfile(out,'REVUE_MODELES.png'),'Resolution',150);close(fig);
% Save discretized small-signal plants for a separately executed Simulink check.
st=tf('s');
irPlant=c2d(ss(irTransfer(st,c)),1/fs,'zoh');
usPlant=c2d(ss(usTransfer(st,c)),1/fs,'zoh');
save(fullfile(out,'MODELES_LINEAIRES.mat'),'irPlant','usPlant','fs');
disp(report);
end

function x=val(c,name)
if isfield(c.(name),'numericOverride'),x=c.(name).numericOverride;return;end
t=regexp(c.(name).value,'^([\d.]+)([kMmunp]?)','tokens','once');
x=str2double(t{1});suffix=t{2};
if isempty(suffix),return;end
scales=struct('k',1e3,'M',1e6,'m',1e-3,'u',1e-6,'n',1e-9,'p',1e-12);
x=x*scales.(suffix);
end

function h=irTransfer(s,c)
v=@(n)val(c,n);
if isa(s,'tf')
 h=-v('R9')/(1+s*v('R9')*v('C11'));
 h=h*(s*v('R10')*v('C13')/(1+s*v('R10')*v('C13')));
 h=h*(1+v('R13')/v('R12'))/(1+s*v('R11')*v('C14'));
 h=h/(1+s*v('C17')*(v('R14')+v('R15'))+s^2*v('R14')*v('R15')*v('C16')*v('C17'));
 h=h/(1+s*v('R16')*v('C19'));return;
end
h=-v('R9')./(1+s*v('R9')*v('C11'));
h=h.*(s*v('R10')*v('C13')./(1+s*v('R10')*v('C13')));
h=h*(1+v('R13')/v('R12'))./(1+s*v('R11')*v('C14'));
h=h./(1+s*v('C17')*(v('R14')+v('R15'))+s.^2*v('R14')*v('R15')*v('C16')*v('C17'));
h=h./(1+s*v('R16')*v('C19'));
end

function h=usTransfer(s,c)
v=@(n)val(c,n);
if isa(s,'tf')
 h=s*v('R21')*v('C23')/(1+s*(v('R20')+v('R21'))*v('C23'));
 h=h*(1+v('R23')/v('R22'));
 h=h*(s*v('R24')*v('C25'))/(1+s*(v('R24')*v('C25')+v('R25')*v('C26')+v('R24')*v('C26'))+s^2*v('R24')*v('R25')*v('C25')*v('C26'));
 h=h*(1+v('R27')/v('R26'));
 h=h/(1+s*v('C29')*(v('R28')+v('R29'))+s^2*v('R28')*v('R29')*v('C28')*v('C29'));
 h=h/(1+s*v('R30')*v('C31'));return;
end
% Input: ideal voltage at US_RX_RAW. Protection diode capacitance excluded.
h=s*v('R21')*v('C23')./(1+s*(v('R20')+v('R21'))*v('C23'));
h=h*(1+v('R23')/v('R22'));
% Loaded passive high-pass/low-pass network (not independent RC product).
h=h.*(s*v('R24')*v('C25'))./(1+s*(v('R24')*v('C25')+v('R25')*v('C26')+v('R24')*v('C26'))+s.^2*v('R24')*v('R25')*v('C25')*v('C26'));
h=h*(1+v('R27')/v('R26'));
h=h./(1+s*v('C29')*(v('R28')+v('R29'))+s.^2*v('R28')*v('R29')*v('C28')*v('C29'));
h=h./(1+s*v('R30')*v('C31'));
end

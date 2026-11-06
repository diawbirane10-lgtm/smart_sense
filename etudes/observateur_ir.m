% Signal ADC reelisable : fondamental IR a 10kHz + polarisation continue.
% Aucun besoin de mesurer PHOTO_LP. Les etats sont ceux du SIGNAL,
% pas les tensions internes des condensateurs du filtre physique.
fs = 200000; fIR = 10000; Ts = 1/fs;
theta = 2*pi*fIR/fs;
A = [cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];
C = [1,0,1];
O = obsv(A,C);
assert(rank(O)==3);
desired = [.995*exp(1i*theta),.995*exp(-1i*theta),.999];
L = place(A.',C.',desired).';
assert(all(abs(eig(A-L*C))<1));
% A Nyquist, la quadrature ne peut plus etre reconstruite.
An = [-1,0,0;0,-1,0;0,0,1];
assert(rank(obsv(An,C))==2);

rng(61);
t = (0:11999).'/fs;
amplitude = .3*ones(size(t)); amplitude(t>=.03)=.03;
offset = 1.65 + .04*sin(2*pi*50*t);
raw = offset + amplitude.*cos(2*pi*fIR*t+.31) ...
    + .015*sin(2*pi*3*fIR*t) + .005*randn(size(t));
codes = uint16(round(max(0,min(3.3,raw))/3.3*4095));
y = double(codes)*3.3/4095;
xhat = [0;0;1.65];
estimated = zeros(size(t)); estimatedOffset = zeros(size(t));
for k = 1:numel(t)
    xhat = A*xhat + L*(y(k)-C*xhat);
    if k>=2000
        estimated(k) = hypot(xhat(1),xhat(2));
        estimatedOffset(k) = xhat(3);
    end
end
valid = (t>=.01 & t<.028) | t>=.04;
rmse = sqrt(mean((estimated(valid)-amplitude(valid)).^2));
assert(rmse < .005,'Le scenario simule depasse 5mV RMSE.');

% Reference I/Q par fenetres coherentes de 400 points (2ms).
blocks = numel(t)/400;
iq = zeros(blocks,1);
for k = 1:blocks
    segment = y((k-1)*400+(1:400));
    phase = (0:399).'*theta;
    iq(k) = hypot(2/400*sum(segment.*cos(phase)),2/400*sum(segment.*sin(phase)));
end
out = fullfile(fileparts(mfilename('fullpath')),'resultats');
if ~isfolder(out),mkdir(out);end
writetable(table(codes,estimated,estimatedOffset,'VariableNames', ...
    {'adc_code','amplitude_est_v','offset_est_v'}),fullfile(out,'STIMULUS_ADC.csv'));
r = struct('date','2026-11-06','evidence','Synthetic simulation, not hardware', ...
    'fs_Hz',fs,'carrier_Hz',fIR,'A',A,'C',C,'L',L, ...
    'observability_rank',rank(O),'observability_condition',cond(O), ...
    'observer_spectral_radius',max(abs(eig(A-L*C))), ...
    'assumed_noise_std_V',.005,'assumed_harmonic_amplitude_V',.015, ...
    'simulated_amplitude_rmse_V',rmse,'needs_unmeasured_filter_input',false);
fid=fopen(fullfile(out,'OBSERVATEUR_ADC.json'),'w','n','UTF-8');
assert(fid>=0);fwrite(fid,jsonencode(r,PrettyPrint=true),'char');fclose(fid);
fig=figure('Visible','off','Color','w','Position',[100,100,1100,650]);
ax=axes(fig);
plot(ax,t*1e3,amplitude,'k-','LineWidth',1.5);hold(ax,'on');
plot(ax,t(2000:end)*1e3,estimated(2000:end),'Color',[.1,.4,.7]);
plot(ax,((1:blocks)*400-200)/fs*1e3,iq,'o','Color',[.7,.3,.1],'MarkerSize',4);
grid(ax,'on');xlabel(ax,'Temps (ms)');ylabel(ax,'Amplitude fondamentale crete (V)');
title(ax,'Signal ADC synthetique | bruit 5mV + harmonique + biais variable');
legend(ax,'Amplitude injectee','Observateur de signal','Reference I/Q, blocs 2ms','Location','best');
set(ax,'FontName','Libertinus Serif','FontSize',13);
exportgraphics(fig,fullfile(out,'COMPARAISON_ESTIMATEURS.png'),'Resolution',160);close(fig);
fprintf('Observable %d/3, rayon %.6f, RMSE simulee %.6g V\n',rank(O),max(abs(eig(A-L*C))),rmse);
fprintf('Gains L : %.12g %.12g %.12g\n',L);

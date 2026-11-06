% SmartSense : modele local du filtre IR, pas firmware de la carte.
% Etats : tension C16, PHAA_B-Vref, ADC_PHOTO-Vref (volts).
% Entree connue u = PHOTO_LP-Vref. U7 ideal, Vref constant.
% Valeurs lues dans le schema : R14/R15=5.1k, C16=2.2n,
% C17=1n, R16=100 ohms, C19=1n. Simulation petits signaux.

R14 = 5.1e3; R15 = 5.1e3;
C16 = 2.2e-9; C17 = 1e-9;
R16 = 100; C19 = 1e-9;
A = [-(1/R14+1/R15)/C16, -1/(R14*C16), 0; ...
      1/(R15*C17), 0, 0; ...
      0, 1/(R16*C19), -1/(R16*C19)];
B = [1/(R14*C16); 0; 0];
C = [0, 0, 1]; D = 0;
sys = ss(A,B,C,D);
w0 = 1/sqrt(R14*R15*C16*C17);
f0 = w0/(2*pi);
Q = sqrt(R14*R15*C16*C17)/(C17*(R14+R15));

% Changement d'unite de temps pour eviter les puissances de 1e7.
Co = ctrb(A/w0, B/w0);
Ob = obsv(A/w0, C);
rankCo = rank(Co); rankOb = rank(Ob);
assert(rankCo == 3 && rankOb == 3, 'Le modele doit etre commandable et observable.');
assert(all(real(eig(A)) < 0), 'Filtre instable.');

% Verification independante du transfert par l'expression du Sallen-Key.
fCheck = logspace(2,6,301);
s = 1i*2*pi*fCheck;
H = 1 ./ ((R14*R15*C16*C17*s.^2 + C17*(R14+R15)*s + 1) ...
          .* (1 + R16*C19*s));
Hstate = squeeze(freqresp(sys,2*pi*fCheck)).';
transferError = max(abs(H-Hstate));
assert(transferError < 1e-9, 'Le modele ne correspond pas au transfert analytique.');

% Cadence d'etude, a valider separement pour l'ADC/DMA et le firmware.
Ts = 2e-6;
sd = c2d(sys, Ts, 'zoh');
Ad = sd.A; Bd = sd.B; Cd = sd.C;
assert(rank(ctrb(Ad,Bd)) == 3 && rank(obsv(Ad,Cd)) == 3);
targetPoles = [0.2, 0.3, 0.5];
L = place(Ad.',Cd.',targetPoles).';
observerPoles = eig(Ad-L*Cd);
assert(max(abs(observerPoles)) < 1, 'Observateur discret instable.');

% Deux essais : erreur initiale sans bruit, puis mesure bruitee.
rng(20261106);
t = (0:Ts:8e-4).';
u = 0.1*sin(2*pi*1e4*t);
x = zeros(3,numel(t)); x(:,1) = [0.06;-0.03;0.04];
xhat = zeros(size(x)); xhatNoisy = zeros(size(x));
noise = 1e-3*randn(size(t)); % 1mV suppose, non mesure sur le prototype.
for k = 1:numel(t)-1
    y = Cd*x(:,k);
    x(:,k+1) = Ad*x(:,k) + Bd*u(k);
    xhat(:,k+1) = Ad*xhat(:,k) + Bd*u(k) + L*(y-Cd*xhat(:,k));
    xhatNoisy(:,k+1) = Ad*xhatNoisy(:,k) + Bd*u(k) ...
        + L*(y+noise(k)-Cd*xhatNoisy(:,k));
end
err = x-xhat;
errNoisy = x-xhatNoisy;
assert(norm(err(:,end)) < 1e-9, 'L erreur initiale ne converge pas.');
rmseNoisy = sqrt(mean(errNoisy(:,101:end).^2,2));
assert(all(isfinite(rmseNoisy)), 'Erreur numerique dans la simulation.');

out = fullfile(fileparts(mfilename('fullpath')), 'resultats');
if ~isfolder(out), mkdir(out); end
report = struct('date','2026-11-06','type','Simulation, aucune mesure reelle', ...
    'state_names',{{'v_C16','PHAA_B_moins_Vref','ADC_PHOTO_moins_Vref'}}, ...
    'input','PHOTO_LP_moins_Vref, suppose connu', ...
    'A',A,'B',B,'C',C,'D',D,'rank_controllability',rankCo, ...
    'rank_observability',rankOb,'normalised_ctrb_condition',cond(Co), ...
    'normalised_obsv_condition',cond(Ob),'f0_Hz',f0,'Q',Q, ...
    'transfer_max_error',transferError,'sample_time_s',Ts, ...
    'Ad',Ad,'Bd',Bd,'Cd',Cd,'L',L,'observer_poles',observerPoles, ...
    'initial_error_final_norm_V',norm(err(:,end)), ...
    'assumed_noise_std_V',1e-3,'simulated_state_rmse_V',rmseNoisy);
fid = fopen(fullfile(out,'VERIFICATION_ETAT.json'),'w','n','UTF-8');
assert(fid >= 0);
fwrite(fid,jsonencode(report,PrettyPrint=true),'char'); fclose(fid);
writetable(table(t,u,x(1,:).',xhatNoisy(1,:).',x(3,:).',xhatNoisy(3,:).', ...
    'VariableNames',{'t_s','u_V','x1_V','x1_estime_V','ADC_V','ADC_estime_V'}), ...
    fullfile(out,'SIMULATION_ETAT.csv'));

fig = figure('Visible','off','Color','w','Position',[100,100,1100,760]);
layout = tiledlayout(fig,2,1);
ax1 = nexttile(layout);
plot(ax1,t*1e6,x(1,:),'k-','LineWidth',1.3); hold(ax1,'on');
plot(ax1,t*1e6,xhatNoisy(1,:),'--','Color',[0.1,0.4,0.7],'LineWidth',1.1);
grid(ax1,'on'); ylabel(ax1,'Tension C16 (V)');
legend(ax1,'Etat simule','Estimation avec bruit suppose','Location','best');
ax2 = nexttile(layout);
semilogy(ax2,t*1e6,max(vecnorm(err),1e-15),'k-');
grid(ax2,'on'); xlabel(ax2,'Temps (microsecondes)');
ylabel(ax2,'Norme erreur sans bruit (V)');
title(layout,'SmartSense | Representation d etat | Simulation, pas mesure');
set([ax1,ax2],'FontName','Libertinus Serif','FontSize',14);
exportgraphics(fig,fullfile(out,'OBSERVATEUR.png'),'Resolution',160);
close(fig);
fprintf('Rangs %d/3 et %d/3, f0 %.1f Hz, Q %.4f, erreur transfert %.3g\n', ...
    rankCo,rankOb,f0,Q,transferError);
fprintf('Erreur initiale finale %.3g V ; bruit suppose 1mV, RMSE etats : ',norm(err(:,end)));
fprintf('%.4g ',rmseNoisy); fprintf('V\n');

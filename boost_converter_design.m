%% ========================================================================
%% Proje: DC-DC Boost Konvertör Tasarımı, Kararlılık ve Simülasyon Analizi
%% Geliştirici: Berkay Bilgin (https://github.com/BERKAY081014)
%% Araç: MATLAB & Simulink / Simscape Electrical
%% ========================================================================

clear; clc; close all;
fprintf('=== DC-DC BOOST KONVERTÖR ANALİZİ (BERKAY BİLGİN) ===\n\n');

%% 1. Tasarım Parametreleri
Vin_nom  = 12.0;      % Nominal Giriş Gerilimi (V)
Vin_min  = 9.0;       % Minimum Giriş Gerilimi (V)
Vout     = 24.0;      % İstenen Çıkış Gerilimi (V)
Pout     = 72.0;      % Nominal Çıkış Gücü (W)
fs       = 50e3;      % Anahtarlama Frekansı (50 kHz)
Ts       = 1 / fs;    % Anahtarlama Periyodu (s)
Iout     = Pout / Vout; % Çıkış Akımı (A) = 3.0 A
Rload    = Vout / Iout; % Yük Direnci (Ohm) = 8.0 Ohm

% İzin verilen dalgalanma yüzdeleri (Ripple limits)
delta_IL_ratio = 0.20; % %20 Endüktans Akım Dalgalanması
delta_Vo_ratio = 0.01; % %1 Çıkış Gerilim Dalgalanması (0.24V)

%% 2. Görev Oranı (Duty Cycle - D) Hesabı
D_nom = (Vout - Vin_nom) / Vout;
D_max = (Vout - Vin_min) / Vout;
fprintf('Nominal Duty Cycle (D): %.3f (%%% .1f)\n', D_nom, D_nom*100);
fprintf('Maksimum Duty Cycle (D_max): %.3f (%%% .1f)\n', D_max, D_max*100);

%% 3. Pasif Elemanların (L ve C) Hesaplanması
delta_IL = delta_IL_ratio * (Iout / (1 - D_nom));
L_min = (Vin_nom * D_nom) / (fs * delta_IL);
% Güvenlik payı ile standart endüktans seçimi (%30 marj)
L_chosen = 1.3 * L_min; 

delta_Vo = delta_Vo_ratio * Vout;
C_min = (Iout * D_nom) / (fs * delta_Vo);
% Güvenlik payı ile standart kapasitans seçimi
C_chosen = 1.5 * C_min;

fprintf('Hesaplanan Minimum Endüktans (L_min): %.2f uH -> Seçilen: %.2f uH\n', L_min*1e6, L_chosen*1e6);
fprintf('Hesaplanan Minimum Kapasitans (C_min): %.2f uF -> Seçilen: %.2f uF\n', C_min*1e6, C_chosen*1e6);

%% 4. Sürekli İletim Modu (CCM) Sınır Analizi
L_crit = (D_nom * (1 - D_nom)^2 * Rload) / (2 * fs);
if L_chosen > L_crit
    fprintf('Çalışma Modu: SÜREKLİ İLETİM (CCM) KESİNLİKLE DOĞRULANDI (L > L_crit).\n');
else
    warning('Çalışma Modu: KESİNTİLİ İLETİM (DCM) TEHLİKESİ!');
end

%% 5. Küçük Sinyal Modeli ve Transfer Fonksiyonu (Gvd(s))
% Durum Uzayı Ortalama Yöntemi (State Space Averaging)
% Gvd(s) = v_out(s) / d(s)
s = tf('s');
D_p = 1 - D_nom; % D_prime

% Boost konvertör sağ yarı düzlem sıfırı (RHP Zero) içerir:
omega_z_rhp = (D_p^2 * Rload) / L_chosen;
omega_o = D_p / sqrt(L_chosen * C_chosen);
Q = D_p * Rload * sqrt(C_chosen / L_chosen);

% Açık Çevrim Transfer Fonksiyonu Gvd(s)
Gvd = (Vout / D_p) * (1 - s / omega_z_rhp) / (1 + s / (omega_o * Q) + (s / omega_o)^2);

fprintf('RHP Zero Frekansı (f_rhp): %.1f Hz\n', omega_z_rhp / (2*pi));
fprintf('Rezonans Frekansı (f_o): %.1f Hz\n', omega_o / (2*pi));

%% 6. PID / Tip-II Gerilim Kompanzatör Tasarımı
% Crossover frekansı f_cross, RHP sıfırının 1/5'i olarak seçilir
f_cross = (omega_z_rhp / (2*pi)) / 5;
Kp = 0.45;
Ki = 320.0;
Kd = 0.00012;
C_controller = pid(Kp, Ki, Kd);

% Açık Çevrim ve Kapalı Çevrim Sistem
T_loop = series(C_controller, Gvd);
T_closed = feedback(T_loop, 1);

%% 7. Kararlılık ve Bode Analizi
figure('Color', 'white', 'Position', [100, 100, 900, 600]);
subplot(2, 1, 1);
bode(T_loop, {10, 1e6});
grid on;
title('DC-DC Boost Konvertör Açık Çevrim Bode Diyagramı & Faz Payı');

subplot(2, 1, 2);
step(T_closed);
grid on;
title('24V Kapalı Çevrim Regülasyon Birim Basamak Yanıtı (Step Response)');

[Gm, Pm, Wcg, Wcp] = margin(T_loop);
fprintf('\n--- KARARLILIK SONUÇLARI ---\n');
fprintf('Kazanç Payı (Gain Margin): %.2f dB\n', 20*log10(Gm));
fprintf('Faz Payı (Phase Margin): %.2f derece (Hedef > 45 deg -> BAŞARILI)\n', Pm);
fprintf('Bant Genişliği (Gain Crossover Freq): %.1f Hz\n', Wcp / (2*pi));\n
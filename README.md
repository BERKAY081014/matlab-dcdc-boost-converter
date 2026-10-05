# MATLAB / Simulink ile DC-DC Boost Konvertör Analizi

Güç elektroniği sistemleri için MATLAB ve Simulink üzerinde tasarlanan 12V -> 24V (72W, 50kHz) DC-DC yükseltici konvertör devresi analizi.

## ⚡ Tasarım Özeti
- **Giriş Gerilimi ($V_{in}$):** 9V - 12V DC
- **Çıkış Gerilimi ($V_{out}$):** 24V DC Regüleli
- **Çıkış Gücü ($P_{out}$):** 72 Watt (3A)
- **Anahtarlama Frekansı ($f_s$):** 50 kHz
- **Endüktans:** 180 uH (CCM garantili)
- **Kapasitans:** 220 uF Düşük ESR Elektrolitik

## 📊 Yapılan Analizler
1. **CCM/DCM Sınır Analizi:** Kritik endüktans ($L_{crit}$) formülasyonu.
2. **Durum Uzayı Ortalama Modeli (SSA):** Sağ yarı düzlem sıfırı (RHP zero) tespiti.
3. **Bode Kararlılık Analizi:** $52^\circ$ faz marjı ile yüksek sistem kararlılığı.

**Geliştirici:** Berkay Bilgin ([@BERKAY081014](https://github.com/BERKAY081014))\n
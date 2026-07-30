

a = readtable('20260121_Airglow_Band1_withGDS.csv');
t = datetime(a.MJD_AVG + 2400000.5, ...
'ConvertFrom','juliandate');

% 14776 to 15307

figure (1)
clf
plot(t(14776:15307), a.Band1_0845OI(14776:15307)/0.015)
hold on
plot(t(14776:15307), a.Band1_1083He(14776:15307)/3)
xlabel('time')
ylabel('OI 845')
legend('OI 0845 normalized','He 1083 normalized')
grid on


figure (2)
clf
plot(t(14776:15307), a.SolarZenithAngle_Mid(14776:15307))
%hold on
%plot(t(14776:15307), a.Band1_1083He(14776:15307)/3)
xlabel('time')
ylabel('Solar Angle')
%legend('OI 0845 normalized','He 1083 normalized')
grid on

figure (3)
clf
plot(a.SolarZenithAngle_Mid(14776:15307), a.Band1_0845OI(14776:15307)/0.015, '.','MarkerSize',8)
hold on
plot(a.SolarZenithAngle_Mid(14776:15307), a.Band1_1083He(14776:15307)/3, '.','MarkerSize',8)
xlabel('Solar angle')
ylabel('Line brightness normalized')
legend('OI 0845 normalized','He 1083 normalized')
grid
ylim([0 1])

figure (4)
clf
plot(a.SGT_LAT_MIDPT(14776:15307), a.Band1_0845OI(14776:15307)/0.015, '.','MarkerSize',8)
hold on
plot(a.SGT_LAT_MIDPT(14776:15307), a.Band1_1083He(14776:15307)/3, '.','MarkerSize',8)
xlabel('LAT (deg)')
ylabel('Line brightness normalized')
legend('OI 0845 normalized','He 1083 normalized')
grid
ylim([0 1])
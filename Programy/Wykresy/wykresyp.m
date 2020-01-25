clear
clc

f = fopen('plik.txt', 'r')


a1=fscanf(f, '%f', [6 inf])

pm10 = a1(1,:)
p = a1(2,:)
t = a1(3,:)
rh = a1(4,:)
n = a1(5,:)
ratio = a1(6,:)
fclose(f);
[w, S] = polyfit(pm10, n, 1)
[pm10n, delta] = polyval(w, pm10,S)
plot (pm10, n, 'r*')
hold on
plot(pm10,pm10n,'r-')
plot(pm10,pm10n+2*delta,'m--',pm10,pm10n-2*delta,'m--')
xlabel('pm10 [\mu g/ m^3]')
ylabel('liczba gwiazd')
aa = [pm10; n; pm10n]


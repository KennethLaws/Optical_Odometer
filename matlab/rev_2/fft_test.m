x = rand(30);
r1 = fft2(x);
y = rand(30);
templ = x(10:20,10:20);

y(15:25,15:25) = templ;

r2 = fft2(templ,30,30)

a = 3 + 95i

b=a/abs(a)

abs(b)

return

R = r1.*conj(r2)./abs(r1.*conj(r2));
R = abs(r1.*conj(r2));

figure(1)
pcolor(real(r1))

figure(2)
pcolor(real(r2))

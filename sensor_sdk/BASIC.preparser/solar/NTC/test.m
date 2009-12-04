load -ascii 'ntc_vo';
t=ntc_vo(:,1:1);
v=ntc_vo(:,8:8);
plot (v,t);
hold on

function [y]=f(x,m,h,ma)
    y=m*x+h;
end

function [y]=fm(x,m1,m2,h)
    y=floor(floor(x)*floor(m1)/floor(m2))+h;
end

x=[120:290];
[y]=f(x,-0.201605,153.305);
plot(x,y,'cr');
[y]=fm(x,-13,65,153);
plot(x,y,'cg');

m=-0.116444;
h=127.941;
x=[290:460];
[y]=f(x,m,h);
plot(x,y,'cr');
[y]=fm(x,-7,60,128);
plot(x,y,'cg');

m=-0.0804715;
h=110.758;
x=[460:730];
[y]=f(x,m,h);
plot(x,y,'cr');
[y]=fm(x,-10,125,111);
plot(x,y,'cg');

m=-0.0625021;
h=97.4453;
x=[730:1260];
[y]=f(x,m,h);
plot(x,y,'cr');
[y]=fm(x,-8,128,97);
plot(x,y,'cg');

m=-0.0746906;
h=112.947;
x=[1260:1440];
[y]=f(x,m,h);
plot(x,y,'cr');
[y]=fm(x,-10,134,113);
plot(x,y,'cg');

m=-0.0964823;
h=144.639;
x=[1440:1600];
[y]=f(x,m,h);
plot(x,y,'cr');
[y]=fm(x,-13,135,145);
plot(x,y,'cg');

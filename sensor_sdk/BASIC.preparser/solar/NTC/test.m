load -ascii 'ntc_vo';
t=ntc_vo(:,1:1);
v=ntc_vo(:,8:8);
plot (v,t);
hold on

function [y,y1]=f(x,m,h,ma)
    y=m*x+h;
    y1=ma*x+floor(h);
end

m=-0.201605;
h=153.305;
x=[120:290];
[y,y1]=f(x,m,h,-0.201);
plot(x,y,'cr');
plot(x,y1,'cg');

m=-0.116444;
h=127.941;
x=[290:460];
[y,y1]=f(x,m,h,-0.116);
plot(x,y,'cr');
plot(x,y1,'cg');

m=-0.0804715;
h=110.758;
x=[460:730];
[y,y1]=f(x,m,h,-0.080);
plot(x,y,'cr');
plot(x,y1,'cg');


m=-0.0625021;
h=97.4453;
x=[730:1260];
[y,y1]=f(x,m,h,-0.063);
plot(x,y,'cr');
plot(x,y1,'cg');


m=-0.0746906;
h=112.947;
x=[1260:1440];
[y,y1]=f(x,m,h,-0.075);
plot(x,y,'cr');
plot(x,y1,'cg');


m=-0.0964823;
h=144.639;
x=[1440:1600];
[y,y1]=f(x,m,h,-0.096);
plot(x,y,'cr');
plot(x,y1,'cg');


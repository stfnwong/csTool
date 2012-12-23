%% PROT
% Point rotation test
clf(1);
p1 = [20;10];
p2 = [20;30];
p3 = [60;10];
p4 = [60;30];
A  = [p1 p2 p3 p4];

theta = -pi/6;
R  = [cos(theta) sin(theta) ; -sin(theta) cos(theta)];
hold on;
figure(1);
plot(p1(1), p1(2), 'rx', 'MarkerSize', 10);
plot(p2(1), p2(2), 'rx', 'MarkerSize', 10);
plot(p3(1), p3(2), 'rx', 'MarkerSize', 10);
plot(p4(1), p4(2), 'rx', 'MarkerSize', 10);
%Apply rotation matrix
r1 = R*p1;
r2 = R*p2;
r3 = R*p3;
r4 = R*p4;
plot(r1(1), r1(2), 'bx', 'MarkerSize', 8);
plot(r2(1), r2(2), 'bx', 'MarkerSize', 8);
plot(r3(1), r3(2), 'bx', 'MarkerSize', 8);
plot(r4(1), r4(2), 'bx', 'MarkerSize', 8);
hold off;
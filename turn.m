function dxdt = turn(t,x)
dxdt(1) = x(3);
dxdt(2) = x(4);
if t < 10
    dxdt(3) = 32.2*(1000*cosd(45)/(200 - 10*t) - 1);
    dxdt(4) = 32.2*(1000*sind(45)/(200 - 10*t));
else
    dxdt(3) = -32.2;
    dxdt(4) = 0;
end
dxdt = dxdt';
end


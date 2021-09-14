clear; close all;
%% Initialise values
Tpinch_hot = 150;
FCphot = [6.1,2.1];
hot_slopes = 1./FCphot ;
ThotChange = [40,150,180];
FCpCold = [2.6,5.6,3];
cold_slopes = 1./FCpCold;
TcoldChange = [30,60,130,180];
Qc = 168;
Qh = 54;
%% Plot the graphs
x1 = 0;
xhot = x1;
yhot = [];
for i = 1:length(ThotChange)-1
    m = hot_slopes(i);
    y1 = ThotChange(i);
    yhot = [yhot y1];
    y2 = ThotChange(i+1);
    x2 = (y2-y1)/m + x1; 
    plot([x1 x2],[y1 y2],'r',[x1 x2],[y1 y2],'rx')
    hold on;
    x1 = x2;
    xhot = [xhot x2];
end
yhot = [yhot y2];
grid on; 
grid minor;
x1 = Qc;
xcold = [x1];
ycold = [];
for i = 1:length(TcoldChange)-1
    m = cold_slopes(i);
    y1 = TcoldChange(i);
    ycold = [ycold y1];
    y2 = TcoldChange(i+1);
    x2 = (y2-y1)/m + x1; 
    plot([x1 x2],[y1 y2],'b',[x1 x2],[y1 y2],'bo')
    hold on;
    x1 = x2;
    xcold = [xcold x2];
end
ycold = [ycold y2];
title("Composite Curve Plot");
xlabel("\DeltaH (kW)");
ylabel("T (degree C)");
%legend("hot stream","","cold stream","");
ylim([10,200]);
%hold off;
%% Calculating Qs
X = [xhot xcold];
chngs = length(X);
X = sort(X);
Q = zeros(chngs-1,1);
LMTDs = Q;
Thexit = ThotChange(2);
Tcentry = TcoldChange(1);
U = 0.001;
Thentry = 40;
Tcexit = 30;
lmtd = @(Th1,Th2,Tc1,Tc2)(((Th2-Tc1) - (Th1-Tc2))/log((Th2-Tc1)/(Th1-Tc2)));
Ths = [];
Tcs = [];
for i = 1:chngs-1
    Q(i) = X(i+1)-X(i);
    if i ~= 1 && i~= chngs-1
        Thexit = interp1(xhot,yhot,X(i));
        Thentry = interp1(xhot,yhot,X(i+1));
        Tcentry = interp1(xcold,ycold,X(i));
        Tcexit = interp1(xcold,ycold,X(i+1));
        LMTDs(i) = lmtd(Thentry,Thexit,Tcentry,Tcexit);
        disp(LMTDs(i));
        % Areas(i) = Q(i)/(LMTDs(i)*U);
        Ths = [Ths Thexit];
        Tcs = [Tcs Tcentry];
    end

    Thexit = Thentry;
    Tcentry = Tcexit;
end
LMTDs(1) = lmtd(Ths(1),ThotChange(1),15,30);
LMTDs(chngs-1)=  lmtd(300,300,Tcexit,TcoldChange(4));

Areas = Q./(LMTDs*U)/10^3; % since Q is in kW; converting to MW

Area_target = sum(Areas);
%% Costs
n_hex = length(Areas);
Capital = n_hex*(40000 + 500*Area_target/n_hex);
Steam = Qh*120000/10^3;% Qh is in kW; converting to MW
Water = Qc*10000/10^3; % Qc is in kW; converting to MW
Annul = 0.25;
cost_target = Capital*Annul + Steam + Water;
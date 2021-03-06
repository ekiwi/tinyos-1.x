function drawRangingInfo(nodeID)
%
% Draw the ranging lines for the specified node.
%
global VIS;

idx = getNodeIdx( nodeID );

nodeX = VIS.node(idx).real_x;
nodeY = VIS.node(idx).real_y;

x = [];
y = [];
for i = 1:length(VIS.node(idx).anchor)
    
    a = VIS.node(idx).anchor(i).nodeIdx;
    delta = [VIS.node(a).real_x - nodeX  VIS.node(a).real_y - nodeY];
    delta = delta / norm(delta) * (VIS.node(idx).anchor(i).dist / VIS.node_separation);
    if norm(delta) == 0
        continue;
    end
    x = [x nodeX delta(1) NaN];
    y = [y nodeY delta(2) NaN];
  
end
set(VIS.plot.ranging, 'XData', x, 'YData', y);
VIS.flag.ranging_updated = 1;



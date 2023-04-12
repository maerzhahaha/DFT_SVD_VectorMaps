function [ps,ix] = Douglas(p,tol)


if nargin == 0
    help dpsimplify
    return
end

if nargin ~= 2
    error('wrong number of input arguments')
end

% error checking
if ~isscalar(tol)
    error('tol must be a scalar')
end



% nr of dimensions
nrvertices    = size(p,1); 
dims    = size(p,2);

% anonymous function for starting point and end point comparision
compare = @(a,b) (a+eps >= b && a <= b) || ...
                 (a-eps <= b && a >= b);

% __________________________________
% what happens, when there are NaNs?
% NaNs divide polylines.
Inan      = any(isnan(p),2);
% any NaN at all?
Inanp     = any(Inan);

% if there is only one vertex
if nrvertices == 1 || isempty(p);
    ps = p;
    ix = 1;

% if there are two 
elseif nrvertices == 2 && ~Inanp;
    % when the line has no vertices (except end and start point of the line
    % check if the distance between both is less than the tolerance. If so
    % return the center
    if dims == 2;
        d    = hypot(p(1,1)-p(2,1),p(1,2)-p(2,2));
    else
        d    = sqrt(sum((p(1,:)-p(2,:)).^2));
    end
    
    if d <= tol;
        ps = sum(p,1)/2;
        ix = 1;
    else
        ps = p;
        ix = [1;2];
    end
    
elseif Inanp;
    
    % case: there are nans in the p array
    % --> find start and end indices of contiguous non-nan data
    Inan = ~Inan;
    sIX = strfind(Inan',[0 1])' + 1; 
    eIX = strfind(Inan',[1 0])'; 
 
    if Inan(end)==true;
        eIX = [eIX;nrvertices];
    end
    
    if Inan(1);
        sIX = [1;sIX];
    end
    
    % calculate length of non-nan components
    lIX = eIX-sIX+1;   
    % put each component into a single cell
    c   = mat2cell(p(Inan,:),lIX,dims);
    
    % now call dpsimplify again via cellfun. 
    if nargout == 2;
        [ps,ix]   = cellfun(@(x) dpsimplify(x,tol),c,'uniformoutput',false);
        ix        = cellfun(@(x,six) x+six-1,ix,num2cell(sIX),'uniformoutput',false);
    else
        ps   = cellfun(@(x) dpsimplify(x,tol),c,'uniformoutput',false);
    end
    
    % write the data from a cell array to a matrix
    ps = cellfun(@(x) [x;nan(1,dims)],ps,'uniformoutput',false);    
    ps = cell2mat(ps);
    ps(end,:) = [];
    
    % ix wanted? write ix to a matrix, too.
    if nargout == 2;
        ix = cell2mat(ix);
    end
    
       
else
    

% if there are no nans than start the recursive algorithm
ixe     = size(p,1);
ixs     = 1;

% logical vector for the vertices to be retained
I   = true(ixe,1);

% call recursive function
p   = simplifyrec(p,tol,ixs,ixe);
ps  = p(I,:);

% if desired return the index of retained vertices
if nargout == 2;
    ix  = find(I);
end

end

% _________________________________________________________
function p  = simplifyrec(p,tol,ixs,ixe)
    
    % check if startpoint and endpoint are the same 
    % better comparison needed which included a tolerance eps
    
    c1 = num2cell(p(ixs,:));
    c2 = num2cell(p(ixe,:));   
%     tol
    % same start and endpoint with tolerance
    sameSE = all(cell2mat(cellfun(compare,c1(:),c2(:),'UniformOutput',false)));

    
    if sameSE; 
        % calculate the shortest distance of all vertices between ixs and
        % ixe to ixs only
        if dims == 2;
            d    = hypot(p(ixs,1)-p(ixs+1:ixe-1,1),p(ixs,2)-p(ixs+1:ixe-1,2));
        else
            d    = sqrt(sum(bsxfun(@minus,p(ixs,:),p(ixs+1:ixe-1,:)).^2,2));
        end
    else    
        % calculate shortest distance of all points to the line from ixs to ixe
        % subtract starting point from other locations
        pt = bsxfun(@minus,p(ixs+1:ixe,:),p(ixs,:));

        % end point
        a = pt(end,:)';

        beta = (a' * pt')./(a'*a);
        b    = pt-bsxfun(@times,beta,a)';
        if dims == 2;
            % if line in 2D use the numerical more robust hypot function
            d    = hypot(b(:,1),b(:,2));
        else
            d    = sqrt(sum(b.^2,2));
        end
    end
    
    % identify maximum distance and get the linear index of its location
    [dmax,ixc] = max(d);
    ixc  = ixs + ixc; 
    
    % if the maximum distance is smaller than the tolerance remove vertices
    % between ixs and ixe
    if dmax <= tol;
        if ixs ~= ixe-1;
            I(ixs+1:ixe-1) = false;
        end
    % if not, call simplifyrec for the segments between ixs and ixc (ixc
    % and ixe)
    else   
        p   = simplifyrec(p,tol,ixs,ixc);
        p   = simplifyrec(p,tol,ixc,ixe);

    end

end
end


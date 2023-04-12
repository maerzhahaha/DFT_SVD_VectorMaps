% get NC
function N=NC(mark_get,mark_prime)
if size(mark_get)~=size(mark_prime)
    error('Input vectors must  be the same size!')
else
    [m,n]=size(mark_get);
    fenzi=1-(xor(mark_get,mark_prime));
    fenzi=sum(sum(fenzi));
    N=fenzi/(m*n);
end
end

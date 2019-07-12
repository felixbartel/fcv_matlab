function [f_r,fhat_r,ddf_r] = H(self,lambda)
% fcv.H computes the matrix-vector product with the hat matrix F*inv(F'*W*F+lambda*What)*F'*W
  [fhat_r,~] = lsqr(...
    @(x,transp_flag) Afun(self.plan,x,lambda,self.W,self.What,transp_flag),...
    [sqrt(self.W).*self.f;zeros(length(self.What),1)],1e-10);
  
  self.plan.fhat = fhat_r;
  nfsoft_trafo(self.plan);
  f_r = self.plan.f;
  
  if nargout > 2
    [tmp,~] = lsqr(...
      @(x,transp_flag) Afun(self.plan,x,lambda,self.W,self.What,transp_flag),...
      [zeros(length(self.W),1);sqrt(self.What/lambda).*fhat_r],1e-10);
    self.plan.fhat = tmp;
    nfsoft_trafo(self.plan);
    ddf_r = -self.plan.f;
  end
end

function y = Afun(plan,x,lambda,W,What,transp_flag)
  if strcmp(transp_flag,'notransp')
    plan.fhat = x;
    nfsoft_trafo(plan);
    y = plan.f;
    
    y = sqrt(W).*y;
    
    y = [y; sqrt(lambda*What).*x];
  else
    y = sqrt(W).*x(1:length(W));
    
    plan.f = y;
    nfsoft_adjoint(plan);
    y = plan.fhat;
    
    y = y+sqrt(lambda*What).*x(length(W)+1:end);
  end
end

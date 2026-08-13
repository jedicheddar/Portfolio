**free
ctl-opt main(main) dftactgrp(*no);

dcl-proc main;
   dcl-pi *n;
      pNum packed(15:5) const;
   end-pi;
   dcl-s sqrt int(5);
   dcl-s i int(5);
   dcl-s j int(5);
   dcl-s primeNum int(5) dim(*auto:20000);
   dcl-s isNotPrime ind;

   if pNum > 20000;
      snd-msg 'The number is too large';
      return;
   endif;
   
   for i = 1 to %int(pNum);
      sqrt = %int(%sqrt(i));
      isNotPrime = *off;
      for j = 1 to sqrt;
         if j <> 1 and %rem(i:j) = 0;
            isNotPrime = *on;
         endif;
      endfor;
      if isNotPrime = *off;
         primeNum(*next) = i;
      endif;
   endfor;

   for i = 1 to %elem(primeNum);
      snd-msg 'The prime number is: ' + %char(primeNum(i));
   endfor;

end-proc; 

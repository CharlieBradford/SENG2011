rm all.dfy; echo '' > all.dfy.tmp; cat *.dfy >> all.dfy.tmp; sed 's+#+//+g' < all.dfy.tmp > all.dfy; rm all.dfy.tmp; dafny /compile:1 all.dfy

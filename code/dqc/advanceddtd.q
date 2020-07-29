\d .dqc

advancedsymdtd:{[tab;func;vars]
  /- List containing the advancedres table of the function and parameter specified from yesterday and two days ago
  listt:{[tab;func;vars;dt]?[tab;((=;`funct;enlist func);(=;`resultkeys;enlist vars);(=;.Q.pf;dt));1b;()]}[tab;func;vars;]each -2#.Q.PV;
  /- List containing only the keys of the two tables from yesterday and two days ago
  keyst:{key first x`resulttables}each listt;
  /- a utility function for the conditional
  f:{" "sv({x,'".",'y}/){$[10h=type x;x;string x]}each x` vs y};
  /- if everything matches, then proceed to 1b on the result. if not, check what is missing from today/missing from yesterday
  $[(all b in a)and all(a:keyst 0)in b:keyst 1;
    (1b;"All keys from day ",(string last .Q.PV)," matched keys from ",string first -2#.Q.PV);
    (0b;"Error: ",$[count mfy:a where not a in b;" ",f[mfy;vars]," missing from last day.";""],$[count mft:b where not b in a;" ",f[mft;vars]," missing from second last day.";""])]
  }

advancedperdtd:{[tab;func;vars;percentage]
  /- List containing the advancedres table of the function and parameter
  /- specified from the last two days
  listt:{[tab;func;vars;dt]?[tab;((=;`funct;enlist func);(=;`resultkeys;enlist vars);(=;.Q.pf;dt));1b;()]}[tab;func;vars;]each -2#.Q.PV;
  /- List containing only the advancedres tables from yesterday and two days ago
  advancedreslist:{first x`resulttables}each listt;
  /- changing the column name for the table two days ago
  advancedreslist[1]:((-1_cols advancedreslist[1]),`bycounttwo)xcol advancedreslist[1];
  advancedreslist[0]:((-1_cols advancedreslist[0]),`bycountone)xcol advancedreslist[0];
  /- Joining the two tables for comparision
  joinedadvancedres:advancedreslist[0]uj advancedreslist[1];
  /- Getting the percentage difference from two days ago to today
  joinedadvancedres:update percentages:100*(abs (0^bycountone)-(0^bycounttwo))%bycounttwo from joinedadvancedres;
  /- Create error message for the conditional below.
  errorsym:{" "sv({x,'".",'y}/){$[10h=type x;x;string x]}each x` vs y}[key select from joinedadvancedres where percentages>percentage;vars];
  $[not count errorsym;
    (1b;"No keys have exceeded more than ",(string percentage),"% from ",(string first -2# .Q.PV)," to ",string last .Q.PV);
    (0b;("The following keys ",ssr[string vars;".";", "]," have changed more than ",(string percentage),"%: ",errorsym))]
  }
max: let
  inherit (builtins) concatStringsSep filter isString map toString;

  mod = num: denom: num / denom * denom == num;

  results = {
    "15" = "fizzbuzz";
    "3" = "fizz";
    "5" = "buzz";
  };

  fizzbuzz = num: let
    a = filter isString (map (d:
      if mod num d
      then results.${toString d}
      else d) [15 3 5]);
  in
    if a == []
    then toString num
    else builtins.elemAt a 0;

  generate = i: max:
    if i == max
    then ["${fizzbuzz i}\n"]
    else [(fizzbuzz i)] ++ (generate (i + 1) max);
in
  concatStringsSep "\n" (generate 1 max)

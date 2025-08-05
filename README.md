# Wordle.jl
This is the world's best Wordle solver. It uses a statistical approach of giving the best option at the next guess given all the previous guesses and their success rate. It works on the basis of equivalance classes.

# How it works

```julia
julia solve-wordle.jl
```

The program will suggest a few good guesses (along with a few random ones and a few bad ones for comparision). You can try them and let the program know what the hits were. The template used for this is 

- `0` means `missing` or `absent`
- `1` means `present` but the match is `inexact`
- `2` means `exact` match



# Eg:-
For example you guessed `arise`, the Wordle you are playing at will say:

- `a` is an `exact` match.  (the first one.)
- `r` is an `inexact` match.
- `i` is `absent`
- `s` is `absent`
- `e` is `exact`

(Because the underlying truth (that you do not have access to) is `aware`.)

This sequence of `exact`, `inexact`, `absent`, `absent`, `exact` will map to `21002` in our scheme. 
You tell the solver that you guessed `arise` and that the match pattern is `21002` and the program will suggest what you could use next. 

# Scores
The program will give you candidate guesses with scores. The first score is a worst-case: even if you are very unlucky you will not have more than `worst case score` amount of possibilities left if you guess this candidate. The second score is on an `average score` — how many will you have left if you use this guess. If you are conservative you can go by the `worst case score`.
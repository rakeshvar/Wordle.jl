wtmean(a) = sum(abs2, a)/sum(a)

using Printf

function suggest_best_guesses(curclasses)
    println("Finding best (and worst) guesses.")
    curr_class_matches = @view matches[curclasses, :]
    table = fill(0, 3^5, num_guesss)
    # table[match, guess] is the number of truths that will remain after guessing `guess` and getting `match`
    # So we can suggest the guess that minimizes the maximum (or average) number of truths remaining
    # whatever the match might be.

    for iguess in 1:num_guesss
        for match_id in curr_class_matches[:, iguess]
            table[match_id==0 ? 3^5 : match_id, iguess] += 1
    end end

    max_class_sz = mapslices(maximum, table, dims=1)[:]
    wtd_class_sz = mapslices(wtmean, table, dims=1)[:]
    best_minimax = partialsortperm(max_class_sz, 1:5)
    best_minwtd = partialsortperm(wtd_class_sz, 1:5)
    wrst_minimax = partialsortperm(max_class_sz, 1:5, rev=true)
    wrst_minwtd = partialsortperm(wtd_class_sz, 1:5, rev=true)
  
    function print_guesses(indices)
        for i in indices
            @printf "│ %s │ %9i │ %7.2f %c │\n" guesss[i] max_class_sz[i] wtd_class_sz[i] (i≤num_truths ? '*' : ' ')
        end
    end

    println("Number of options that will remain via this guess (* indicates a valid solution):")
    println("┌───────┬───────────┬───────────┐")
    println("│ Guess │ WorstCase │ Average   │")
  if length(curclasses) <= 10                    # Print possible truths if there are only a few
    println("├───────┼───────────┼───────────┤ Possible Truths ")
    print_guesses(indexin(truths[curclasses], guesss))     
  end
    println("├───────┼───────────┼───────────┤ Best Bets")
    print_guesses(best_minimax ∪ best_minwtd )
    println("├───────┼───────────┼───────────┤ Random Options")
    print_guesses(rand(1:num_guesss, 5))         # Print some random guesses
    println("├───────┼───────────┼───────────┤ Worst Options")
    print_guesses(wrst_minimax ∪ wrst_minwtd)
    println("└───────┴───────────┴───────────┘")
end

#######################################################################################

function getinput()
    println("Enter next guess and match pattern — Inexact: '1' Exact:'2' Absent:'0'")

    while true
        print("Next Guess   : ")
        global input_guess = readline(stdin)
        length(input_guess) == 5 && input_guess ∈ guesss && break
        println("Invalid Guess. Should be a 5-letter word from the list of guesses. Try again.")
    end
    
    while true
        print("Match Pattern: ")
        global input_match = readline(stdin)
        length(input_match) == 5 && all((c -> c in "012"), input_match) && break
        println("Invalid match pattern. Should be 5 characters in \" .-=\". Try again.")
    end
    
    input_guess, parse(UInt8, input_match, base=3)
end


function updatetruths(curclasses, guess, match)
    ig = findfirst(isequal(guess), guesss)
    filter(curclasses) do it
        matches[it,ig] == match
    end
end


function main()
    println("\n~~~~~~~~~~~~~~~~~~~~~~ New Game ~~~~~~~~~~~~~~~~~~~~~~ ")
    round = 1
    possible_truths = 1:num_truths

    while length(possible_truths) > 1
        println("\n~~~~~~~~~~~~~~~~~~~~~~ Round $round ")
        print("\n$(length(possible_truths)) possible solutions left ")
        println((1 < length(possible_truths) < 15) ? truths[possible_truths] : ".")

        suggest_best_guesses(possible_truths)
        guess, matchid = getinput()
        possible_truths = updatetruths(possible_truths, guess, matchid)
        round += 1
    end

    if length(possible_truths) == 0
        println("No possible solutions left. You must have made a mistake.")
    elseif length(possible_truths) == 1
        println("Congratulations! The solution is: $(truths[possible_truths])")
    end
end

###########################################################################

function readwords(f::IO)
    ret = String[]
    for l in readlines(f)
        l = strip(l)
        (length(l) != 5) && println(l) && error
        push!(ret, l)
    end
    ret
end
readwords(fname::AbstractString) = open(readwords, fname)

const spares = readwords("non-solution-guesses")
const truths = readwords("solutions")
const guesss = truths ∪ spares
const num_guesss = length(guesss)
const num_truths = length(truths)

using JLD2, CodecZlib
print("Loading data... ")
const matches = load("matches-matrix.jld2", "matches")
println("Done.")

while true
    main()
    print("Do you want to play again? (y/n): ")
    if readline(stdin) != "y"
        println("Thanks for playing!")
        break           
    end
end

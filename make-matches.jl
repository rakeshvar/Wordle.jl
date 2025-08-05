
Absent = '0'
Present = '1'
Exact = '2'

function get_match_str(guess, truth, debug=false)::String
    guess_matched_exact = falses(5)
    truth_matched = falses(5) 
    match_str = fill(Absent, 5)

    for i in 1:5
        if guess[i] == truth[i]
            guess_matched_exact[i] = truth_matched[i] = true
            match_str[i] = Exact  
    end end

    if debug
        @show guess truth guess_matched_exact truth_matched join(match_str) 
    end

    for ig in 1:5
        guess_matched_exact[ig] && continue
        for it in 1:5
            if !truth_matched[it] && guess[ig] == truth[it]
                truth_matched[it] = true
                match_str[ig] = Present
                if debug
                    @show ig it guess_matched_exact truth_matched join(match_str)
                end
                break
    end end end

    join(match_str)
end

get_match_id(match_str::String)::UInt8 = parse(UInt8, match_str, base=3)
get_match_id(guess, truth, debug=false)::UInt8 = get_match_id(get_match_str(guess, truth, debug))

function get_match_str_id(guess, truth, debug=false)
    match_str = get_match_str(guess, truth, debug)
    match_id = get_match_id(match_str)
    match_str, match_id
end

function get_all_match_ids(my_truths)
    match_ids = Array{UInt8, 2}(undef, length(my_truths), length(guesss))
    for (ig, guess) in enumerate(guesss)
        print("\x1b[1K\x1b[G$ig/$(length(guesss)) words\t")
        for (it, turth) in enumerate(my_truths)
            match_ids[it, ig] = get_match_id(guess, turth)
        end
    end
    println()
    match_ids
end

#######################################################################################
function readwords(f::IO)
    words = String[]
    for l in readlines(f)
        l = strip(l)
        (length(l) != 5) && println(l) && error()
        push!(words, l)
    end
    words
end
readwords(fname::AbstractString) = open(readwords, fname)

const spares = readwords("non-solution-guesses")
const truths = readwords("solutions")
const guesss = truths ∪ spares

#######################################################################################
using Random, Printf

function test_matches()
    println("Testing some matches...")  
    ids=Tuple{UInt8, String}[]
    num_samples = 1000

    for  i in 1:num_samples
        guess = rand(guesss)
        truth = rand(truths)
        s, id = get_match_str_id(guess, truth)
        println("$i $guess $truth $s $id", )
        push!(ids, (id, s))
    end

    println("\nID   UInt8   Base3 Number of samples (out of $num_samples)")
    for u in sort!(unique(ids))
        @printf("%3d %s %4d\n", u[1], u, sum(isequal(u), ids))
    end

    @show get_match_str_id("carrs", "crass", true)
    @show get_match_str_id("allee", "eagle", true)
    @show get_match_str_id("apple", "allee", true)
    @show get_match_str_id("saore", "arose", true)  
end

# test_matches()

#######################################################################################
using JLD2, CodecZlib

matches = get_all_match_ids(truths)
jldsave("matches-matrix.jld2", true; matches)
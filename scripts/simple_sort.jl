using CSV
using DataFrames
using DelimitedFiles

function find_slug(str::Nothing)
    return "none"
end

function find_slug(str::String)
    str = strip(str)
    if findfirst("youtube.com", str) != nothing
        if findfirst("channel/", str) != nothing
            return "channel"
        end
        if findfirst("list", str) != nothing
            return "channel"
        end
        if findfirst("&", str) != nothing
            return str[findfirst("=",str)[1]+1:findfirst("&",str)[1]-1]
        elseif findfirst("=", str) == nothing
            return "channel"
        else
            return str[findfirst("=",str)[1]+1:end]
        end
    elseif findfirst("youtu.be", str) != nothing
       return str[findlast("/",str)[1]+1:end]
    else
        return "none"
    end

    return "none"
end

function format_cells!(df)
    df[:,2] .= strip.(df[:,2])
    df[:,4] .= strip.(df[:,4])
    for i = 1:size(df)[1]
        if !ismissing(df[i,3])
            df[i,3] = replace(df[i,3], "," => ".")
            df[i,3] = replace(df[i,3], ";" => ".")
        end

        if !ismissing(df[i,5])
            df[i,5] = replace(df[i,5], "," => "")
            df[i,5] = replace(df[i,5], ";" => ".")
        end
    end
end

# This function removes any entry without a . in them
# All links have dots, so all entries should also have a dot
# The main purpose here is to remove spurrious entries like "yo yo yo"
#     Most of these people have not written complete sentences, so there
#     is no period. We can disable certain entries during the judging to get
#     rid of the rest of the bad entries.
function remove_bad_links!(df)

    dropmissing!(df, "Link to your submission")
    
    bad_indices = []
    for i = 1:size(df)[1]
        if isa(findfirst(".", df[i, "Link to your submission"]), Nothing)
            append!(bad_indices, i)
        end
        if !occursin("http", df[i, "Link to your submission"])
            println("Link: ", df[i, "Link to your submission"],
                    " Must be prepended with http:// or https://")
        end
    end

    delete!(df, bad_indices)
end

function remove_duplicates!(df)

    usernames = df[!,"Email Address"]

    bad_indices = []

    for i = 1:length(usernames)-1
        if !(i in bad_indices)
            copies = [false for i = 1:length(usernames)]
            for j = i+1:length(usernames)
                if lowercase(usernames[j]) == lowercase(usernames[i])
                    copies[j] = true
                end
            end
            copy_indices = findall(copies)

            if length(copy_indices) > 0
                append!(bad_indices,i)
                for j in copy_indices
                    if j != copy_indices[end] && !(j in bad_indices)
                        append!(bad_indices, j)
                    end
                end
            end
        end
    end

    sort!(bad_indices)
    delete!(df, bad_indices)

end

function find_bad_indices(judge_df, entry_df)
    indices = []
    found_item = false
    for i = 1:size(entry_df)[1]
        for j = 1:size(judge_df)[1]
            if strip(lowercase(entry_df[i, "Email Address"])) ==
               strip(lowercase(judge_df[j, "Email Address"]))
                found_item = true
            end
        end
        if !found_item
            append!(indices, i)
        end
        found_item = false
    end

    return sort(indices)

end

function find_indices!(judge_df, entry_df)
    indices = []
    indices_size = 0
    for i = 1:size(judge_df)[1]
        for j = 1:size(entry_df)[1]
            if strip(lowercase(entry_df[j, "Email Address"])) == 
               strip(lowercase(judge_df[i, "Email Address"]))
                append!(indices,j)
                indices_size += 1 
            end
        end
        if indices_size != length(indices)
            println(judge_df[i,"Email Address"])
            indices_size += 1
        end
    end

    return sort(indices)
end

function find_beta_judges(entry_df, judge_filename, output_file1, output_file2)
    df = DataFrame(CSV.File(judge_filename))
    remove_duplicates!(df)

    dropmissing!(df, 5)

    bad_indices = []
    for i = 1:size(df)[1]
        if df[i,5] != "Yes"
            append!(bad_indices, i)
        end
    end

    sort!(bad_indices)
    delete!(df, bad_indices)

    name = [string(i) for i = 1:size(df)[1]]
    link = ["https://youtu.be/ojjzXyQCzso" for i = 1:size(df)[1]]

    df.name = name
    df.link = link

    indices = find_indices!(df, entry_df)

    CSV.write(output_file1, df[!,[6,2,7]])
    CSV.write(output_file2, df[!,[2,7,7]])
end

function find_judges(entry_df, judge_filename, output_file_judges,
                     output_file_entrants)
    df = DataFrame(CSV.File(judge_filename))
    remove_duplicates!(df)


    bad_indices = []
    for i = 1:size(df)[1]
        if df[i,3] != "Yes, I would like to judge other entries for a chance to win the SoME1 competition"
            append!(bad_indices, i)
        end
    end

    sort!(bad_indices)
    delete!(df, bad_indices)

    indices = find_indices!(df, entry_df)

    CSV.write(output_file_entrants, entry_df[indices,[2,5,4]])

    left_over = length(indices)
    i = 0
    while left_over > 0
        i += 1
        if left_over > 50
            println(indices[(i-1)*50+1:i*50])
            CSV.write(output_file_judges*string(i)*".csv",
                      entry_df[indices[(i-1)*50+1:i*50],[3,2,4]])
            left_over -= 50
        else
            println(indices[(i-1)*50+1:(i-1)*50+left_over])
            CSV.write(output_file_judges*string(i)*".csv",
                      entry_df[indices[(i-1)*50+1:(i-1)*50+left_over],[3,2,4]])
            left_over -= left_over
        end
    end

    println(size(entry_df))
    println(length(indices))
    return df
end

function find_missing_entrants(entry_df, judge_filename, output_file)
    df = DataFrame(CSV.File(judge_filename))

    indices = find_bad_indices(df, entry_df)

    CSV.write(output_file, entry_df[indices,[3,2]])
end



function simple_sort(filename, output_file, judge_file)
    df = DataFrame(CSV.File(filename))
    remove_bad_links!(df)
    remove_duplicates!(df)
    format_cells!(df)

    CSV.write(output_file, df[!,[2,5,4]])
    CSV.write(judge_file, df[!,[3,2,4]])

    return df
end 

function find_names(df_selected, df_entries)
    names = ["" for i = 1:size(df_selected)[1]]
    for i = 1:size(df_selected)[1]
        for j = 1:size(df_entries)[1]
            if df_selected[i,2] == df_entries[j,2]
                names[i] = df_entries[j,3]
            end
        end
        if names[i] == ""
            println(df_selected[i,2])
        end
    end
    return names
end

#df = simple_sort("SoME1 Entries.csv", "SoME1_entries.csv", "SoME1_judges.csv")
#find_missing_entrants(df, "SoME1 Peer Review.csv", "missing_entrants.csv")
#judge_df = find_judges(df, "SoME1 Peer Review.csv", "judges", "entries.csv")

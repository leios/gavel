using CSV
using DataFrames
using DelimitedFiles

function find_emails(entry_filename, ranking_filename, output_filename)

    entry_df = CSV.read(entry_filename, DataFrame)
    ranking_df = CSV.read(ranking_filename, DataFrame)
    
    indices = zeros(Int,size(ranking_df)[1])
    for i = 1:size(ranking_df)[1]
        for j = 1:size(entry_df)[1]
            if strip(ranking_df[i,"link"]) == strip(entry_df[j,"Link to your submission"])
                indices[i] = j
            end
        end
        if indices[i] == 0
            println(ranking_df[i,:])
        end
    end

    CSV.write(output_filename, entry_df[indices,["Name(s)", "Email Address"]])

end

function find_slug(str::Nothing)
    return "none"
end

function find_slug(str::S) where S <: AbstractString
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

        if !ismissing(df[i,6])
            df[i,6] = replace(df[i,6], "," => "")
            df[i,6] = replace(df[i,6], ";" => ".")
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

    println(bad_indices .+ 1)

    delete!(df, bad_indices)
end

function remove_duplicates!(df)

    usernames = df[!,"Name(s)"]
    emails = df[!,"Email Address"]

    bad_indices = []

    for i = 1:length(usernames)-1
        if !(i in bad_indices)
            copies = [false for i = 1:length(usernames)]
            for j = i+1:length(usernames)
                if lowercase(usernames[j]) == lowercase(usernames[i]) &&
                   lowercase(emails[j]) == lowercase(emails[i])
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
               strip(lowercase(judge_df[j, "Email Address"])) &&
               strip(lowercase(entry_df[i, "Name(s)"])) ==
               strip(lowercase(judge_df[j, "Name(s)"]))
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
               strip(lowercase(judge_df[i, "Email Address"])) &&
               strip(lowercase(entry_df[j, "Name(s)"])) == 
               strip(lowercase(judge_df[i, "Name(s)"]))
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

function chunk_judges(judge_filename::String,
                      output_file_judges::String,
                      additional_string::String)
    df = CSV.read(judge_filename, DataFrame)
    df[!,"additional_string"] .= additional_string

    left_over = size(df)[1]
    i = 0
    while left_over > 0
        i += 1
        if left_over > 50
            rng = (i-1)*50+1:i*50
            println(rng)
            CSV.write(output_file_judges*string(i)*".csv",
                      df[rng,[1,2,4]])
            left_over -= 50
        else
            rng = (i-1)*50+1:(i-1)*50+left_over
            println(rng)
            CSV.write(output_file_judges*string(i)*".csv",
                      df[rng,[1,2,4]])
            left_over -= left_over
        end
    end

end

function chunk_judges(entry_df, judge_filename, output_file_judges)
    df = DataFrame(CSV.File(judge_filename))
    remove_duplicates!(df)

    indices = find_indices!(df, entry_df)
    println(indices)

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

function find_missing_entrants(entry_df, judge_filenames, output_file)
    if isa(judge_filenames, Array) ||
       isa(judge_filenames, Tuple)
        df = DataFrame(CSV.File(judge_filenames[1]))
        for i = 2:length(judge_filenames)
            temp_df = DataFrame(CSV.File(judge_filenames[i]))
            append!(df, temp_df)
        end
    else
        df = DataFrame(CSV.File(judge_filenames))
    end

    indices = find_bad_indices(df, entry_df)

    CSV.write(output_file, entry_df[indices,[3,2,4]])
end

function simple_sort(filename, video_output_file,
                     nonvideo_output_file, judge_file)
    df = CSV.read(filename, DataFrame)
    remove_bad_links!(df)
    remove_duplicates!(df)
    format_cells!(df)

    video_df = find_videos(df)
    nonvideo_df = find_nonvideos(df)

    CSV.write(video_output_file, video_df[1:end,[3,6,4]])
    CSV.write(nonvideo_output_file, nonvideo_df[1:end,[3,6,4]])
    CSV.write(judge_file, df[1:end,[3,2,4]])

    return df
end 

function find_videos(df)
    indices = []
    for i = 1:size(df)[1]
        if df[i,5] == "Video"
            append!(indices,i)
        end
    end
    return df[indices, :]
end

function find_nonvideos(df)
    indices = []
    for i = 1:size(df)[1]
        if df[i,5] == "Not Video"
            append!(indices,i)
        end
    end
    return df[indices, :]
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

function find_additional_judges(df, reviewer_input_file, video_output_file,
                                nonvideo_output_file, both_output_file)
    reviewer_df = CSV.read(reviewer_input_file, DataFrame)
    dropmissing!(reviewer_df, "Email Address")
    dropmissing!(reviewer_df, "Name(s)")

    # Remove reviewers with e-mail addresses in the entrant dataframe (df)

    bad_indices = []
    for i = 1:size(reviewer_df)[1]
        for j = 1:size(df)[1]
            if strip(lowercase(reviewer_df[i, "Email Address"])) == 
               strip(lowercase(df[j, "Email Address"])) &&
               strip(lowercase(reviewer_df[i, "Name(s)"])) == 
               strip(lowercase(df[j, "Name(s)"]))
                append!(bad_indices, i)
            end 
        end
    end

    println(bad_indices .+ 1)

    delete!(reviewer_df, bad_indices)

    video_indices = []
    nonvideo_indices = []
    both_indices = []

    for i = 1:size(reviewer_df)[1]
        if reviewer_df[i, "I would like to review..."] == "Video entries only"
            append!(video_indices, i)
        elseif reviewer_df[i, "I would like to review..."] == "Non-video entries only"
            append!(nonvideo_indices, i)
        elseif reviewer_df[i, "I would like to review..."] == "Both"
            append!(both_indices, i)
        else
            error("cannot find, ", reviewer_df[i, "I would like to review..."])
        end
    end

    video_df = reviewer_df[video_indices,:]
    nonvideo_df = reviewer_df[nonvideo_indices,:]
    both_df = reviewer_df[both_indices,:]

    remove_duplicates!(video_df)
    remove_duplicates!(nonvideo_df)
    remove_duplicates!(both_df)

    CSV.write(video_output_file, video_df[!,[3,2,4]])
    CSV.write(nonvideo_output_file, nonvideo_df[!,[3,2,4]])
    CSV.write(both_output_file, both_df[!,[3,2,4]])
end


function send_feedback(feedback_df, entry_df, basic_body)

    #dropmissing!(feedback_df)

    names = []
    emails = []
    specific_bodies = []
    chosen_slugs = []

    for i = 1:size(feedback_df)[1]
        slug = find_slug(feedback_df[i,"Link to the entry:"])
        if slug != "channel" && slug != "none"
            feedback_df[i,"Link to the entry:"] = strip(slug)
        end
    end

    for i = 1:size(entry_df)[1]
        slug = find_slug(entry_df[i,"Link to your submission"])
        if slug != "channel" && slug != "none"
            entry_df[i,"Link to your submission"] = strip(slug)
        end
    end

    for i = 1:size(feedback_df)[1]
        slug = feedback_df[i,"Link to the entry:"]
        if in(slug, chosen_slugs)
            elid = findfirst(x->x==slug,chosen_slugs)
            specific_bodies[elid] *= feedback_df[i,"Feedback:"]*"<p>-----<p>"
        else
            if in(slug,entry_df[:,"Link to your submission"])
                push!(chosen_slugs, slug)
                push!(specific_bodies, feedback_df[i,"Feedback:"]*"<p>-----<p>")
                elid = findfirst(x->x==slug,entry_df[:,"Link to your submission"])
                push!(names, entry_df[elid,"Name(s)"])
                push!(emails, entry_df[elid,"Email Address"])
            else
                println("could not find "*slug)
            end
            
        end
    end
    
    #return hcat(emails, names, specific_bodies, chosen_slugs)
    send_emails(emails, names, specific_bodies, basic_body)
end

# Setup: https://wiki.archlinux.org/title/msmtp
function send_emails(emails, names, specific_bodies, basic_body)
    for i = 1:length(emails)
        message = "To: "*
                  replace(names[i],","=>" and")*" <"*emails[i]*">\n"
        message *= "From: Summer of Math Exposition <3b1b.some@gmail.com>\n"
        message *= "Subject: SoME2 Specific Feedback\n"
        message *= "Mime-Version: 1.0\n"
        message *= "Content-Type: text/html\n\n"
        message *= "Hello "*names[i]*",<p>"
        message *= basic_body
        message *= specific_bodies[i]

        sendEmailCmd = pipeline(IOBuffer(message), `sendmail -t`)
        println(emails[i])
        run(sendEmailCmd)
        sleep(5)
    end
end

basic_body = """
<p>
Thanks again for submitting your entry to the Summer of Math Exposition (SoME2) competition this year!

<p>
We could not be happier with the content people have created for this competition and are looking forward to running it again next year. No matter how you did, you should be really proud of the content you made!

<p>
During the Peer Review process, we asked the reviewers to provide specific feedback about the entries they were judging and have decided to return most of that feedback to you now; however, before reading it, please keep in mind that we tried to pre-screen everything, but might have missed some comments that were out-of-line (such as crude remarks, unjustified claims, or generally unhelpful / incorrect advice)

<p>
Remember, the following message(s) is(are) not from Grant or I, but instead from community members who have likely also made some form of math content and know how challenging it can be. It should also give you some perspective on how you did during the Peer Review and what could be improved in the future.

<p>
On to the feedback:
<p>
-----------------------------
<p>
"""

#df = simple_sort("SoME2 Entries.csv", "SoME2_entries_video.csv",
#                 "SoME2_entries_nonvideo.csv", "SoME2_judges.csv")
#find_missing_entrants(df, "SoME2 Peer Review.csv", "missing_entrants.csv")
#judge_df = chunk_judges(df, "SoME2 Peer Review.csv", "judges")
#find_additional_judges(df, "SoME2 Reviewers.csv", "additional_video.csv",
#                       "additional_nonvideo.csv, "additional_both.csv")
#chunk_judges("additional_video.csv", "chunked_additional_judges_video",
#             "additional video judge")
#chunk_judges("additional_nonvideo.csv", "chunked_additional_judges_nonvideo",
#             "additional nonvideo judge")
#chunk_judges("additional_both.csv", "chunked_additional_judges_both",
#             "additional judge")

#df = simple_sort("input_entries.csv", "final_entries_video_temp.csv",
#                 "final_entries_nonvideo_temp.csv", "initial_judges_temp.csv")
#find_missing_entrants(df, "initial_judges.csv", "missing_entrants.csv")
#judge_df = chunk_judges(df, "initial_judges.csv", "chunked_judges")
#find_additional_judges(df, "input_additional_judges_3.csv",
#                       "additional_video3.csv",
#                       "additional_nonvideo3.csv", "additional_both3.csv")
#chunk_judges("additional_video3.csv", "chunked_additional_judges_video_3_",
#             "additional video judge")
#chunk_judges("additional_nonvideo3.csv",
#             "chunked_additional_judges_nonvideo_3_",
#             "additional nonvideo judge")
#chunk_judges("additional_both3.csv", "chunked_additional_judges_both_3_",
#             "additional judge")

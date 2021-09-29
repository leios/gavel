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

function send_feedback(feedback_df, entry_df, basic_body)

    dropmissing!(feedback_df)

    names = []
    emails = []
    specific_bodies = []
    chosen_slugs = []

    for i = 1:size(feedback_df)[1]
        slug = find_slug(feedback_df[i,2])
        if slug != "channel" && slug != "none"
            feedback_df[i,2] = slug
        end
    end

    for i = 1:size(entry_df)[1]
        slug = find_slug(entry_df[i,4])
        if slug != "channel" && slug != "none"
            entry_df[i,4] = slug
        end
    end

    for i = 1:size(feedback_df)[1]
        slug = feedback_df[i,2]
        if in(slug, chosen_slugs)
            elid = findfirst(x->x==slug,chosen_slugs)
            specific_bodies[elid] *= feedback_df[i,3]*"<p>-----<p>"
        else
            if in(slug,entry_df[:,4])
                push!(chosen_slugs, slug)
                push!(specific_bodies, feedback_df[i,3]*"<p>-----<p>")
                elid = findfirst(x->x==slug,entry_df[:,4])
                push!(names, entry_df[elid,3])
                push!(emails, entry_df[elid,2])
            else
                println("could not find "*slug)
            end
            
        end
    end
    
    return hcat(emails, names, specific_bodies, chosen_slugs)
    #send_emails(emails, names, specific_bodies, basic_body)
end

function send_emails(emails, names, specific_bodies, basic_body)
    for i = 1:length(emails)
        message = "To: "*emails[i]*"\n"
        message *= "From: jrs.schloss@gmail.com\n"
        message *= "Subject: SoME1 Specific Feedback\n"
        message *= "Mime-Version: 1.0\n"
        message *= "Content-Type: text/html\n\n"
        message *= "Hello "*names[i]*",<p>"
        message *= basic_body
        message *= specific_bodies[i]

        sendEmailCmd = pipeline(IOBuffer(message), `sendmail -t`)
        run(sendEmailCmd)
        println(emails[i])
        sleep(1)
    end
end

basic_body = """
<p>
Thanks again for submitting exposition to the Summer of Math Exposition (SoME1) competition this year!

<p>
We could not be happier with the content people have created for this competition and are looking forward to running it again next year! No matter how you did, you should be really proud of the content you made!

<p>
During the peer review process, we asked people to provide specific feedback about the entries they were judging and have decided to return most of that feedback to you now; however, before reading it, there are a few things to keep in mind:

<ol>
<li>The SoME1 peer reviewers were quite biased towards video content. In fact, many reviewers mistakenly believed this competition was a video contest. This was one of the biases we tried to correct for at the end of the peer review, but if you made a non-video entry, there is a possibility that your specific feedback was asking for a video of some kind. </li>
<li>We tried to pre-screen all the comments made, but might have missed some comments that were out-of-line (such as crude remarks, unjustified claims, or generally unhelpful / incorrect advice).</li>
</ol>

<p>
Please keep in mind that this feedback is not from Grant or I, but instead from other SoME1 participants who may or may not be justified in making the statements they have made, so take everything they have said with a grain of salt and really consider whether their feedback is valid or not. On the other hand, this feedback is from motivated individuals who have also made math content and know how challenging it can be, so they might know more than you think!

<p>
Ok, that's all for now. Thank you for helping make the first Summer of Math Exposition a smashing success! We look forward to seeing more from you in the future!

<p>
James Schloss and Grant Sanderson

<p>
On to the feedback:
<p>
-----------------------------
<p>
"""

#df = simple_sort("SoME1 Entries.csv", "SoME1_entries.csv", "SoME1_judges.csv")
#find_missing_entrants(df, "SoME1 Peer Review.csv", "missing_entrants.csv")
#judge_df = find_judges(df, "SoME1 Peer Review.csv", "judges", "entries.csv")

#!/usr/bin/env ruby

require "json"
require "octokit"

json = File.read(ENV.fetch("GITHUB_EVENT_PATH"))
event = JSON.parse(json)

$github = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

if !ENV["GITHUB_TOKEN"]
  puts "Missing GITHUB_TOKEN"
  exit(1)
end

if ARGV[0].empty?
  puts "Missing file path argument."
  exit(1)
end

$repo = event["repository"]["full_name"]

if ENV.fetch("GITHUB_EVENT_NAME") == "pull_request"
  $pr_number = event["number"]
else
  pulls = github.pull_requests(repo, state: "open")

  push_head = event["after"]
  pr = pulls.find { |pr| pr["head"]["sha"] == push_head }

  if !pr
    puts "Couldn't find an open pull request for branch with head at #{push_head}."
    exit(1)
  end
  pr_number = pr["number"]
end
file_path = ARGV[0]
$header = ARGV[1]

def chunker f_in, minsize, chunksize = 65000
  chunknum = 1
  File.open(f_in,"r") do |fh_in|
    until fh_in.eof?
     fh_out = ""
        loop do
          line = fh_in.readline
          fh_out << line
		  break if line.include? "----------- end diff -----------" and fh_out.size > (minsize-line.length) and fh_out.size < (chunksize-line.length) or fh_in.eof?
          #break if fh_out.size > (chunksize-line.length) || fh_in.eof?
        end
        if chunknum > 1 
         message = " < Continuation of previous comment" + "\n" + "<details><summary>Show Output</summary> " + "\n" + "\n" + "```diff"  + "\n" + fh_out + "\n" + "```"
        else
         message = $header + "\n" + "<details><summary>Show Output</summary> " + "\n" + "\n" + "```diff"  + "\n" + fh_out + "\n" + "```"
        end

       
        coms = $github.issue_comments($repo, $pr_number)
        $github.add_comment($repo, $pr_number, message)
         chunknum += 1
      end
  
    end
  end

chunker file_path, 35000, 65000

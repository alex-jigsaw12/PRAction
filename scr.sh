#!/usr/bin/env ruby

require "json"
require "octokit"

json = File.read(ENV.fetch("GITHUB_EVENT_PATH"))
event = JSON.parse(json)

github = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

if !ENV["GITHUB_TOKEN"]
  puts "Missing GITHUB_TOKEN"
  exit(1)
end

if ARGV.empty?
  puts "Missing file path argument."
  exit(1)
end

repo = event["repository"]["full_name"]

if ENV.fetch("GITHUB_EVENT_NAME") == "pull_request"
  pr_number = event["number"]
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

puts Dir.entries(".")

puts "Hello World"


def chunker f_in, out_pref, chunksize = 6500
  outfilenum = 1
  File.open(f_in,"r") do |fh_in|
    until fh_in.eof?
     fh_out = ""
        loop do
          line = fh_in.readline
          fh_out << line
          break if fh_out.size > (chunksize-line.length) || fh_in.eof?
        end
		message = fh_out
        coms = github.issue_comments(repo, pr_number)
        github.add_comment(repo, pr_number, message)
		puts "==========================================================================================================================================================================="
      end
      outfilenum += 1
    end
  end


chunker "#{file_path}", "output_prefix", 6500

Dir.foreach('tmp/') do |filename|
  next if filename == '.' or filename == '..'
  message = File.read("tmp/""#{filename}")
  coms = github.issue_comments(repo, pr_number)
  github.add_comment(repo, pr_number, message)
  puts "#{filename}"
end

message = File.read(file_path)

coms = github.issue_comments(repo, pr_number)

github.add_comment(repo, pr_number, message)
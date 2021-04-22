#!/usr/bin/env ruby

require 'octokit'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--name NAME') { |o| options[:name] = o }
  opt.on('--branch BRANCH') { |o| options[:branch] = o }
  opt.on('--repository REPOSITORY') { |o| options[:repository] = o }
  opt.on('--token TOKEN') { |o| options[:token] = o }
  options[:conclusion] = ""
  opt.on('--conclusion CONCLUSION') { |o| options[:conclusion] = o }
  options[:status] = ""
  opt.on('--status STATUS') { |o| options[:status] = o }
end.parse!

client = Octokit::Client.new(:access_token => options[:token])
client.auto_paginate = true

response = client.repository_workflow_runs(options[:repository], {:branch => options[:branch]})

workflow_runs = response[:workflow_runs].select { |run| run[:name] == options[:name] }
workflow_runs = workflow_runs.select { |run| run[:conclusion] == options[:conclusion] } if !options[:conclusion].empty?
workflow_runs = workflow_runs.select { |run| run[:status] == options[:status] } if !options[:status].empty?

last_build_sha_run = workflow_runs.max_by { |run| run[:run_number] }

if last_build_sha_run.nil?
  last_build_sha = ""
  running_jobs_count = 0

  response = client.list_workflows(options[:repository])
  workflow = response[:workflows].select { |workflow| workflow[:name] == options[:name] }
  workflow_id = workflow[0][:id]
else
  last_build_sha = last_build_sha_run[:head_sha]

  running_jobs = workflow_runs.select { |run| run[:status] != 'completed' }
  running_jobs_count = running_jobs.length()

  workflow_id = workflow_runs.length() > 0 ? workflow_runs[0][:workflow_id] : ''
end

puts "::set-output name=last-build-sha::#{last_build_sha}"
puts "::set-output name=running-jobs-count::#{running_jobs_count}"
puts "::set-output name=workflow-id::#{workflow_id}"

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
  options[:job_name] = ""
  opt.on('--job-name JOB_NAME') { |o| options[:job_name] = o }
end.parse!

client = Octokit::Client.new(:access_token => options[:token])
client.auto_paginate = true

branch = options[:branch]
repository = options[:repository]
workflow_file = "#{options[:name]}.yml"

if branch == '*'
  workflow_options = {}
else
  workflow_options = {:branch => branch}
end

workflow_runs = client.workflow_runs(repository,
                                     workflow_file,
                                     workflow_options)[:workflow_runs]

if options[:conclusion] and !options[:conclusion].empty?
  workflow_runs = workflow_runs.select do |run|
    run[:conclusion] == options[:conclusion]
  end
end

if options[:status] and !options[:status].empty?
  workflow_runs = workflow_runs.select do |run|
    run[:status] == options[:status]
  end
end

last_build_sha_run = workflow_runs.max_by do |run|
  run[:run_number]
end

running_jobs_count = 0

if last_build_sha_run.nil?
  # no runs matching filters
  last_build_sha = ""
  last_build_run_number = 0
  running_workflows_count = 0

  response = client.list_workflows(repository)
  workflows = response[:workflows].select do |workflow|
    workflow[:name] == options[:name]
  end

  workflow_id = workflows.length() > 0 ? workflows[0][:id] : ''
else
  last_build_sha = last_build_sha_run[:head_sha]
  last_build_run_number = last_build_sha_run[:run_number]

  running_workflows = workflow_runs.select do |run|
    run[:status] != 'completed'
  end
  running_workflows_count = running_workflows.length()

  if running_workflows_count and options[:job_name] and !options[:job_name].empty?
    running_workflows.each do |workflow|
      selected_jobs = workflow.rels[:jobs].get.data[:jobs].select do |job|
        job.name == options[:job_name]
      end
      if selected_jobs and selected_jobs.length() > 0
        if selected_jobs[0].status != 'completed'
          running_jobs_count += 1
        end
      end
    end
  end

  workflow_id = workflow_runs.length() > 0 ? workflow_runs[0][:workflow_id] : ''
end

puts "::set-output name=last-build-sha::#{last_build_sha}"
puts "::set-output name=last-build-run-number::#{last_build_run_number}"
puts "::set-output name=running-workflows-count::#{running_workflows_count}"
puts "::set-output name=workflow-id::#{workflow_id}"
puts "::set-output name=running-jobs-count::#{running_jobs_count}"

#!/usr/bin/env ruby
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative "./lib/stations_human_diff"

SHD::Logger.info "Running script"

SHD::EnvironmentChecker.check!

SHD::Logger.info "Getting request..."
json = File.read(ENV.fetch("GITHUB_EVENT_PATH"))
event = JSON.parse(json)

if %w(opened reopened synchronize).include?(event['action'])
  SHD::Logger.info "Action is `#{event['action']}`. Acknowleding webhook..."

  client = SHD::GithubClient.generate

  SHD::GithubClient.remove_old_comments!(client: client, pull: event["pull_request"])

  ## Diffing stations..
  report = SHD::DiffAnalyzer.new(
    base: event["pull_request"]["base"],
    head: event["pull_request"]["head"],
  ).run

  formatted_report = SHD::ReportFormatter.run(report)

  unless formatted_report.empty?
    SHD::GithubClient.post_comment!(
      client: client,
      pull:   event["pull_request"],
      body:   formatted_report,
    )
  end

  SHD::Logger.info "Done."
else
  SHD::Logger.info "Action is #{event['action']}, doing nothing."
end

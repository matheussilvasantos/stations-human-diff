#!/usr/bin/env ruby
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative "./lib/stations_human_diff"

puts "Running script"

# if !ENV["GITHUB_TOKEN"]
#   puts "Missing GITHUB_TOKEN"
#   exit(1)
# end

SHD::EnvironmentChecker.check!

SHD::Logger.info "Getting request..."
body = request.body.read

if SHD::Utils.verify_signature(body, request.env["HTTP_X_HUB_SIGNATURE"])
  SHD::Logger.info "Signature valid, moving on..."

  params = JSON.parse(body)

  if %w(opened reopened synchronize).include?(params['action'])
    SHD::Logger.info "Action is `#{params['action']}`. Acknowleding webhook..."

    t = Thread.start do
      client = SHD::GithubClient.generate

      SHD::GithubClient.remove_old_comments!(client: client, pull: params["pull_request"])

      ## Diffing stations..
      report = SHD::DiffAnalyzer.new(
        base: params["pull_request"]["base"],
        head: params["pull_request"]["head"],
      ).run

      formatted_report = SHD::ReportFormatter.run(report)

      SHD::GithubClient.post_comment!(
        client: client,
        pull:   params["pull_request"],
        body:   formatted_report,
      )

      SHD::Logger.info "Done."
    end
    t.abort_on_exception = true

    exit(0)
  else
    SHD::Logger.info "Action is #{params['action']}, doing nothing."

    exit(0)
  end
else
  SHD::Logger.info "Signature invalid, doing nothing"

  exit(1)
end

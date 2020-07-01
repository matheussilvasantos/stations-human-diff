module SHD
  class EnvironmentChecker
    def self.check!
      return if !ENV["GITHUB_TOKEN"].nil? && !ENV["GITHUB_TOKEN"].empty?

      REQUIRED_ENV.each do |key|
        if ENV[key].nil? || ENV[key].empty?
          Logger.fatal "`#{key}` is missing from the environment, exiting"

          exit(-1)
        end
      end
    end
  end
end

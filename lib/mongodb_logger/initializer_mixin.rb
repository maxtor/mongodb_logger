module MongodbLogger
  module InitializerMixin
    
    def rails30?
      3 == Rails::VERSION::MAJOR && 0 == Rails::VERSION::MINOR
    end
    
    def create_logger(config)
      path = rails30? ? config.paths.log.to_a.first : config.paths['log'].first
      level = ActiveSupport::BufferedLogger.const_get(config.log_level.to_s.upcase)
      logger = MongodbLogger::Logger.new(:path => path, :level => level)
      logger.auto_flushing = false if Rails.env.production?
      logger
    rescue StandardError => e
      logger = ActiveSupport::BufferedLogger.new(STDERR)
      logger.level = ActiveSupport::BufferedLogger::WARN
      logger.warn(
        "MongodbLogger Initializer Error: Unable to access log file. Please ensure that #{path} exists and is chmod 0666. " +
        "The log level has been raised to WARN and the output directed to STDERR until the problem is fixed." + "\n" +
        e.message + "\n" + e.backtrace.join("\n")
      )
      logger
    end
    
  end
end
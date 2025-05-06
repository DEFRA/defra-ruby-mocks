# frozen_string_literal: true

require "aws-sdk-s3"
require "defra_ruby/aws"

module DefraRubyMocks
  class AwsBucketService

    attr_accessor :bucket_name, :file_name

    def self.write(bucket_name, file_name, content)
      new.write(bucket_name, file_name, content)
    end

    def self.read(bucket_name, file_name)
      new.read(bucket_name, file_name)
    end

    def self.remove(bucket_name, file_name)
      Rails.logger.debug ":::::: mocks removing #{file_name} on S3"
      new.remove(bucket_name, file_name)
    end

    def write(bucket_name, file_name, content)
      @bucket_name = bucket_name
      @file_name = file_name
      Rails.logger.debug ":::::: mocks writing #{file_name} to S3"

      write_temp_file(content)

      load_temp_file_to_s3

      true
    end

    def read(bucket_name, file_name)
      @bucket_name = bucket_name
      @file_name = file_name
      Rails.logger.debug ":::::: mocks reading #{file_name} from S3"

      s3.get_object(bucket: bucket_name, key: file_name).body.read
    end

    def remove(bucket_name, file_name)
      @bucket_name = bucket_name
      Rails.logger.debug ":::::: mocks removing #{file_name} from S3"

      bucket.delete(file_name)
    end

    private

    def s3
      @s3 ||= Aws::S3::Client.new(
        region: ENV.fetch("AWS_REGION", nil),
        credentials: Aws::Credentials.new(
          ENV.fetch("AWS_DEFRA_RUBY_MOCKS_ACCESS_KEY_ID", nil),
          ENV.fetch("AWS_DEFRA_RUBY_MOCKS_SECRET_ACCESS_KEY", nil)
        )
      )
    end

    def temp_filepath
      "#{Dir.tmpdir}/#{file_name}"
    end

    def write_temp_file(content)
      Rails.logger.debug ":::::: mocks creating temp file for #{content}"
      File.write(temp_filepath, content)
    end

    def load_temp_file_to_s3
      Rails.logger.debug ":::::: mocks loading temp file to S3 bucket #{bucket_name}"

      result = nil

      3.times do
        result = bucket.load(File.new(temp_filepath, "r"))

        break if result.successful?
      end

      raise(result&.error) unless result&.successful?
    end

    def bucket
      @bucket ||= DefraRuby::Aws.get_bucket(bucket_name)
    end
  end
end

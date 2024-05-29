# frozen_string_literal: true

require "rails_helper"
require "defra_ruby/aws"

module DefraRubyMocks
  RSpec.describe AwsBucketService do
    let(:s3_bucket_name) { "s3_bucket" }
    let(:s3_bucket) { instance_double(DefraRuby::Aws::Bucket) }

    before { allow(DefraRuby::Aws).to receive(:get_bucket).with(s3_bucket_name).and_return(s3_bucket) }

    describe ".write" do
      let(:s3_load_result) { instance_double(DefraRuby::Aws::Response) }

      subject(:write_bucket) { described_class.write(s3_bucket_name, "a_file_name", "some content") }

      before { allow(s3_bucket).to receive(:load).and_return(s3_load_result) }

      context "when bucket#load fails" do
        before do
          allow(s3_load_result).to receive_messages(successful?: false, error: "an error occurred")
        end

        it { expect { write_bucket }.to raise_error(StandardError) }
      end

      context "when bucket#load succeeds" do
        before { allow(s3_load_result).to receive(:successful?).and_return(true) }

        it { expect(write_bucket).to be(true) }
      end
    end

    describe ".read" do
      let(:expected_content) { Faker::Lorem.sentence }
      let(:aws_response) { instance_double(Aws::S3::Types::GetObjectOutput, body: StringIO.new(expected_content)) }
      let(:s3_client) { instance_double(Aws::S3::Client) }

      subject(:read_bucket) { described_class.read(s3_bucket_name, "a_file_name") }

      before { allow(Aws::S3::Client).to receive(:new).and_return(s3_client) }

      context "when bucket#read fails" do
        before { allow(s3_client).to receive(:get_object).and_raise(Aws::S3::Errors::NoSuchBucket) }

        it { expect { read_bucket }.to raise_error(StandardError) }
      end

      context "when bucket#read succeeds" do
        before { allow(s3_client).to receive(:get_object).and_return(aws_response) }

        it { expect(read_bucket).to eq(expected_content) }
      end
    end
  end
end

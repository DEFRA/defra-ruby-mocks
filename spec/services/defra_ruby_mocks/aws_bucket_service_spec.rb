# frozen_string_literal: true

require "rails_helper"
require "defra_ruby/aws"

module DefraRubyMocks
  RSpec.describe AwsBucketService do
    let(:s3_bucket_name) { "s3_bucket" }
    let(:s3_bucket) { instance_double(DefraRuby::Aws::Bucket) }
    let(:s3_client) { instance_double(Aws::S3::Client) }

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(DefraRuby::Aws).to receive(:get_bucket).with(s3_bucket_name).and_return(s3_bucket)
    end

    describe ".write" do
      subject(:write_bucket) { described_class.write(s3_bucket_name, "a_file_name", "some content") }

      let(:s3_load_result) { instance_double(DefraRuby::Aws::Response) }

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

      subject(:read_bucket) { described_class.read(s3_bucket_name, "a_file_name") }

      context "when bucket#read fails" do
        before { allow(s3_client).to receive(:get_object).and_raise(Aws::S3::Errors::NoSuchBucket) }

        it { expect { read_bucket }.to raise_error(StandardError) }
      end

      context "when bucket#read succeeds" do
        before { allow(s3_client).to receive(:get_object).and_return(aws_response) }

        it { expect(read_bucket).to eq(expected_content) }
      end
    end

    describe ".remove" do
      let(:target_file) { "file_to_remove" }
      let(:s3_load_result) { instance_double(DefraRuby::Aws::Response) }

      before do
        allow(s3_bucket).to receive(:load).and_return(s3_load_result)
        allow(s3_load_result).to receive(:successful?).and_return(true)
        allow(s3_bucket).to receive(:delete)

        described_class.write(s3_bucket_name, target_file, "foo")
      end

      it "deletes the file" do
        described_class.remove(s3_bucket_name, target_file)

        expect(s3_bucket).to have_received(:delete)
      end
    end
  end
end

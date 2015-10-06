require 'spec_helper'

module Segment
  class Analytics
    describe Worker do
      describe "#init" do
        it 'accepts string keys' do
          queue = Queue.new
          worker = Segment::Analytics::Worker.new(queue, 'secret', 'batch_size' => 100)
          worker.instance_variable_get(:@batch_size).should == 100
        end
      end

      describe '#flush' do
        before :all do
          Segment::Analytics::Defaults::Request::BACKOFF = 0.1
        end

        after :all do
          Segment::Analytics::Defaults::Request::BACKOFF = 30.0
        end

        it 'should not error if the endpoint is unreachable' do
          Net::HTTP.any_instance.stub(:post).and_raise(Exception)

          queue = Queue.new
          queue << {}
          worker = Segment::Analytics::Worker.new(queue, 'secret')
          worker.run

          queue.should be_empty

          Net::HTTP.any_instance.unstub(:post)
        end

        it 'should execute the error handler if the request is invalid' do
          Segment::Analytics::Request.any_instance.stub(:post).and_return(Segment::Analytics::Response.new(400, "Some error"))

          on_error = Proc.new do |status, error|
            puts "#{status}, #{error}"
          end

          on_error.should_receive(:call).once

          queue = Queue.new
          queue << {}
          worker = Segment::Analytics::Worker.new queue, 'secret', :on_error => on_error
          worker.run

          Segment::Analytics::Request::any_instance.unstub(:post)

          queue.should be_empty
        end

        it 'should not call on_error if the request is good' do

          on_error = Proc.new do |status, error|
            puts "#{status}, #{error}"
          end

          on_error.should_receive(:call).at_most(0).times

          queue = Queue.new
          queue << Requested::TRACK
          worker = Segment::Analytics::Worker.new queue, 'testsecret', :on_error => on_error
          worker.run

          queue.should be_empty
        end
      end

      describe '#is_requesting?' do
        it 'should not return true if there isn\'t a current batch' do

          queue = Queue.new
          worker = Segment::Analytics::Worker.new(queue, 'testsecret')

          worker.is_requesting?.should == false
        end

        it 'should return true if there is a current batch' do
          queue = Queue.new
          queue << Requested::TRACK
          worker = Segment::Analytics::Worker.new(queue, 'testsecret')

          Thread.new do
            worker.run
            worker.is_requesting?.should == false
          end

          eventually { worker.is_requesting?.should be_true }
        end
      end
    end
  end
end
